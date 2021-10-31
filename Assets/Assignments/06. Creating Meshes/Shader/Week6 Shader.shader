Shader "hw/week 6"
{
    Properties
    {
        _selfRotSpeed("Self rotation speed", Float) = 0.0
        _ringRotSpeed("Ring rotation speed",Float)= 0.0
        _cloudSpeed("Cloud Speed",Float) = 0.0
        _cloudColor("Cloud Color", Color) = (1,0,0,1)
        _seaColor("Sea Color",Color) = (0,0,1,1)
        //_ringLayers("Ring Layers",Float) = 5
        _ringColor("Ring Color", Color) = (1,0.61,0,1)
    }

        SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            #define TAU 6.28318530718

            float _selfRotSpeed;
            float _cloudSpeed;
            float3 _cloudColor;
            float3 _seaColor;
            float _ringRotSpeed;
            float _ringLayers;
            float3 _ringColor;

            struct MeshData
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv:TEXCOORD0;
                float3 normal:NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float2 uv: TEXCOORD0;
            };

            float4x4 rotation_matrix(float3 axis, float angle) {
                axis = normalize(axis);
                float s = sin(angle);
                float c = cos(angle);
                float oc = 1.0 - c;

                return float4x4(
                    oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                    oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                    oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                    0.0,                                0.0,                                0.0,                                1.0);
            }


            float rand(float2 uv) {
                return frac(sin(dot(uv.xy, float2(12598.9898, 78335.233))) * 43758.5453123);
            }



            float value_noise(float2 uv) {
                float2 ipos = floor(uv);
                float2 fpos = frac(uv);

                float o = rand(ipos);
                float x = rand(ipos + float2(1, 0));
                float y = rand(ipos + float2(0, 1));
                float xy = rand(ipos + float2(1, 1));

                float2 smooth = smoothstep(0, 1, fpos);
                return lerp(lerp(o, x, smooth.x),
                    lerp(y, xy, smooth.x), smooth.y);
            }
            
            float fractal_noise(float2 uv) {
                float n = 0;

                n = (1 / 2.0) * value_noise(sin(uv) * 1);
                n += (1 / 3.0) * value_noise(uv * 2);
                n += (1 / 5) * value_noise(uv * 4);
                n += (1 / 16) * value_noise(uv * 8);

                return n;
            }


            Interpolators vert(MeshData v)
            {
                Interpolators o;


                if (v.uv.x >= 0.5 && v.uv.y <= 0.5) {
                    

                    if (v.color.g >= 0.4) { //land
                        v.vertex.xyz += v.normal * (v.color.g-0.3) * 0.003;
                    }

                    float4x4 rotation = rotation_matrix(float3(0, 0, 1), _Time.x * _selfRotSpeed * TAU);
                    v.vertex = mul(rotation, v.vertex);
                }
                else{ //ring rotation
                    //float4x4 rotationX = rotation_matrix(float3(1, 0, 0), _Time.x * _ringRotSpeed * TAU);
                    //float4x4 rotationY = rotation_matrix(float3(0, 1, 0), _Time.x * _ringRotSpeed * TAU);
                    float4x4 rotationZ = rotation_matrix(float3(0, 0, 1), _Time.x * _ringRotSpeed * TAU);

                    //float4x4 rotation = mul(mul(rotationX, rotationY), rotationZ);

                    
                    v.vertex.z += (rand(v.vertex.xy*100 / (1.1 - v.color.r))*2-1) //-1 ~ 1
                        * 0.001 * (1.05-v.color.r); //bigger r has smaller displacement
                    

                    v.vertex = mul(rotationZ, v.vertex);
                   
                }


                o.color = v.color;
                o.uv = v.uv;

                o.vertex = UnityObjectToClipPos(v.vertex);

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                //sphere UV:
                //x: 5-10; Y:0-5
                float2 uv = i.uv;
                float2 fixedUV = uv;
                fixedUV *= 100;
                uv *= 10;

                float3 color;

                if (uv.x >= 5 && uv.y <= 5) {
                    
                    //rotate the atmosphere. Upper and lower atmosphere move more slowly
                    uv.x += _Time.y * _cloudSpeed * round(i.color.b *100)*0.01;
                    uv.x = 5 + (uv.x - 5) % 5;
                    
                    float2 temp = float2(abs(uv.x-7.5),uv.y);

                    //0-1 + 0.2-0.6
                    //0.2-1.6
                    float fn = (value_noise(temp * 6) + 
                        0.5* (sin(0.1 * _Time.z)+2)) /2.2;
                   
                   
                    //judge if the current fragment is sea or land
                    //i.color.b also determines the depth of fragmentColor
                    float3 fragmentColor;
                    if (i.color.b > 0 && i.color.g == 0) { //sea
                        fragmentColor = _seaColor * i.color.b;
                    }
                    else if(i.color.b>0 && i.color.g >0) { //land
                        //lower landscape is darker
                        fragmentColor = pow(i.color, i.color.g * 2.5) ;
                    }


                    
                    if (fn >= 0.3 * (sin(_Time.x)) + 0.8){
                        float3 cloudFixedColor = _cloudColor;

                        cloudFixedColor *= value_noise(uv*10);

                        color = 1 - (1 - cloudFixedColor) * (1 - fragmentColor);
                            //_cloudColor <= 0.5 ? fragmentColor * (_cloudColor + 0.5) : 1 - (1 - fragmentColor) * (1 - (_cloudColor - 0.5));
                           
                        // (fn * _cloudColor + fragmentColor) / 2;
                    }
                    else {
                        color = fragmentColor;
                    }
                    
                }
                else {
                    //uv.x: 0-5
                    _ringLayers = 5 * cos(_Time.y*0.2) + 15;

                    float2 temp = float2(abs(uv.x - 2.5), uv.y);

                    float noise = value_noise(temp * 3)+0.5;

                    color = (value_noise(float2(i.color.r * _ringLayers, noise)) + 0.4) * _ringColor;
                    
                    color = pow(color, 1.4);
                }
                
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

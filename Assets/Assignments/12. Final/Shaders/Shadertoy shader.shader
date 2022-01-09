//Modified from https://www.shadertoy.com/view/llSGRG

Shader "hw/final/black hole"
{
	Properties {
		_tex0 ("tex", 2D) = "white" {}
        _bhr("BHR", Float) = 0.1
        _bhMass("Black Hole Mass", Float) = 5
        _premulG("Premul G", Range(0.001,1)) = 0.001
        _dt("dt", Float) = 0.02
        _color("Color", Color) = (1, 0.9, 0.85,1)
        _center("Center", Vector) = (0.5,0.5,0,0)
        _radius("Blackhole radius", Float) = 0.5
        _distortScale("Distort Scale",Range(0,100)) = 1
	}

    SubShader
    {
        Tags {"Queue"="Transparent" }


        GrabPass{
	        "_BackgroundTex" 
        }

        ZWrite Off

		
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
           
            #define PI 3.14159265358

            sampler2D _tex0;
            sampler2D _BackgroundTex;
            float _bhr;
            float _bhMass;
            float _premulG;
            float _dt;
            float3 _color;
            float2 _center;
            float _radius;
            float _distortScale;
            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            
            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float2 uv: TEXCOORD1;
                float4 screenUV : TEXCOORD2;
                float4 centerScreenUV: TEXCOORD3;
                float3 objPos : TEXCOORD4;
            };


            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.screenUV = ComputeGrabScreenPos(o.vertex);
                o.centerScreenUV = ComputeGrabScreenPos(float4(0.5,0.5,0.5,0));
                o.uv = v.uv;
                o.objPos = v.vertex;
                return o;
            }

            float sdSphere(float3 p, float s)
            {
                return length(p) - s;
            }

            float sdCappedCylinder(float3 p, float2 h)
            {
                float2 d = abs(float2(length(p.xz), p.y)) - h;
                return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
            }


            float sdTorus(float3 p, float2 t) 
            {
                float2 q = float2(length(p.xz) - t.x, p.y);
                return length(q)- t.y;
            }

            float rand (float3 uv) {
                return frac(sin(dot(uv.xyz, float3(129.898, 78.233, 98.314))) * 4138.5453123);
            }

            float value_noise (float3 uv) {
                float3 ipos = floor(uv);
                float3 fpos = frac(uv); 
                
                float o  = rand(ipos);
                float x  = rand(ipos + float3(1, 0,0));
                float y  = rand(ipos + float3(0, 1, 0));
                float z = rand(ipos + float3(0,0,1));
                float xy = rand(ipos + float3(1, 1,0));
                float xz = rand(ipos + float3(1,0,1));
                float yz = rand(ipos + float3(0,1,1));
                float xyz = rand(ipos + float3(1,1,1));

                float3 smooth = smoothstep(0, 1, fpos);

                float3 lerp1 = lerp(lerp(o,  x, smooth.x), 
                             lerp(y, xy, smooth.x), smooth.y);

                float3 lerp2 = lerp(lerp(z,xz,smooth.x),
                lerp(yz,xyz,smooth.x),smooth.y);

                return lerp(lerp1, lerp2, smooth.z);

             
            }
            float4 frag (Interpolators i) : SV_Target
            {
                float2 pp = i.uv;
                pp = pp*2 - 1;
                float aspect = _ScreenParams.x / _ScreenParams.y;
                //pp.x *= aspect;
                
               
	            float3 lookAt = float3(0.0, -0.1, 0.0);

                float eyer = 2.0;
                float eyea = ( _ScreenParams.x) * PI * 2.0;
                float eyea2 = ((_ScreenParams.y) - 0.24) * PI * 2.0;

                float3 ro = float3(
                    eyer * cos(eyea) * sin(eyea2),
                   eyer * cos(eyea2),
                    eyer * sin(eyea) * sin(eyea2)); //camera position


                float3 front = normalize(lookAt - ro);
                float3 left = normalize(cross(normalize(float3(0.0, 1, -0.1)), front));
                float3 up = normalize(cross(front, left));
                float3 rd = normalize(front * 1.5 + left * pp.x + up * pp.y); // rect vector


                float3 bh = float3(0.0, 0.0, 0.0);
                float bhr = _bhr;
                float bhmass = _bhMass;
                bhmass *= _premulG; // premul G
                
                float3 p = ro;
                float3 pv = rd;
                float dt = _dt;

                float3 col = 0;

                float noncaptured = 1.0;

                float3 c1 = float3(0.5, 0.46, 0.4);
                float3 c2 = float3(1.0, 0.8, 0.6);
            
            
                for(float t=0.0;t<1.0;t+=0.005)
                {
                    p += pv * dt * noncaptured;

                    // gravity
                    float3 bhv = bh - p;
                    float r = dot(bhv, bhv);
                    pv += normalize(bhv) * ((bhmass) / r);

                    noncaptured = smoothstep(0.0, 0.666, sdSphere(p - bh, bhr));

                    // Texture for the accretion disc
                    float dr = length(bhv.xz);
                    float da = atan2( bhv.z,bhv.x);
                    float2 ra = float2(dr, da * (0.01 + (dr - bhr) * 0.002) + 2.0 * PI + _Time.y * 0.005);
                    ra *= float2(10.0, 20.0);

                    float3 dcol = lerp(c2, c1, pow(length(bhv) - bhr, 2.0)) *
                                max(0.0, tex2Dlod(_tex0, float4(ra * float2(0.1, 0.5),0,0)).r + 0.05) *
                                (4.0 / ((0.001 + (length(bhv) - bhr) * 50.0)));


                    col += max(0,
                        dcol * smoothstep(0.0, 1.0, -sdTorus((p * float3(1.0, 25.0, 1.0)) - bh, float2(0.8, 0.99))) * noncaptured);

                    //col += dcol * (1.0/dr) * noncaptured * 0.001;

                    // Glow
                    col += _color * (1.0 / (dot(bhv, bhv))) * 0.0033 * noncaptured;
                }
             
                float2 screenUV = i.screenUV.xy / i.screenUV.w;
                float2 centerScreenUV = i.centerScreenUV.xy / i.centerScreenUV.w;

                float2 toCenter = screenUV - centerScreenUV;
                float screenDistToCenter = abs(length(toCenter));
                float angle = screenDistToCenter * _distortScale; 
                
                float2x2 rotMatrix = {
                                         cos(angle), sin(angle),
                                        -sin(angle) ,cos(angle)
                                     };

                screenUV += mul(rotMatrix, toCenter) + _center;
                
                float distToCenter = abs(length(pp - _center));
                float3 background = tex2D(_BackgroundTex, screenUV);
                float3 fragColor = col;

                //float prect = abs(pp.x / aspect);
                float opacity = 1 - min(length(pp),1);
                
                if(distToCenter <= _radius){
                    opacity = 1;
                    if(fragColor.r < 1){
                        fragColor = lerp(0,fragColor, distToCenter / _radius);
                    }
                    
                }else{
                    opacity = lerp(1,0,(distToCenter - _radius) / (1 - _radius));
                }

                
                fragColor = lerp(fragColor, background, 1 - opacity);

               
                return float4(fragColor, opacity);
            }
            ENDCG
        }
    }
	FallBack "Diffuse"
}


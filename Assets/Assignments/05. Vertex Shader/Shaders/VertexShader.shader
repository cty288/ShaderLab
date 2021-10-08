Shader "hw/week 5"
{
    Properties
    {
        _displacement("Wave displacement", Range(0, 3)) = 0.05
        _speed("Wave speed",Range(0,3)) = 1
        _frequency("Wave frequency",Range(0,5)) = 2

        _scale("Splash scale", Range(0, 500)) = 15.5
        _splashTimer("_splashTimer", Float) = 0.0
        _splashFrequency("_splashFrequency",Float) = 0.0
       
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
            #define PAI 3.1415926535897984626

            float _scale;
            float _displacement;
            
            float _seed;
            float _speed;
            float _frequency;
            float _splashDisplacement;
            float _splashTimer;
            float _splashFrequency;

            float rand(float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float4x4 rotation_matrix(float3 axis, float angle) {
                axis = normalize(axis);
                float s = sin(angle);
                float c = cos(angle);
                float oc = 1.0 - c;

                return float4x4(
                    oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s, 0.0,
                    oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s, 0.0,
                    oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c, 0.0,
                    0.0, 0.0, 0.0, 1.0);
            }


            float value_noise (float2 uv) {
                float2 ipos = floor(uv);
                float2 fpos = frac(uv); 
                
                float o  = rand(ipos);
                float x  = rand(ipos + float2(1, 0));
                float y  = rand(ipos + float2(0, 1));
                float xy = rand(ipos + float2(1, 1));

                float2 smooth = smoothstep(0, 1, fpos);
                return lerp( lerp(o,  x, smooth.x), 
                             lerp(y, xy, smooth.x), smooth.y);
            }

            float fractal_noise (float2 uv) {
                float n = 0;

                n  = (1 / 2.0)  * value_noise( sin(uv) * 1);
                n += (1/3.0)  * value_noise(uv * 2); 
                n += (1/5) * value_noise( uv * 4);
                n += (1 / 16) * value_noise( uv*8);
                
                return n;
            }


            float3 rand_vec(float3 pos, float seed) {
                pos.x += _seed / 4;
                pos.y += _seed / rand(_seed);
                pos.z += rand(_seed) * pos.x;


                return normalize(float3(rand(pos.xz) * 2 - 1 , rand(pos.yx) * 2 - 1, rand(pos.zy) * 2 - 1));
            }

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float disp : TEXCOORD1;
                float4 vertex2 : TEXCOORD2;
            };

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                //-50 ~ 50. The original range of the vertex was too small
                float3 vertexFixed = v.vertex.xyz * 10000;
                float3 vertexFixed2 = vertexFixed;
                

                if (vertexFixed2.y >= 45) {
                    //wave effect
                    float wave = sin(_Time.y * _speed + vertexFixed.x * _frequency);
                    vertexFixed.y += wave * _displacement;


                    int splashPosition = rand(float2(cos(_splashFrequency), tan(_splashFrequency)))*40;
                 
                    int splashSize = smoothstep(1,4, _splashFrequency)*15;

                    float centerDistance = distance(vertexFixed2.xz, float2(splashPosition, splashPosition));
                    
                    //wave radius
                    if (centerDistance <= splashSize) {
                        //wave height
                        float height =smoothstep(-1,1, fractal_noise((v.uv*10) * _scale) * 2 - 1);
                        
                        ////pi/frequency seconds each splash
                        //this function makes the splash move slower then faster, with a standard period of 1 pi
                        _splashDisplacement = 50* abs(pow(sin(1.7725*sqrt(_splashTimer*_splashFrequency)),2)); 
                        vertexFixed.y += height * _splashDisplacement;

                        //rotation
                        float progress = _splashTimer / (PAI / _splashFrequency);

                        float rotationRandom = value_noise(v.uv*50);
                        float rotationDirectionRandom = rand(sin(_splashFrequency) * cos(_splashFrequency));

                        float rotationDirection = rotationDirectionRandom < 0.5 ? 1 : -1;

                        float4x4 rotationMatrix;
                        float rot = progress *0.03;
                        if (rotationRandom<= 0.33) {
                            rotationMatrix = rotation_matrix(float3(1, 0, 0), rotationDirection*  rot * TAU);
                        }
                        else if(rotationRandom<=0.66){
                            rotationMatrix = rotation_matrix(float3(0, 0, 1), rotationDirection* rot * TAU);
                        }
                        else {
                            rotationMatrix = rotation_matrix(float3(0, 1, 0), rotationDirection* rot * TAU);
                        }

                        if (rot != 0) {
                            vertexFixed = mul(vertexFixed, rotationMatrix);
                        }
                       
                        
                        

                        //random jitter movement
                        float3 rVec = float3(rand(vertexFixed.xy), rand(vertexFixed.xz), rand(vertexFixed.yz));
                        vertexFixed += rVec * smoothstep(50, 100, vertexFixed.y);   
                    }
                }
               
                //transform back to the range of the original vertices.
                v.vertex.xyz = vertexFixed / 10000;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.vertex2 = v.vertex;
                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float2 uv = i.uv/1;
                float3 vertex = i.vertex2.xyz;
                vertex += 0.005;
                vertex *= 100;

                float3 color;

                color = vertex.y * float3(0, 0.3, 0.8);
                return float4(color, 1.0);
            }
            ENDCG
		}
	}
}
Shader "hw/final/star"
{
    Properties {

	    _particleNum ("Particle Number", Int) = 5
        _particleFreq ("Particle Freq", Range(10,100)) = 50
        _particleAmpRate("Particle Rate", Range(0,1)) = 0.8

        _particlePower("Particle Power", Range(0,5)) = 1
        _sunspotFreq("Sunspot Frequency", Range(3,10)) = 5
        _sunspotSize("Sunspot Size", Range(0,0.5)) = 0.3

        _sunColor("Sun Color", Color) = (1,1,1,1)
    }
    SubShader
    {

        Tags { "LightMode"="ForwardBase" "RenderType"="Opaque"}

       
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            
            #include "Lighting.cginc"

            #define MAX_SPECULAR_POWER 256
            #define SPECULAR_MIP_STEP 0
            #define DIFFUSE_MIP_LEVEL 5
            
            int _particleNum;
            float _particleFreq;
            float _particleAmpRate;
            float _particlePower;

            float _sunspotFreq;
            float _sunspotSize;

            float3 _sunColor;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 bitangent : TEXCOORD3;
                float3 posWorld : TEXCOORD4;
                float4 screenUV : TEXCOORD5;
                float3 objPos : TEXCOORD6;
            };


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

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.uv = v.uv;
                
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldNormal(v.tangent);
                o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;
                
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.screenUV = ComputeGrabScreenPos(o.vertex);

                o.posWorld = mul(unity_ObjectToWorld, v.vertex);

                o.objPos = v.vertex;
                
                return o;
            }


            float particleNoise(float3 pos, int num, float freq, float ampRate){
               
               float result = 0;
               float amp = 1; 
               float maxAmp = 0;

               for(int i=0; i<num; i++){
                   result += value_noise((pos + (_Time.y/50)) * freq) * amp;
                   maxAmp += amp;
                   freq *=2 ;
                   amp *= ampRate;
               }

               return result / maxAmp;
            
            }


            float sunspotNoise(float3 pos, float freq){
                float n1 = (value_noise(pos + (_Time.y/50) * _sunspotFreq)*2 - 1) - (0.5 - _sunspotSize);
                float n2 = (value_noise((pos + (_Time.y/50) + 1000) * _sunspotFreq)* 2 - 1) - (0.5 - _sunspotSize);
                return max(n1, 0) * max(n2, 0) * 2;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
               
                float3 color = 0;
              
                float particle = particleNoise(i.objPos * 100 , _particleNum, _particleFreq, _particleAmpRate);
                particle = pow(particle, _particlePower);
                float sunspot = sunspotNoise(i.objPos * 100, 5);
                
                particle -= sunspot;
                color = particle * _sunColor;

                return float4(color, 1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

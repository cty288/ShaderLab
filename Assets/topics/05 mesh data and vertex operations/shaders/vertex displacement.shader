Shader "examples/week 5/vertex displacement"
{
    Properties
    {
        _scale ("noise scale", Range(2, 50)) = 15.5
        _displacement ("displacement", Range(0, 100)) = 0.33
        _seed ("seed", Range(0,1000)) = 300
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float _scale;
            float _displacement;
            float _seed;

            float rand (float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
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
                float amp = 1;
                float a = 1.5;

                for(int j=0; j<6; j++){
                  n += amp * value_noise(uv * a);
                  amp/=1.5;
                  a*=1.5;
                 
                }
                
                return n;
            }

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                 o.uv = v.uv;

                float height = fractal_noise((o.uv + _seed)* _scale) * _displacement;
                v.vertex.xyz += v.normal * height;
               
                o.vertex = UnityObjectToClipPos(v.vertex);
               
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                return float4((value_noise((i.uv) * _scale)).rrr, 1.0);
            }
            ENDCG
        }
    }
}

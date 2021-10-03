Shader "examples/week 4/using noise 2"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            #define TAU 6.28318530718

            float rectangle (float2 uv, float2 scale) {
                float2 s = scale * 0.5;
                float2 shaper = float2(step(-s.x, uv.x), step(-s.y, uv.y));
                shaper *= float2(1-step(s.x, uv.x), 1-step(s.y, uv.y));
                return shaper.x * shaper.y;
            }

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

            struct MeshData
            {
                float4 vertex : POSITION;
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
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float2 uv = i.uv;

                float time = _Time.y;

                float x = value_noise(float2(time, 1)) - 0.5;
                float y = value_noise(float2(-time, time)) - 0.5;
                float rot = value_noise(float2(time, time)) - 0.5;

                uv = i.uv * 2 - 1;
                
                // create translation vector using noise values
                float2 translate = float2(x, y);

                // calculate rotation using noise value
                float angle = rot * TAU;
                float2x2 rotate2D = float2x2 (
                    cos(angle), -sin(angle),
                    sin(angle),  cos(angle)
                );

                // apply transformations
                uv += translate;
                uv = mul(uv, rotate2D);

                float3 color = 0;
                // color += float3(uv.x, 0, uv.y);
                
                // create rectangle using the transformed uv coordinates
                float rect = rectangle(uv, float2(0.2, 0.35));
                color += rect.rrr;
                
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

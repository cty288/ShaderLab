Shader "examples/week 4/using white noise"
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

            float random (float value) {
                return frac(sin(value) * 90321);
            }

            float white_noise (float2 value) {
                return frac(sin(dot(value, float2(128.239, -78.381))) * 90321);
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;

                int gridSize = 20;
                //uv in grid
                float2 fpos = frac(uv * gridSize);
                //grid
                float2 ipos = floor(uv * gridSize);
            
                //-1~1
                fpos = fpos * 2.0 - 1.0;
                float polar = atan2(fpos.y, fpos.x);
                
                // atan2 will give us a range from -PI to PI (radians). dividing by 2PI will give us a range -0.5 to 0.5. add 0.5 for range of 0 - 1
                polar = (polar / TAU) + 0.5;

                float wn = white_noise(ipos);
                
                // using lerp here to use our random value to give us either -1 or 1
                // you could also do: spinDir = step(0.5, rand) * 2 - 1;
                float spinDir = lerp(-1, 1, step(0.5, wn));

                // adding to our polar value will change the rotation since it represents an angle
                // so we add rand as an offset
                // then we add time with some modifications to get it to animate
                polar = frac(polar + wn + (_Time.x * spinDir * (0.1 + wn * 30)));
                
                // using pow() here allows us to shape the brightness of our angle gradient
                polar = pow(polar, 0.1 + wn * 2);

                // here i create a circle in each cell
                float circle = smoothstep(0.00, 0.03, 1 - length(fpos));

                // our circle acting as a mask, when multiplied with our polar value will make each cell appear circular
                polar *= circle;

                // return float4(wn.rrr, 1.0);
                return float4(polar.rrr, 1.0);
            }
            ENDCG
        }
    }
}

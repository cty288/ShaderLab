Shader "examples/week 2/pattern"
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

            float circle(float cutoff, float2 uv) {
                return step(cutoff, 1 - length(uv));
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float output = 0;
                float gridSize = 40;

                float2 uv=i.uv;
                uv = uv * gridSize;

              
                float2 gridUV = frac(uv) * 2 -1;

                float index = floor(uv.x) + floor(uv.y);

                gridUV.x += sin(_Time.y+index/3) * 0.5;
                gridUV.y += sin(_Time.y+index/3) * 0.5;

                output = circle(0.5, gridUV);

                output = step(sin(_Time.y) * 0.5 + 0.5, 1 - length(gridUV));

                

               // return float4(gridUV.x, 0, gridUV.y, 1);
                return float4(output.rrr, 1.0);
            }
            ENDCG
        }
    }
}

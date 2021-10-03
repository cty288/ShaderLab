Shader "examples/week 2/polar"
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

            float4 frag(Interpolators i) : SV_Target
            {
                float2 uv = i.uv * 2 - 1;
                


                float output = 0;
               
                float2 polarUV = float2((atan2(uv.y, uv.x) / (3.14159265358 * 2)) + 0.5, length(uv));
                //polarUV.x = frac(polarUV.x + _Time.y);

                output = step(0.2,polarUV.y * sin(_Time.y));

                //return float4(polarUV.x, 0, polarUV.y, 1);
                // return float4(uv.x, 0, uv.y, 1);
                return float4(output.rrr, 1.0);
            }
            ENDCG
        }
    }
}

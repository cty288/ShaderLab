Shader "examples/week 1/gradient"
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

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                float3 color = uv.yyy;


                float3 colorX = float3(0.2, 0.7, 0.9);
                float3 colorY = float3(0.5, 0.9, 0.1);

                float3 gradientX = lerp(colorX, colorY, uv.x);
                float3 gradientY = lerp(colorX, colorY, uv.y);


                color = (gradientX + gradientY) /2 ;
                color = color;

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

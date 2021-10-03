Shader "examples/week 5/vertex color"
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
                float4 color : COLOR;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                return float4(i.color.rgb, 1.0);
            }
            ENDCG
        }
    }
}

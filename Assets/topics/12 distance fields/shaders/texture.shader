Shader "examples/week 12/texture"
{
    Properties
    {
        [NoScaleOffset]_tex ("texture", 2D) = "white"{}
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}

        Blend One One

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _tex;

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
                return tex2D(_tex, i.uv);
            }
            ENDCG
        }
    }
}

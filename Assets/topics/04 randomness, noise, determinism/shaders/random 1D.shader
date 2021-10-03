Shader "examples/week 4/random 1D"
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

                float rand = 0;
                
                rand = frac(sin(uv.x) * 18489);

                return float4(rand.rrr, 1.0);
            }
            ENDCG
        }
    }
}

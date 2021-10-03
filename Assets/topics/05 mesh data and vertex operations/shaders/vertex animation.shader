Shader "examples/week 5/vertex animation"
{
    Properties
    {
        _scale ("noise scale", Range(2, 100)) = 15.5
        _displacement ("displacement", Range(0, 0.1)) = 0.05
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
                float disp : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;


                o.disp = sin(((v.uv.x + v.uv.y) * _scale) + _Time.z) * 0.5 + 0.5;
                

                v.vertex.xyz += v.normal * o.disp * _displacement;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                return float4(i.uv.x, i.disp * 0.5, i.uv.y, 1.0);
            }
            ENDCG
        }
    }
}

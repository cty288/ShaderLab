Shader "examples/week 2/polar blend"
{
    Properties
    {
        _spaceBlend ("space blend", Range(0,1)) = 0
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

            #define TAU 6.28318530718

            uniform float _spaceBlend;

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
                float2 uv = i.uv * 2.0 - 1.0;
                float2 outUV = uv;

                float2 polarUV = float2((atan2(uv.y, uv.x) / (3.14159265358 * 2)) + 0.5, length(uv));
                
                outUV = lerp(uv, polarUV, _spaceBlend);
                outUV = frac(outUV * 8);


                return float4(outUV.x, 0.0, outUV.y, 1.0);
            }
            ENDCG
        }
    }
}

Shader "examples/week 1/color blend intro"
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

            #define PI 3.141592653

            float circle (float2 uv, float2 offset, float size) {
                return smoothstep(0.0, 0.005, 1 - length(uv - offset) / size);
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

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv * 2 - 1;
                
                float centerOffset = smoothstep(0, 1, sin(_Time.y) * 0.5 + 0.5);
                float cutoff = 0.5;
                

                float r = circle(uv, float2( 0.0,  0.10) * centerOffset, cutoff);
                float g = circle(uv, float2( 0.1, -0.07) * centerOffset, cutoff);
                float b = circle(uv, float2(-0.1, -0.07) * centerOffset, cutoff);

                return float4(r, g, b, 1.0);
            }
            ENDCG
        }
    }
}

Shader "examples/week 7/half lambert"
{
    Properties 
    {
        _surfaceColor ("surface color", Color) = (0.4, 0.1, 0.9)
    }
    SubShader
    {
        // this tag is required to use _LightColor0
        Tags { "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #define TAU 6.28318530718
            // might be UnityLightingCommon.cginc for later versions of unity
            #include "Lighting.cginc"

            float3 _surfaceColor;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.normal = v.normal;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 normal = normalize(i.normal);
                float3 color = 0;

                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0; // includes intensity

                float falloff = max(0, dot(normal, lightDirection));

                falloff = pow(falloff * 0.5 + 0.5, 2);
                color = falloff * _surfaceColor * lightColor;

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

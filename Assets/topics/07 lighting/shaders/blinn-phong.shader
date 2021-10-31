Shader "examples/week 7/blinn-phong"
{
    Properties 
    {
        _surfaceColor ("surface color", Color) = (0.4, 0.1, 0.9)
        _gloss ("gloss", Range(0,1)) = 1
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

            // might be UnityLightingCommon.cginc for later versions of unity
            #include "Lighting.cginc"

            #define MAX_SPECULAR_POWER 256

            float3 _surfaceColor;
            float _gloss;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.normal = v.normal;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;

                float3 normal = normalize(i.normal);
                
                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0; // includes intensity

                float diffuseFalloff = max(0, dot(normal, lightDirection));
                float3 diffuse = diffuseFalloff * _surfaceColor * lightColor;

                float3 cameraPos = _WorldSpaceCameraPos.xyz;
                float3 viewDirection = normalize(cameraPos - i.worldPos);

                float3 halfDirection = normalize(viewDirection + lightDirection);
                float specularFalloff = max(0, dot(halfDirection, normal));
                specularFalloff = pow(specularFalloff, MAX_SPECULAR_POWER * _gloss + 0.0001) * _gloss;

                float3 specular = specularFalloff * lightColor;

                color = diffuse + specular;

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

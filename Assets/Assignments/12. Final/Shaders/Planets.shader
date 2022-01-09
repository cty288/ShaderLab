Shader "hw/final/planets"
{

    Properties 
    {
        _surfaceColor("Surface Color", Color) = (1,1,1,1)
        _sunPosition("Sun Position", vector) = (1,1,1,1)
        // how smooth the surface is - sharpness of specular reflection
        _gloss ("gloss", Range(0,1)) = 1

        // brightness of specular reflection - proportion of color contributed by diffuse and specular
        // reflectivity at 1, color is all specular
        _reflectivity ("reflectivity", Range(0,1)) = 0.5

        _fresnelPower ("fresnel power", Range(0, 10)) = 5
        _normalIntensity ("normal intensity", Range(0, 1)) = 1
        _displacementIntensity ("displacement intensity", Range(0, 0.5)) = 0
       
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

            #define DIFFUSE_MIP_LEVEL 5
            #define SPECULAR_MIP_STEPS 4
            #define MAX_SPECULAR_POWER 256

           
            float _gloss;
            float _reflectivity;
            float _fresnelPower;
            float _normalIntensity;
            float3 _surfaceColor;
            float3 _sunPosition;
            float _displacementIntensity;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;

                // xyz is the tangent direction, w is the tangent sign
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 bitangent : TEXCOORD3;
                float3 posWorld : TEXCOORD4;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.uv = v.uv;
                
                
                v.vertex.xyz += v.normal * _displacementIntensity;

                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldNormal(v.tangent);
                o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;
                float2 uv = i.uv;

               

                float3 normal = i.normal;

                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
              
                float fresnel = 1-saturate(dot(viewDirection,normal));
                fresnel = pow(fresnel,_fresnelPower);
                

               
                float reflectivity = _reflectivity * fresnel;



                float3 surfaceColor = lerp(0, _surfaceColor, 1 - reflectivity);

                float3 lightDirection = -normalize(i.posWorld - _sunPosition);

                float3 lightColor = _LightColor0; // includes intensity

                // make view direction negative because reflect takes an incidence vector meanining, it is point toward the surface
                // viewDirection is pointing toward the camera
                float3 viewReflection = reflect(-viewDirection, normal);
                
                // gloss value corresponds to how smooth or rough a surface is
                // the smoother the surface the sharper the specular reflection
                float mip = (1 - _gloss) * SPECULAR_MIP_STEPS;
                float3 indirectSpecular = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, viewReflection, mip )* reflectivity;

                float3 halfDirection = normalize(viewDirection + lightDirection);

                float directDiffuse = max(0, dot(normal, lightDirection));
                float specularFalloff = max(0, dot(normal, halfDirection));
                
                // the specular power, which controls the sharpness of the direct specular light is dependent on the glossiness (smoothness)
                float3 directSpecular = pow(specularFalloff, _gloss * MAX_SPECULAR_POWER + 0.0001) * lightColor * _gloss;

                float3 specular = directSpecular + indirectSpecular * reflectivity;
               
                float3 indirectDiffuse = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, normal, DIFFUSE_MIP_LEVEL);
                float3 diffuse = surfaceColor * (directDiffuse * lightColor + indirectDiffuse);

                color = diffuse + specular;

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

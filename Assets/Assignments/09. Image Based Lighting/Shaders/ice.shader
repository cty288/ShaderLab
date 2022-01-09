Shader "hw/hw9/ice"
{
    Properties 
    {
	    _scale ("noise scale", Range(2, 50)) = 15.5
	    _displacement ("displacement", Range(0, 100)) = 0.33
	    _seed ("seed", Range(0,1000)) = 300

        _tint ("tint color", Color) = (1, 1, 1, 1)
        _albedo ("albedo", 2D) = "white" {}
        [NoScaleOffset] _normalMap ("normal map", 2D) = "bump" {}
       
        _gloss ("gloss", Range(0,1)) = 1
        _normalIntensity ("normal intensity", Range(0, 1)) = 1
        _displacementIntensity ("displacement intensity", Range(0, 0.5)) = 0
        _opacity ("opacity", Range(0,1)) = 1
        _refractionIntensity("Refraction Intensity", Range(0,1))=0
        _iceColor("Ice Color", Color) = (1,1,1,1)

	    _fresnelPower ("fresnel power", Range(0, 10)) = 5

	    _reflectivity("reflectivity", Range(0,1)) = 1

        _moveSpeed("move speed", Float) = 1
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" "Queue"="Transparent" "IgnoreProjector"="True"}

        GrabPass{
            "_BackgroundTex" 
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // might be UnityLightingCommon.cginc for later versions of unity
            #include "Lighting.cginc"

             #define MAX_SPECULAR_POWER 256
            #define SPECULAR_MIP_STEP 0
            #define DIFFUSE_MIP_LEVEL 5
             float _scale;
            float _displacement;
            float _seed;

            float3 _tint;
            sampler2D _albedo; float4 _albedo_ST;
            sampler2D _normalMap;
           
            sampler2D _BackgroundTex;
            float _reflectivity;
            float _fresnelPower;
            float _gloss;
            float _normalIntensity;
            float _displacementIntensity;
            float _refractionIntensity;
            float _opacity;
            float _moveSpeed;
            float3 _iceColor;
            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
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
                float4 screenUV : TEXCOORD5;
            };
            float rand (float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float value_noise (float2 uv) {
                float2 ipos = floor(uv);
                float2 fpos = frac(uv); 
                
                float o  = rand(ipos);
                float x  = rand(ipos + float2(1, 0));
                float y  = rand(ipos + float2(0, 1));
                float xy = rand(ipos + float2(1, 1));

                float2 smooth = smoothstep(0, 1, fpos);
                return lerp( lerp(o,  x, smooth.x), 
                             lerp(y, xy, smooth.x), smooth.y);
            }

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.uv = TRANSFORM_TEX(v.uv, _albedo);
                
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldNormal(v.tangent);
                o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;
                
                float height = value_noise( (v.uv+_seed) * _scale);

                v.vertex.z +=  height * _displacementIntensity;
               // v.vertex.xy += v.normal * height * _displacementIntensity/10;
                
                v.vertex.z -= 3 * _displacementIntensity * (value_noise(v.vertex.xy * 500));

                v.vertex.xyz += float3(cos(_Time.x)* _moveSpeed,
                sin(_Time.y)* _moveSpeed, 
                cos(_Time.z)* _moveSpeed) * 0.001;

                o.vertex = UnityObjectToClipPos(v.vertex);

                o.screenUV = ComputeGrabScreenPos(o.vertex);

                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                float3 color = 0;
                
                float2 screenUV = i.screenUV.xy / i.screenUV.w;
                float4 screenPos = float4(i.screenUV.xyz, i.screenUV.w);

                float3 tangentSpaceNormal = UnpackNormal(tex2D(_normalMap, uv));
                tangentSpaceNormal = normalize(lerp(float3(0, 0, 1), tangentSpaceNormal, _normalIntensity));
                
                screenUV = screenUV + (tangentSpaceNormal.xy * _refractionIntensity);

                float3 background = tex2D(_BackgroundTex, screenUV);

                float3x3 tangentToWorld = float3x3 
                (
                    i.tangent.x, i.bitangent.x, i.normal.x,
                    i.tangent.y, i.bitangent.y, i.normal.y,
                    i.tangent.z, i.bitangent.z, i.normal.z
                );

                float3 normal = mul(tangentToWorld, tangentSpaceNormal);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
                 //fresnel
                float fresnel = 1 - saturate(dot(viewDirection, normal));
                fresnel = pow(fresnel, _fresnelPower);
                float reflectivity = _reflectivity * fresnel;

                // blinn phong
                

                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0; // includes intensity

                
                float3 halfDirection = normalize(viewDirection + lightDirection);



                 //Diffuse
                //direct DIFFUSE
                float directDiffuse = max(0, dot(normal, lightDirection));
                 //indirect DIFFUSE
                float3 indirectDiffuse = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, normal, DIFFUSE_MIP_LEVEL);
                float3 surfaceColor =  lerp(0, tex2D(_albedo,uv).rgb, 1 - reflectivity) * _iceColor;
                
                float3 diffuse =  surfaceColor * (directDiffuse  * lightColor + indirectDiffuse) *_tint;


                //SPECULAR

              
                float specularFalloff = max(0, dot(normal, halfDirection));
                float3 directSpecular = pow(specularFalloff, _gloss * MAX_SPECULAR_POWER + 0.0001) * _gloss * lightColor;
                
                

                //indirect specular (reflection)
                 
                 float3 viewReflection = reflect(-viewDirection, normal);
                 float mip = (1-_gloss) * SPECULAR_MIP_STEP;

                viewReflection = BoxProjectedCubemapDirection(viewReflection, i.posWorld,unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
                
                float3 indirectSpecular = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, viewReflection, mip )* reflectivity;


                 float3 specular = directSpecular + indirectSpecular;
                color = (diffuse*_opacity) + (background*(1-_opacity)) + specular;
              

                return float4(color, 1);
            }
            ENDCG
        }
    }
}

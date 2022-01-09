Shader "hw/hw9/water"
{
    Properties 
    {
        _albedo ("albedo", 2D) = "white" {}
        [NoScaleOffset] _normalMap ("normal map", 2D) = "bump" {}
        [NoScaleOffset] _displacementMap ("displacement map", 2D) = "white" {}
        _gloss ("gloss", Range(0,1)) = 1
        _normalIntensity ("normal intensity", Range(0, 1)) = 1
        _displacementIntensity ("displacement intensity", Range(0,1)) = 0.5
        _refractionIntensity ("refraction intensity", Range(0, 0.5)) = 0.1
        _pan ("pan", Vector) = (0, 0, 0, 0)
        _opacity ("opacity", Range(0,1)) = 0.9

        _fresnelPower ("fresnel power", Range(0, 10)) = 5

        _reflectivity("reflectivity", Range(0,1)) = 1

        _foamDepth("Foam Depth", Float) =0 
        _foamColor("Foam color", Color) = (1,1,1,1)
        _foamStrength("Foam Strength", Float) = 1
    }
    SubShader
    {
        // this tag is required to use _LightColor0
        // this shader won't actually use transparency, but we want it to render with the transparent objects
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "LightMode"="ForwardBase" }

        GrabPass {
            "_BackgroundTex"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc" // might be UnityLightingCommon.cginc for later versions of unity
            #define SPECULAR_MIP_STEP 3
            #define DIFFUSE_MIP_LEVEL 5
            #define MAX_SPECULAR_POWER 256

            sampler2D _albedo; float4 _albedo_ST;
            sampler2D _normalMap;
            sampler2D _displacementMap;
            sampler2D _BackgroundTex;
            sampler2D _CameraDepthTexture;
            float4 _pan;
            float _gloss;
            float _normalIntensity;
            float _displacementIntensity;
            float _refractionIntensity;
            float _opacity;
            float _foamDepth;
            float _reflectivity;
            float3 _foamColor;
            float _foamStrength;
            float _fresnelPower;
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
                
                // create a variable to hold two float2 direction vectors that we'll use to pan our textures
                float4 uvPan : TEXCOORD5;
                float4 screenUV : TEXCOORD6;
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


            float foam_noise (float2 uv) {
                float2 ipos = floor(uv);
                float2 fpos = frac(uv); 
                
                float o  = rand(ipos);
                float x  = rand(ipos + float2(0.1, 0));
                float y  = rand(ipos + float2(0, 0.1));
                float xy = rand(ipos + float2(0.1, 0.1));

                float2 smooth = smoothstep(0, 1, fpos);
                return lerp( lerp(o,  x, smooth.x), 
                             lerp(y, xy, smooth.x), smooth.y);
            }

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.uv = TRANSFORM_TEX(v.uv, _albedo);
                
                // panning
                o.uvPan = _pan * _Time.x; 

               
                float height = tex2Dlod(_displacementMap, float4(o.uv + o.uvPan.xy, 0, 0)).r;
                v.vertex.xyz += v.normal * height * _displacementIntensity;

                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldNormal(v.tangent);
                o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;

                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.screenUV = ComputeGrabScreenPos(o.vertex);
                
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                float2 screenUV = i.screenUV.xy / i.screenUV.w;
                float4 screenPos = float4(i.screenUV.xyz, i.screenUV.w);

                float3 tangentSpaceNormal = UnpackNormal(tex2D(_normalMap, uv + i.uvPan.xy));
                float3 tangentSpaceDetailNormal = UnpackNormal(tex2D(_normalMap, (uv * 5) + i.uvPan.zw));
                tangentSpaceNormal = BlendNormals(tangentSpaceNormal, tangentSpaceDetailNormal);


                tangentSpaceNormal = normalize(lerp(float3(0, 0, 1), tangentSpaceNormal, _normalIntensity));
                
                
                float2 refractionUV = screenUV.xy + (tangentSpaceNormal.xy * _refractionIntensity);
                float3 background = tex2D(_BackgroundTex, refractionUV);

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
                float3 surfaceColor = lerp(0, tex2D(_albedo, uv + i.uvPan.xy).rgb, 1 - reflectivity);
                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0; // includes intensity
                
                float3 normal2 = i.normal;

                //DIFFUSE
                //direct diffuse
                float directDiffuse = max(0, dot(normal, lightDirection));
             
                //indirect DIFFUSE
                float3 indirectDiffuse = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, normal, DIFFUSE_MIP_LEVEL);

               

                float3 diffuse =  surfaceColor * (directDiffuse  * lightColor + indirectDiffuse);

                 //Foam
                //calculate depth
                float cameraDepth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,
                UNITY_PROJ_COORD(screenPos))));
                cameraDepth = abs(cameraDepth - screenPos.w);
                float depthMask = 1-cameraDepth + _foamDepth;


                float3 foamColor1 = value_noise(uv * 1000 + _Time.y);
                float3 foamColor2 = value_noise(uv * 2000 + _Time.x*2);
                float3 foamColor = saturate((foamColor1.r + foamColor2.r) * depthMask + _foamStrength);

                diffuse = lerp(diffuse, _foamColor, foamColor);
                //SPECULAR

       
                //direct specular
               
                float3 halfDirection = normalize(viewDirection + lightDirection);
                float specularFalloff = max(0, dot(normal, halfDirection));
                float3 directSpecular = pow(specularFalloff, _gloss * MAX_SPECULAR_POWER + 0.0001) * _gloss * lightColor;
                
                

                //indirect specular (reflection)
                 
                 float3 viewReflection = reflect(-viewDirection, lerp(normal2, normal, cos(_Time.x)));
                  float mip = (1-_gloss) * SPECULAR_MIP_STEP;

                //box projection cube map
                viewReflection = BoxProjectedCubemapDirection(viewReflection, i.posWorld,unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);

                float3 indirectSpecular = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, viewReflection, mip )* reflectivity;


                indirectSpecular = pow(indirectSpecular, 1.5);

                float3 specular = directSpecular + indirectSpecular;


                

                float3 color = (diffuse * _opacity) + (background * (1 - _opacity)) + specular;
               // color = tex2D(_CameraDepthTexture, screenUV.xy);
                
                return float4(color, 1);
            }
            ENDCG
        }
    }
}

Shader "hw/hw9/glacier"
{
    Properties
    {
        _scale ("noise scale", Range(2, 50)) = 15.5
        _displacement ("displacement", Range(0, 100)) = 0.33
        _seed ("seed", Range(0,1000)) = 300
        _mountainRadius("Mountain Radius", Range(0,1)) = 0.6
        _center("Center", Vector) = (0,0,0,0)
        _color ("color", Color) = (1, 1, 1, 1)



        _tint ("tint color", Color) = (1, 1, 1, 1)

        _albedo ("albedo", 2D) = "white" {}
        [NoScaleOffset] _normalMap ("normal map", 2D) = "bump" {}

        _snowAlbedo ("snow albedo", 2D) = "white" {}
        [NoScaleOffset] _snowNormalMap ("snow normal map", 2D) = "bump" {}


        _gloss ("gloss", Range(0,1)) = 1
        _normalIntensity ("normal intensity", Range(0, 1)) = 1
        _displacementIntensity ("displacement intensity", Range(0, 3)) = 0
        _opacity ("opacity", Range(0,1)) = 1
        _refractionIntensity("Refraction Intensity", Range(0,1))=0
        _fresnelPower ("fresnel power", Range(0, 10)) = 5

        _reflectivity("reflectivity", Range(0,1)) = 1
        _snowLine("snow line", Range(-10,10)) = 0.8
        _snowColor("Snow color", Color) = (1,1,1,1)
    }

    SubShader
    {
	    Tags {"Queue"="Transparent" "IgnoreProjector"="True"}
	    ZWrite Off
	    Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
             // might be UnityLightingCommon.cginc for later versions of unity
            #include "Lighting.cginc"

            #define MAX_SPECULAR_POWER 256
            #define SPECULAR_MIP_STEP 3
            #define DIFFUSE_MIP_LEVEL 5

            float _scale;
            float _displacement;
            float _seed;
            float _mountainRadius;
            float2 _center;
            float4 _color;

            float _snowLine;
            float3 _snowColor;

            float3 _tint;
            sampler2D _albedo; float4 _albedo_ST;
            sampler2D _snowAlbedo; float4 _snowAlbedo_ST;
            sampler2D _snowNormalMap;
            sampler2D _normalMap;
            
            sampler2D _BackgroundTex;

            float _gloss;
            float _normalIntensity;
            float _displacementIntensity;
            float _refractionIntensity;
            float _opacity;
            float _reflectivity;
            float _fresnelPower;
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

            float fractal_noise (float2 uv) {
                float n = 0;
                float amp = 1;
                float a = 1.5;

                for(int j=0; j<6; j++){
                  n += amp * value_noise(uv * a);
                  amp/=1.5;
                  a*=1.5;
                 
                }
                
                return n;
            }

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
                float3 posObj : TEXCOORD6;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                
                
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldNormal(v.tangent);
                o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;
                
                float distanceToCenter = distance(v.uv , _center);
                
                
                float displacement=0;

                if(distanceToCenter >= _mountainRadius){
                    displacement = _displacement;
                }else{
                    displacement = lerp(0, _displacement, pow(distanceToCenter / _mountainRadius, 10));
                }

                //displacement = lerp(displacement,0, abs(v.uv.x));
               
                float height = fractal_noise((v.uv + _seed)* _scale) * displacement;

                v.vertex.xyz += v.normal * height * _displacementIntensity;

                bool isSnow = v.vertex.y >= _snowLine + (value_noise(v.vertex.xz*10)*2-1);

                if(!isSnow){
                    o.uv = TRANSFORM_TEX(v.uv, _albedo);
                }else{
                    o.uv = TRANSFORM_TEX(v.uv, _snowAlbedo);
                }
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenUV = ComputeGrabScreenPos(o.vertex);

                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.posObj = v.vertex.xyz;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                float3 color = 0;
                bool isSnow = i.posObj.y >= _snowLine + (value_noise(i.posObj.xz*10)*2-1);


                float2 screenUV = i.screenUV.xy / i.screenUV.w;
                float4 screenPos = float4(i.screenUV.xyz, i.screenUV.w);

                float3 tangentSpaceNormal;
                if(!isSnow){
                    tangentSpaceNormal  = UnpackNormal(tex2D(_normalMap, uv));
                }else{
                    tangentSpaceNormal  = UnpackNormal(tex2D(_snowNormalMap, uv));
                }
                
                tangentSpaceNormal = normalize(lerp(float3(0, 0, 1), tangentSpaceNormal, _normalIntensity));
                
                screenUV += (tangentSpaceNormal.xy * _refractionIntensity);

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

                float3 diffuse;
                float3 surfaceColor;

                if(isSnow){
                    surfaceColor = tex2D(_snowAlbedo,uv).rgb * _snowColor;
                    diffuse = surfaceColor * (directDiffuse  + indirectDiffuse);
                }else{
                    surfaceColor =  lerp(0, tex2D(_albedo,uv).rgb, 1 - reflectivity) * _color;
                    diffuse =  surfaceColor * (directDiffuse  * lightColor + indirectDiffuse) *_tint;
                }
               

                //specular
                //direct specular
               
                float specularFalloff = max(0, dot(normal, halfDirection));
                float3 directSpecular = pow(specularFalloff, _gloss * MAX_SPECULAR_POWER + 0.0001) * _gloss * lightColor;
                
                

                //indirect specular (reflection)
                 
                 float3 viewReflection = reflect(-viewDirection, normal);
                 float mip = (1-_gloss) * SPECULAR_MIP_STEP;

                viewReflection = BoxProjectedCubemapDirection(viewReflection, i.posWorld,unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);

                float3 indirectSpecular = 0;

                if(!isSnow){
                    indirectSpecular  = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, viewReflection, mip )* reflectivity;
                }else{
                    indirectSpecular  = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, viewReflection, mip )* 0.5 * reflectivity;
                }



               float3 specular = directSpecular + indirectSpecular;


              


                color = (diffuse*_opacity) + (background*(1-_opacity)) + specular;

               // color += _color;

                float distanceToCenter = distance(i.uv , _center);

                float4 finalColor = float4(color, _color.a);
                if(distanceToCenter <= _mountainRadius-0.12){
                    finalColor.a = lerp(0, _displacement, pow(distanceToCenter / _mountainRadius, 2));
                }

               // color.rgb *= value_noise(i.uv * _scale);
                return finalColor;
            }
            ENDCG
        }
    }
}

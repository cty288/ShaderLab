Shader "examples/week 8/Ocean"
{
    Properties 
    {

        _shallowColor ("Shallow", Color) = (0.44, 0.95, 0.36, 1.0)
        _deepColor ("Deep", Color) =  (0.0, 0.05, 0.19, 1.0)
        _farColor ("Far", Color) = (0.04, 0.27, 0.75, 1.0)

        _depthDensity ("Depth Scaler / Opacity", Range(0.0, 0.001)) = 0.00005
        _distanceDensity ("Distance Scaler", Range(0.0, 1.0)) = 0.1

        _normalMap ("normal map", 2D) = "bump" {}
        _normalIntensity ("Normal intensity", Range(0, 5)) = 1
        [NoScaleOffset] _displacementMap ("Displacement map", 2D) = "white" {}
        _displacementIntensity ("Displacement intensity", Range(0,1)) = 0.5
        [NoScaleOffset] _FoamTexture ("Foam texture", 2D) = "black"{}
        _foamIntensity ("Foam intensity", Range(0,10)) = 0.1
        _EdgeFoamColor ("Edge Foam Color", Color) = (1, 1, 1, 1)
        _EdgeFoamDepth ("Edge Foam Scale", float) = 10.0
        

		_MainTex ("Main Texture", 2D) = "white" {}
		_TextureDistort("Texture Wobble", range(0,1)) = 0.2


        _gloss ("Gloss", Range(0,1)) = 1
        _specularPower ("Specular Power", float) = 1000

        _refractionIntensity ("Refraction intensity", Range(0, 0.5)) = 0.1

        _pan("Pan", Vector) = (0,0,0,0)

        //_diffuseIntensity ("Diffuse intensity", Range(0, 1)) = 0.5
        _opacity ("Opacity", Range(0,1)) = 0.9
    }
    SubShader
    {
        // this tag is required to use _LightColor0
        // this shader won't actually use transparency, but we want it to render with the transparent objects
        Tags { "Queue"="Transparent" 
            "RenderType" = "Transparent"
            "IgnoreProjector"="True" 
            "LightMode"="ForwardBase" 
        }

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
            
            sampler2D _BackgroundTex;
            sampler2D _CameraDepthTexture;

            float3 _shallowColor;
            float3 _deepColor;
            float3 _farColor;

            float _depthDensity;
            float _distanceDensity;

            sampler2D _normalMap;float4 _normalMap_ST;
            float _normalIntensity;

            sampler2D _displacementMap;
            float _displacementIntensity;

            sampler2D _FoamTexture;
            float _foamIntensity;
            float3 _EdgeFoamColor;
            float _EdgeFoamDepth;


            
			float _TextureDistort;
            sampler2D _MainTex;



            float _gloss;
            float _specularPower;

            float _refractionIntensity;

            float4 _pan;

            //float _diffuseIntensity;
            float _opacity;

            float3 warp_noise (sampler2D tex, float2 uv) {

                float speed = 0.05;

                float2 uv1 = uv + float2(0, 0) + normalize( float2( 0.1,  0.1) ) * speed * _Time.y;
                float2 uv2 = uv + float2(0.418, 0.355) + normalize( float2( -0.1,  0.1) ) * speed * _Time.y;
                float2 uv3 = uv + float2(0.865, 0.148) + normalize( float2( 0.1,  -0.1) ) * speed * _Time.y;
                float2 uv4 = uv + float2(0.651, 0.752) + normalize( float2( -0.1,  -0.1) ) * speed * _Time.y;

                return (tex2D(tex, uv1).rgb + tex2D(tex, uv2).rgb + tex2D(tex, uv3).rgb + tex2D(tex, uv4).rgb) / 4.0;
            }

            float3 warp_noise_unpack (sampler2D tex, float2 uv) {

                float speed = 0.05;

                float2 uv1 = uv + float2(0, 0) + normalize( float2( 0.1,  0.1) ) * speed * _Time.y;
                float2 uv2 = uv + float2(0.418, 0.355) + normalize( float2( -0.1,  0.1) ) * speed * _Time.y;
                float2 uv3 = uv + float2(0.865, 0.148) + normalize( float2( 0.1,  -0.1) ) * speed * _Time.y;
                float2 uv4 = uv + float2(0.651, 0.752) + normalize( float2( -0.1,  -0.1) ) * speed * _Time.y;

                return normalize(UnpackNormal(tex2D(tex, uv1)) + UnpackNormal(tex2D(tex, uv2)) + UnpackNormal(tex2D(tex, uv3))+ UnpackNormal(tex2D(tex, uv4)));
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
                float3 worldPos : TEXCOORD4;
                float4 screenUV : TEXCOORD5;
                
            };

            Interpolators vert (MeshData v)
            { 
                Interpolators o;
                o.uv = TRANSFORM_TEX(v.uv, _normalMap);

                o.uv = v.uv; 
                // panning
                float4 uvPan = _pan * _Time.x;
                uvPan = float4(float2(0.9, 0.2) * _Time.x, float2(0.5, -0.2) * _Time.x);

                // add our panning to our displacement texture sample
                float height = tex2Dlod(_displacementMap, float4(o.uv + uvPan.xy, 0, 0)).r;
                v.vertex.xyz += v.normal * height * _displacementIntensity;

                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldNormal(v.tangent);
                o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;
                
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.vertex = mul(UNITY_MATRIX_VP, float4(o.worldPos, 1));
                o.screenUV = ComputeGrabScreenPos(o.vertex);
                o.uv = v.uv;
                //o.uv = TRANSFORM_TEX(v.uv, _albedo);

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                float2 screenUV = i.screenUV.xy / i.screenUV.w;

                
                float3x3 tangentToWorld = float3x3 
                (
                    i.tangent.x, i.bitangent.x, i.normal.x,
                    i.tangent.y, i.bitangent.y, i.normal.y,
                    i.tangent.z, i.bitangent.z, i.normal.z
                );
                float3 tangentSpaceNormal = warp_noise_unpack(_normalMap, i.worldPos.xz/25);
                //float3 tangentSpaceDetailNormal = UnpackNormal(tex2D(_normalMap, uv * 5 - i.uvPan.zw));
                //tangentSpaceNormal = BlendNormals(tangentSpaceNormal, tangentSpaceDetailNormal);
                float3 foamNormal = mul(tangentToWorld, tangentSpaceNormal);
                tangentSpaceNormal = normalize(lerp(float3(0, 0, 1), tangentSpaceNormal, _normalIntensity));
                float3 normal = mul(tangentToWorld, tangentSpaceNormal);


                float2 refractionUV = screenUV.xy + ( tangentSpaceNormal.xy * _refractionIntensity);
                float3 background = tex2D(_BackgroundTex, refractionUV);
                float fragDepth = tex2D(_CameraDepthTexture, screenUV.xy);
                 
                
                float depth = abs(LinearEyeDepth(fragDepth) - LinearEyeDepth(i.vertex.z));
                float transmittance = exp(-_depthDensity * depth);
                float distance = exp(-_distanceDensity * length(_WorldSpaceCameraPos - i.worldPos));

                 
                float3 baseColor = _shallowColor;// * background;
                baseColor = lerp(_deepColor, baseColor, transmittance);
                baseColor = lerp(_farColor, baseColor, distance);


                float2 foamUV = (i.worldPos.xz / 10) + (foamNormal.xz * 0.75);// / _FoamScale //_FoamNoise Scale * 
                float3 foamColor = warp_noise(_FoamTexture, foamUV);
                foamColor = foamColor * distance;
                foamColor = foamColor * _foamIntensity;
                //return float4(foamColor + baseColor, 1);
                

                float edgeFoamMask = round(exp(-depth / _EdgeFoamDepth));
                float3 edgeFoamColor = lerp(0, _EdgeFoamColor, edgeFoamMask);;


                // blinn phong
                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0; // includes intensity

                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                float3 halfDirection = normalize(viewDirection + lightDirection);

                float diffuseFalloff = max(0, dot(normal, lightDirection));// * _diffuseIntensity;
                float3 diffuse = diffuseFalloff * 1.25 * baseColor * lightColor;
                
                //float specularFalloff = max(0, dot(normal, halfDirection));
                //float3 specular = pow(specularFalloff, _gloss * 256 + 0.0001) * lightColor * _gloss;
                float3 view = reflect(viewDirection, tangentSpaceNormal);
                float specularFalloff = saturate(dot(view, _WorldSpaceLightPos0));
                specularFalloff = round(saturate(pow(specularFalloff, _specularPower)));
                float3 specular = lerp(0, lightColor, specularFalloff);

                
                //float3 color = tex2D(_MainTex, i.uv);
                float3 color = (diffuse * _opacity) + (background * (1 - _opacity)) + foamColor + edgeFoamColor; // + (background * (1 - _opacity))
                return float4(color, 1);
            }
            ENDCG
        }
    }
}

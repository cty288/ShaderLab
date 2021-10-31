Shader "hw/water"
{
    Properties
    {
        _albedo("albedo", 2D) = "white" {}
        [NoScaleOffset] _normalMap("normal map", 2D) = "bump" {}
        [NoScaleOffset] _normalMapDefault("Normal map default",2D) = "bump"{}
        [NoScaleOffset] _displacementMap("displacement map", 2D) = "white" {}
        _gloss("gloss", Range(0,1)) = 1
        _normalIntensity("normal intensity", Range(0, 1)) = 1
        _displacementIntensity("displacement intensity", Range(0,1)) = 0.5


        _waterfallDisplacementIntensity("Waterfall Displacement Intensity",Range(0,1)) = 0.5
        _refractionIntensity("refraction intensity", Range(0, 0.5)) = 0.1
        _pan("Pan",Vector) = (0,0,0,0)
        _opacity("opacity", Range(0,1)) = 0.9
        _waterfallDetailIntensity("Waterfall Detail Intensity", Float) = 10
        //_waterfallDetailRange("Waterfall Detail Range",Range(-1,1)) = 0.5 // 0.1-0.22

        _vortexCenter("Vortex Center",Vector) = (0,0,0,0) //use only x and z
        _vortexRadius("Vortex Radius", Float) = 1.0
        _vortexDepth("Vortex Depth",Float) = 1.0
       
    }
        SubShader
        {
            // this tag is required to use _LightColor0
            // this shader won't actually use transparency, but we want it to render with the transparent objects
            Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "LightMode" = "ForwardBase" }

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

                #define MAX_SPECULAR_POWER 256

                sampler2D _albedo; float4 _albedo_ST;
                sampler2D _normalMap;
                sampler2D _displacementMap;
                sampler2D _BackgroundTex;
                sampler2D _normalMapDefault;
                float _gloss;
                float _normalIntensity;
                float _displacementIntensity;
                float _waterfallDisplacementIntensity;
                float _waterfallDetailRange;
                float _refractionIntensity;
                float _opacity;
                float _waterfallDetailIntensity;
                float4 _pan;

                float3 _vortexCenter;
                float _vortexRadius;
                float _vortexDepth;
              
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
                    float3 objectVertex: TEXCOORD7;
                    // create a variable to hold two float2 direction vectors that we'll use to pan our textures
                    float4 uvPan : TEXCOORD5;
                    float4 screenUV : TEXCOORD6;
                };

                float4x4 rotation_matrix(float3 axis, float angle) {
                    axis = normalize(axis);
                    float s = sin(angle);
                    float c = cos(angle);
                    float oc = 1.0 - c;

                    return float4x4(
                        oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s, 0.0,
                        oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s, 0.0,
                        oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c, 0.0,
                        0.0, 0.0, 0.0, 1.0);
                }
                float rand(float2 uv) {
                    return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
                }
                float value_noise(float2 uv) {
                    float2 ipos = floor(uv);
                    float2 fpos = frac(uv);

                    float o = rand(ipos);
                    float x = rand(ipos + float2(1, 0));
                    float y = rand(ipos + float2(0, 1));
                    float xy = rand(ipos + float2(1, 1));

                    float2 smooth = smoothstep(0, 1, fpos);
                    return lerp(lerp(o, x, smooth.x),
                        lerp(y, xy, smooth.x), smooth.y);
                }

                Interpolators vert(MeshData v)
                {
                    Interpolators o;
                    o.uv = TRANSFORM_TEX(v.uv, _albedo);

                

                    // panning
                    o.uvPan = _pan * _Time.x;
                    float height = tex2Dlod(_displacementMap, float4(o.uv + o.uvPan.xy, 0, 0)).r;
                    v.vertex.xyz += v.normal * height * _displacementIntensity;

                    //vertex displacement
                    float distanceToCenter2 = abs(v.vertex.x);

                    float direction = v.vertex.x > 0 ? -1 : 1;
                    float3 normalMap = tex2Dlod(_normalMapDefault, float4(o.uv + (o.uvPan.xy) * direction, 0, 0));
                    if (normalMap.r > 0.5) {
                        if (distanceToCenter2 <= _vortexRadius) {
                            v.vertex.xyz += v.normal * _waterfallDisplacementIntensity
                                * value_noise(float2(v.uv * 10));
                        }
                        else {
                            v.vertex.xyz += v.normal * _waterfallDisplacementIntensity
                                * value_noise(float2(v.uv * 10)) * (1-(distanceToCenter2-_vortexRadius)/ distanceToCenter2);
                        }
                          
                    }


                    float distanceToCenter = distance(float3(v.vertex.x, 0, v.vertex.z), _vortexCenter);
                    float vortex = pow(saturate((_vortexRadius - distanceToCenter) / _vortexRadius), 2);
                    v.vertex.xyz -= v.normal * _vortexDepth * vortex;


                    o.normal = UnityObjectToWorldNormal(v.normal);
                    o.tangent = UnityObjectToWorldNormal(v.tangent);
                    o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;

                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.objectVertex = v.vertex;
                    o.screenUV = ComputeGrabScreenPos(o.vertex);

                    o.posWorld = mul(unity_ObjectToWorld, v.vertex);

                    return o;
                }

              

             

                float fractal_noise(float2 uv) {
                    float n = 0;

                    n = (1 / 2.0) * value_noise(uv * 1);
                    n += (1 / 4.0) * value_noise(uv * 2);
                    n += (1 / 8.0) * value_noise(uv * 4);
                    n += (1 / 16.0) * value_noise(uv * 8);

                    return n;
                }

                float4 frag(Interpolators i) : SV_Target
                {
                    float2 uv = i.uv;
                    float2 uv2 = uv;
                    float2 screenUV = i.screenUV.xy / i.screenUV.w;
                    float3 tangentSpaceNormal = 0;
                    float3 tangentSpaceDetailNormal = 0;

                    //blend normals
                    //direction of the waterfall 
                    float direction = i.objectVertex.x > 0 ? -1 : 1;

                    //waterfall
                    float distanceToCenter = abs(i.objectVertex.x);
                    float speedBuffer = 0;

                    //shorter distance = higher speed
                    if (abs(distanceToCenter <= _vortexRadius)) {
                        speedBuffer = (_vortexRadius - distanceToCenter) /_vortexRadius;
                        uv.x += direction*0.1* ceil(speedBuffer*2) *  _Time.y;
                    }
                   
                   
                    
                    tangentSpaceNormal = UnpackNormal(tex2D(_normalMap, uv + (i.uvPan.xy) * direction));
                    tangentSpaceDetailNormal = UnpackNormal(tex2D(_normalMap, (uv * 5) + (i.uvPan.zw) * direction));
                   
                    tangentSpaceNormal = BlendNormals(tangentSpaceNormal, tangentSpaceDetailNormal);

                    tangentSpaceNormal = normalize(lerp(float3(0, 0, 1), tangentSpaceNormal, _normalIntensity));

                    float3x3 tangentToWorld = float3x3
                        (
                            i.tangent.x, i.bitangent.x, i.normal.x,
                            i.tangent.y, i.bitangent.y, i.normal.y,
                            i.tangent.z, i.bitangent.z, i.normal.z
                            );

                    float3 normal = mul(tangentToWorld, tangentSpaceNormal);

                   
                    //limited refraction. only show refraction near the bottom of the waterfall
                    float refractionIntensity = _refractionIntensity;


                    if (abs(distanceToCenter) >= _vortexRadius) {
                       refractionIntensity =100;
                    }
                    else {
                        refractionIntensity += lerp(0,5, abs(distanceToCenter));
                    }

                    float2 refractionUV = screenUV.xy + (tangentSpaceNormal.xy * refractionIntensity);
                    float3 background = tex2D(_BackgroundTex, refractionUV);
                 
                   
                    // blinn phong
                    float3 surfaceColor = tex2D(_albedo, uv + i.uvPan.xy).rgb;

                    float3 lightDirection = _WorldSpaceLightPos0;
                    float3 lightColor = _LightColor0; // includes intensity

                    float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
                    float3 halfDirection = normalize(viewDirection + lightDirection);

                    float diffuseFalloff = max(0, dot(normal, lightDirection));
                    float specularFalloff = max(0, dot(normal, halfDirection));

                    float3 specular = pow(specularFalloff, _gloss * MAX_SPECULAR_POWER + 0.0001) * _gloss * lightColor;
                    float3 diffuse = diffuseFalloff * surfaceColor * lightColor;
                    float3 color = 0;

                  
                    //waterfall color color
                    
                    float3 waterfallColorBuffer = 0;
                  
                   
                    uv2.x += direction * 0.1 *  _Time.y;
                    float3 normalMap = UnpackNormal(tex2D(_normalMap, uv2 + (i.uvPan.xy) * direction));

                    //dynamic change water fall density
                    _waterfallDetailRange = (0.25 * value_noise(float2(_Time.y, _Time.z/10)) + 0.2) / 2;

                    if (normalMap.r >= _waterfallDetailRange) {
                        waterfallColorBuffer = value_noise(normalMap.rg * _waterfallDetailIntensity);
                    }


                    color += (diffuse * _opacity) + (background * (1 - _opacity)) + specular + waterfallColorBuffer;

                   
                    return float4(color, 1);
                }
                ENDCG
            }
        }
}

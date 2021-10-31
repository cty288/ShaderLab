Shader "hw/hw7"
{
    Properties
    {
        _surfaceColor("surface color", Color) = (0.4, 0.1, 0.9)
        _gloss("gloss", Range(0,1)) = 1

        _innerRimColor("InnerRimColor",Color) = (1,1,1,1)
        _innerRimContrast("InnerRimContrast",Float) = 0

       
       
        _laserInterval("laser Interval",Float) = 10
        _laserSpeed("laser Speed",Float) = 15
        _laserPower("laser Power",Float) = 1
     
    }
        SubShader
    {
        // this tag is required to use _LightColor0
        Tags { "LightMode" = "ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
             #define TAU 6.28318530718
            // might be UnityLightingCommon.cginc for later versions of unity
            #include "Lighting.cginc"

            #define MAX_SPECULAR_POWER 256

            float3 _surfaceColor;
            float _gloss;
            float3 _innerRimColor;
            float _innerRimContrast;

           
           
            float _laserInterval;
            float _laserSpeed;
            float _laserPower;
           
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


            Interpolators vert(MeshData v)
            {
                Interpolators o;
                o.normal = UnityObjectToWorldNormal(v.normal);
              
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float3 color = 0;

                float3 normal = normalize(i.normal);

                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0; // includes intensity

                //diffuse
                float diffuseFalloff = max(0, dot(normal, lightDirection));
                diffuseFalloff = pow(diffuseFalloff * 0.5 + 0.5, 2);
                float3 diffuse = diffuseFalloff * _surfaceColor * lightColor;

                //specular
                float3 cameraPos = _WorldSpaceCameraPos.xyz;
                float3 viewDirection = normalize(cameraPos - i.worldPos);
                float3 halfDirection = normalize(viewDirection + lightDirection);
                float specularFalloff = max(0, dot(halfDirection, normal));
                specularFalloff = pow(specularFalloff, MAX_SPECULAR_POWER * _gloss + 0.0001) * _gloss;
                float3 specular = specularFalloff * lightColor;

                //inner rim
                float innerRimFalloff = 1 - max(0, dot(viewDirection, normal));
                float3 _innerRimIntensity = (5 * sin(_Time.y* _laserSpeed / 9) + 5) / 2;
                float3 innerRing = pow(innerRimFalloff, _innerRimContrast+0.0001) * _innerRimIntensity
                    * _innerRimColor;

                color = diffuse + specular + innerRing;
                //laser
                for (int j = 0; j < 2; j++) {
                    float3 laserLightDirection;
                    if (j == 0) {
                        laserLightDirection = _WorldSpaceLightPos0;
                    }
                    else {
                        laserLightDirection = mul( rotation_matrix(float3(1, 0, 0), 0.25 * TAU), _WorldSpaceLightPos0);
                    }

                    float laser = dot(i.worldPos, -laserLightDirection); //directional light as the direction of laser

                    laser = laser - _Time.y * _laserSpeed;
                    //get the positive decimal of laser divided by interval
                    laser = frac(abs(laser) / _laserInterval);

                    laser = max(0, (pow(laser, _laserPower)
                        + pow(laser, _laserPower * 2)) * 0.5 * lightColor); //intensity controlled by directional light intensity

                    float3 laserColor = laser * _surfaceColor;

                    color += laserColor;
                }
        
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

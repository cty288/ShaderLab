Shader "examples/week 11/water depth"
{
    Properties
    {
        _color ("color", Color) = (0, 0, 0.8, 1)
        _scale ("noise scale", Range(2, 100)) = 15.5
        _displacement ("displacement", Range(0, 0.3)) = 0.05
        _refractionIntensity ("refraction intensity", Range(0, 0.2)) = 0.02
        _surfaceIntersectionSize ("surface intersection size", Range(0, 1)) = 0.1
        _depthFog ("depth fog", Range(0, 2)) = 0.1
        _opacity ("opacity", Range(0,1)) = 0.8
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry+1"}
        
        GrabPass{
            "_BackgroundTex"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // get depth texture and background grab pass texture
            sampler2D _CameraDepthTexture;
            
            float3 _color;
            float _scale;
            float _displacement;
            float _refractionIntensity;
            float _surfaceIntersectionSize;
            float _depthFog;
            float _opacity;

            sampler2D _BackgroundTex;

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 color : COLOR;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float2 worldUV : TEXCOORD1;
                
                // screenPos and surfZ
                float4 screenPos : TEXCOORD2;
                float surfZ : TEXCOORD3;
            };

            float wave (float2 uv) {
                float wave1 = sin(((uv.x + uv.y) * _scale) + _Time.z) * 0.5 + 0.5;
                float wave2 = (cos(((uv.x - uv.y) * _scale/2.568) + _Time.z) + 1) * sin(_Time.x * 5.2321 + (uv.x * uv.y)) * 0.5 + 0.5;
                return (wave1 + wave2) / 3;
            }

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.worldUV = mul(unity_ObjectToWorld, v.vertex).xz * 0.2;

                v.vertex.y += wave(o.worldUV) * _displacement * v.color.r;

                o.vertex = UnityObjectToClipPos(v.vertex);
                
                // screenPos and surfZ
                o.screenPos = ComputeGrabScreenPos(o.vertex);
                o.surfZ = -UnityObjectToViewPos(v.vertex).z * _ProjectionParams.w;

                o.uv = v.uv;
                o.normal = v.normal;

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float w = wave(i.worldUV);
                // just some dumb hard coded shading
                float3 color = lerp(_color * dot(abs(i.normal), float3(0.23, 0.15, 0.41)), (w.rrr * 0.5 + 0.5) * _color, saturate(i.normal.y));

                // calculate screenUV coordinates
                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                float2 distortedScreenUV = screenUV + (float2(0.1,1) * (w*saturate(i.normal.y)* _refractionIntensity));

                float depth = Linear01Depth(tex2D(_CameraDepthTexture, screenUV)).r;
                float depthDifference = abs(depth - i.surfZ);
                float intersection = 1 - smoothstep(0, _ProjectionParams.w * _surfaceIntersectionSize, depthDifference);

                intersection = pow(intersection, 7);

                float3 background = tex2D(_BackgroundTex, distortedScreenUV).rgb;
                float distortedDepth = Linear01Depth(tex2D(_CameraDepthTexture, distortedScreenUV)).r;
                float distortedDepthDifference = abs(distortedDepth - i.surfZ);
                float underwaterDepth = 1 - smoothstep(0, _ProjectionParams.w * _depthFog,
                distortedDepthDifference);

                background *= underwaterDepth;
                
                color = (color * _opacity) + (background * (1-_opacity));
                color += smoothstep(0.1, 0.2, intersection) * 0.5;
                color = saturate(color);

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

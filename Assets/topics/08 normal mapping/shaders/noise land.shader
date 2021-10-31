Shader "examples/week 8/noise land"
{
    Properties
    {
        _highColor ("high color", Color) = (1, 1, 1, 1)
        _highElevation ("high elevation", Float) = 3
        _midColor ("mid color", Color) = (1, 1, 1, 1)
        _midElevation ("mid elevation", Float) = 3
        _lowColor ("low color", Color) = (1, 1, 1, 1)
        _lowElevation ("low elevation", Float) = 3
        _scale ("noise scale", Range(2, 50)) = 15.5
        _displacement ("displacement", Range(0, 5)) = 0.33
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float3 _highColor;
            float _highElevation;
            float3 _midColor;
            float _midElevation;
            float3 _lowColor;
            float _lowElevation;
            float _scale;
            float _displacement;

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

                n  = (1 / 2.0)  * value_noise( uv * 1);
                n += (1 / 4.0)  * value_noise( uv * 2); 
                n += (1 / 8.0)  * value_noise( uv * 4); 
                n += (1 / 16.0) * value_noise( uv * 8);
                
                return n;
            }

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                v.vertex.xyz += v.normal.xyz * fractal_noise((v.uv * _scale)) * _displacement;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float elevation = i.worldPos.y;
                float3 color = lerp(_lowColor, _midColor, smoothstep(_lowElevation, _midElevation, elevation));
                color = lerp(color, _highColor, smoothstep(_midElevation, _highElevation, elevation));

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

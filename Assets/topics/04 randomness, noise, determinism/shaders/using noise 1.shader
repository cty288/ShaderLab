Shader "examples/using noise 1"
{
    Properties
    {
        [NoScaleOffset] _tex ("texture", 2D) = "white"{}
        _scale ("noise scale", Range(2, 30)) = 15.5
        _intensity ("noise intensity", Range(0.001, 0.05)) = 0.006
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

            sampler2D _tex;
            float _scale;
            float _intensity;

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

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                
                // try different ways of using time
                float time = 0;
                 time = _Time.y;
                 //time = floor(_Time.z/2);
                 //time = pow(sin(_Time.y), 8);

                /*
                 sample value noise at uv + time
                 scale coordinates to scale noise output
                 subtract 0.5 for a range between -0.5 and 0.5
                 multiply by _intensity
                */
                float n = (value_noise((uv + time) * _scale) - 0.5) * _intensity;

                // add our noise value to our uv coordinates when we sample the texture
                float3 color = tex2D(_tex, uv + n).rgb;
                
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

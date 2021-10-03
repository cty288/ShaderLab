Shader "examples/week 4/fractal noise"
{
    Properties
    {
        _scale ("noise scale", Range(2, 100)) = 50  
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

            float _scale;

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
                float2 uv = i.uv * _scale;

                float fn = 0;
                
                fn = (1 / 2.0) * value_noise(uv * 1);
                fn += (1 / 4.0) * value_noise(uv * 2);
                fn += (1 / 8.0) * value_noise(uv * 4);
                fn += (1 / 16.0) * value_noise(uv * 8);

                return float4(fn.rrr, 1.0);
            }
            ENDCG
        }
    }
}

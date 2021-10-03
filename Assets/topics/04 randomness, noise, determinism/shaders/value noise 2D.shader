Shader "examples/week 4/value noise 2D"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float rand (float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
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
                uv *= 20;

                
                float vn = 0;
                //uv in grid
                float2 fpos = frac(uv);
                //grid
                float2 ipos = floor(uv);

                float o = rand(ipos);
                float x = rand(ipos + float2(1, 0));
                float y = rand(ipos + float2(0, 1));
                float xy = rand(ipos + float2(1, 1));

                float2 smooth = smoothstep(0, 1, fpos);

                float ox = lerp(o, x, smooth.x);
                float yxy = lerp(y, xy, smooth.x);
                vn = lerp(ox, yxy, smooth.y);
                
              
                return float4(vn.rrr, 1.0);
            }
            ENDCG
        }
    }
}

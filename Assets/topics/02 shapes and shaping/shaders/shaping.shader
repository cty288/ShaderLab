Shader "examples/week 2/shaping"
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
                uv = uv *2 - 1;
                uv *= 5;
                //-4 ~ 4

                float x = uv.x;
                float y = uv.y;

                float2 c = x;

                c = sin(x);
                c = cos(x);
                c = abs(x);
                c = ceil(x);
                c = floor(x);
                c = step(x, -2);
                c = frac(x);
                c = min(x, y);
                c = max(x, y);
                c = sign(x);
                //c = smoothstep(0, 4, x);
                
                //float3 c1 = float3(0.3, 0.8, 0.2);
               // float3 c2 = float3(0.1, 0.5, 0.9);

              //  return float4(lerp(c1, c2, sin(x)),0);

                return float4(c.rrr, 1.0);
            }
            ENDCG
        }
    }
}

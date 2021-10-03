Shader "examples/week 1/color blending"
{
    Properties
    {
        _color1 ("color one", Color) = (1, 0, 0, 1)
        _color2 ("color two", Color) = (0, 0, 1, 1)
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

            uniform float3 _color1;
            uniform float3 _color2;
            
            float circle (float2 uv, float2 offset, float size) {
                return smoothstep(0.0, 0.005, 1 - length(uv - offset) / size);
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
                float2 uv = i.uv * 2 - 1;
                float3 base  = circle(uv, float2(0.0, -0.3), 0.5) * _color1;
                float3 blend = circle(uv, float2(0.0,  0.3), 0.5) * _color2;
                
                float3 color = 0.0;

                color = 1-(1-base)/blend;
                
                //color = 1 - base/blend;

              //  color = abs(base - blend);

                //color = blend <= 0.5 ? base + 2 * blend - 1 : base + 2 * (blend - 0.5);

                color = lerp(base, blend, 0.5);
          

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

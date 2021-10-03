Shader "examples/week 1/texture color blending"
{
    Properties
    {
        [NoScaleOffset] _baseTex ("base texture", 2D) = "white" {}
        [NoScaleOffset] _blendTex ("blend texture", 2D) = "white" {}
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

            uniform sampler2D _baseTex;
            uniform sampler2D _blendTex;
            
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

                float3 base = tex2D(_baseTex, i.uv).rgb;
                float3 blend = tex2D(_blendTex, i.uv).rgb;
                float3 color = 0;




                /*
                    COLOR BLENDING
                    the following code creates a mix of a base colo and the blend color by following different algorithms.
                    uncomment lines and save the shader to see the effect.

                    some of these blends are commutative and some are non-commutative.
                    in a commutative equation, the base and blend colors can be swapped and return the same result
                    in a non-commutative equation, you'll get different results if you swap the base and blend colors
                */
                
                color = base + blend; // add - commutative
                // color = base - blend; // subtract - non-commutative
                // color = base * blend; // multiply - commutative
                // color = base / blend; // divide - non-commutative
                // color = min(base, blend); // darken - commutative
                // color = 1 - (1 - base) / blend; // color burn - non-commutative
                // color = base + blend - 1; // linear burn - commutative
                // color = max(base, blend); // lighten - commutative
                // color = 1 - (1 - base) * (1 - blend); // screen - commutative
                // color = base / (1 - blend); // color dodge - non-commutative
                // color = abs(base - blend); // difference - commutative
                // color = 0.5 - 2 * (base - 0.5) * (blend - 0.5); // exclusion - commutative

                // color = base <= 0.5 ? 2 * base * blend : 1 - 2 * (1 - base) * (1 - blend); // overlay - non-commutative
                // color = blend <= 0.5 ? base * (blend + 0.5) : 1 - (1 - base) * (1 - (blend - 0.5)); // soft light - non-commutative
                // color = blend <= 0.5 ? base * (2 * blend) : 1 - (1 - base) * (1 - 2 * (blend - 0.5)); // hard light - non-commutative
                // color = blend <= 0.5 ? base * (1 - 2 * blend) : 1 - (1 - base) / (2 * (blend - 0.5)); // vivid light - non-commutative
                // color = blend <= 0.5 ? base + 2 * blend - 1 : base + 2 * (blend - 0.5); // linear light - non-commutative
                // color = blend <= 0.5 ? min(base, 2 * blend) : max(base, 2 * (blend - 0.5)); // pin light - non-commutative

                // color = lerp(base, blend, 0.5); // linear interpolation






                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

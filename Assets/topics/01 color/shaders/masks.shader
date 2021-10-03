Shader "examples/week 1/masks"
{
    Properties
    {
        [NoScaleOffset] _tex1 ("texture one", 2D) = "white" {}
        [NoScaleOffset] _tex2 ("texture two", 2D) = "white" {}
        [NoScaleOffset] _tex3 ("texture three", 2D) = "white" {}
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

            uniform sampler2D _tex1;
            uniform sampler2D _tex2;
            uniform sampler2D _tex3;
            
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

                // sample the color data from each of the three textures and store them in float3 variables
                float3 t1 = tex2D(_tex1, uv).rgb;
                float3 t2 = tex2D(_tex2, uv).rgb;
                float3 mask = tex2D(_tex3, uv).rgb;

                float3 color = 0;

                color = t1*mask + (t2*(1-mask));

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

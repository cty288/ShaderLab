Shader "examples/week 11/depth"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _CameraDepthTexture;


            struct MeshData
            {
                float4 vertex : POSITION;
                
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float4 screenPos: TEXCOORD0;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;
                float2 screenUV = i.screenPos.xy / i.screenPos.w;

                float depth = tex2D(_CameraDepthTexture, screenUV);
                depth = Linear01Depth(depth);
                color = depth.rrr;


                return float4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    
}

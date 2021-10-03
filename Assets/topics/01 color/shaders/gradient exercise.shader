Shader "examples/week 1/gradient exercise"
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
                float3 color = 0;

                // add your code here
             


                float3 color1 = float3(1,0,0);
                float3 color2 = float3(0,1,0);
                float3 color3 = float3(0,0,1);
                float3 color4 = float3(1,1,1);
               

                float3 gradientX = lerp(color1, color2, uv.x);
                float3 gradientY = lerp(color3, color4, uv.y);
            
              

                color = (gradientX + gradientY) / 2;
                


                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

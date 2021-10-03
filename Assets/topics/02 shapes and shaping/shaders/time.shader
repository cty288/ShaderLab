Shader "examples/week 2/time"
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
                float3 colorA = float3(0.72, 0.04, 0.30);
                float3 colorB = float3(0.00, 0.57, 0.68);
                

                float4 time = _Time; // _Time is a built in unity shader variable. it gives you the time since level load (t/20, t, t*2, t*3)
                
                float l = 0.5;
                l = frac(time.y);
                
                l = (sin(2*time.y) + 1) / 2;
                //l = pow(l, 6);

                l = sin(time.y);
                l = ceil(l);

                float3 c = lerp(colorA, colorB, l);
                return float4(c, 1);
            }
            ENDCG
        }
    }
}

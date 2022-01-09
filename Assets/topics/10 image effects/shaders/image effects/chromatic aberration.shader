Shader "examples/week 10/chromatic aberration"
{
    Properties
    {
        _MainTex ("render texture", 2D) = "white"{}
        _Intensity("intensity", Range(0,1)) = 0.2
    }

    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #define MAX_OFFSET  0.15

            sampler2D _MainTex;
            float _Intensity;

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
                float3 color = 0;
                float2 uv = i.uv;

                float Offset = MAX_OFFSET * _Intensity;

                float r = tex2D(_MainTex, uv - Offset).r;
                float g = tex2D(_MainTex, uv).g;
                float b = tex2D(_MainTex, uv + Offset).b;

                color = float3(r,g,b);

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

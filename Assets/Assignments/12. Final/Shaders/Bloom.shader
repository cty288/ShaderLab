Shader "hw/final/bloom"
{
	Properties
	{
		_MainTex ("render texture", 2D) = "white"{}
		_Intensity("Bloom intensity", Range(0,1)) = 0.2

        _overallStrength("Overall strength", Range(0,1)) = 0.6

        _horizontalBlurStrength("Horizontal Blur Strength", Range(0,10)) = 1
		_verticalBlurStrength("Vertical Blur Strength", Range(0,10)) = 1

        _mixColor("Mixed Color", Color) = (1,1,1,1)
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
            #define MAX_OFFSET  1.5

            sampler2D _MainTex; float4 _MainTex_TexelSize;
            float _Intensity;
            float _horizontalBlurStrength;
            float _verticalBlurStrength;
            float3 _mixColor;
            float _overallStrength;
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


            float3 gaussian_blur(float2 uv){
                float2 blurOffset =  _MainTex_TexelSize.xy * float2(_horizontalBlurStrength, _verticalBlurStrength);

                float3 color = tex2D(_MainTex, uv) * 0.4;
                float3 s1 = tex2D(_MainTex, uv + blurOffset);
                float3 s2 = tex2D(_MainTex, uv + blurOffset * 2);
                float3 s3 = tex2D(_MainTex, uv + blurOffset * 3);
                float3 s4 = tex2D(_MainTex, uv - blurOffset);
                float3 s5 = tex2D(_MainTex, uv - blurOffset * 2);
                float3 s6 = tex2D(_MainTex, uv - blurOffset * 3);

                color += s1 * 0.05 + s2 *0.125 + s3 * 0.125 + s4 * 0.05 + s5 * 0.125 + s6*0.125;
                color = saturate(color);
                return color;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                
                float2 uv = i.uv;

                float Offset = MAX_OFFSET * _Intensity;

                float3 color = tex2D(_MainTex, uv);

                float3 s1 = tex2D(_MainTex, uv + _MainTex_TexelSize.xy * float2(Offset,Offset));
                float3 s2 = tex2D(_MainTex, uv + _MainTex_TexelSize.xy * float2(-Offset,-Offset));
                float3 s3 = tex2D(_MainTex, uv + _MainTex_TexelSize.xy * float2(Offset, - Offset));
                float3 s4 = tex2D(_MainTex, uv + _MainTex_TexelSize.xy * float2(-Offset, Offset));

                //get the brightest fragment between its neighbors
                color = max(color, s1);
                color = max(color, s2);
                color = max(color, s3);
                color = max(color, s4);

                //darker
                color = saturate(color - 1 + _Intensity);
                color += gaussian_blur(uv);
                color *= _mixColor * _overallStrength;

                color = saturate(color);

                return float4(color, 1.0);
            }
            ENDCG
		}
	}
}
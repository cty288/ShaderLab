Shader "hw/final/panel"
{
	Properties
	{
		_MainTex ("render texture", 2D) = "white"{}
		_InvFade ("Soft Particles Factor", Range(0.010000,3.000000)) = 1.000000
		_Color ("Tint", Color) = (1,1,1,1)
        _center("Distort center", vector) = (0.5,0.5,0,0)
	}

	SubShader
	{
		ZWrite Off
		Cull Off
		Blend One OneMinusSrcColor
		ColorMask RGB

		Tags { "QUEUE"="Transparent" "IGNOREPROJECTOR"="true" "RenderType"="Transparent" "PreviewType"="Plane" }
		
        GrabPass{
			"_BackgroundTex" 
		}
		
        Pass
		{
			CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
          

            sampler2D _MainTex; float4 _MainTex_TexelSize;
           
            float2 _center;
            float _Strength;
            float3 _Color;
            sampler2D _BackgroundTex; 
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
                

                float2 distortUV = uv;
                
                float2 dirToCenter = uv - _center;

                distortUV += _Strength * normalize(dirToCenter) * (1-length(dirToCenter)) * 0.5;

                float3 color = tex2D(_MainTex, distortUV);


                return float4(color, 1.0);
            }
            ENDCG
		}
	}
}
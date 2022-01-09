Shader "hw/hw11/xRay"
{
	Properties {
		_stencilRef("Stencil Reference", Int) = 1
       

       
	}

	SubShader
	{
		Tags{"Queue" = "Geometry+1" "IgnoreProjector"="True"}
        
		ZWrite Off
		ColorMask 0
		Cull Off
		Stencil{
			Ref [_stencilRef]
			Comp Always
			Pass Replace   
		}
        
		Pass
		{
			CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _BackgroundTex;
            float3 _color1;
            float3 _color2;
            float _transparency;
            
            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
               
                float3 color = 0;
               
                return float4(color, 1);
            }
            ENDCG
		}
	}
}
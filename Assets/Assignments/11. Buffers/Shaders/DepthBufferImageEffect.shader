Shader "hw/hw11/depthBufferImageEffect"
{
    Properties{
	    _MainTex ("render texture", 2D) = "white"{}
	    _stencilRef("Stencil Reference", Int) = 1

        _NearX("Near 01 depth", Range(0,1)) = 0.5
        _FarX("Far 01 depth", Range(0,1)) = 0.5

        _NearColor("Near Color", Color) = (1,1,1,1)
        _FarColor("Far Color", Color) = (1,1,1,1)

	    _laserInterval("laser Interval",Float) = 10
	    _laserSpeed("laser Speed",Float) = 15
        _width("Width", Range(0,1)) = 0.1
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

            sampler2D _CameraDepthTexture;
           
            sampler2D _MainTex;

            float _NearX;
            float _FarX;
              float _laserInterval;
            float _laserSpeed;
            float3 _NearColor;
            float3 _FarColor;
            float _width;
            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv: TEXCOORD0;
                
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float4 screenPos: TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = tex2D(_MainTex, i.uv);

                float depth = tex2D(_CameraDepthTexture, i.uv);
                depth = Linear01Depth(depth);
                //color = depth.rrr;

                float laserY = (1 - ((_Time.y % _laserInterval)* _laserSpeed));

                //skeleton
                if(depth >= _NearX && depth <=_FarX){
                    float distanceToLaser = abs(i.uv.y - laserY);
                    float lerpValue = smoothstep(_NearX, _FarX, depth);

                    if(distanceToLaser< _width){
                      
                       color *= lerp(_NearColor, _FarColor, lerpValue);
                    }else{
                       color *= depth * saturate((lerpValue + 0.5));
                    }

                 
                }

                return float4(color, 1.0);
            }
            ENDCG
		}
	}
	FallBack "Diffuse"
    
}
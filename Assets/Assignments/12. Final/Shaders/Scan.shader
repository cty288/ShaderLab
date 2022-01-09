Shader "hw/final/scan"
{
	Properties
	{
		_MainTex ("render texture", 2D) = "white"{}
	
        _scanLineWidth("Scan line Width", Float) = 2
       
        _scanLineColor("Scan Line Color", Color) = (0,0,1,1)
        _scanGradientBound("Scan Gradient", Vector) = (700,1500,0,0)
        _scanSpeed("Scan Speed", Float) = 1
        
	}

	SubShader
	{
		Cull Off
		ZWrite Off
		

		Pass
		{
			CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
          

            sampler2D _MainTex; float4 _MainTex_TexelSize;
            sampler2D _CameraDepthTexture;
            float4x4 _FragToWorldMatrix;
            float _scanSpeed;
            float3 _ScanPos;
            float _scanLineWidth;
            float3 _scanLineColor;
            float _scanLineGradient;
            float2 _scanGradientBound;
            float _scanRadius;

            
            

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


           float rand (float3 uv) {
                return frac(sin(dot(uv.xyz, float3(129.898, 78.233, 98.314))) * 4138.5453123);
            }


            float value_noise (float3 uv) {
                float3 ipos = floor(uv);
                float3 fpos = frac(uv); 
                
                float o  = rand(ipos);
                float x  = rand(ipos + float3(1, 0,0));
                float y  = rand(ipos + float3(0, 1, 0));
                float z = rand(ipos + float3(0,0,1));
                float xy = rand(ipos + float3(1, 1,0));
                float xz = rand(ipos + float3(1,0,1));
                float yz = rand(ipos + float3(0,1,1));
                float xyz = rand(ipos + float3(1,1,1));

                float3 smooth = smoothstep(0, 1, fpos);

                float3 lerp1 = lerp(lerp(o,  x, smooth.x), 
                             lerp(y, xy, smooth.x), smooth.y);

                float3 lerp2 = lerp(lerp(z,xz,smooth.x),
                lerp(yz,xyz,smooth.x),smooth.y);

                return lerp(lerp1, lerp2, smooth.z);
                }

             

            float4 frag (Interpolators i) : SV_Target
            {
                
                float2 uv = i.uv;
               
                float3 color = 0;
             
                color += tex2D(_MainTex, uv);
                
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
                
                
                #if defined(UNITY_REVERSED_Z)
                depth = 1 - depth;
                #endif
                
                //get the world position of the fragment from its depth Texture (from tutorial)
                float4 uv2 = float4(uv.x * 2 - 1, uv.y * 2 - 1, depth * 2 -1, 1);
                float4 worldPos = mul(_FragToWorldMatrix, uv2);
                worldPos /= worldPos.w;

                float disToClickPosition = length(_ScanPos - worldPos.xyz);

                _scanLineGradient = lerp(_scanGradientBound.x, _scanGradientBound.y,
                abs(sin(_Time.y * _scanSpeed)));
 
                float scan = 1 - saturate((abs((disToClickPosition - _scanRadius)) - _scanLineWidth) / _scanLineGradient);

               // scan = scan * internalFade.x;
                
                color = lerp(color, saturate(color + scan * _scanLineColor), scan);
               
                
                return float4(color, 1.0);
            }
            ENDCG
		}
	}
}
Shader "hw/final/traverse"
{
	Properties
	{
		_MainTex ("render texture", 2D) = "white"{}
		_SpaceshipRenderImage("Spaceship Render Image", 2D) = "white"{}
        _center("Distort center", Vector) = (0,0,0,0)
       
        _screenY("Screen Y Threshold", Float) = 0.2
        _particlePower("Particle Power", Float) = 1
        _particleDensity("Particle Density", Range(0,1)) = 0.25
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
          

            sampler2D _MainTex; float4 _MainTex_TexelSize;
            sampler2D _SpaceshipRenderImage;
            float2 _center;
            float _Strength;
            float _screenY;
            float _particlePower;

            float _particleDensity;
            #define COUNT 1

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
                float2 uv2 = uv;
                
              //  _center = float2(uv.x>0.5?1:0, 0.5);

                float2 dirToCenter = uv - _center;
                float3 color = 0;


                for(int j=0 ; j< COUNT; j++){
                    float2 tempUv = uv + _Strength * normalize(dirToCenter) * (1 - dirToCenter) ;
                    color += tex2D(_MainTex, tempUv);
                }
                
                color /= COUNT;
                

                float3 spaceshipColor = tex2D(_SpaceshipRenderImage, uv2);

                if(spaceshipColor.r > 0 && uv2.y <= _screenY){
                   if(spaceshipColor.b > 0 ){
                       color = spaceshipColor;
                   }else{
                       color += spaceshipColor;
                   }
                   //color = spaceshipColor;
                }else{
                   color += spaceshipColor;
                }


                float2 uv3 = i.uv;
                float2 uv4 = i.uv;
                
                float2 angleToCenter = normalize(uv3 - _center);
                uv3 -= angleToCenter * _Time.x * 20 * (_Strength + 0.1);

                float distToCenter = distance(uv3 , _center);
                float traverseNoise = value_noise(float3(angleToCenter.xy * 60,  distToCenter * 15));
                

                
                float3 traverseColor = traverseNoise > (1-_particleDensity) ? 1:0;

                traverseColor = float3(rand(float3(angleToCenter.xy * 50,-31)), 
                 rand(float3(angleToCenter.xy * 698,-49)), 
                 rand(float3(angleToCenter.xy * -412,-90)));


                traverseColor = pow(traverseColor, _particlePower);
                if(uv2.y >= _screenY && traverseNoise > (1- _particleDensity * _Strength - 0.03) ){
                    color += traverseColor;
                }
                
                color = saturate(color);

                return float4(color, 1.0);
            }
            ENDCG
		}
	}
}
Shader "hw/final/flare"
{
	Properties 
	{
		_color ("color", Color) = (1, 1, 1, 1)

        _scale("Scale", Float) = 1

        _power("Flare power", Float) = 3

        _center("Center", Vector) = (0,0,0,0)

		_flareNum ("Flare Number", Int) = 5
		_flareFreq ("Flare Freq", Range(0,10)) = 5
		_flareAmpRate("Flare Particle Rate", Range(0,1)) = 0.8
        _flareStrength("Flare Strength", Range(0,1)) = 0.5
        
	}
	SubShader
	{
		
		Tags {"Queue"="Transparent" "IgnoreProjector"="True"}
        
		GrabPass{
			"_BackgroundTex" 
		}

		ZWrite Off

		
		Blend SrcAlpha OneMinusSrcAlpha
	
		Pass
		{
			CGPROGRAM
           #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            #include "Lighting.cginc"

            float4 _color;
            float _power;
            float _scale;
            float3 _center;

            int _flareNum;
            float _flareFreq;
            float _flareAmpRate;
            float _flareStrength;
            sampler2D _BackgroundTex;
            float _flareLayerPower = 2;
            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };
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
            struct Interpolators
            {
                 float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 bitangent : TEXCOORD3;
                float3 posWorld : TEXCOORD4;
                float4 screenUV : TEXCOORD5;
                float3 objPos : TEXCOORD6;
            };

            float particleNoise(float3 pos, int num, float freq, float ampRate, float time){
               
               float result = 0;
               float amp = 1; 
               float maxAmp = 0;

               for(int i=0; i<num; i++){
                   result += value_noise((pos + (time / 10)) * freq) * amp;
                   maxAmp += amp;
                   freq *=2 ;
                   amp *= ampRate;
               }

               return result / maxAmp;
            
            }
            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.uv = v.uv;
                
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldNormal(v.tangent);
                o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;
                
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.screenUV = ComputeGrabScreenPos(o.vertex);

                o.posWorld = mul(unity_ObjectToWorld, v.vertex);

                o.objPos = v.vertex;
                
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                uv = uv*2-1;

                float2 screenUV = i.screenUV.xy / i.screenUV.w;
                float3 background = tex2D(_BackgroundTex, screenUV);
                
                float3 pos = i.objPos * _scale;

                float3 distort = float3(value_noise(pos * _flareFreq + _Time.x),
                value_noise(pos + 1000 * _flareFreq  + _Time.x),
                value_noise(pos + 2000 * _flareFreq + _Time.x));

                float3 dirToCenter = normalize(pos - _center + distort * 0.25);
                
                float time = _Time.y/4 - length(pos);
                pos += particleNoise(dirToCenter,_flareNum,_flareFreq,_flareAmpRate, time) * _flareStrength;

                float flare = length(pos);

                //change size
                _flareLayerPower = (sin(_Time.x * 5)/2) + 1.7;
                flare = (1/(pow(flare,_flareLayerPower))) *0.6;

                
                flare = pow(flare, _power);
               // flare *= value_noise(pos);

                float3 color = flare * _color;
                float opacity = 1 - min(abs(length(uv)),1);
                
                color = lerp(color, background, 1 - opacity);
                
                return float4(color, opacity);
            }
            ENDCG
		}
	}
	FallBack "Diffuse"
}
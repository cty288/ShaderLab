Shader "hw/hw9/skybox"
{
	Properties 
	{
		_colorHigh ("color high", Color) = (1, 1, 1, 1)
		_colorLow ("color low", Color) = (0, 0, 0, 1)
        _colorNormal("normal sky color", Color) = (0,0,0,1)
		_offset ("sky height offset", Range(0, 1)) = 0
		_contrast ("sky color contrast", Float) = 1
        _upperSkyHeight("Upper Sky Height",Float)=1
        _lowerSkyHeight("LowerSkyHeight",Float)=1

        _skyboxMinimumHeight("Skybox Minimum Height", Range(-1,1)) =0

        _starColor("star color",Color) = (1,1,1,1)
        _starDensity("star density", Range(0,0.01)) = 0.01
        _starSize("star distribution", Range(0,1)) = 1
        _starRotationSpeed("Star rotation speed", Range(0,1))=0.5

        _cloudColor("Cloud color", Color) = (1,1,1,1)
        _cloudIntensity("Cloud Intensity", Range(0,1)) = 0.2
        _cloudRotationSpeed("Cloud rotation speed", Range(0,1))=0.5

        _moonColor("Moon color", Color) = (1,1,0,1)
        _moonRadius("Moon Radius", Range(0,10)) = 0.1
        _moonCoord("Moon coordinate", Vector) =(0,0,0,0)

		_auroraStrength("Aurora Intensity", Range(0,1)) = 0.5
        _auroraColor1 ("Aurora Color 1", Color) = (1,1,1,1)
        _auroraColor2 ("Aurora Color 2", Color) = (1,1,1,1)

	}

	SubShader
	{
		Tags { 
			"Queue" = "Background" "RenderType" = "Background" "PreviewType" = "Skybox"
		}
		Cull off
		ZWrite off

		Pass
		{
			CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #define SPECULAR_MIP_STEPS 4

            float3 _colorHigh;
            float3 _colorLow;
            float3 _colorNormal;
            float _offset;
            float _contrast;
            float _upperSkyHeight;
            float _lowerSkyHeight;
            float3 _starColor;
            float _starDensity;
            float _starSize;
            float _starRotationSpeed;
            float _cloudRotationSpeed;
            float _skyboxMinimumHeight;

            float3 _cloudColor;
            float _cloudIntensity;

            float3 _moonColor;
            float _moonRadius;
            float4 _moonCoord;

            float _gloss;
            float _reflectivity;
            float _fresnelPower;

            float _auroraInensity;
            float3 _auroraColor1;
            float3 _auroraColor2;
            float _auroraStrength;
            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 uv : TEXCOORD0;
                 float3 normal : TEXCOORD1;
                float3 posWorld : TEXCOORD2;
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


            float rand2 (float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float value_noise2 (float2 uv) {
                float2 ipos = floor(uv);
                float2 fpos = frac(uv); 
                
                float o  = rand2(ipos);
                float x  = rand2(ipos + float2(1, 0));
                float y  = rand2(ipos + float2(0, 1));
                float xy = rand2(ipos + float2(1, 1));

                float2 smooth = smoothstep(0, 1, fpos);
                return lerp( lerp(o,  x, smooth.x), 
                             lerp(y, xy, smooth.x), smooth.y);
            }

            float cloud_noise(float3 uv){
                float result = 0 ;
                float amp = 0.5;

                for(int j=0; j<5; j++){
                    result += amp * value_noise(uv);
                    uv *= 2;
                    amp *= 0.5;

                }

                return result;
            
            }

           

            float aurora_noise(float3 uv){
              float amp = 10;
              float result =0;
              for(int j=0; j<5; j++){
                  result = amp * value_noise2(uv.xz);
                  amp/=2;
                  uv *= 1.1;
              }

              return result;
            
            }


            float3x3 rotation_matrix (float3 axis, float angle) {
                axis = normalize(axis);
                float s = sin(angle);
                float c = cos(angle);
                float oc = 1.0 - c;
                
                return float3x3(
                    oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,

                    oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,

                    oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c);
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;

                float3 uv = i.uv;
                float3 starUV = uv * (1-_starSize) * 500;

                float lerpNum = 0;

                if(uv.y>=0){
                    lerpNum = smoothstep(_offset, _offset + _upperSkyHeight, uv.y); 
                    color = lerp(_colorNormal, _colorHigh, lerpNum);
                }else{
                    lerpNum = smoothstep(-_offset, -_lowerSkyHeight-_offset, uv.y);
                    color = lerp(_colorNormal, _colorLow, lerpNum);
                }

                color = pow(color, _contrast);

                //star rotation
                float3x3 rotationMatrix = rotation_matrix(float3(0,0,1), -_Time.x * _starRotationSpeed);
                starUV = floor(mul(starUV , rotationMatrix));
                 
                 //star
                float starNoise = value_noise(starUV) * rand(starUV) ;

                if(starNoise>= 1- _starDensity && uv.y >= _skyboxMinimumHeight){
                   

                    float3 starColor = starNoise * _starColor;
                    color = lerp(color, starColor, 0.8);
                }


                //cloud
                float3 cloudUV = uv * 5;
                
                cloudUV.xz += _Time.y * _cloudRotationSpeed;
                //vertical cloud
                float cloudNoise = cloud_noise(float3(cloudUV.x,0,cloudUV.z));
                
                if(uv.y >= _skyboxMinimumHeight){
                    color += cloudNoise * _cloudIntensity * lerp(0.5,1,uv.y) * _cloudColor;
                }
                
                //moon
               float moon = distance(uv, _moonCoord.xyz);
               moon = 1 - (moon / _moonRadius);
               moon = saturate(moon * 40);
               color += moon * _moonColor;

               //aurora
               float aurora = aurora_noise(uv*3);
              
               if(uv.y >=_skyboxMinimumHeight){
                  _auroraInensity = lerp(0.1, 0.7, abs(cos(_Time.x))) * _auroraStrength;
                  float3 c = lerp(_auroraColor1, _auroraColor2, sin(uv.x *5 + 1.2 *_Time.y)); 
                  float3 auroraColor = aurora * _auroraInensity * c;
                  auroraColor = lerp(auroraColor,0, uv.y);
                  color += auroraColor;
               }
              
                color = saturate(color);

              
                return float4(color, 1.0);
            }
            ENDCG
		}
	}
}
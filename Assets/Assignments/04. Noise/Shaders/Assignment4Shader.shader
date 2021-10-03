Shader "examples/hw/hw4"
{
	Properties{
		_tex("texture",2D) = "black"{}
		
	}

        SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float _scale;
            sampler2D _tex;
            

            float rand(float2 uv) {
                return frac(sin(dot(uv.xy, float2(31.145, 78.233))) * 314159.265358);
            }

            float value_noise(float2 uv) {
                float2 ipos = floor(uv);
                float2 fpos = frac(uv);

                float o = rand(ipos);
                float x = rand(ipos + float2(1, 0));
                float y = rand(ipos + float2(0, 1));
                float xy = rand(ipos + float2(1, 1));

                float2 smooth = smoothstep(0, 1, fpos);
                return lerp(lerp(o,  x, smooth.x),
                             lerp(y, xy, smooth.x), smooth.y);
            }



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

            Interpolators vert(MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float2 uv = i.uv * 20;
                
                float time = _Time.y * 10;
                
                //2 uvs for 2 different uv transformations
                float2 uv1 = uv - time * float2(0.0, 0.5);
                float2 uv2 = uv - time * float2(0.0, 1.0);
                
                float4 color = 0;

                float fn = 0;

                
                fn += value_noise(uv1);
                fn += value_noise(uv2);
                

                //add contrast
                fn = pow(fn, 4);

               
                //fn = uv.y < 5 ? fn : lerp(fn, 1, smoothstep(5,8,uv.y));
                
                //dynamically change the overall size of the fire
                float size = (sin(time/10) + 1.3) / 2;
                
                //Only show fire at the bottom of the screen
                fn =2.5 *  uv.y / 20 + 
                    fn * pow(uv.y, 2) * size / pow((10 - distance(uv.x,10)),2); //fire near the middle of the screen burns higher

                fn = 1 - fn;

                //add color and color contrast
                fn = pow(fn, 3);

                color = fn>0 ? lerp(float4(240.0/255, 0, 25.0/255,1), float4(1, 220.0/255, 0,1), pow(fn,1.5)) : fn;

                //add texture to background
                float4 textureColor = tex2D(_tex, i.uv);

               
                //burn effect
                float burnNoise = 0.0;
                float offset = 1.8;

                for (int i = 0; i < 9; i++) {
                    burnNoise += value_noise(offset * uv/4) / offset;
                    offset *= 2;
                }

                float time2 = frac(_Time.x*2);
                
                //fade by time. Fragment with a larger noise will fade later. 
                textureColor *= smoothstep(time2, time2 + 0.15, burnNoise);
                

                color = fn > 0 ? color :  textureColor;

                return float4(color);
            }
            ENDCG
        }
    }
}

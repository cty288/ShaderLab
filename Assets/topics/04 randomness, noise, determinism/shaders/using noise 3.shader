Shader "examples/week 4/using noise 3"
{
    Properties
    {
        _tex ("texture", 2D) = "white" {}
        _scale ("noise scale", Range(2, 800)) = 50
        _speed ("speed", Range(0, 10)) = 1
        _contrast ("contrast", Range(1, 30)) = 25
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _tex;
            float _scale;
            float _speed;
            float _contrast;

            float rand (float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float noise (float2 uv) {
                float2 ipos = floor(uv);
                float2 fpos = frac(uv); 
                
                float o  = rand(ipos);
                float x  = rand(ipos + float2(1, 0));
                float y  = rand(ipos + float2(0, 1));
                float xy = rand(ipos + float2(1, 1));

                float2 smooth = smoothstep(0, 1, fpos);
                return lerp( lerp(o,  x, smooth.x), 
                             lerp(y, xy, smooth.x), smooth.y);
            }

            float fractal_noise (float2 uv) {
                float n = 0;
                // fractal noise is created by adding together "octaves" of a noise
                // an octave is another noise value that is half the amplitude and double the frequency of the previously added noise
                // below the uv is multiplied by a value double the previous. multiplying the uv changes the "frequency" or scale of the noise becuase it scales the underlying grid that is used to create the value noise
                // the noise result from each line is multiplied by a value half of the previous value to change the "amplitude" or intensity or just how much that noise contributes to the overall resulting fractal noise.

                n  = (1 / 2.0)  * noise( uv * 1);
                n += (1 / 4.0)  * noise( uv * 2); 
                n += (1 / 8.0)  * noise( uv * 4); 
                n += (1 / 16.0) * noise( uv * 8);
                
                return n;
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

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {   
                // create a variable for our uvs
                float2 uv = i.uv;

                // create a separate uv variable we'll use as our coordinates to sample noise
                float2 nUV = uv * _scale;

                // create discrete lines by rounding value
                nUV.y = floor(nUV.y);
                
                // the x component we'll use to sample the noise will change over time
                nUV.x = _Time.y * _speed;

                // sample fractal noise using nUV
                float fn = fractal_noise(nUV);

                // modify the uvs we'll use to sample the texture using the fractal noise
                uv += float2(pow(fn, _contrast), 0);

                // sample the texture
                float3 color = tex2D(_tex, uv);

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

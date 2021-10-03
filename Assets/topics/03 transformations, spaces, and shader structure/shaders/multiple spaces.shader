Shader "examples/week 3/multiple spaces"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

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

            //  Function from Iñigo Quiles
            //  https://www.shadertoy.com/view/MsS3Wc
            float3 hsb2rgb( in float3 c ){
                float3 rgb = saturate(abs((c.x*6.0+float3(0.0,4.0,2.0) %
                                        6.0)-3.0)-1.0);
                rgb = rgb*rgb*(3.0-2.0*rgb);
                return c.z * lerp(float3(1, 1, 1), rgb, c.y);
            }

            float rectangle (float2 uv, float2 scale) {
                float2 s = scale * 0.5;
                float2 shaper = float2(step(-s.x, uv.x), step(-s.y, uv.y));
                shaper *= float2(1-step(s.x, uv.x), 1-step(s.y, uv.y));
                return shaper.x * shaper.y;
            }

            float2x2 rotate2D (float angle) {
                return float2x2 (
                    cos(angle), -sin(angle),
                    sin(angle),  cos(angle)
                );
            }

            #define PI  3.14159265
            #define TAU 6.28318531

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv * 2 - 1;
                float time = _Time.z;
            
                // number of shapes
                int count = 8;
                
                // initialize a color that we will add to as we create rectangles
                float3 color = float3(0, 0, 0);

                for(int i = 0; i < count; i++) {
                    // make a copy of the uv coordinates to modify in our for loop
                    float2 newUV = uv; 
                    
                    // create an offset driven by time and the iteration we're currently drawing. 
                    float offset = pow(smoothstep(0, 1, frac((time + i * 0.085) * 0.1)), 4);
            
                    // handle translating the uv space
                    float2 translate = float2(0, 0);
                    translate.x += sin(offset * TAU); // translating x by sin of our offset
                    translate.y += cos(offset * TAU); // translating y by cos of our offset
                    translate *= 0.33; // scaling translate magnitude
                    
                    newUV += translate; // apply translation to uv space
                    
                    float angle = PI * offset; // our offset goes between 0 - 1. multiplying by PI gives us a half a rotation in radians
                    newUV = mul(newUV, rotate2D(angle)); // apply rotation to uv space
                    
                    // creating a rectangle with our uniquely transformed uv space
                    float newRect = rectangle(newUV, float2(0.4, 0.4 * 1.618)); 
                    
                    // again using offset to drive change in color of our rectangle
                    float colorOffset = sin(offset * TAU) * 0.1;

                    // create our color using HSB color space (hue, saturation, brightness)
                    float3 col = hsb2rgb(float3(colorOffset, 0.8, 0.15)); 
                    
                    // multiply our shape (white in rectangle, black outside) by our color so that the color is only present inside the rectangle
                    col *= newRect;

                    // add our color for this iteration of a rectangle to the total color we'll output from the shader. saturate() makes sure the value is clamped between 0 - 1
                    color = saturate(color + col); 
                }

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

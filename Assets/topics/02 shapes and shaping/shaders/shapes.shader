Shader "examples/week 2/shapes"
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

            float circle(float cutoff, float2 uv) {
                return step(cutoff, 1 - length(uv));
            }

            float4 frag (Interpolators i) : SV_Target
            {
                //-1 ~ 1
                float2 uv = i.uv * 2 - 1;
                float shape = 0;
               
                
                //circle
               // shape = floor(length(uv));
                shape = step(sin(_Time.y) * 0.5 + 0.5, 1 - length(uv));
                shape = circle(0.5, uv);
                //return float4(shape,shape,shape, 1.0);


                //rectangle
                float2 size = float2(0.2, 0.5);
                float2 shaper;
                shaper = float2(step(-size.x, uv.x), step(-size.y, uv.y));
                shaper *= float2(1 - step(size.x, uv.x), 1 - step(size.y, uv.y));
                shape = shaper.x * shaper.y;
               
               

                return float4(shape, shape, shape, 1.0);
            }
            ENDCG
        }
    }
}

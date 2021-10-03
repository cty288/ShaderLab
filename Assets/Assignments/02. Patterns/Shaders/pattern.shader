Shader "examples/hw2/shader"
{
   
    SubShader
    {
        Tags { "RenderType" = "Opaque" }



        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #define PI 3.14159265358
           
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

            float circle(float cutoff, float2 uv) {
                return step(cutoff, 1 - length(uv));
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float output = 0;
                float gridSize = 90;

                float2 uv = i.uv;
                uv = uv * gridSize;


                float2 gridUV = frac(uv) * 2 - 1;
                
                float index = round(sqrt(pow(uv.x - gridSize / 2, 2) + pow(uv.y - gridSize / 2, 2)));

            
                float num =((_Time.z * 90) % (gridSize*7));
                float num2 = 0;

                if (num >= 0 && num <= (gridSize * 7)/2) {
                    num2 = num;
                }
                else {
                    num2 = (gridSize * 7)/2 - round(num / 2);
                }

                //change in each grid
                float2 polarGridUV = float2((atan2(gridUV.y, gridUV.x) / (PI * 2)) , length(gridUV));
                

                int currentCycle = num2 / 3;
               
                if (index>3 &&(index % currentCycle >= 0 && index % currentCycle<=3)) {
                    float3 color = float3(1, pow(sin(index),2), pow(cos(index),3));
                    output = step(polarGridUV.y,index / (gridSize/2));
                 
                    color *= output;
                    
                    color = polarGridUV.y > index / (gridSize/2) ? float4(sin(_Time.y), frac(log(_Time.y)), pow(cos(_Time.y), 3), 1.0) : color;
                    //change color
                    return float4(color, 1.0);
                }
                else {
                   
                    return float4(sin(_Time.y), frac(log(_Time.y)), pow(cos(_Time.y),3), 1.0);
                }
                
            
             }
             ENDCG
		}
	}
}
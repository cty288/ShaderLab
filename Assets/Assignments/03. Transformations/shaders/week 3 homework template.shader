Shader "examples/week 3/homework template"
{
    Properties 
    {
	    
        _totalSecInYear("_totalSecInYear", Float) = 0
       
        _bg("bg", 2D) = "white" {}
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

            #define TAU 6.28318530718
            #define PI 3.14159265358

            
            float _totalSecInYear;

          

            float3 _colors[8];
            float _initialRotations[8];
            float _size[8];
            float _radius[8];

            float _degreePerSec[8];

            uniform sampler2D _bg;
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

            float3 circle(float2 uv, float2 pos, float radius, float3 color,float2 uv2) {
                float cir = length(pos - uv) - radius;
                cir = step(cir,1);
                return float3(color * cir);
            }

            float3 circleUnfilled(float2 uv, float2 pos, float radius, float3 color,float2 uv2) {
                float cir = length(pos - uv) - radius;
                cir = step(cir, 1);

                float3 innerCircle =1 - circle(uv, pos, radius - 1, float3(1,1,1),uv2);

                return float3(color * cir * innerCircle);
            }

           

            float2x2 rotate2D(float angle) {
                return float2x2 (
                    cos(angle), -sin(angle),
                    sin(angle), cos(angle)
                    );
            }

            void init() {
                _colors[0] = float3(0.49804, 0.45098, 0.42745);
                _colors[1] = float3(0.85882,  0.63529,  0.11765);
                _colors[2] = float3(0.09412, 0.43529, 0.85882);
                _colors[3] = float3(0.85882, 0.31373,  0.00000);
                _colors[4] = float3(0.67843, 0.51765,  0.00000);
                _colors[5] = float3(1.00000,  0.80784,  0.47843);
                _colors[6] = float3(0.00000,  0.98039,  1.00000);
                _colors[7] = float3(0.00000,  0.20000,  1.00000);

                _initialRotations[0] = 0;
                _initialRotations[1] = 130;
                _initialRotations[2] = 280;
                _initialRotations[3] = 43;
                _initialRotations[4] = 18;
                _initialRotations[5] = 75;
                _initialRotations[6] = 340;
                _initialRotations[7] = 225;

                _size[0] = 1;
                _size[1] = 2.48;
                _size[2] = 2.61;
                _size[3] = 1.39;
                _size[4] = 30;
                _size[5] = 30;
                _size[6] = 15;
                _size[7] = 15;

                _radius[0] = 40;
                _radius[1] = 52;
                _radius[2] = 64;
                _radius[3] = 76;
                _radius[4] = 120;
                _radius[5] = 170;
                _radius[6] = 250;
                _radius[7] = 320;

                _degreePerSec[0] = 0.0000463;
                _degreePerSec[1] = 0.00001984126;
                _degreePerSec[2] = 0.00001141552;
                _degreePerSec[3] = 0.00000603864;
                _degreePerSec[4] = 9.78090767e-7;
                _degreePerSec[5] = 3.92341494e-7;
                _degreePerSec[6] = 1.37650039e-7;
                _degreePerSec[7] = 7.01813486e-8;
            }

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag(Interpolators interpolator) : SV_Target
            {
                //initialize
                init();
         
                float2 uv = interpolator.uv * 2 - 1;
                uv *= 200;
                float time = _Time.x*3;

                float3 color=0; 

                float2 scale = 0;
                scale.x = sin(2 * time) -1.5;
                scale.y = sin(2 * time) -1.5;
                uv *= scale;

                //sun change color
                color = circle(uv, float2(0, 0), 40, float3(1, 0.8* sin(time/1000), 0), interpolator.uv);
               
                
                
                for (int i = 0; i < 8; i++) {
                    float2 newUV = uv;
                    newUV.x *= 0.9;

              
                    
                    float angle = (_initialRotations[i] + _totalSecInYear * _degreePerSec[i]) * (PI/180);
                    newUV = mul(rotate2D(angle), newUV);

                    float radius = sqrt(2 * pow(_radius[i], 2));
                    float3 outline = circleUnfilled(newUV, float2(0,0), radius, float3(0.27,0.27,0.27), interpolator.uv);
                    
                    

                    color += outline;
                    color += circle(newUV, float2(_radius[i], _radius[i]), _size[i], float3(_colors[i]), interpolator.uv);
                    
                    
                }
                
                //add bg
                color += length(color)<=0.1? tex2D(_bg, interpolator.uv).rgb:0;
                return float4(color, 1);
                //return float4(_hour/24, _minute/60, _second/60, 1.0);
            }
            ENDCG
        }
    }
}

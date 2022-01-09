Shader "hw/hw11/interface"
{
	Properties {
		_stencilRef("Stencil Reference", Int) = 1
        _color1("Blend Color1", COLOR) = (1,1,1,1)
        _color2("Blend Color2", Color) = (1,1,1,1)
        _transparency("Transparency", Float) = 0.3

        _gridSize("Grid Size", Float) = 100
        _gridWidth("Grid Width", Float) = 1
        _gridColor("Grid Color", Color) = (1,1,1,1)

		_laserInterval("laser Interval",Float) = 10
		_laserSpeed("laser Speed",Float) = 15
		_laserPower("laser Power",Float) = 1
        _laserColor("laser color", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags{"Queue" = "Geometry-1" "IgnoreProjector"="True"}
        Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off

		GrabPass{
			"_BackgroundTex" 
		}
		//SColorMask 0
       
		Stencil{
			Ref [_stencilRef]
			Comp Always
			Pass Replace   
		}
        
		Pass
		{
			CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _BackgroundTex;
            float3 _color1;
            float3 _color2;
            float _transparency;
            float _gridSize;
            float _gridWidth;
            float3 _gridColor;

             float _laserInterval;
            float _laserSpeed;
            float _laserPower;
            float3 _laserColor;
            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
               
                float3 color = 0;
                float transparency = _transparency;

                //grid
                if(fmod(uv.x, _gridSize) < _gridWidth || fmod(uv.y, _gridSize)  < _gridWidth){
                    color = _gridColor;
                    transparency = lerp(0.2,0.5, sin(_Time.y));
                }else{
                    float centerX = 0.5;
                    float distenceToCenter = abs(uv.x- centerX);
                    float lerpV = 1- smoothstep(0, centerX, distenceToCenter);
                    color += lerp(_color1, _color2, lerpV);
                }

                
                float laser = 0;
                
                float laserY = (1 - ((_Time.y % _laserInterval)* _laserSpeed));

                float distanceToLaser = abs(uv.y - laserY);
                laser = 1- smoothstep(0,0.03,distanceToLaser);
                
                laser = pow(laser, _laserPower);
                color += laser * _laserColor;

                if(laser>0){
                    transparency = lerp(_transparency,1, laser);
                }
                return float4(color, transparency);
            }
            ENDCG
		}
	}
}
Shader "hw/splash"
{
	Properties
	{
		_color("color", Color) = (1, 1, 1, 1)
		_fogSize("Splash Size",Range(0,0.1)) =0
		_displacement("displacement", Range(0, 0.1)) = 0.05
		_seed("Seed",float) = 124749179
		_fogSmooth("Splash Smooth", Range(10,200)) = 10

	
	}
	SubShader
	{
		// tags here set the render queue to happen with transparencies
		// and the ignore projector tag is set to true. projectors will project a material to objects in a frustrum, but don't work with transparent objects
		Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "LightMode" = "ForwardBase"}

		// this line prevents this object from writing to the depth buffer
		// the depth buffer is used internally for culling fragments that are obstructed from view by other objects
		// this assumes opaque geometry and so you don't write transparent objects to the depth buffer in most cases
		ZWrite Off

		// blend command and blend mode information in unity's shaderlab:
		// https://docs.unity3d.com/Manual/SL-Blend.html
		// this blend mode creates standard opacity effect
		Blend SrcAlpha OneMinusSrcAlpha
		// Blend One One // additive
		// Blend DstColor Zero // multiplicative
		GrabPass{
			"_BackgroundTex"
		}

		Pass
		{
			

			CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
			 #include "Lighting.cginc"

			#define MAX_SPECULAR_POWER 256
            float4 _color;
	        float _fogSize;	
			float _displacement;
			float _seed;
			float _fogSmooth;

			
            struct MeshData
            {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 uv : TEXCOORD0;
            };

			float rand(float2 uv) {
				return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
			}

			float value_noise(float2 uv) {
				float2 ipos = floor(uv);
				float2 fpos = frac(uv);

				float o = rand(ipos);
				float x = rand(ipos + float2(1, 0));
				float y = rand(ipos + float2(0, 1));
				float xy = rand(ipos + float2(1, 1));

				float2 smooth = smoothstep(0, 1, fpos);
				return lerp(lerp(o, x, smooth.x),
					lerp(y, xy, smooth.x), smooth.y);
			}


			float3 rand_vec(float3 pos, float seed) {
				pos.x += _seed / 4;
				pos.y += _seed / rand(_seed);
				pos.z += rand(_seed) * pos.x;


				return normalize(float3(rand(pos.xz) * 2 - 1, rand(pos.yx) * 2 - 1, rand(pos.zy) * 2 - 1));
			}

            struct Interpolators
            {
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 tangent : TEXCOORD2;
				float3 bitangent: TEXCOORD3;
				float3 worldPos : TEXCOORD4;
				float4 screenUV : TEXCOORD5;
            };

			float4x4 rotation_matrix(float3 axis, float angle) {
				axis = normalize(axis);
				float s = sin(angle);
				float c = cos(angle);
				float oc = 1.0 - c;

				return float4x4(
					oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s, 0.0,
					oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s, 0.0,
					oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c, 0.0,
					0.0, 0.0, 0.0, 1.0);
			}

            Interpolators vert(MeshData v)
            {
                Interpolators o;

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex);

				v.vertex.xyz += float3(v.normal.x* (value_noise(float2(_Time.z/5, worldPos.z)*4-2)), 
					abs(v.normal.y),
					v.normal.z * (value_noise(float2(_Time.y / 5, 13241))+1)/2)
					* abs(value_noise(v.uv * _fogSmooth)) * _fogSize;

				float timeSeed = _seed + _Time.z;
				float3 rVec = rand_vec(v.vertex.xyz + round(_Time.y), timeSeed);

				v.vertex.xyz += (value_noise(worldPos*10*_Time.y / 60)*2-1) * _displacement;

				//v.vertex = mul(rotation_matrix(float3(0, 1, 0), _Time.y),v.vertex);
				v.vertex.y += cos(_Time.y) * 0.003;
			
				
				o.vertex = UnityObjectToClipPos(v.vertex);
					
				
                return o;
            }

			

			float4 frag(Interpolators i) : SV_Target
			{
				float2 uv = i.uv;
				uv.y += rand(uv * _Time.x) * _Time.y;


				float4 color = _color;

				
				color.rgba *= (rand(uv*50*sin(_Time.z))+1.5)/2;
				
				return color;
            }
            ENDCG
		}
	}
	
}
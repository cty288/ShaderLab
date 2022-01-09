Shader "examples/week 12/normals and lighting for ray marching"
{
    Properties {
        _smoothness ("shape blend smoothness", Range(0.001,1)) = 0.2
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #define MAX_STEPS 100
            #define MAX_DIST 100
            #define MIN_DIST 0.001

            float _smoothness;

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 hitPos : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.hitPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.uv;
                return o;
            }

            float sdf_sphere (float3 spherePos, float radius, float3 pos) {
                return distance(spherePos, pos) - radius;
            }


            float sdBoxFrame( float3 p, float3 b, float e )
{
  p = abs(p  )-b;
  float3 q = abs(p+e)-e;
  return min(min(
      length(max(float3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(float3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(float3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}

             // vertical
float sdCylinder( float3 p, float2 h )
{
    float2 d = abs(float2(length(p.xz),p.y)) - h;
    return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

            // a substitute for our min function that smoothly blends primitives together
            float smin ( float a, float b) {
                // k is smoothness factor
                float k = _smoothness;
                float h = max( k-abs(a-b), 0.0 )/k;
                return min( a, b ) - h*h*h*k*(1.0/6.0);
            }

            float get_dist (float3 pos) {
                // this defines the scene
                float t = _Time.y;

                const int objectCount = 6;
                float distances[objectCount];
                distances[0] = sdf_sphere(float3(sin(t), -cos(t), 0) * 0.8, 0.75, pos);
                distances[1] = sdf_sphere(float3(0, -sin(t), cos(t)) * 0.7, 0.6, pos);
                distances[2] = sdCylinder(float3(0.8,0,1), float2(0.2,0.2));

                distances[3] = sdf_sphere(float3(-sin(t), cos(t), 0) * 0.48, 0.75, pos);
                distances[4] = sdf_sphere(float3(0, sin(t), -cos(t)) * 0.28, 0.6, pos);
                distances[5] = sdf_sphere(pow(float3(cos(t), sin(t), -cos(t)), 10) * 0.65, 0.5, pos);
                
                float m = MAX_DIST;
                for(int i = 0; i < objectCount; i++) {
                    m = smin(m, distances[i]);
                }

                return m;
            }

            float3 get_normal(float3 pos){
                float disAtPos = get_dist(pos);
                float sampleDelta = 0.01;
                float3 sampleVec = float3(
                   get_dist(pos + float3(sampleDelta,0,0)),
                   get_dist(pos + float3(0,sampleDelta,0)),
                   get_dist(pos + float3(0,0,sampleDelta))
                );
                float3 normal = normalize(sampleVec - disAtPos);
                return normal;

            }


            float ray_march (float3 rayOrigin, float3 rayDir) {
                // keep track of the total distance we've traveled
                float marchDist = 0;

                for(int i = 0; i < MAX_STEPS; i++) {
                    // our current position
                    float3 pos = rayOrigin + rayDir * marchDist;

                    // our current distance to the closest point in the scene
                    float distToSurf = get_dist(pos);

                    // add this distance to our accumulated march distance
                    marchDist += distToSurf;

                    // break out of loop if we are at the surface or go too far
                    if (distToSurf < MIN_DIST || marchDist > MAX_DIST) break;
                }

                return marchDist;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;
                float3 normal = float3(0,1,0);

                float3 camPos = _WorldSpaceCameraPos;
                float3 rayDir = normalize(i.hitPos - camPos);
                float d = ray_march(camPos, rayDir);

                normal = get_normal(camPos + rayDir * d);

                // half lambert lighting
                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0;

                float diffuseFalloff = max(0, dot(normal, lightDirection));
                float halfLambert = pow(diffuseFalloff * 0.5 + 0.5, 2);
                float3 diffuse = halfLambert * lightColor;

                // constrain lighting values to distances that are less than max (only where we hit something)
                diffuse *= 1-step(MAX_DIST, d);

                color = diffuse;
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

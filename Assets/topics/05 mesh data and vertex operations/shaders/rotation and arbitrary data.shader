Shader "examples/week 5/rotation and arbitrary data"
{
    Properties
    {
        _rotX ("x rotation", Range(-2,2)) = 0
        _rotY ("y rotation", Range(-2,2)) = 0
        _rotZ ("z rotation", Range(-2,2)) = 0
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

            float _rotX;
            float _rotY;
            float _rotZ;

            struct MeshData
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            float4x4 rotation_matrix (float3 axis, float angle) {
                axis = normalize(axis);
                float s = sin(angle);
                float c = cos(angle);
                float oc = 1.0 - c;
                
                return float4x4(
                    oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                    oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                    oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                    0.0,                                0.0,                                0.0,                                1.0);
            }

            Interpolators vert (MeshData v)
            {
                Interpolators o;

                // set vertex color
                o.color = v.color;

                float4x4 x = rotation_matrix(float3(1, 0, 0), _rotX * TAU * o.color.r);
                float4x4 y = rotation_matrix(float3(0, 1, 0), _rotY * TAU * o.color.r);
                float4x4 z = rotation_matrix(float3(0, 0, 1), _rotZ * TAU * o.color.r);

                float4x4 rotation = mul(mul(x, y), z);

                v.vertex = mul(rotation, v.vertex);

                o.vertex = UnityObjectToClipPos(v.vertex);
                
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                return float4(i.color.rgb, 1.0);
            }
            ENDCG
        }
    }
}

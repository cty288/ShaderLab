Shader "examples/week 7/lambert"
{
    Properties
    {
        _surfaceColor("Surface Color",Color) = (1,1,1,1)
    }
        SubShader
    {
        Tags {
            "LightMode" = "ForwardBase"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"


            float3 _surfaceColor;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;
                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0;
               
                    //normalize(float3(1, 1, 1));

                float falloff =max(0, dot(normalize(i.normal), lightDirection));

                color = falloff * _LightColor0 * _surfaceColor;

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

Shader "examples/week 5/cube to sphere"
{
    Properties
    {
        _radius ("radius", Float) = 5
        _morph ("morph", Range(0,1)) = 0
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

            float _radius;
            float _morph;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.normal = v.normal;

                float3 sphere = normalize(v.vertex.xyz) * _radius;
                
                v.vertex.xyz = lerp(v.vertex.xyz, sphere, _morph);
                o.vertex = UnityObjectToClipPos(v.vertex);

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                return float4(abs(i.normal.rgb), 1.0);
            }
            ENDCG
        }
    }
}

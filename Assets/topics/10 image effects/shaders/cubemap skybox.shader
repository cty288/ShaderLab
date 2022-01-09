Shader "examples/week 10/textured skybox"
{
    Properties 
    {
       [NoScaleOffset] _texCube ("texture", Cube) = "black" {}
       _mip ("mip level", Range(0, 12)) = 0
    }

    SubShader
    {
        // these tags tell unity to render 
        Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
        Cull Off
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            #define TAU 6.28318530718

            samplerCUBE _texCube;
            float _mip;

            struct MeshData
            {
                float4 vertex : POSITION;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 objPos : TEXCOORD0;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.objPos = v.vertex.xyz;

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;
                color = texCUBElod(_texCube, float4(i.objPos, _mip));

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

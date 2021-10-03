Shader "examples/week 1/hello shader"
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
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
            };

            
            Interpolators vert (MeshData v)  //run on vertex
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }
            

            float4 frag (Interpolators i) : SV_Target {  //fragment
                return float4(0, 0, 0, 1.0);
            }
            ENDCG
        }
    }
}

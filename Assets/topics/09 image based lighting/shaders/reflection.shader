Shader "examples/week 9/reflection"
{
    Properties 
    {
        //[NoScaleOffset] _IBL ("IBL cube map", Cube) = "black" {}
        
        // smoothness of surface - sharpness of reflection
        _gloss ("gloss", Range(0,1)) = 1

        _reflectivity("reflectivity", Range(0,1)) = 1
    }
    SubShader
    {
        // this tag is required to use _LightColor0
        Tags { "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #define SPECULAR_MIP_STEP 4

            // might be UnityLightingCommon.cginc for later versions of unity
            #include "Lighting.cginc"


            //samplerCUBE _IBL;
            float _gloss;
            float _reflectivity;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 posWorld : TEXCOORD2;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.uv = v.uv;

                o.normal = UnityObjectToWorldNormal(v.normal);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                
                return o;
            }

            float4 frag (Interpolators i) : SV_Target{
                float3 color = 0;
                float2 uv = i.uv;
                float3 normal = i.normal;
                 
                float3 viewDirection = -normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
                float3 viewReflection = reflect(viewDirection,normal);
                        

                float mip = (1-_gloss) * SPECULAR_MIP_STEP;
                //float3 indirectSpecular = texCUBElod(_IBL,float4(viewReflection,mip)) * _reflectivity;
                float3 indirectSpecular = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, viewReflection, mip )
                *_reflectivity;
               

                color = indirectSpecular;
                
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

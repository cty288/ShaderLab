Shader "examples/week 8/transparency"
{
    Properties 
    {
        _color ("color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        // tags here set the render queue to happen with transparencies
        // and the ignore projector tag is set to true. projectors will project a material to objects in a frustrum, but don't work with transparent objects
        Tags {"Queue"="Transparent" "IgnoreProjector"="True"}
        
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
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float4 _color;

            struct MeshData
            {
                float4 vertex : POSITION;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                return _color;
            }
            ENDCG
        }
    }
}

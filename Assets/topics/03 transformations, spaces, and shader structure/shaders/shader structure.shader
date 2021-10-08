// our shader. some of this is a unity language called "ShaderLab" The code in between "CGPROGRAM" and "ENDCG" is normal shader code (in this case CG or HLSL)
Shader "examples/week 3/shader structure"
{
    // this is how you declare properties which are just values that get exposed to be edited in a material (like global variables in you c# scripts)
    Properties 
    {
        // property template:
        // variable name  ("text description", type) = (default value)
        _Color ("a color", Color) = (1, 1, 1, 1)
        _Texture ("a texture", 2D) = "white" {}
        _Float ("a number", Float) = 1
        _Range ("a range", Range(0, 1)) = 0.5
        _Vector ("a vector", Vector) = (1, 1, 1, 1)
    }
    

    // shaders can contain more than one SubShader, but unless you're doing way more advanced stuff targeting different capabilities of different GPU hardware, you'll only need one.
    SubShader
    {

        // you will often see tags here. using tags in a meaningful way is outside of the scope of this class. your shader will work without a tag. if you want to learn more you can here: https://docs.unity3d.com/Manual/SL-SubShaderTags.html
        // Tags { "RenderType"="Opaque" }


        // each SubShader can have one or more passes. a pass executes its own vertex and fragment shaders so adding another pass alows you to do some other process on top of one you just did. we'll write a shader that uses 2 passes simply once we talk about stencil buffers.
        Pass
        {
            CGPROGRAM
            #pragma vertex vert      // defines what our vertex shader is called (vert) so the gpu knows what to execute
            #pragma fragment frag    // defines what our fragment shader is called (frag) so the gpu knows what to execute
            #include "UnityCG.cginc" // this is a way of including outside code to be accessible inside the shader. UnityCG.cginc holds many essential unity functions

            // defining our properties and variables in the shader
            float4 _Color;
            float4 _Texture;
            float _Float;
            float _Range;
            float4 _Vector;
            
            // a struct used to define what data we'll use from the mesh
            struct MeshData
            {
                float4 vertex : POSITION; // vertex position input
                float3 normal : NORMAL;   // vertex normal input
                float4 color : COLOR;     // vertex color input
                float2 uv0 : TEXCOORD0;   // vertex uv0 input
                float2 uv1 : TEXCOORD1;   // vertex uv1 input
            };

            // a struct used to define what data we're passing from the vertex shader to the fragment shader
            // these outputs from the vertex shader get interpolated across the face of the triangle
            struct Interpolators
            {
                float4 vertex : SV_POSITION; // clip space position output
                float3 normal : TEXCOORD0;   // TEXCOORDn is a high precision variable. there is a limit to the number of these you can have depending on target hardware. you can safely use up to 8 for most all hardware.
                float4 color : TEXCOORD1;
                float2 uv0 : TEXCOORD2;
                float2 uv1 : TEXCOORD3;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex); // transforms object space vertex position to clip space position. UnityObjectToClipPos() is code that we get by using UnityCG.cginc
                return o;
            }

            float4 frag (Interpolators i) : SV_Target // SV_Target is a shader semantic that is referring to a render target
            {
                return _Color;
            }
            ENDCG
        }
    }
}

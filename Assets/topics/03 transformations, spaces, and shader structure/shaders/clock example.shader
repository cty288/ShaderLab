Shader "examples/week 3/clock example"
{
    Properties 
    {
        _hour ("hour", Float) = 0
        _minute ("minute", Float) = 0
        _second ("second", Float) = 0
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

            float _hour;
            float _minute;
            float _second;

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv * 2 - 1;
                float time = _Time.z;

                // converting our coordinates from cartesian to polar.
                // dividing by TAU converts the range that atan2() outputs from -PI, PI to -0.5, 0.5
                // adding 0.5 changes the range to 0 - 1 so we can now set our angle based on a percent
                float polar = (atan2(uv.y, uv.x) / TAU) + 0.5;
                
                // creating a copy of our polar coordinate system to modify to render the hour hand
                float hA = polar;
                // here is where we add our percent rotation to our coordinates based on the _hour value we're getting sent to the shader from the c# script. adding 0.25 at the end just makes sure that the starting point for the rotation is at the "12 o-clock" position
                hA = frac(hA + (_hour / 12) + 0.25);

                float mA = polar;
                mA = frac(mA + (_minute / 60) + 0.25);

                float sA = polar;
                sA = frac(sA + (_second / 60) + 0.25);
                
                // blending the values by adding them together with differing weights
                float3 color = (hA * 0.433) + (mA * 0.333) + (sA * 0.233);
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}

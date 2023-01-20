Shader "Volumetric/Test"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "black"
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "RenderPipeline" = "UniversalPipeline" }

        ZWrite On
        ZTest LEqual

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}

            Cull Off

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            sampler2D _MainTex;

            struct Attributes
            {
                float4 position: POSITION;
                float2 texcoord     : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS: SV_POSITION;
                float4 uv: TEXCOORD0;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = TransformObjectToHClip(input.position.xyz);
                output.uv.xy = input.texcoord;
                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float test = 1-tex2D(_MainTex, input.uv.xy).r;// - 0.5;//input.uv.x;
                return half4(test, -test, 0, 1);
            }
            ENDHLSL
        }
    }
}
Shader "Volumetric/BlitShadowMap"
{
    Properties
    {
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Overlay" "RenderPipeline" = "UniversalPipeline" }

        ZTest Always

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}

            Blend One Zero
            Cull Off

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Utils.hlsl"

            sampler2D _CameraDepthTexture;

            struct Attributes
            {
                float4 position: POSITION;
                float2 texcoord: TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS: SV_POSITION;
                float4 uv: TEXCOORD0;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                output.positionCS = float4(input.texcoord * 2 - 1, 0, 1);
                output.uv.xy = float2(input.texcoord.x, 1 - input.texcoord.y);

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float depth = tex2D(_CameraDepthTexture, input.uv.xy).r;
                depth = Linear01Depth(depth, _ZBufferParams);
                return half4(depth,0,0,1);
                // float depth = tex2D(_CameraDepthTexture, input.uv.xy).r;
                half4 encode = EncodeFloatRGBA(clamp(depth, 0.0001, 0.9999));
                return encode;
                // depth = DecodeFloatRGBA(encode);
            }

            ENDHLSL
        }
    }
}
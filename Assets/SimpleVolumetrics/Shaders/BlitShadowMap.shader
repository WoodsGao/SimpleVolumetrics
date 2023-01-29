Shader "Volumetric/BlitShadowMap"
{
    Properties
    {
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Overlay" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}

            Cull Off
            ZTest Always

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            sampler2D _CameraDepthTexture;

            struct Attributes
            {
                float4 position: POSITION;
                float2 texcoord: TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS: SV_POSITION;
                float2 screenPos: TEXCOORD0;
                float3 viewDirVS: TEXCOORD1;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                output.positionCS = float4(input.texcoord * 2 - 1, 0, 1);
                output.screenPos = float2(input.texcoord.x, 1 - input.texcoord.y);

                // NDC position
                float2 ndcPos = output.screenPos * 2 - 1;

                // Camera parameter
                float far = _ProjectionParams.z;

                // View space vector pointing to the far plane
                float3 clipVec = float3(ndcPos.x, ndcPos.y, 1.0) * far;
                output.viewDirVS = mul(unity_CameraInvProjection, clipVec.xyzz).xyz;
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float depth = tex2D(_CameraDepthTexture, input.screenPos).r;
                depth = Linear01Depth(depth, _ZBufferParams);
                depth *= length(input.viewDirVS);

                return half4(depth * 0.001,0,0,0);
            }

            ENDHLSL
        }
    }
}
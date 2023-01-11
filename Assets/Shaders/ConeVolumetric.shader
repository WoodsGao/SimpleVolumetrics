Shader "Volumetric/ConeVolumetric"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _NoiseFactor("Noise Factor", Float) = 1.0
        _Speed("Noise Speed", Float) = 1.0
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent+101" "RenderPipeline" = "UniversalPipeline" }

        Blend One One
        // Blend SrcAlpha OneMinusSrcAlpha
        ZWrite On
        ZTest LEqual

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}

            Cull Front

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Noise3D.hlsl"

            struct Attributes
            {
                float4 position: POSITION;
                // float2 texcoord     : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS: SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
                float4 positionWS: TEXCOORD0;
                float4 viewDir: TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half _NoiseFactor;
                half _Speed;
            CBUFFER_END

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.positionCS = TransformObjectToHClip(input.position.xyz);
                output.positionWS = float4(TransformObjectToWorld(input.position.xyz), 1);
                output.viewDir = output.positionCS / output.positionCS.w * 0.5 + 0.5;
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                // Returning the _BaseColor value.
                half noise = GetNoise3D(input.positionWS.xyz * _NoiseFactor + _Time.x * _Speed);
                noise = noise * 0.5 + 0.5;
                return half4(noise, noise, noise, 1);

            }
            ENDHLSL
        }
    }
}
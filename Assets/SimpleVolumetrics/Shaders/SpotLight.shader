Shader "Volumetric/SpotLight"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _NoiseFactor("Noise Factor", Float) = 1.0
        _Speed("Noise Speed", Float) = 1.0
        _EdgeContrast("EdgeContrast", Float) = 1
        _Intensity("Intensity", Float) = 1
        _ShadowMap("Shadow Map", Cube) = "black"
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent+101" "RenderPipeline" = "UniversalPipeline" }

        BlendOp Add
        Blend One One
        ZWrite Off
        ZTest LEqual

        Pass
        {
            Tags{"LightMode" = "SRPDefaultUnlit"}
            Cull Front


            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma multi_compile _ VOLUMETRIC_SHADOW_ON
            #pragma multi_compile _ VOLUMETRIC_SPOT_LIGHT

            #include "Volumetric.hlsl"

            ENDHLSL
        }

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}
            Cull Back


            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma multi_compile _ VOLUMETRIC_SHADOW_ON
            #pragma multi_compile _ VOLUMETRIC_SPOT_LIGHT

            #include "Volumetric.hlsl"

            ENDHLSL
        }
    }
}
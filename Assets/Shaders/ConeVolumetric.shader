Shader "Volumetric/ConeVolumetric"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _NoiseFactor("Noise Factor", Float) = 1.0
        _Speed("Noise Speed", Float) = 1.0
        _Angle("Angle", Float) = 90
        _Range("Range", Float) = 10
        _ShadowMap("Shadow Map", 2D) = "black"
        _ShadowMapZBufferParams("Shadow Map ZBuffer Params", Vector) = (0, 0, 0, 0)
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent+101" "RenderPipeline" = "UniversalPipeline" }

        // Blend One One
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite On
        ZTest LEqual

        // Pass
        // {
            //     Tags{"LightMode" = "SRPDefaultUnlit"}

            //     Cull Front

            //     HLSLPROGRAM

            //     #pragma vertex vert
            //     #pragma fragment frag
            
            //     //--------------------------------------
            //     // GPU Instancing
            //     #pragma multi_compile_instancing
            //     #pragma multi_compile _ DOTS_INSTANCING_ON

            //     #include "ConeVolumetric.hlsl"

            //     ENDHLSL
        // }

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

            #include "ConeVolumetric.hlsl"

            ENDHLSL
        }
    }
}
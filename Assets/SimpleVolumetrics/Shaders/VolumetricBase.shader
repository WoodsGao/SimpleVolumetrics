Shader "Volumetric/VolumetricBase"
{
    Properties
    {
        [Header(Base)]
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [PowerSlider(2.0)]_Intensity("Intensity", Range(0, 100)) = 1
        
        [Header(Noise)]
        _NoiseDensity("Noise Density", Range(0, 10)) = 1.0
        _NoiseSpeed("Noise Speed", Range(0, 10)) = 1.0

        [Header(Shadow)]
        [VolumetricShadow] _SHADOW("Shadow", Float) = 0
        [PowerSlider(2.0)] _EdgeContrast("EdgeContrast", Range(0, 100)) = 1
        [NoScaleOffset]_ShadowMap("Shadow Map", Cube) = "white" {}

        [Header(Cast vertex to floor)]
        [Toggle(VOLUMETRIC_CAST_TO_FLOOR_ON)] _CAST_TO_FLOOR("Cast To Floor", Float) = 0
        _FloorHeight("Floor Height", Float) = 0.001

        [Header(VAT)]
        [Toggle(VOLUMETRIC_VAT_ON)] _VAT("Vertex Animation", Float) = 0
        _VATDensity("VAT Density", Range(0, 10)) = 1.0
        _VATScale("VAT Scale", Range(0, 10)) = 1.0
        _VATSpeed("VAT Speed", Range(0, 10)) = 1.0

        [Header(Macros)]
        [KeywordEnum(Fog, SpotLight, PointLight)] Volumetric_Type("VolumetricType", int) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendFactor ("Src Blend Factor", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendFactor ("Dst Blend Factor", Float) = 10
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent+101" "RenderPipeline" = "UniversalPipeline" }

        Blend [_SrcBlendFactor] [_DstBlendFactor]
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

            #pragma multi_compile _ VOLUMETRIC_CAST_TO_FLOOR_ON
            #pragma multi_compile _ VOLUMETRIC_SHADOW_ON
            #pragma multi_compile _ VOLUMETRIC_VAT_ON
            #pragma multi_compile VOLUMETRIC_TYPE_FOG VOLUMETRIC_TYPE_SPOTLIGHT VOLUMETRIC_TYPE_POINTLIGHT

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

            #pragma multi_compile _ VOLUMETRIC_CAST_TO_FLOOR_ON
            #pragma multi_compile _ VOLUMETRIC_SHADOW_ON
            #pragma multi_compile _ VOLUMETRIC_VAT_ON
            #pragma multi_compile VOLUMETRIC_TYPE_FOG VOLUMETRIC_TYPE_SPOTLIGHT VOLUMETRIC_TYPE_POINTLIGHT

            #include "Volumetric.hlsl"
            ENDHLSL
        }
    }
}
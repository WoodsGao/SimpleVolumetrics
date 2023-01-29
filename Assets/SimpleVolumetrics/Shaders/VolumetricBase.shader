Shader "Volumetric/VolumetricBase"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _NoiseFactor("Noise Factor", Float) = 1.0
        _Speed("Noise Speed", Float) = 1.0
        _EdgeContrast("EdgeContrast", Float) = 1
        _Intensity("Intensity", Float) = 1
        _Range("Range", Float) = 1
        _Angle("Angle", Float) = 1
        _ShadowMap("Shadow Map", Cube) = "black"
        [Toggle(VOLUMETRIC_SPOT_LIGHT)]_SpotLight("SpotLight", int) = 0
        [Toggle(VOLUMETRIC_POINT_LIGHT)]_PointLight("PointLight", int) = 0
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent+101" "RenderPipeline" = "UniversalPipeline" }

        Blend One One
        ZWrite Off
        ZTest LEqual

        Pass
        {
            Tags{"LightMode" = "SRPDefaultUnlit"}
            Cull Front

            HLSLPROGRAM
            #include "Volumetric.hlsl"
            ENDHLSL
        }

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}
            Cull Back

            HLSLPROGRAM
            #include "Volumetric.hlsl"
            ENDHLSL
        }
    }
}
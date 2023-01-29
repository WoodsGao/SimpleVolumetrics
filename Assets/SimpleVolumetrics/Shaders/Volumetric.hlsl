#ifndef WOODS_VOLUMETRIC_SPOTLIGHT
#define WOODS_VOLUMETRIC_SPOTLIGHT

#pragma vertex vert
#pragma fragment frag

//--------------------------------------
// GPU Instancing
#pragma multi_compile_instancing
#pragma multi_compile _ DOTS_INSTANCING_ON

#pragma multi_compile _ VOLUMETRIC_SHADOW_ON
#pragma multi_compile _ VOLUMETRIC_SPOT_LIGHT
#pragma multi_compile _ VOLUMETRIC_POINT_LIGHT

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Noise3D.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _BaseColor;
    float _NoiseFactor;
    float _Speed;
    float _EdgeContrast;
    float _Intensity;
#if VOLUMETRIC_SPOT_LIGHT || VOLUMETRIC_POINT_LIGHT
    float _Range;
#endif
#if VOLUMETRIC_SPOT_LIGHT
    float _Angle;
#endif
CBUFFER_END

samplerCUBE _ShadowMap;

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
    // ShadowMap Space
    float3 positionSS: TEXCOORD0;
    float4 noiseCoord: TEXCOORD1;
};

Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    half3 position = input.position.xyz;
#if VOLUMETRIC_POINT_LIGHT
    position *= _Range * 2;
#endif
#if VOLUMETRIC_SPOT_LIGHT
    position *= _Range;
    position.xy = normalize(position.xy) * step(0.1, length(position.xy)) * _Angle * abs(position.z);
#endif

    output.positionCS = TransformObjectToHClip(position);
    half3 positionWS = TransformObjectToWorld(position);
    output.noiseCoord.xyz = normalize(positionWS - _WorldSpaceCameraPos) * 0.1;
    output.noiseCoord.xyz += positionWS.xyz + 1000;
    output.noiseCoord.xyz = output.noiseCoord.xyz * _NoiseFactor + _Time.x * _Speed;
    output.positionSS = TransformObjectToWorld(position) - TransformObjectToWorld(half3(0,0,0));
    return output;
}

float4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float rayLength = length(input.positionSS);
    float intensity = exp2(-rayLength * rayLength / _Intensity / _Intensity);

#if VOLUMETRIC_SHADOW_ON
    float3 viewDir = -normalize(input.positionSS);
    float depth = texCUBE(_ShadowMap, viewDir);
    depth *= 1000;
    float distance = max(0, depth - rayLength);
    // return half4(distance, -distance, 0, 1);

    intensity *= 1 - exp2(- distance * distance * _EdgeContrast * _EdgeContrast);
#endif

    float noise = GetNoise3D(input.noiseCoord.xyz);
    noise = noise * 0.5 + 0.5;
    half4 color = half4(_BaseColor.xyz, 1) * _BaseColor.a;
    color *= noise * intensity;

    return color;
}

#endif
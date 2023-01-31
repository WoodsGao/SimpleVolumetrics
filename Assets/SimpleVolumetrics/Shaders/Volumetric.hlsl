#ifndef WOODS_VOLUMETRIC_SPOTLIGHT
#define WOODS_VOLUMETRIC_SPOTLIGHT

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Noise3D.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _BaseColor;
    float _NoiseDensity;
    float _NoiseSpeed;
    float _EdgeContrast;
    float _Intensity;

    float _FloorHeight;

    float _VATDensity;
    float _VATScale;
    float _VATSpeed;

    float _Range;
    float _Angle;
CBUFFER_END

samplerCUBE _ShadowMap;

struct Attributes
{
    float4 position: POSITION;
    float3 normal: NORMAL;
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

#if VOLUMETRIC_TYPE_POINTLIGHT
    position *= _Range * 2;
#endif
#if VOLUMETRIC_TYPE_SPOTLIGHT
    position *= _Range;
    position.xy = normalize(position.xy) * step(0.1, length(position.xy)) * _Angle * abs(position.z);
#endif

    half3 positionWS = TransformObjectToWorld(position);

#if VOLUMETRIC_CAST_TO_FLOOR_ON
    positionWS.y = max(_FloorHeight, positionWS.y);
    position = TransformWorldToObject(positionWS);
#endif

#if VOLUMETRIC_VAT_ON
    float noise = GetNoise3D(position*_VATDensity + 1000 + _Time.x * _VATSpeed);
    half3 offsetDir = input.normal;
    noise *= _VATScale;
    #if VOLUMETRIC_CAST_TO_FLOOR_ON
        noise *= step(_FloorHeight, positionWS.y);
        offsetDir *= saturate((positionWS.y - _FloorHeight)/ _VATScale);
    #endif
    position += offsetDir * noise;
    positionWS = TransformObjectToWorld(position);
#endif

    output.positionCS = TransformObjectToHClip(position);
    output.noiseCoord.xyz = normalize(positionWS - _WorldSpaceCameraPos) * 0.1;
    output.noiseCoord.xyz += position.xyz + 1000;
    output.noiseCoord.xyz = output.noiseCoord.xyz * _NoiseDensity + _Time.x * _NoiseSpeed;
    output.positionSS = TransformObjectToWorld(position) - TransformObjectToWorld(half3(0,0,0));
    return output;
}

float4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float rayLength = length(input.positionSS);
#if VOLUMETRIC_TYPE_FOG
    float intensity = _Intensity;
#else
    float intensity = exp2(-rayLength * rayLength / _Intensity);
#endif

#if VOLUMETRIC_SHADOW_ON
    float3 viewDir = -normalize(input.positionSS);
    float depth = texCUBE(_ShadowMap, viewDir);
    depth *= 1000;
    float distance = max(0, depth - rayLength);
    // return half4(distance, -distance, 0, 1);

    intensity *= 1 - exp2(- distance * distance * _EdgeContrast);
#endif

    float noise = GetNoise3D(input.noiseCoord.xyz);
    noise = noise * 0.5 + 0.5;
    half4 color = half4(_BaseColor.xyz, 1) * _BaseColor.a;
    color *= noise * intensity;

    return color;
}

#endif
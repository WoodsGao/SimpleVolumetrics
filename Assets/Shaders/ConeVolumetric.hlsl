#ifndef WOODS_CONEVOLUMETRIC
#define WOODS_CONEVOLUMETRIC

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Noise3D.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _BaseColor;
    float _NoiseFactor;
    float _Speed;
    float _EdgeContrast;
    float _Intensity;
    float4x4 _ShadowMapProjectMatrix;
CBUFFER_END

sampler2D _ShadowMap;

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
    // Spot Light View Space
    float4 positionVS: TEXCOORD0;
    float4 noiseCoord: TEXCOORD1;
};

Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.positionCS = TransformObjectToHClip(input.position.xyz);
    output.positionVS = float4(input.position.xyz, 1);
    output.positionVS.z = -output.positionVS.z;
    float3 positionWS = TransformObjectToWorld(input.position.xyz);
    output.noiseCoord.xyz = normalize(positionWS - _WorldSpaceCameraPos) * 0.1;
    output.noiseCoord.xyz += positionWS.xyz + 1000;
    output.noiseCoord.xyz = output.noiseCoord.xyz * _NoiseFactor + _Time.x * _Speed;
    return output;
}

float4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float rayLength = -input.positionVS.z;
    float intensity = exp2(-rayLength * rayLength / _Intensity);

#if VOLUMETRIC_SHADOW_ON
    // some vertex are out of frastum, so it has to be calculated in fragment
    float4 shadowMapCoord = mul(_ShadowMapProjectMatrix, input.positionVS);
    shadowMapCoord /= shadowMapCoord.w;
    shadowMapCoord *= 0.5;
    shadowMapCoord += 0.5;

    float depth = tex2D(_ShadowMap, shadowMapCoord.xy);
    // return half4(depth, -depth, 0, 1);
    depth *= 100;
    float distance = depth - rayLength;

    intensity *= 1 - exp2(- distance * distance * _EdgeContrast);
#endif

    float noise = GetNoise3D(input.noiseCoord.xyz);
    noise = noise * 0.5 + 0.5;
    float3 color = _BaseColor.xyz * _BaseColor.a;
    color *= noise * intensity;

    return float4(color, 1);
}

#endif
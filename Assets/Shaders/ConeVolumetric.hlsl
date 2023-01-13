#ifndef WOODS_CONEVOLUMETRIC
#define WOODS_CONEVOLUMETRIC

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Utils.hlsl"
#include "Noise3D.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _BaseColor;
    float _NoiseFactor;
    float _Speed;
    float _Angle;
    float _Range;
    float4 _ShadowMapZBufferParams;
    float4x4 _ShadowMapViewMatrix;
    float4x4 _ShadowMapProjectMatrix;
CBUFFER_END

sampler2D _ShadowMap;

struct Attributes
{
    float4 position: POSITION;
    // float2 texcoord     : TEXCOORD0;
    // UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS: SV_POSITION;
    // UNITY_VERTEX_INPUT_INSTANCE_ID
    // UNITY_VERTEX_OUTPUT_STEREO
    float4 positionWS: TEXCOORD0;
    float4 viewDir: TEXCOORD1;
    // Spot Light View Space
    float4 positionLVS: TEXCOORD2;
    // Spot Light NDC Coord
    float4 positionLNDC: TEXCOORD3;
};

Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;
    // UNITY_SETUP_INSTANCE_ID(input);
    // UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.positionCS = TransformObjectToHClip(input.position.xyz);
    output.positionWS = float4(TransformObjectToWorld(input.position.xyz), 1);
    output.viewDir.xyz = output.positionWS.xyz - _WorldSpaceCameraPos;

    output.positionLVS = mul(_ShadowMapViewMatrix, output.positionWS);
    return output;
}

float4 frag(Varyings input) : SV_Target
{
    // UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    // some vertex are out of frastum, so it has to be calculated in fragment
    float4 shadowMapCoord = mul(_ShadowMapProjectMatrix, input.positionWS);
    shadowMapCoord /= shadowMapCoord.w;
    shadowMapCoord *= 0.5;
    shadowMapCoord += 0.5;
    return float4(shadowMapCoord.xyz,1);

    // float depth = DecodeFloatRGBA(tex2D(_ShadowMap, shadowMapCoord.xy));
    float depth = tex2D(_ShadowMap, shadowMapCoord.xy).r;
    // depth *= _Range;

    float rayLength = shadowMapCoord.z;
    float distance = depth - rayLength;
    float intensity = saturate(distance);

    float noise = GetNoise3D((input.positionWS.xyz + input.viewDir.xyz + 10) * _NoiseFactor + _Time.x * _Speed);
    noise = noise * 0.5 + 0.5;
    float3 color = _BaseColor.xyz * _BaseColor.a;
    color *= noise * intensity;

    return float4(color, 1);
}

#endif
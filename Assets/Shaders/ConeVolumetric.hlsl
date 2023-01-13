#ifndef WOODS_CONEVOLUMETRIC
#define WOODS_CONEVOLUMETRIC

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Utils.hlsl"
#include "Noise3D.hlsl"

CBUFFER_START(UnityPerMaterial)
    half4 _BaseColor;
    half _NoiseFactor;
    half _Speed;
    half _Angle;
    half _Range;
    half4 _ShadowMapZBufferParams;
    half4x4 _ShadowMapViewMatrix;
    half4x4 _ShadowMapProjectMatrix;
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
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.positionCS = TransformObjectToHClip(input.position.xyz);
    output.positionWS = float4(TransformObjectToWorld(input.position.xyz), 1);
    output.viewDir.xyz = output.positionWS.xyz - _WorldSpaceCameraPos;

    output.positionLVS = mul(_ShadowMapViewMatrix, output.positionWS);
    return output;
}

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    // some vertex are out of frastum, so it has to be calculated in fragment
    half4 shadowMapCoord = mul(_ShadowMapProjectMatrix, input.positionLVS);
    shadowMapCoord = shadowMapCoord / shadowMapCoord.w * 0.5 + 0.5;

    // float depth = DecodeFloatRGBA(tex2D(_ShadowMap, shadowMapCoord.xy));
    float depth = tex2D(_ShadowMap, shadowMapCoord.xy).r;
    // depth *= _Range;

    float rayLength = -input.positionLVS.z;
    float distance = depth - rayLength;
    float intensity = saturate(distance);
    return half4(depth * _Range - rayLength,0,0,1);

    half noise = GetNoise3D((input.positionWS.xyz + input.viewDir.xyz + 10) * _NoiseFactor + _Time.x * _Speed);
    noise = noise * 0.5 + 0.5;
    half3 color = _BaseColor.xyz * _BaseColor.a;
    color *= noise * intensity;

    return half4(color, 1);
}

#endif
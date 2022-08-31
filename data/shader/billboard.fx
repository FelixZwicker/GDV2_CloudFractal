
cbuffer VSConstantBuffer : register(b0)
{
    float4   m_VSConstant0;
    float4   m_VSConstant1;
    float4x4 m_VSConstant2;
}

#define c_VSViewPosition         m_VSConstant0.xyz
#define c_VSBillboardPosition    m_VSConstant1.xyz
#define c_VSViewProjectionMatrix m_VSConstant2

struct VSInput
{
    float2 m_Position : POSITION;
};

struct PSInput
{
    float4 m_Position : SV_POSITION;
};

PSInput VSMain(VSInput _Input)
{
    float3 BillboardNormal   = c_VSViewPosition - c_VSBillboardPosition;    // z-axis
    float3 BillboardBinormal = float3(0.0f, 1.0f, 0.0);                     // y-axis
    float3 BillboardTangent  = cross(BillboardNormal, BillboardBinormal);

    BillboardTangent = normalize(BillboardTangent);
    BillboardNormal  = normalize(BillboardNormal);

    float3x3 BillboardMatrix = float3x3(BillboardTangent, BillboardBinormal, BillboardNormal);

    //                  Translation             Rotation          XY          Z
    float3 WSPosition = c_VSBillboardPosition + mul(float3(_Input.m_Position, 0.0f), BillboardMatrix);
    float4 CSPosition = mul(float4(WSPosition, 1.0f), c_VSViewProjectionMatrix);

    PSInput Result;

    Result.m_Position = CSPosition;

    return Result;
}

float4 PSMain(PSInput _Input) : SV_TARGET
{
    return 1;
}
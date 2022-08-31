cbuffer vertexBuffer : register(b0)
{
	float4x4 constant01;
};
#define g_ScreenMatrix constant01

cbuffer pixelBuffer : register(b0)
{
	float4 constant02;
};
#define g_Time			g_PSConstant01.x
#define g_Resolution	g_PSConstant01.yz

struct VSInput
{
	float3 m_Position : POSITION;
};

struct PSInput
{
	float4 m_Position : SV_POSITION;
};

float3 palette(float d) {
    return mix(float3(0.2, 0.7, 0.9), float3(1., 0., 1.), d);
}

float2 rotate(float2 p, float a) {
    float c = cos(a);
    float s = sin(a);
    return p * c + p * s + p * -s + p * c);
}

float map(float3 p) {
    for (int i = 0; i < 8; ++i) {
        float t = g_Time * 0.2;
        p.xz = rotate(p.xz, t);
        p.xy = rotate(p.xy, t * 1.89);
        p.xz = abs(p.xz);
        p.xz -= .5;
    }
    return dot(sign(p), p) / 5.;
}

float4 rm(float3 ro, float3 rd) {
    float t = 0.;
    float3 col = float3(0.);
    float d;
    for (float i = 0.; i < 64.; i++) {
        float3 p = ro + rd * t;
        d = map(p) * .5;
        if (d < 0.02) {
            break;
        }
        if (d > 100.) {
            break;
        }
        //col+=float3(0.6,0.8,0.8)/(400.*(d));
        col += palette(length(p) * .1) / (400. * (d));
        t += d;
    }
    return float4(col, 1. / (d * 100.));
}

PSInput VSShader(VSInput _Input)
{
    float4 WSPosition;

    PSInput Output = (PSInput)0;

    Output.m_Position = mul(float4(_Input.m_Position, 1.0f), g_ScreenMatrix);

    return Output;
}

float4 PSShader(PSInput _Input) : SV_Target
{
    float2 uv = (_Input.m_Position.xy - (g_Resolution.xy / 2.)) / g_Resolution.x;
    float3 ro = float3(0., 0., -50.);
    ro.xz = rotate(ro.xz, g_Time);
    float3 cf = normalize(-ro);
    float3 cs = normalize(cross(cf, float3(0., 1., 0.)));
    float3 cu = normalize(cross(cf, cs));

    float3 uuv = ro + cf * 3. + uv.x * cs + uv.y * cu;

    float3 rd = normalize(uuv - ro);

    float4 col = rm(ro, rd);

    return col;
}



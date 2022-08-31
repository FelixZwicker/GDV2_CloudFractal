#define AA 0

cbuffer VSBuffer : register(b0)
{
	float4x4 ScreenMatrix;
};

cbuffer PSBuffer : register(b0)
{
	float4 PSConstant;
};

#define TIME		PSConstant.x
#define RESOLUTION	PSConstant.yz

struct VSInput
{
	float3 position : POSITION;
};

struct PSInput
{
	float4 position : SV_POSITION;
};

//Vertex Shader
PSInput VSShader(VSInput _Input)
{
    PSInput Output = (PSInput) 0;

    Output.position = mul(float4(_Input.position, 1.0f), ScreenMatrix);

    return Output;
}

//Shader Functions
float2x2 rot(float a)
{
    float s = sin(a), c = cos(a);
    return float2x2(c, -s, s, c);
}

float cube(float3 p)
{
    float3 a = abs(p) - 1.0f;
    return max(a.x, max(a.y, a.z));
}

static float2x2 mx = float2x2(0, 0, 0, 0);
static float2x2 my = float2x2(0, 0, 0, 0);
static float2x2 mz = float2x2(0, 0, 0, 0);

float fold(float3 p)
{
    float scale = 50.0f;
    p *= scale;
    int iter = 13;
    for (int i = 0; i < iter; i++)
    {
        p.xy = mul(p.xy, transpose(mz));
        p.yz = mul(p.yz, transpose(mx));
        p.xz = mul(p.xz, transpose(my));
        p = abs(p) - float(iter - i);
    }
    return cube(p) / scale;
}

float map(float3 p)
{
    return fold(p);
}

float rayCastShadow(float3 ro, float3 rd)
{
    float3 p = ro;
    float acc = 0.0f;
    float dist = 0.0f;

    for (int i = 0; i < 32; i++)
    {
        if ((dist > 6.0f) || (acc > 0.75f))
            break;

        float sdf = map(p);

        const float h = 0.05f;
        float ld = max(h - sdf, 0.0f);
        float w = (1.0f - acc) * ld;

        acc += w;

        sdf = max(sdf, 0.05f);
        p += sdf * rd;
        dist += sdf;
    }
    return max((0.75f - acc), 0.0f) / 0.75f + 0.02f;
}

float3 Render(float3 ro, float3 rd)
{
    float3 p = ro;
    float acc = 0.0f;

    float3 accColor = float3(0.0f, 0.0f, 0.0f);

    float dist = 0.0f;

    for (int i = 0; i < 64; i++)
    {
        if ((dist > 10.0f) || (acc > 0.95f))
            break;

        float sdf = map(p) * 0.80f;

        const float h = 0.05f;
        float ld = max(h - sdf, 0.0f);
        float w = (1. - acc) * ld;
        //cast shadow direction
        accColor += w * rayCastShadow(p, normalize(float3(0.0f, -0.1f, -0.2f)));
        acc += w;

        sdf = max(sdf, 0.03f);

        p += sdf * rd;
        dist += sdf;
    }

    return accColor;
}

float3x3 setCamera(float3 ro, float3 ta)
{
    float3 cw = normalize(ta - ro);
    float3 up = float3(0.0f, 1.0f, 0.0f);
    float3 cu = normalize(cross(cw, up));
    float3 cv = normalize(cross(cu, cw));
    return float3x3(cu, cv, cw);
}

//Pixel Shader
float4 PSShader(PSInput _Input) : SV_Target
{
    mz = rot(TIME * 0.19f);
    mx = rot(TIME * 0.13f);
    my = rot(TIME * 0.11f);

    float3 tot = float3(0.0f,0.213f,0.255f);

#if AA
    float2 rook[4];
    rook[0] = float2(1.0f / 8.0f, 3.0f / 8.0f);
    rook[1] = float2(3.0f / 8.0f, -1.0f / 8.0f);
    rook[2] = float2(-1.0f / 8.0f, -3.0f / 8.0f);
    rook[3] = float2(-3.0f / 8.0f, 1.0f / 8.0f);
    for (int n = 0; n < 4; ++n)
    {
        // pixel coordinates
        float2 o = rook[n];
        float2 p = (-RESOLUTION.xy + 2.0f * (_Input.position.xy + o)) / RESOLUTION.y;
#else 
        float2 p = (-RESOLUTION.xy + 2.0f * _Input.position.xy) / RESOLUTION.y;
#endif 

        // camera       
        float theta = radians(360.0f) * (RESOLUTION.x - 0.5f);
        float phi = radians(90.0f) * (RESOLUTION.y - 0.5f) - 1.0f;
        float3 ro = 7. * float3(sin(phi) * cos(theta), cos(phi), sin(phi) * sin(theta));
        float3 ta = float3(0.0f,0.0f,0.0f);
        // camera-to-world transformation
        float3x3 ca = setCamera(ro, ta);

        float3 rd = mul(transpose(ca), normalize(float3(p, 1.5f)));

        float3 col = Render(ro, rd);

        tot += col;
#if AA
    }

    tot /= 4.0f;
#endif


return float4(sqrt(tot), 1.0f);
}
/* Source: https://www.shadertoy.com/view/NsySD3 */
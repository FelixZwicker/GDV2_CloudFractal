#define AA 0

cbuffer VSBuffer : register(b0)
{
	float4x4 ScreenMatrix;
};

cbuffer PSBuffer : register(b0)
{
	float4 PSConstant;
};

#define TIME			PSConstant.x
#define RESOLUTION	    PSConstant.yz
#define MOUSE           PSConstant.xy

struct VSInput
{
	float3 m_Position : POSITION;
};

struct PSInput
{
	float4 m_Position : SV_POSITION;
};

//Vertex Shader
PSInput VSShader(VSInput _Input)
{
    PSInput Output = (PSInput) 0;

    Output.m_Position = mul(float4(_Input.m_Position, 1.0f), ScreenMatrix);

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
    float3 a = abs(p) - 1.;
    return max(a.x, max(a.y, a.z));
}

static float2x2 mx = float2x2(0, 0, 0, 0);
static float2x2 my = float2x2(0, 0, 0, 0);
static float2x2 mz = float2x2(0, 0, 0, 0);

float fold(float3 p)
{
    float scale = 50.0;
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

float rayCastShadow(in float3 ro, in float3 rd)
{
    float3 p = ro;
    float acc = 0.0;
    float dist = 0.0;

    for (int i = 0; i < 32; i++)
    {
        if ((dist > 6.) || (acc > .75))
            break;

        float sdf = map(p);

        const float h = .05;
        float ld = max(h - sdf, 0.0);
        float w = (1. - acc) * ld;

        acc += w;

        sdf = max(sdf, 0.05);
        p += sdf * rd;
        dist += sdf;
    }
    return max((0.75 - acc), 0.0) / 0.75 + 0.02;
}

float3 Render(in float3 ro, in float3 rd)
{
    float3 p = ro;
    float acc = 0.;

    float3 accColor = float3(0.0, 0.0, 0.0);

    float dist = 0.0;

    for (int i = 0; i < 64; i++)
    {
        if ((dist > 10.) || (acc > .95))
            break;

        float sdf = map(p) * 0.80;

        const float h = .05;
        float ld = max(h - sdf, 0.0);
        float w = (1. - acc) * ld;
        //cast shadow direction
        accColor += w * rayCastShadow(p, normalize(float3(-0.9, -0.1, 0.0)));
        acc += w;

        sdf = max(sdf, 0.03);

        p += sdf * rd;
        dist += sdf;
    }

    return accColor;
}

float3x3 setCamera(in float3 ro, in float3 ta)
{
    float3 cw = normalize(ta - ro);
    float3 up = float3(0, 1, 0);
    float3 cu = normalize(cross(cw, up));
    float3 cv = normalize(cross(cu, cw));
    return float3x3(cu, cv, cw);
}

//Pixel Shader
float4 PSShader(PSInput _Input) : SV_Target
{
    mz = rot(TIME * 0.19);
    mx = rot(TIME * 0.13);
    my = rot(TIME * 0.11);

    float3 tot = float3(0,0.213,0.255);

#if AA
    float2 rook[4];
    rook[0] = float2(1. / 8., 3. / 8.);
    rook[1] = float2(3. / 8., -1. / 8.);
    rook[2] = float2(-1. / 8., -3. / 8.);
    rook[3] = float2(-3. / 8., 1. / 8.);
    for (int n = 0; n < 4; ++n)
    {
        // pixel coordinates
        float2 o = rook[n];
        float2 p = (-RESOLUTION.xy + 2.0 * (_Input.m_Position.xy + o)) / RESOLUTION.y;
#else 
        float2 p = (-RESOLUTION.xy + 2.0 * _Input.m_Position.xy) / RESOLUTION.y;
#endif 

        // camera       
        float theta = radians(360.) * (MOUSE.x / RESOLUTION.x - 0.5);
        float phi = radians(90.) * (MOUSE.y / RESOLUTION.y - 0.5) - 1.;
        float3 ro = 7. * float3(sin(phi) * cos(theta), cos(phi), sin(phi) * sin(theta));
        float3 ta = float3(0.0,0.0,0.0);
        // camera-to-world transformation
        float3x3 ca = setCamera(ro, ta);

        float3 rd = mul(transpose(ca), normalize(float3(p, 1.5)));

        float3 col = Render(ro, rd);

        tot += col;
#if AA
    }

    tot /= 4.;
#endif


return float4(sqrt(tot), 1.0);
}
/* Source: https://www.shadertoy.com/view/NsySD3 */
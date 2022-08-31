#define AA 0

cbuffer VSBuffer : register(b0)
{
	float4x4 g_ScreenMatrix;
};

cbuffer PSBuffer : register(b0)
{
	float4 g_PSConstant01;
};
#define g_Time			g_PSConstant01.x
#define g_Resolution	g_PSConstant01.yz
#define g_Mouse         g_PSConstant01.xy

struct VSInput
{
	float3 m_Position : POSITION;
};

struct PSInput
{
	float4 m_Position : SV_POSITION;
};

PSInput VSShader(VSInput _Input)
{
    PSInput Output = (PSInput) 0;

    Output.m_Position = mul(float4(_Input.m_Position, 1.0f), g_ScreenMatrix);

    return Output;
}

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

float4 PSShader(PSInput _Input) : SV_Target
{
    mz = rot(g_Time * 0.19);
    mx = rot(g_Time * 0.13);
    my = rot(g_Time * 0.11);

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
        float2 p = (-g_Resolution.xy + 2.0 * (_Input.m_Position.xy + o)) / g_Resolution.y;
#else //AA
    float2 p = (-g_Resolution.xy + 2.0 * _Input.m_Position.xy) / g_Resolution.y;
#endif //AA

    // camera       
    float theta = radians(360.) * (g_Mouse.x / g_Resolution.x - 0.5);
    float phi = radians(90.) * (g_Mouse.y / g_Resolution.y - 0.5) - 1.;
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

/*
* first
* 
* #define MAX_ITERATIONS 6.0f
float2 rot(float2 uv, float a) {
    return float2(uv.x * cos(a) - uv.y * sin(a), uv.y * cos(a) + uv.x * sin(a));
}

float4 PSShader(PSInput _Input) : SV_Target
{
    //normalize stuff
    float circleSize = 1.0 / (3.0 * pow(2.0, float(MAX_ITERATIONS)));

    float2 uv = g_Resolution.xy; uv = -.5 * (uv - 2.0 * _Input.m_Position.xy) / uv.x;

    //global rotation and zoom
    uv = rot(uv, g_Time);
    uv *= sin(g_Time) * 0.5 + 1.5;

    //mirror, rotate and scale 6 times...
    float s = 0.3;
    for (int i = 0; i < MAX_ITERATIONS; i++) {
        uv = abs(uv) - s;
        uv = rot(uv, g_Time);
        s = s / 2.1;
    }

    //draw a circle
    float c = length(uv) > circleSize ? 0.0 : 1.0;

    float4 result = float4(1.0f, 1.0f, 1.0f, 1.0f);
    result = float4(c, c, c, 1.0);

    return result;
}*/

/*
* Julia https://www.shadertoy.com/view/Mss3R8#
* 
#define AA 2

float calc(float2 p, float time)
{
    // non p dependent
    float ltime = 0.5 - 0.5 * cos(time * 0.06);
    float zoom = pow(0.9, 50.0 * ltime);
    float2 cen = float2(0.2655, 0.301) + zoom * 0.8 * cos(4.0 + 2.0 * ltime);

    float2 c = float2(-0.745, 0.186) - 0.045 * zoom * (1.0 - ltime * 0.5);

    //
    p = (2.0 * p - g_Resolution.xy) / g_Resolution.y;
    float2 z = cen + (p - cen) * zoom;

#if 0
    // full derivatives version
    float2 dz = float2(1.0, 0.0);
    for (int i = 0; i < 256; i++)
    {
        dz = 2.0 * float2(z.x * dz.x - z.y * dz.y, z.x * dz.y + z.y * dz.x);
        z = float2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (dot(z, z) > 200.0) break;
    }
    float d = sqrt(dot(z, z) / dot(dz, dz)) * log(dot(z, z));

#else
    // only derivative length version
    float ld2 = 1.0;
    float lz2 = dot(z, z);
    for (int i = 0; i < 256; i++)
    {
        ld2 *= 4.0 * lz2;
        z = float2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        lz2 = dot(z, z);
        if (lz2 > 200.0) break;
    }
    float d = sqrt(lz2 / ld2) * log(lz2);

#endif

    return sqrt(clamp((150.0 / zoom) * d, 0.0, 1.0));
}

float4 PSShader(PSInput _Input) : SV_Target
{
#if 0
    float scol = calc(_Input.m_Position.xy, g_Time);
#else

    float scol = 0.0;
    for (int j = 0; j < AA; j++)
        for (int i = 0; i < AA; i++)
        {
            float2 of = -0.5 + float2(float(i), float(j)) / float(AA);
            scol += calc(_Input.m_Position.xy + of, g_Time);
        }
    scol /= float(AA * AA);

#endif

    float3 vcol = pow(float3(scol,0.0,0.0), float3(0.9, 1.1, 1.4));

    float2 uv = _Input.m_Position.xy / g_Resolution.xy;
    vcol *= 0.7 + 0.3 * pow(abs(16.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y)), 0.25);

    float4 result = float4(0.0, 0.0, 0.0, 0.0);
    result = float4(vcol, 1.0);

    return result;
}*/
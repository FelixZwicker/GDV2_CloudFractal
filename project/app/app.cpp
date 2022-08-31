#include "app.h"
#include <math.h>

struct SVertexBuffer
{
    float m_ScreenMatrix[16];
};

struct SPixelBuffer
{
    float m_Time;
    float m_Resolution[2];
    float m_Mouse;
};

CApplication::CApplication()
    : m_Time(0.0f)
    , m_Mouse(0.0f)
    , m_FieldOfViewY(60.0f)        
    , m_pVertexConstantBuffer(nullptr)
    , m_pPixelConstantBuffer(nullptr)
    , m_pVertexShader(nullptr)
    , m_pPixelShader(nullptr)
    , m_pMaterial(nullptr)
    , m_pMesh(nullptr)
{
}

CApplication::~CApplication()
{
}

bool CApplication::InternOnCreateConstantBuffers()
{
    CreateConstantBuffer(sizeof(SVertexBuffer), &m_pVertexConstantBuffer);
    CreateConstantBuffer(sizeof(SPixelBuffer), &m_pPixelConstantBuffer);

    return true;
}

bool CApplication::InternOnReleaseConstantBuffers()
{
    ReleaseConstantBuffer(m_pVertexConstantBuffer);
    ReleaseConstantBuffer(m_pPixelConstantBuffer);

    return true;
}

bool CApplication::InternOnCreateShader()
{
    CreateVertexShader("..\\data\\shader\\fractal_cloud_shader.fx", "VSShader", &m_pVertexShader);
    CreatePixelShader("..\\data\\shader\\fractal_cloud_shader.fx", "PSShader", &m_pPixelShader);

    return true;
}

bool CApplication::InternOnReleaseShader()
{
    ReleaseVertexShader(m_pVertexShader);
    ReleasePixelShader(m_pPixelShader);

    return true;
}

bool CApplication::InternOnCreateMaterials()
{
    this->m_pMaterial = CreateMaterial(m_pVertexConstantBuffer, m_pPixelConstantBuffer, m_pVertexShader, m_pPixelShader);

    return true;
}

bool CApplication::InternOnReleaseMaterials()
{
    ReleaseMaterial(m_pMaterial);

    return true;
}

bool CApplication::InternOnCreateMeshes()
{
    this->m_pMesh = CreateMesh(m_pMaterial);

    return true;
}

bool CApplication::InternOnReleaseMeshes()
{
    ReleaseMesh(m_pMesh);

    return true;
}

bool CApplication::InternOnFrame()
{
    SVertexBuffer VertexBuffer;

    m_Time += 0.05f;

    GetScreenMatrix(VertexBuffer.m_ScreenMatrix);

    UploadConstantBuffer(&VertexBuffer, m_pVertexConstantBuffer);


    SPixelBuffer PixelBuffer;

    PixelBuffer.m_Time = m_Time;
    PixelBuffer.m_Resolution[0] = 800.0f;
    PixelBuffer.m_Resolution[1] = 600.0f;
    PixelBuffer.m_Mouse = m_Mouse;

    UploadConstantBuffer(&PixelBuffer, m_pPixelConstantBuffer);

    DrawMesh(m_pMesh);

    return true;
}

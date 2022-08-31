#include "app.h"
#include <math.h>

CApplication::CApplication()
    : time(0.0f)       
    , vertexConstantBuffer(nullptr)
    , pixelConstantBuffer(nullptr)
    , vertexShader(nullptr)
    , pixelShader(nullptr)
    , material(nullptr)
    , mesh(nullptr)
{
}

CApplication::~CApplication()
{
}

bool CApplication::InternOnCreateConstantBuffers()
{
    CreateConstantBuffer(sizeof(SVertexBuffer), &vertexConstantBuffer);
    CreateConstantBuffer(sizeof(SPixelBuffer), &pixelConstantBuffer);

    return true;
}

bool CApplication::InternOnReleaseConstantBuffers()
{
    ReleaseConstantBuffer(vertexConstantBuffer);
    ReleaseConstantBuffer(pixelConstantBuffer);

    return true;
}

bool CApplication::InternOnCreateShader()
{
    CreateVertexShader("..\\data\\shader\\fractal_cloud_shader.fx", "VSShader", &vertexShader);
    CreatePixelShader("..\\data\\shader\\fractal_cloud_shader.fx", "PSShader", &pixelShader);

    return true;
}

bool CApplication::InternOnReleaseShader()
{
    ReleaseVertexShader(vertexShader);
    ReleasePixelShader(pixelShader);

    return true;
}

bool CApplication::InternOnCreateMaterials()
{
    this->material = CreateMaterial(vertexConstantBuffer, pixelConstantBuffer, vertexShader, pixelShader);

    return true;
}

bool CApplication::InternOnReleaseMaterials()
{
    ReleaseMaterial(material);

    return true;
}

bool CApplication::InternOnCreateMeshes()
{
    this->mesh = CreateMesh(material);

    return true;
}

bool CApplication::InternOnReleaseMeshes()
{
    ReleaseMesh(mesh);

    return true;
}

bool CApplication::InternOnFrame()
{
    SVertexBuffer VertexBuffer;

    time += 0.05f;

    GetScreenMatrix(VertexBuffer.screenMatrix);

    UploadConstantBuffer(&VertexBuffer, vertexConstantBuffer);


    SPixelBuffer PixelBuffer;

    PixelBuffer.time = time;
    PixelBuffer.resolution[0] = 800.0f;
    PixelBuffer.resolution[1] = 600.0f;

    UploadConstantBuffer(&PixelBuffer, pixelConstantBuffer);

    DrawMesh(mesh);

    return true;
}

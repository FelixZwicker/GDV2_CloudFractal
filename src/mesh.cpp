#include "mesh.h"

BHandle CreateMesh(BHandle material)
{
    float Vertices[][3] =
    {
        { 0.0f, 1.0f, 0.0f, },
        { 1.0f, 1.0f, 0.0f, },
        { 1.0f, 0.0f, 0.0f, },
        { 0.0f, 0.0f, 0.0f, },
    };

    int Indices[][3] =
    {
        { 0, 1, 2, },
        { 0, 2, 3, },
    };

    SMeshInfo MeshInfo;

    MeshInfo.m_NumberOfVertices = 4;
    MeshInfo.m_NumberOfIndices = 6;
    MeshInfo.m_pVertices = &Vertices[0][0];
    MeshInfo.m_pIndices = &Indices[0][0];
    MeshInfo.m_pMaterial = material;

    BHandle mesh = nullptr;
    CreateMesh(MeshInfo, &mesh);

    return mesh;
}
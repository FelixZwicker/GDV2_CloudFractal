#pragma once
#include "material.h"

class CApplication : public IApplication
{
public:
    CApplication();
    virtual ~CApplication();

private:
    float   m_Time;
    float   m_Mouse;
    float   m_FieldOfViewY;             // Vertical view angle of the camera
    
    BHandle m_pVertexConstantBuffer;    // A pointer to a YoshiX constant buffer, which defines global data for a vertex shader.
    BHandle m_pPixelConstantBuffer;     // A pointer to a YoshiX constant buffer, which defines global data for a pixel shader.
    
    BHandle m_pVertexShader;            // A pointer to a YoshiX vertex shader, which processes each single vertex of the mesh.
    BHandle m_pPixelShader;             // A pointer to a YoshiX pixel shader, which computes the color of each pixel visible of the mesh on the screen.
   
    BHandle m_pMaterial;                // A pointer to a YoshiX material, spawning the surface of the mesh.
    BHandle m_pMesh;                    // A pointer to a YoshiX mesh, which represents a single triangle.

private:
    virtual bool InternOnCreateConstantBuffers();
    virtual bool InternOnReleaseConstantBuffers();
    virtual bool InternOnCreateShader();
    virtual bool InternOnReleaseShader();
    virtual bool InternOnCreateMaterials();
    virtual bool InternOnReleaseMaterials();
    virtual bool InternOnCreateMeshes();
    virtual bool InternOnReleaseMeshes();
    virtual bool InternOnFrame();
};
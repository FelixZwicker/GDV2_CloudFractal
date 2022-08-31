#pragma once
#include "material.h"

class CApplication : public IApplication
{
public:
    CApplication();
    virtual ~CApplication();

private:
    float   time;            
    
    BHandle vertexConstantBuffer;    
    BHandle pixelConstantBuffer;     
    
    BHandle vertexShader;            
    BHandle pixelShader;         
   
    BHandle material;                
    BHandle mesh;                    

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
#include "material.h"

BHandle CreateMaterial(BHandle vertextConstantBuffer, BHandle pixelConstantBuffer, BHandle vertexShader, BHandle pixelShader)
{
    SMaterialInfo MaterialInfo;

    MaterialInfo.m_NumberOfTextures = 0;                          
    MaterialInfo.m_NumberOfVertexConstantBuffers = 1;                         
    MaterialInfo.m_pVertexConstantBuffers[0] = vertextConstantBuffer;    
    MaterialInfo.m_NumberOfPixelConstantBuffers = 1;                           
    MaterialInfo.m_pPixelConstantBuffers[0] = pixelConstantBuffer;      
    MaterialInfo.m_pVertexShader = vertexShader;         
    MaterialInfo.m_pPixelShader = pixelShader;              
    MaterialInfo.m_NumberOfInputElements = 1;                        
    MaterialInfo.m_InputElements[0].m_pName = "POSITION";               
    MaterialInfo.m_InputElements[0].m_Type = SInputElement::Float3;      

    BHandle material = nullptr;
    CreateMaterial(MaterialInfo, &material);

    return material;
}
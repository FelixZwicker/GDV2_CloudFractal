#include "material.h"

BHandle CreateMaterial(BHandle vertextConstantBuffer, BHandle pixelConstantBuffer, BHandle vertexShader, BHandle pixelShader)
{
    SMaterialInfo MaterialInfo;

    MaterialInfo.m_NumberOfTextures = 0;                           // The material does not need textures, because the pixel shader just returns a constant color.
    MaterialInfo.m_NumberOfVertexConstantBuffers = 1;                           // We need one vertex constant buffer to pass world matrix and view projection matrix to the vertex shader.
    MaterialInfo.m_pVertexConstantBuffers[0] = vertextConstantBuffer;     // Pass the handle to the created vertex constant buffer.
    MaterialInfo.m_NumberOfPixelConstantBuffers = 1;                           // We need one pixel constant buffer to pass the color to the pixel shader.
    MaterialInfo.m_pPixelConstantBuffers[0] = pixelConstantBuffer;      // Pass the handle to the created pixel constant buffer.
    MaterialInfo.m_pVertexShader = vertexShader;             // The handle to the vertex shader.
    MaterialInfo.m_pPixelShader = pixelShader;              // The handle to the pixel shader.
    MaterialInfo.m_NumberOfInputElements = 1;                           // The vertex shader requests the position as only argument.
    MaterialInfo.m_InputElements[0].m_pName = "POSITION";                  // The semantic name of the argument, which matches exactly the identifier in the 'VSInput' struct.
    MaterialInfo.m_InputElements[0].m_Type = SInputElement::Float3;       // The position is a 3D vector with floating points.

    BHandle material = nullptr;
    CreateMaterial(MaterialInfo, &material);

    return material;
}
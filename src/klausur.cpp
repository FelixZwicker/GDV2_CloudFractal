/*
#include "yoshix.h"

using namespace gfx;

class CApplication : public IApplication
{
	public:

		CApplication();
		virtual ~CApplication();

	private:

        struct VSConstants
        {
            float m_VSViewPosition[3];
            float m_Padding0[1];
            float m_VSBillboardPosition[3];
            float m_Padding1[1];
            float m_VSViewProjectionMatrix[16];
        };

	private:

        float   m_BillboardPosition[3];
		float   m_FieldOfViewY;             // Vertical view angle of the camera
        float   m_ViewMatrix[16];
        float   m_ProjectionMatrix[16];
        BHandle m_pVSConstants;
        BHandle m_pVertexShader;
        BHandle m_pPixelShader;
        BHandle m_pMaterial;
        BHandle m_pMesh;

    private:

		virtual bool InternOnCreateConstantBuffers();
		virtual bool InternOnReleaseConstantBuffers();
		virtual bool InternOnCreateShader();
		virtual bool InternOnReleaseShader();
		virtual bool InternOnCreateMaterials();
		virtual bool InternOnReleaseMaterials();
		virtual bool InternOnCreateMeshes();
		virtual bool InternOnReleaseMeshes();
		virtual bool InternOnResize(int _Width, int _Height);
		virtual bool InternOnUpdate();
		virtual bool InternOnFrame();
};

// -----------------------------------------------------------------------------

CApplication::CApplication()
    : m_BillboardPosition{ 0.0f }
    , m_FieldOfViewY     (60.0f)        // Set the vertical view angle of the camera to 60 degrees.
{
}

// -----------------------------------------------------------------------------

CApplication::~CApplication()
{
}

// -----------------------------------------------------------------------------

bool CApplication::InternOnCreateConstantBuffers()
{
    CreateConstantBuffer(sizeof(VSConstants), &m_pVSConstants);

	return true; 
}

// -----------------------------------------------------------------------------

bool CApplication::InternOnReleaseConstantBuffers()
{
    ReleaseConstantBuffer(m_pVSConstants);

	return true;
}

// -----------------------------------------------------------------------------

bool CApplication::InternOnCreateShader()
{
    CreateVertexShader("..\\data\\shader\\billboard.fx", "VSMain", &m_pVertexShader);
    CreatePixelShader ("..\\data\\shader\\billboard.fx", "PSMain", &m_pPixelShader );

    return true;
}

// -----------------------------------------------------------------------------

bool CApplication::InternOnReleaseShader()
{
    ReleaseVertexShader(m_pVertexShader);
    ReleasePixelShader (m_pPixelShader );

	return true;
}

// -----------------------------------------------------------------------------

bool CApplication::InternOnCreateMaterials()
{
    SMaterialInfo Info;

    Info.m_NumberOfTextures              = 0;
    Info.m_NumberOfVertexConstantBuffers = 1;
    Info.m_pVertexConstantBuffers[0]     = m_pVSConstants;
    Info.m_NumberOfPixelConstantBuffers  = 0;
    Info.m_pVertexShader                 = m_pVertexShader;
    Info.m_pPixelShader                  = m_pPixelShader;
    Info.m_NumberOfInputElements         = 1;
    Info.m_InputElements[0].m_Type       = SInputElement::Float2;
    Info.m_InputElements[0].m_pName      = "POSITION";

    CreateMaterial(Info, &m_pMaterial);

	return true;
}

// -----------------------------------------------------------------------------

bool CApplication::InternOnReleaseMaterials()
{
    ReleaseMaterial(m_pMaterial);

	return true;
}

// -----------------------------------------------------------------------------

bool CApplication::InternOnCreateMeshes()
{   
    float Vertices[][2] =
    {
        // X      Y
        { -2.0f, -2.0f },
        {  2.0f, -2.0f },
        {  2.0f,  2.0f },
        { -2.0f,  2.0f },
    };

    int Indices[][3] =
    {
        { 0, 1, 2 }, // Triangle 0
        { 0, 2, 3 }, // Triangle 1
    };

    SMeshInfo Info;

    Info.m_pVertices        = &Vertices[0][0];
    Info.m_NumberOfVertices = 4;
    Info.m_pIndices         = &Indices[0][0];
    Info.m_NumberOfIndices  = 6;
    Info.m_pMaterial        = m_pMaterial;

    CreateMesh(Info, &m_pMesh);

	return true;
}

// -----------------------------------------------------------------------------

bool CApplication::InternOnReleaseMeshes()
{
    ReleaseMesh(m_pMesh);

	return true;
}

// -----------------------------------------------------------------------------

bool CApplication::InternOnResize(int _Width, int _Height)
{
    float AspectRatio = static_cast<float>(_Width) / static_cast<float>(_Height);

    GetProjectionMatrix(60.0f, AspectRatio, 0.01f, 1000.0f, m_ProjectionMatrix);

	return true;
}

// -----------------------------------------------------------------------------

bool CApplication::InternOnUpdate()
{
    //                  Z
    //                  ^
    //                  |
    //                  |
    //                  |
    //                  |
    //                  | Quad
    //      ----------TTTTT--------------> X
    //                  ^
    //                  |
    //                  |
    //                  |
    //                  |
    //                  x Eye
    float Eye[] = { 0.0f, 0.0f, -10.0f };
    float At [] = { 0.0f, 0.0f,   0.0f };
    float Up [] = { 0.0f, 1.0f,   0.0f };

    GetViewMatrix(Eye, At, Up, m_ViewMatrix);

	return true;
}

// -----------------------------------------------------------------------------

bool CApplication::InternOnFrame()
{
    // Once per frame
    VSConstants ConstantsVS;

    ConstantsVS.m_VSViewPosition[0] =   0.0f;
    ConstantsVS.m_VSViewPosition[1] =   0.0f;
    ConstantsVS.m_VSViewPosition[2] = -10.0f;

    ConstantsVS.m_VSBillboardPosition[0] = m_BillboardPosition[0];
    ConstantsVS.m_VSBillboardPosition[1] = m_BillboardPosition[1];
    ConstantsVS.m_VSBillboardPosition[2] = m_BillboardPosition[2];

    MulMatrix(m_ViewMatrix, m_ProjectionMatrix, ConstantsVS.m_VSViewProjectionMatrix);

    UploadConstantBuffer(&ConstantsVS, m_pVSConstants);

    DrawMesh(m_pMesh);

    m_BillboardPosition[0] += 0.02f;

	return true;
}

// -----------------------------------------------------------------------------

void main()
{
	CApplication Application;

	RunApplication(800, 600, "YoshiX Example", &Application);
}
*/
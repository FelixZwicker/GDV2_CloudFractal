#pragma once
#include "yoshix.h"

using namespace gfx;

struct SVertexBuffer
{
    float screenMatrix[16];
};

struct SPixelBuffer
{
    float time;
    float resolution[2];
    float padding;
};
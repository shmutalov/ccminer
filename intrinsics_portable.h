#ifndef _INTRINSICS_PORTABLE_H
#define _INTRINSICS_PORTABLE_H

#ifdef __ARM_NEON
#include "SSE2NEON.h"
#else
#include <immintrin.h>
#endif

#endif
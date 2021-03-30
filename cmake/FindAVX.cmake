# This file is use to check all support level of AVX on the machine

INCLUDE(CheckCSourceRuns)

SET(HAVE_AVXINTRIN_H)
SET(HAVE_AVX2INTRIN_H)
SET(HAVE_AVX512FINTRIN_H)
SET(AVX_FLAGS)
SET(AVX_FOUND)

# Check AVX 512
SET(CMAKE_REQUIRED_FLAGS)
IF(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUC OR CMAKE_C_COMPILER_ID MATCHES "Clang")
  SET(CMAKE_REQUIRED_FLAGS "-mavx512f")
ELSEIF(MSVC AND NOT CMAKE_CL_64)  # reserve for WINDOWS
  SET(CMAKE_REQUIRED_FLAGS "/arch:AVX512")
ENDIF()

CHECK_C_SOURCE_RUNS("
#ifdef __native_client__
# error NativeClient detected - Avoiding AVX512F opcodes
#endif
#pragma GCC target(\"avx512f\")
#include <immintrin.h>

#ifndef __AVX512F__
# error No AVX512 support
#elif defined(__clang__)
# if __clang_major__ < 4
#  error Compiler AVX512 support may be broken
# endif
#elif defined(__GNUC__)
# if __GNUC__ < 6
#  error Compiler AVX512 support may be broken
# endif
#endif

int main(void) {
    __m512i x = _mm512_setzero_epi32();
    __m512i y = _mm512_permutexvar_epi64(_mm512_setr_epi64(0, 1, 4, 5, 2, 3, 6, 7), x);
}" HAVE_AVX512FINTRIN_H)

# Check AVX 2
SET(CMAKE_REQUIRED_FLAGS)
IF(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUC OR CMAKE_C_COMPILER_ID MATCHES "Clang")
  SET(CMAKE_REQUIRED_FLAGS "-mavx2")
ELSEIF(MSVC AND NOT CMAKE_CL_64)  # reserve for WINDOWS
  SET(CMAKE_REQUIRED_FLAGS "/arch:AVX2")
ENDIF()

CHECK_C_SOURCE_RUNS("
#include <immintrin.h>
int main()
{
    __m256i a = _mm256_set_epi32 (-1, 2, -3, 4, -1, 2, -3, 4);
    __m256i result = _mm256_abs_epi32 (a);
    return 0;
}" HAVE_AVX2INTRIN_H)

# Check AVX
SET(CMAKE_REQUIRED_FLAGS)
IF(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUC OR CMAKE_C_COMPILER_ID MATCHES "Clang")
    SET(CMAKE_REQUIRED_FLAGS "-mavx")
ELSEIF(MSVC AND NOT CMAKE_CL_64)
    SET(CMAKE_REQUIRED_FLAGS "/arch:AVX")
endif()

CHECK_C_SOURCE_RUNS("
#include <immintrin.h>
int main()
{
    __m256 a = _mm256_set_ps (-1.0f, 2.0f, -3.0f, 4.0f, -1.0f, 2.0f, -3.0f, 4.0f);
    __m256 b = _mm256_set_ps (1.0f, 2.0f, 3.0f, 4.0f, 1.0f, 2.0f, 3.0f, 4.0f);
    __m256 result = _mm256_add_ps (a, b);
    return 0;
}" HAVE_AVXINTRIN_H)

IF(HAVE_AVX512FINTRIN_H)
    IF(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUC OR CMAKE_C_COMPILER_ID MATCHES "Clang")
        SET(AVX_FLAGS "${AVX_FLAGS} -mavx512f")
    ELSEIF(MSVC)
        SET(AVX_FLAGS "${AVX_FLAGS} /arch:AVX512")
    ENDIF()
ENDIF()

IF(HAVE_AVX2INTRIN_H)
    IF(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUC OR CMAKE_C_COMPILER_ID MATCHES "Clang")
        SET(AVX_FLAGS "${AVX_FLAGS} -mavx2")
    ELSEIF(MSVC)
        SET(AVX_FLAGS "${AVX_FLAGS} /arch:AVX2")
    ENDIF()
ENDIF()

IF(HAVE_AVXINTRIN_H)
    IF(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUC OR CMAKE_C_COMPILER_ID MATCHES "Clang")
        SET(AVX_FLAGS "${AVX_FLAGS} -mavx")
    ELSEIF(MSVC)
        SET(AVX_FLAGS "${AVX_FLAGS} /arch:AVX")
    ENDIF()
ENDIF()

IF(HAVE_AVXINTRIN_H OR HAVE_AVX2INTRIN_H OR HAVE_AVX512FINTRIN_H)
    SET(AVX_FOUND TRUE)
    MESSAGE(STATUS "Find CPU supports ${AVX_FLAGS}.")
ENDIF()

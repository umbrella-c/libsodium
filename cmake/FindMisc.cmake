# This file is use to check all support level of 128 bit ints on the machine

INCLUDE(CheckCSourceRuns)
INCLUDE(CheckCSourceCompiles)

SET (MISC_FLAGS)
SET (MISC_DEFINITIONS)

check_c_source_compiles ("
  #if !defined(__clang__) && !defined(__GNUC__) && !defined(__SIZEOF_INT128__)
  # error mode(TI) is a gcc extension, and __int128 is not available
  #endif
  #if defined(__clang__) && !defined(__x86_64__) && !defined(__aarch64__)
  # error clang does not properly handle the 128-bit type on 32-bit systems
  #endif
  #ifdef __EMSCRIPTEN__
  # error emscripten currently doesn't support some operations on integers larger than 64 bits
  #endif
  #include <stddef.h>
  #include <stdint.h>
  #if defined(__SIZEOF_INT128__)
  typedef unsigned __int128 uint128_t;
  #else
  typedef unsigned uint128_t __attribute__((mode(TI)));
  #endif
  void fcontract(uint128_t *t) {
    *t += 0x8000000000000 - 1;
    *t *= *t;
    *t >>= 84;
  }

  int main() {
    (void)fcontract;
  }
" SUPPORTS_128BIT)

check_c_source_compiles("
  int main(void) {
    int a = 42;
    int *pnt = &a;
    __asm__ __volatile__ (\"\" : : \"r\"(pnt) : \"memory\");
  }
" HAVE_INLINE_ASM)

if (HAVE_INLINE_ASM)
  SET(MISC_DEFINITIONS "${MISC_DEFINITIONS} -DHAVE_INLINE_ASM")
endif ()

check_c_source_compiles("
#include <intrin.h>
int main(void) {
  (void) _xgetbv(0);
}
" HAVE__XGETBV)

if (HAVE__XGETBV)
  SET(MISC_DEFINITIONS "${MISC_DEFINITIONS} -DHAVE__XGETBV")
endif ()

check_c_source_compiles("
#ifdef __native_client__
# error NativeClient detected - Avoiding RDRAND opcodes
#endif
#pragma GCC target(\"rdrnd\")
#include <immintrin.h>
int main(void) {
  unsigned long long x;
  _rdrand64_step(&x);
}
" HAVE_RDRAND)

if (HAVE_RDRAND)
  SET(MISC_DEFINITIONS "${MISC_DEFINITIONS} -DHAVE_RDRAND")
  SET(MISC_FLAGS "${MISC_FLAGS} -mrdrnd")
endif ()

check_c_source_compiles(
"
int main(void) {
  static volatile int _sodium_lock;
  __sync_lock_test_and_set(&_sodium_lock, 1);
  __sync_lock_release(&_sodium_lock);
}
" HAVE_ATOMIC_OPS)

if (HAVE_ATOMIC_OPS)
  SET(MISC_DEFINITIONS "${MISC_DEFINITIONS} -DHAVE_ATOMIC_OPS")
endif ()

check_c_source_compiles("
#if !defined(__ELF__) && !defined(__APPLE_CC__)
# error Support for weak symbols may not be available
#endif
__attribute__((weak)) void __dummy(void *x) { }
void f(void *x) { __dummy(x); }
int main(void) {}
" HAVE_WEAK_SYMBOLS)

if (HAVE_WEAK_SYMBOLS)
  SET(MISC_DEFINITIONS "${MISC_DEFINITIONS} -DHAVE_WEAK_SYMBOLS")
endif ()

check_c_source_compiles("
int main(void) {
  unsigned int cpu_info[4];
  __asm__ __volatile__ (\"xchgl %%ebx, %k1; cpuid; xchgl %%ebx, %k1\" :
    \"=a\" (cpu_info[0]), \"=&r\" (cpu_info[1]),
    \"=c\" (cpu_info[2]), \"=d\" (cpu_info[3]) :
    \"0\" (0U), \"2\" (0U));
}
" HAVE_CPUID)

if (HAVE_CPUID)
  SET(MISC_DEFINITIONS "${MISC_DEFINITIONS} -DHAVE_CPUID")
endif ()

check_c_source_compiles("
int main(void) {
#if defined(__amd64) || defined(__amd64__) || defined(__x86_64__)
# if defined(__CYGWIN__) || defined(__MINGW32__) || defined(__MINGW64__) || defined(_WIN32) || defined(_WIN64)
#  error Windows x86_64 calling conventions are not supported yet
# endif
/* neat */
#else
# error !x86_64
#endif
  __asm__ __volatile__ (\"vpunpcklqdq %xmm0,%xmm13,%xmm0\");
}
" HAVE_AVX_ASM)

if (HAVE_AVX_ASM)
  SET(MISC_DEFINITIONS "${MISC_DEFINITIONS} -DHAVE_AVX_ASM")
endif ()

check_c_source_compiles("
int main(void) {
#if defined(__amd64) || defined(__amd64__) || defined(__x86_64__)
# if defined(__CYGWIN__) || defined(__MINGW32__) || defined(__MINGW64__) || defined(_WIN32) || defined(_WIN64)
#  error Windows x86_64 calling conventions are not supported yet
# endif
/* neat */
#else
# error !x86_64
#endif
  unsigned char i = 0, o = 0, t;
  __asm__ __volatile__ (\"pxor %%xmm12, %%xmm6 \n\"
    \"movb (%[i]), %[t] \n\"
    \"addb %[t], (%[o]) \n\"
    : [t] \"=&r\"(t)
    : [o] \"D\"(&o), [i] \"S\"(&i)
    : \"memory\", \"flags\", \"cc\");
}
" HAVE_AMD64_ASM)

if (HAVE_AMD64_ASM)
  SET(MISC_DEFINITIONS "${MISC_DEFINITIONS} -DHAVE_AMD64_ASM")
endif ()

check_c_source_compiles("
#ifdef __native_client__
# error NativeClient detected - Avoiding AESNI opcodes
#endif
#pragma GCC target(\"aes\")
#pragma GCC target(\"pclmul\")
#include <wmmintrin.h>
int main(void) {
  __m128i x = _mm_aesimc_si128(_mm_setzero_si128());
  __m128i y = _mm_clmulepi64_si128(_mm_setzero_si128(), _mm_setzero_si128(), 0);
}
" HAVE_WMMINTRIN_H)

if (HAVE_WMMINTRIN_H)
  SET(MISC_DEFINITIONS "${MISC_DEFINITIONS} -DHAVE_WMMINTRIN_H")
  SET(MISC_FLAGS "${MISC_FLAGS} -maes -mpclmul")
endif ()

MESSAGE(STATUS "Supported misc flags ${MISC_FLAGS}.")

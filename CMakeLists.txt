project (libsodium C)
cmake_minimum_required (VERSION 3.8)

option (SODIUM_SHARED "Build the shared version of the librar" OFF)
option (SODIUM_MINIMAL "Compile the minimal version of libsodium" OFF)
option (SODIUM_BIGENDIAN "Compile library as big-endian format" OFF)

set (SODIUM_LIBRARY_VERSION_MAJOR 11)
set (SODIUM_LIBRARY_VERSION_MINOR 0)
set (VERSION "${SODIUM_LIBRARY_VERSION_MAJOR}.${SODIUM_LIBRARY_VERSION_MINOR}")

if (SODIUM_MINIMAL)
    set (SODIUM_LIBRARY_MINIMAL_DEF "#define SODIUM_LIBRARY_MINIMAL 1")
endif ()

set (CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${libsodium_SOURCE_DIR}/cmake")

include (CheckIncludeFiles)
macro (check_and_add inc def)
    check_include_files (${ARGV0} HAVE_${ARGV1})
    if (HAVE_${ARGV1})
        add_definitions (-DHAVE_${ARGV1})
    endif ()
endmacro ()

check_and_add (pthread.h PTHREAD)
check_and_add (unistd.h UNISTD_H)
check_and_add (sys/random.h SYS_RANDOM_H)
check_and_add (sys/auxv.h SYS_AUXV_H)
check_and_add (sys/mman.h SYS_MMAN_H)
check_and_add (alloca.h ALLOCA_H)
check_and_add (cpuid.h CPUID_H)
check_and_add (intrin.h INTRIN_H)
check_and_add (mmintrin.h MMINTRIN_H)
check_and_add (emmintrin.h EMMINTRIN_H)
check_and_add (pmmintrin.h PMMINTRIN_H)
check_and_add (tmmintrin.h TMMINTRIN_H)
check_and_add (smmintrin.h SMMINTRIN_H)

find_package(Misc)
find_package(SSE)
find_package(AVX)

configure_file (src/libsodium/include/sodium/version.h.in version.h @ONLY)

include_directories (
    ${CMAKE_BINARY_DIR}
    src/libsodium/include/sodium
)

set (SRCS
    src/libsodium/crypto_generichash/crypto_generichash.c
    src/libsodium/crypto_generichash/blake2b/generichash_blake2.c
    src/libsodium/crypto_generichash/blake2b/ref/blake2b-compress-ref.c
    src/libsodium/crypto_generichash/blake2b/ref/blake2b-compress-ssse3.c
    src/libsodium/crypto_generichash/blake2b/ref/blake2b-compress-avx2.c
    src/libsodium/crypto_generichash/blake2b/ref/blake2b-compress-sse41.c
    src/libsodium/crypto_generichash/blake2b/ref/generichash_blake2b.c
    src/libsodium/crypto_generichash/blake2b/ref/blake2b-ref.c
    src/libsodium/crypto_kx/crypto_kx.c
    src/libsodium/crypto_sign/crypto_sign.c
    src/libsodium/crypto_sign/ed25519/sign_ed25519.c
    src/libsodium/crypto_sign/ed25519/ref10/sign.c
    src/libsodium/crypto_sign/ed25519/ref10/keypair.c
    src/libsodium/crypto_sign/ed25519/ref10/open.c
    src/libsodium/crypto_secretbox/crypto_secretbox.c
    src/libsodium/crypto_secretbox/crypto_secretbox_easy.c
    src/libsodium/crypto_secretbox/xsalsa20poly1305/secretbox_xsalsa20poly1305.c
    src/libsodium/crypto_secretbox/xchacha20poly1305/secretbox_xchacha20poly1305.c
    src/libsodium/crypto_pwhash/crypto_pwhash.c
    src/libsodium/crypto_pwhash/argon2/blake2b-long.c
    src/libsodium/crypto_pwhash/argon2/argon2-core.c
    src/libsodium/crypto_pwhash/argon2/argon2-fill-block-avx512f.c
    src/libsodium/crypto_pwhash/argon2/argon2-fill-block-ref.c
    src/libsodium/crypto_pwhash/argon2/argon2-fill-block-ssse3.c
    src/libsodium/crypto_pwhash/argon2/pwhash_argon2i.c
    src/libsodium/crypto_pwhash/argon2/pwhash_argon2id.c
    src/libsodium/crypto_pwhash/argon2/argon2.c
    src/libsodium/crypto_pwhash/argon2/argon2-fill-block-avx2.c
    src/libsodium/crypto_pwhash/argon2/argon2-encoding.c
    src/libsodium/crypto_pwhash/scryptsalsa208sha256/scrypt_platform.c
    src/libsodium/crypto_pwhash/scryptsalsa208sha256/crypto_scrypt-common.c
    src/libsodium/crypto_pwhash/scryptsalsa208sha256/pwhash_scryptsalsa208sha256.c
    src/libsodium/crypto_pwhash/scryptsalsa208sha256/pbkdf2-sha256.c
    src/libsodium/crypto_pwhash/scryptsalsa208sha256/nosse/pwhash_scryptsalsa208sha256_nosse.c
    src/libsodium/crypto_pwhash/scryptsalsa208sha256/sse/pwhash_scryptsalsa208sha256_sse.c
    src/libsodium/crypto_verify/sodium/verify.c
    src/libsodium/crypto_auth/crypto_auth.c
    src/libsodium/crypto_auth/hmacsha512/auth_hmacsha512.c
    src/libsodium/crypto_auth/hmacsha512256/auth_hmacsha512256.c
    src/libsodium/crypto_auth/hmacsha256/auth_hmacsha256.c
    src/libsodium/crypto_kdf/crypto_kdf.c
    src/libsodium/crypto_kdf/blake2b/kdf_blake2b.c
    src/libsodium/crypto_kdf/hkdf/kdf_hkdf_sha256.c
    src/libsodium/crypto_kdf/hkdf/kdf_hkdf_sha512.c
    src/libsodium/crypto_shorthash/crypto_shorthash.c
    src/libsodium/crypto_shorthash/siphash24/shorthash_siphash24.c
    src/libsodium/crypto_shorthash/siphash24/shorthash_siphashx24.c
    src/libsodium/crypto_shorthash/siphash24/ref/shorthash_siphashx24_ref.c
    src/libsodium/crypto_shorthash/siphash24/ref/shorthash_siphash24_ref.c
    src/libsodium/crypto_scalarmult/crypto_scalarmult.c
    src/libsodium/crypto_scalarmult/ristretto255/ref10/scalarmult_ristretto255_ref10.c
    src/libsodium/crypto_scalarmult/ed25519/ref10/scalarmult_ed25519_ref10.c
    src/libsodium/crypto_scalarmult/curve25519/scalarmult_curve25519.c
    src/libsodium/crypto_scalarmult/curve25519/sandy2x/curve25519_sandy2x.c
    src/libsodium/crypto_scalarmult/curve25519/sandy2x/fe_frombytes_sandy2x.c
    src/libsodium/crypto_scalarmult/curve25519/sandy2x/fe51_invert.c
    src/libsodium/crypto_scalarmult/curve25519/ref10/x25519_ref10.c
    src/libsodium/crypto_onetimeauth/crypto_onetimeauth.c
    src/libsodium/crypto_onetimeauth/poly1305/onetimeauth_poly1305.c
    src/libsodium/crypto_onetimeauth/poly1305/donna/poly1305_donna.c
    src/libsodium/crypto_onetimeauth/poly1305/sse2/poly1305_sse2.c
    src/libsodium/randombytes/randombytes.c
    src/libsodium/randombytes/sysrandom/randombytes_sysrandom.c
    src/libsodium/randombytes/internal/randombytes_internal_random.c
    src/libsodium/crypto_box/crypto_box_easy.c
    src/libsodium/crypto_box/crypto_box_seal.c
    src/libsodium/crypto_box/crypto_box.c
    src/libsodium/crypto_box/curve25519xsalsa20poly1305/box_curve25519xsalsa20poly1305.c
    src/libsodium/crypto_box/curve25519xchacha20poly1305/box_curve25519xchacha20poly1305.c
    src/libsodium/crypto_box/curve25519xchacha20poly1305/box_seal_curve25519xchacha20poly1305.c
    src/libsodium/sodium/codecs.c
    src/libsodium/sodium/runtime.c
    src/libsodium/sodium/core.c
    src/libsodium/sodium/utils.c
    src/libsodium/sodium/version.c
    src/libsodium/crypto_stream/crypto_stream.c
    src/libsodium/crypto_stream/xchacha20/stream_xchacha20.c
    src/libsodium/crypto_stream/chacha20/stream_chacha20.c
    src/libsodium/crypto_stream/chacha20/ref/chacha20_ref.c
    src/libsodium/crypto_stream/chacha20/dolbeau/chacha20_dolbeau-avx2.c
    src/libsodium/crypto_stream/chacha20/dolbeau/chacha20_dolbeau-ssse3.c
    src/libsodium/crypto_stream/salsa20/stream_salsa20.c
    src/libsodium/crypto_stream/salsa20/ref/salsa20_ref.c
    src/libsodium/crypto_stream/salsa20/xmm6int/salsa20_xmm6int-avx2.c
    src/libsodium/crypto_stream/salsa20/xmm6int/salsa20_xmm6int-sse2.c
    src/libsodium/crypto_stream/salsa20/xmm6/salsa20_xmm6.c
    src/libsodium/crypto_stream/salsa2012/stream_salsa2012.c
    src/libsodium/crypto_stream/salsa2012/ref/stream_salsa2012_ref.c
    src/libsodium/crypto_stream/salsa208/stream_salsa208.c
    src/libsodium/crypto_stream/salsa208/ref/stream_salsa208_ref.c
    src/libsodium/crypto_stream/xsalsa20/stream_xsalsa20.c
    src/libsodium/crypto_hash/crypto_hash.c
    src/libsodium/crypto_hash/sha512/hash_sha512.c
    src/libsodium/crypto_hash/sha512/cp/hash_sha512_cp.c
    src/libsodium/crypto_hash/sha256/hash_sha256.c
    src/libsodium/crypto_hash/sha256/cp/hash_sha256_cp.c
    src/libsodium/crypto_aead/xchacha20poly1305/sodium/aead_xchacha20poly1305.c
    src/libsodium/crypto_aead/aegis128l/aead_aegis128l.c
    src/libsodium/crypto_aead/aegis128l/aesni/aead_aegis128l_aesni.c
    src/libsodium/crypto_aead/aegis128l/armcrypto/aead_aegis128l_armcrypto.c
    src/libsodium/crypto_aead/aegis256/aead_aegis256.c
    src/libsodium/crypto_aead/aegis256/aesni/aead_aegis256_aesni.c
    src/libsodium/crypto_aead/aegis256/armcrypto/aead_aegis256_armcrypto.c
    src/libsodium/crypto_aead/aes256gcm/aesni/aead_aes256gcm_aesni.c
    src/libsodium/crypto_aead/chacha20poly1305/sodium/aead_chacha20poly1305.c
    src/libsodium/crypto_secretstream/xchacha20poly1305/secretstream_xchacha20poly1305.c
    src/libsodium/crypto_core/salsa/ref/core_salsa_ref.c
    src/libsodium/crypto_core/hchacha20/core_hchacha20.c
    src/libsodium/crypto_core/hsalsa20/core_hsalsa20.c
    src/libsodium/crypto_core/hsalsa20/ref2/core_hsalsa20_ref2.c
    src/libsodium/crypto_core/ed25519/core_ed25519.c
    src/libsodium/crypto_core/ed25519/core_ristretto255.c
    src/libsodium/crypto_core/ed25519/core_h2c.c
    src/libsodium/crypto_core/ed25519/ref10/ed25519_ref10.c
)

add_definitions(-DCONFIGURED=1 -DDEV_MODE)

if (NOT SODIUM_BIGENDIAN AND SUPPORTS_128BIT)
    add_definitions(-DHAVE_TI_MODE)
endif ()

if (MISC_DEFINITIONS)
    add_definitions(${MISC_DEFINITIONS})
    add_definitions(${MISC_FLAGS})
endif ()

if (SSE_DEFINITIONS)
    add_definitions(${SSE_FLAGS})
endif ()

if (AVX_FOUND)
    add_definitions(${AVX_DEFINITIONS})
    add_definitions(${AVX_FLAGS})
endif ()

if (SODIUM_BIGENDIAN)
    add_definitions(-DNATIVE_BIG_ENDIAN)
else ()
    add_definitions(-DNATIVE_LITTLE_ENDIAN)
endif ()

if (NOT SODIUM_SHARED)
    add_definitions(-DSODIUM_STATIC)
    add_library (sodium ${SRCS})
else ()
    add_library (sodium SHARED ${SRCS})
endif ()

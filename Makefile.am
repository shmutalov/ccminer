# allow to use Host cuda functions in C/C++
#DEF_INCLUDES = @CUDA_INCLUDES@

if WANT_JANSSON
JANSSON_INCLUDES= -I$(top_srcdir)/compat/jansson
else
JANSSON_INCLUDES=
endif

EXTRA_DIST		= autogen.sh README.md README.txt LICENSE.txt \
			  ccminer.sln ccminer.vcxproj ccminer.vcxproj.filters \
			  compat/gettimeofday.c compat/getopt/getopt_long.c

SUBDIRS = compat

bin_PROGRAMS = ccminer

ccminer_SOURCES	= elist.h miner.h compat.h \
			  compat/inttypes.h compat/stdbool.h compat/unistd.h bignum.cpp bignum.hpp \
			  compat/sys/time.h compat/getopt/getopt.h \
			  crc32.c \
			  ccminer.cpp pools.cpp util.cpp bench.cpp \
			  api.cpp hashlog.cpp stats.cpp sysinfos.cpp \
			  equi/equi-stratum.cpp

if ARCH_ARM
if ARCH_ARM_64
ccminer_SOURCES += verus/aarch64/verusscan.cpp verus/aarch64/haraka_portable.c verus/aarch64/haraka.c verus/aarch64/verus_clhash_portable.cpp
libs_ARCH = arm64-v8a
else
ccminer_SOURCES += verus/armv7/verusscan.cpp verus/armv7/haraka_portable.c verus/armv7/haraka.c verus/armv7/verus_clhash_portable.cpp
libs_ARCH = armeabi-v7a
endif
else
if ARCH_x86
ccminer_SOURCES += verus/x86-64/verusscan.cpp verus/x86-64/haraka.c verus/x86-64/verus_clhash.cpp
if ARCH_x86_64
libs_ARCH = x86-64
else
libs_ARCH = x86
endif
endif
endif

if HAVE_WINDOWS
ccminer_SOURCES += compat/winansi.c
endif

if BUILD_STATIC
ccminer_LDFLAGS  = -static $(PTHREAD_FLAGS)
ccminer_LDADD    = libs/$(libs_ARCH)/curl/lib/libcurl.a libs/$(libs_ARCH)/openssl/lib/libcrypto.a libs/$(libs_ARCH)/openssl/lib/libssl.a libs/$(libs_ARCH)/openssl/lib/libcrypto.a libs/$(libs_ARCH)/nghttp2/lib/libnghttp2.a libs/$(libs_ARCH)/lz4/lib/liblz4.a 
ccminer_CPPFLAGS = -I$(top_srcdir)/libs/$(libs_ARCH)/curl/include -I$(top_srcdir)/libs/$(libs_ARCH)/openssl/include -I$(top_srcdir)/libs/$(libs_ARCH)/nghttp2/include -I$(top_srcdir)/libs/$(libs_ARCH)/lz4/include 
else
ccminer_LDFLAGS  = $(PTHREAD_FLAGS)
ccminer_LDADD    = @LIBCURL@ 
ccminer_CPPFLAGS = @LIBCURL_CPPFLAGS@ 
endif

ccminer_LDADD    += @JANSSON_LIBS@ @PTHREAD_LIBS@ @WS2_LIBS@ @OPENMP_CFLAGS@ @LIBS@
ccminer_CPPFLAGS += @OPENMP_CFLAGS@ $(CPPFLAGS) $(PTHREAD_FLAGS) -flax-vector-conversions -fno-strict-aliasing $(JANSSON_INCLUDES) $(DEF_INCLUDES)

if ARCH_ARM
if ARCH_ARM_64
ccminer_CPPFLAGS += -march=armv8-a+crypto
else
ccminer_CPPFLAGS += -march=armv7-a+simd
endif
else
if ARCH_x86_64
ccminer_CPPFLAGS += -march=atom -mtune=atom -msse3 -maes -mpclmul
endif
endif

if HAVE_OSX
ccminer_CPPFLAGS += -I/usr/local/llvm/lib/clang/4.0.0/include
ccminer_LDFLAGS += -L/usr/local/llvm/lib
ccminer_LDADD += -lomp
endif

if HAVE_ANDROID
ccminer_LDADD += -llog
endif

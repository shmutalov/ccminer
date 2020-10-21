# To change the cuda arch, edit Makefile.am and run ./build.sh

extracflags="-D_REENTRANT -falign-functions=16 -falign-jumps=16 -falign-labels=16"

./configure CXXFLAGS="-O3 $extracflags" BUILD_STATIC=false


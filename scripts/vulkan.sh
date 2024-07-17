#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Vulkan Header and Loader
cd $PACKAGES
git clone https://github.com/KhronosGroup/Vulkan-Headers.git --branch main
git clone https://github.com/KhronosGroup/Vulkan-Loader.git --branch main

cd Vulkan-Headers
mkdir out && cd out
cmake .. \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DCMAKE_BUILD_TYPE=Release
cmake --install .

cd $PACKAGES/Vulkan-Loader
mkdir out && cd out
cmake .. \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_FIND_ROOT_PATH="$DIR/opt" \
  -DVULKAN_HEADERS_INSTALL_DIR="$DIR/opt" \
  -DBUILD_SHARED_LIBS=OFF \
  -DAPPLE_STATIC_LOADER=ON \
  -DBUILD_TESTS=OFF \
  -DENABLE_WERROR=OFF
cmake --build .
cmake --install .

mkdir -p $DIR/opt/lib/pkgconfig
cp loader/libvulkan.a $DIR/opt/lib
cp $DIR/vulkan.pc $DIR/opt/lib/pkgconfig

cd $DIR
tar -zcvf vulkan.tar.xz -C $DIR/opt .
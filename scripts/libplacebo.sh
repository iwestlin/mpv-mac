#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

#depends on: vulkan, lcms2(libjpeg-turbo, libtiff(libjpeg-turbo, zlib, zstd(lz4, xz, zlib), xz)), shaderc
# A Free Implementation of the Unicode Bidirectional Algorithm

cd $PACKAGES
git clone --recursive https://github.com/haasn/libplacebo.git
cd libplacebo
meson setup build \
  --prefix="$DIR/opt" \
  --buildtype=release \
  --default-library=static \
  -Dwrap_mode=nodownload \
  -Db_lto=true \
  -Db_lto_mode=thin \
  -Dvulkan-registry="${WORKSPACE}"/share/vulkan/registry/vk.xml \
  -Dvulkan=enabled \
  -Dshaderc=enabled \
  -Dlcms=enabled \
  -Dopengl=enabled \
  -Dd3d11=disabled \
  -Dglslang=disabled \
  -Ddemos=false \
  -Dlibdovi=enabled \
  -Ddemos=false
meson compile -C build
meson install -C build

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libplacebo.tar.xz -C $DIR/opt .

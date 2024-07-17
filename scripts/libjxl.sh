#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

#depends on: brotli, giflib, highway, jpeg-turbo, libpng(zlib), lcms2(libjpeg-turbo, libtiff(libjpeg-turbo, zlib, zstd(lz4, xz, zlib), xz))
# New file format for still image compression
cd $PACKAGES
git clone https://github.com/libjxl/libjxl.git
cd libjxl
git submodule update --init --recursive --depth 1 --recommend-shallow third_party/libjpeg-turbo
mkdir out && cd out
cmake .. \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DCMAKE_FIND_ROOT_PATH="$WORKSPACE" \
  -DBUILD_TESTING=OFF \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DBUILD_SHARED_LIBS=OFF \
  -DJPEGXL_STATIC=OFF \
  -DBUILD_SHARED_LIBS=OFF \
  -DJPEGXL_EMSCRIPTEN=OFF \
  -DJPEGXL_BUNDLE_LIBPNG=OFF \
  -DJPEGXL_ENABLE_TOOLS=OFF \
  -DJPEGXL_ENABLE_VIEWERS=OFF \
  -DJPEGXL_ENABLE_DOXYGEN=OFF \
  -DJPEGXL_ENABLE_EXAMPLES=OFF \
  -DJPEGXL_ENABLE_MANPAGES=OFF \
  -DJPEGXL_ENABLE_JNI=OFF \
  -DJPEGXL_ENABLE_SKCMS=OFF \
  -DJPEGXL_ENABLE_PLUGINS=OFF \
  -DJPEGXL_ENABLE_DEVTOOLS=OFF \
  -DJPEGXL_ENABLE_BENCHMARK=OFF \
  -DJPEGXL_ENABLE_SJPEG=OFF \
  -DJPEGXL_FORCE_SYSTEM_LCMS2=ON \
  -DJPEGXL_FORCE_SYSTEM_BROTLI=ON \
  -DJPEGXL_FORCE_SYSTEM_HWY=ON
cmake --build .
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc
sed -i "" '/Libs.private:/d' $DIR/opt/lib/pkgconfig/libjxl.pc
sed -i "" '/Libs.private:/d' $DIR/opt/lib/pkgconfig/libjxl_threads.pc
echo "Libs.private: -lstdc++" >> $DIR/opt/lib/pkgconfig/libjxl.pc
echo "Libs.private: -lstdc++" >> $DIR/opt/lib/pkgconfig/libjxl_threads.pc
echo "Requires.private: lcms2" >> $DIR/opt/lib/pkgconfig//libjxl_cms.pc

cd $DIR
tar -zcvf libjxl.tar.xz -C $DIR/opt .

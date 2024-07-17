#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# depends on: libX11[util-macros, libxcb, xorgproto(util-macros), xtrans(util-macros)
# depends on: libxcb[xcb-proto libXau(xorgproto(util-macros)), libXdmcp(xorgproto)]

cp $DIR/intl.pc $WORKSPACE/lib/pkgconfig
cd $PACKAGES
git clone https://github.com/FFmpeg/FFmpeg.git
cd FFmpeg
./configure \
  --prefix="$DIR/opt" \
  --pkg-config-flags=--static \
  --disable-debug \
  --disable-doc \
  --enable-gpl \
  --enable-nonfree \
  --disable-shared \
  --disable-ffplay \
  --disable-ffprobe \
  --enable-static \
  --enable-lto=thin \
  --enable-pthreads \
  --enable-version3 \
  --extra-cflags="${CFLAGS}" \
  --extra-ldflags="${LDFLAGS}" \
  --enable-frei0r \
  --enable-lcms2 \
  --enable-libaribb24 \
  --enable-libaribcaption \
  --enable-libass \
  --enable-libbs2b \
  --enable-libcaca \
  --enable-libdav1d \
  --enable-libdavs2 \
  --enable-libdvdnav \
  --enable-libdvdread \
  --enable-libfontconfig \
  --enable-libfreetype \
  --enable-libfribidi \
  --enable-libharfbuzz \
  --enable-libjxl \
  --enable-libmodplug \
  --enable-libmp3lame \
  --enable-libmysofa \
  --enable-libopencore_amrnb \
  --enable-libopencore_amrwb \
  --enable-libopus \
  --enable-libplacebo \
  --enable-librist \
  --enable-librubberband \
  --enable-libsnappy \
  --enable-libsoxr \
  --enable-libspeex \
  --enable-libsrt \
  --enable-libssh \
  --enable-libsvtav1 \
  --enable-libtheora \
  --enable-libuavs3d \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libwebp \
  --enable-libx264 \
  --enable-libx265 \
  --enable-libxml2 \
  --enable-libxvid \
  --enable-libzimg \
  --enable-libzvbi \
  --enable-opencl \
  --enable-openssl \
  --enable-sdl2 \
  --enable-audiotoolbox \
  --enable-videotoolbox \
  --enable-vulkan \
  --disable-htmlpages
make install

mkdir -p $DIR/opt/lib/pkgconfig
find . -type f \( -name "*.pc" ! -name "*uninstalled.pc" \) -print0 | xargs -0 -I {} cp {} $DIR/opt/lib/pkgconfig

cd $DIR
tar -zcvf ffmpeg.tar.xz -C $DIR/opt .
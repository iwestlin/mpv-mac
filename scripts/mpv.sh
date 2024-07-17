#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

cd $PACKAGES
git clone https://github.com/mpv-player/mpv.git
cd mpv
#git reset --hard cb75ecf19f28cfa00ecd348da13bca2550e85963
#export TOOLCHAINS=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" /Library/Developer/Toolchains/swift-latest.xctoolchain/Info.plist)
meson setup build \
  --buildtype=release \
  -Dprefix="${WORKSPACE}" \
  -Dwrap_mode=nodownload \
  -Db_lto=true \
  -Db_lto_mode=thin \
  -Diconv=enabled \
  -Dmanpage-build=disabled \
  -Dswift-flags="-target x86_64-apple-macos11.0"
meson compile -C build
#meson compile -C build macos-bundle

# get latest commit sha
short_sha=$(git rev-parse --short HEAD)
echo $short_sha > build/SHORT_SHA

#bundle mpv
cp -r TOOLS/osxbundle/mpv.app build
cp build/mpv build/mpv.app/Contents/MacOS
cp $WORKSPACE/lib/libvulkan.1.dylib build/mpv.app/Contents/MacOS/lib
cp $WORKSPACE/lib/libluajit-5.1.2.dylib build/mpv.app/Contents/MacOS/lib
mkdir -p build/mpv.app/Contents/Frameworks
cp $WORKSPACE/lib/libMoltenVK.dylib build/mpv.app/Contents/Frameworks
cp -r $WORKSPACE/share/vulkan build/mpv.app/Contents/Resources

for f in build/mpv.app/Contents/MacOS/lib/*.dylib; do
  sudo install_name_tool -id "@executable_path/lib/$(basename $f)" "$f"
done

sed -i "" 's|../../../lib/libMoltenVK.dylib|../../../Frameworks/libMoltenVK.dylib|g' build/mpv.app/Contents/Resources/vulkan/icd.d/MoltenVK_icd.json
sudo install_name_tool -change $DIR/opt/lib/libvulkan.1.dylib @executable_path/lib/libvulkan.1.dylib build/mpv.app/Contents/MacOS/mpv
sudo install_name_tool -change $DIR/opt/lib/libluajit-5.1.2.dylib @executable_path/lib/libluajit-5.1.2.dylib build/mpv.app/Contents/MacOS/mpv


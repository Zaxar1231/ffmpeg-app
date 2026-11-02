#!/usr/bin/env bash
# Builds Kadra-<tag>.AppImage from a release bundle.
#   linux/packaging/build_appimage.sh <bundle dir> <output.AppImage>
# Needs appimagetool on PATH (or APPIMAGETOOL=path). libmpv and the
# libraries it needs are bundled, except those every GTK desktop already has
# (anything GTK 3 links to) and graphics/audio-server/glibc libraries, which
# must come from the host.
set -euo pipefail
bundle=$(readlink -f "$1")
out=$(readlink -f "$2")
here=$(dirname "$(readlink -f "$0")")
tool=${APPIMAGETOOL:-appimagetool}
appdir=$(mktemp -d)/Kadra.AppDir
trap 'rm -rf "$(dirname "$appdir")"' EXIT

mkdir -p "$appdir/usr/bin" "$appdir/usr/lib" "$appdir/usr/share/applications" "$appdir/usr/share/icons/hicolor/256x256/apps"
cp -a "$bundle" "$appdir/usr/bin/kadra"
cp "$here/AppRun" "$appdir/AppRun"
cp "$here/kadra.desktop" "$appdir/kadra.desktop"
cp "$here/kadra.desktop" "$appdir/usr/share/applications/kadra.desktop"
cp "$here/kadra.png" "$appdir/kadra.png"
cp "$here/kadra.png" "$appdir/usr/share/icons/hicolor/256x256/apps/kadra.png"
ln -s kadra.png "$appdir/.DirIcon"

deps() { ldd "$@" 2>/dev/null | awk '/=> \//{print $3}' | sort -u; }
gtk=$(ldconfig -p | awk '/libgtk-3\.so\.0 /{print $NF; exit}')
deps "$gtk" > /tmp/kadra-host-libs
echo "$gtk" >> /tmp/kadra-host-libs
# The libraries libmpv (media_kit) needs.
mpv=$(ldd "$bundle"/lib/libmedia_kit_*plugin.so | awk '/libmpv/{print $3; exit}')
test -n "$mpv" || { echo "libmpv not found"; exit 1; }
n=0
for lib in $mpv $(deps "$mpv"); do
  base=$(basename "$lib")
  grep -qxF "$lib" /tmp/kadra-host-libs && continue
  case "$base" in
    ld-linux*|libc.so*|libm.so*|libdl.so*|libpthread.so*|librt.so*|libresolv.so*|libutil.so*|libstdc++.so*|libgcc_s.so*) continue ;;
    libGL*|libEGL*|libGLX*|libGLdispatch*|libOpenGL*|libdrm*|libgbm*|libvulkan*|libva*|libvdpau*|libwayland*|libX*|libxcb*|libxkb*) continue ;;
    libasound*|libpulse*|libjack*|libpipewire*|libsystemd*|libudev*|libdbus*|libcuda*|libnvidia*) continue ;;
  esac
  cp -L "$lib" "$appdir/usr/lib/$base"
  n=$((n + 1))
done
echo "bundled $n libraries"
ARCH=x86_64 "$tool" --no-appstream "$appdir" "$out"

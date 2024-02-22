set -e

cmake_generator="-GUnix Makefiles"

if command -v ninja; then
    cmake_generator="-GNinja"
fi

mkdir -p deps/build_linux
mkdir -p build_linux

cd deps/build_linux
cmake -DCMAKE_BUILD_TYPE=Release "$cmake_generator" -DDEP_WX_GTK3=ON ..
cmake --build .

cd ../../build_linux
cmake -DCMAKE_BUILD_TYPE=Release "$cmake_generator" -DSLIC3R_STATIC=1 -DSLIC3R_GTK=3 -DSLIC3R_PCH=OFF -DCMAKE_CXX_FLAGS="-Wno-enum-constexpr-conversion" -DCMAKE_PREFIX_PATH="$(pwd)/../deps/build_linux/destdir/usr/local" -DCMAKE_INSTALL_PREFIX="bin" ..
cmake --build .
cmake --install .
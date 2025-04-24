name: Build Qt 6.9.0 Static on Ubuntu

on:
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-22.04
    steps:
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y \
            build-essential \
            ninja-build \
            python3 \
            perl \
            git \
            cmake \
            libgl1-mesa-dev \
            libxcb1-dev \
            libx11-dev \
            libx11-xcb-dev \
            libxext-dev \
            libxfixes-dev \
            libxi-dev \
            libxrender-dev \
            libxrandr-dev \
            libxkbcommon-dev \
            libxcb-glx0-dev \
            libxcb-keysyms1-dev \
            libxcb-image0-dev \
            libxcb-shm0-dev \
            libxcb-icccm4-dev \
            libxcb-sync-dev \
            libxcb-xfixes0-dev \
            libxcb-shape0-dev \
            libxcb-randr0-dev \
            libxcb-render-util0-dev \
            libxcb-xinerama0-dev \
            libxcb-util-dev \
            zlib1g-dev

      - name: Download qtbase source only
        run: |
          curl -LO https://download.qt.io/official_releases/qt/6.9/6.9.0/submodules/qtbase-everywhere-src-6.9.0.tar.xz
          tar xf qtbase-everywhere-src-6.9.0.tar.xz

      - name: Configure and build qtbase statically
        run: |
          mkdir qt-build
          cd qt-build
          cmake -GNinja ../qtbase-everywhere-src-6.9.0 \
            -DCMAKE_INSTALL_PREFIX=../qt6-static-install \
            -DCMAKE_BUILD_TYPE=Release \
            -DBUILD_SHARED_LIBS=OFF \
            -DQT_BUILD_EXAMPLES=OFF \
            -DQT_BUILD_TESTS=OFF \
            -DFEATURE_dbus=ON \
            -DFEATURE_icu=OFF \
            -DFEATURE_opengl=ON \
            -DFEATURE_png=ON \
            -DFEATURE_jpeg=ON \
            -DFEATURE_freetype=ON \
            -DFEATURE_harfbuzz=ON \
            -DQT_FEATURE_gui=ON \
            -DQT_FEATURE_widgets=ON \
            -DINPUT_xcb=ON \
            -DQT_FEATURE_xlib=ON \
            -DQT_FEATURE_xcb=ON \
            -DQT_FEATURE_xcb_xlib=ON \
            -DQT_FEATURE_xkbcommon=ON \
            -DQT_FEATURE_fontconfig=ON \
            -DQT_FEATURE_sessionmanager=ON \
            -DQT_FEATURE_glib=OFF \
            -DQT_FEATURE_xrender=ON \
            -DFEATURE_system_zlib=OFF \
            -DFEATURE_system_png=OFF \
            -DFEATURE_system_jpeg=OFF \
            -DFEATURE_system_freetype=OFF \
            -DFEATURE_system_harfbuzz=OFF

          cmake --build . --parallel
          cmake --install .

      - name: Archive static Qt installation
        run: |
          tar -czf qt6.9.0-static-ubuntu22.04.tar.gz -C qt6-static-install .

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: qt6.9.0-static-ubuntu22.04
          path: qt6.9.0-static-ubuntu22.04.tar.gz
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV QT_VERSION=6.9.0
ENV QT_MODULE=qtbase
ENV INSTALL_PREFIX=/opt/qt6-static

# 必要な依存をインストール
RUN apt-get update && apt-get install -y \
  build-essential \
  ninja-build \
  curl \
  cmake \
  python3 \
  libx11-dev \
  libxext-dev \
  libxfixes-dev \
  libxi-dev \
  libxrender-dev \
  libxcb1-dev \
  libxkbcommon-dev \
  libfontconfig1-dev \
  libfreetype-dev \
  libpng-dev \
  libjpeg-dev \
  libxcb-xkb-dev \
  libxcb-cursor-dev \
  libxcb-render0-dev \
  libxcb-keysyms1-dev \
  libxcb-shape0-dev \
  libxcb-shm0-dev \
  libxcb-icccm4-dev \
  libxcb-image0-dev \
  libxcb-util-dev \
  xz-utils \
  git && \
  rm -rf /var/lib/apt/lists/*

# Qtソース取得 & 展開
WORKDIR /build
RUN curl -LO https://download.qt.io/official_releases/qt/${QT_VERSION%.*}/$QT_VERSION/submodules/${QT_MODULE}-everywhere-src-$QT_VERSION.tar.xz && \
    tar xf ${QT_MODULE}-everywhere-src-$QT_VERSION.tar.xz

# ビルド＆インストール
RUN mkdir qt-build && cd qt-build && \
    cmake -GNinja ../${QT_MODULE}-everywhere-src-$QT_VERSION \
      -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
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
      -DFEATURE_system_harfbuzz=OFF && \
    cmake --build . --parallel && \
    cmake --install .

# パス追加（必要に応じて）
ENV PATH="${INSTALL_PREFIX}/bin:$PATH"
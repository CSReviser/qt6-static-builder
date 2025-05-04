FROM ubuntu:22.04

# 環境変数
ARG DEBIAN_FRONTEND=noninteractive
ARG QT_VERSION=6.9.0
ARG QT_VERSION1=6.9
ARG QT_MODULE=qtbase
ENV QT_VERSION=${QT_VERSION}
ENV QT_MODULE=${QT_MODULE}
ENV INSTALL_PREFIX=/opt/qt6-static

# 依存インストール
# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    git \
    curl \
    ca-certificates \
    libxcb1-dev libxcb-util-dev libx11-dev \
    libxext-dev libxrender-dev libxkbcommon-dev \
    libfontconfig1-dev libfreetype6-dev \
    libpng-dev libjpeg-dev zlib1g-dev \
    libdbus-1-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libglib2.0-dev \
    libgtk-3-dev \
    libssl-dev \
    meson \
    python3-pip \
    pkg-config \
    libxcb-dri2-0-dev \
    && rm -rf /var/lib/apt/lists/*

# Qt取得 & ビルド
# Download and extract Qt module source
WORKDIR /build
RUN curl -LO https://download.qt.io/official_releases/qt/${QT_VERSION%.*}/${QT_VERSION}/submodules/${QT_MODULE}-everywhere-src-${QT_VERSION}.tar.xz && \
    tar -xf ${QT_MODULE}-everywhere-src-${QT_VERSION}.tar.xz

# Configure, build, and install Qt statically
RUN mkdir qt-build && cd qt-build && \
    cmake -GNinja ../${QT_MODULE}-everywhere-src-${QT_VERSION} \
      -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=OFF \
      -DQT_BUILD_EXAMPLES=OFF \
      -DQT_BUILD_TESTS=OFF \
      -DFEATURE_dbus=ON \                   # 必要に応じて OFF にしてもOK
      -DFEATURE_icu=OFF \
      -DQT_FEATURE_static=ON \
      -DQT_FEATURE_openssl=ON \
      -DQT_FEATURE_openssl_linked=ON \
      -DQT_FEATURE_gui=ON \
      -DQT_FEATURE_widgets=ON \
      -DQT_FEATURE_xlib=ON \
      -DQT_FEATURE_xcb=ON \
      -DQT_FEATURE_xkbcommon=ON \
      -DQT_FEATURE_xrender=ON \
      -DQT_FEATURE_fontconfig=ON \
      -DQT_FEATURE_sessionmanager=ON \
      -DFEATURE_glib=OFF \
      -DQT_FEATURE_opengl=OFF \             # WrapOpenGL_FOUND=FALSE 対策
      -DFEATURE_system_zlib=OFF \
      -DFEATURE_system_png=OFF \
      -DFEATURE_system_jpeg=OFF \
      -DFEATURE_system_freetype=OFF \
      -DFEATURE_system_harfbuzz=OFF \
      -DFEATURE_png=ON \
      -DFEATURE_jpeg=ON \
      -DFEATURE_freetype=ON \
      -DFEATURE_harfbuzz=ON && \
    cmake --build . --parallel && \
    cmake --install .

# PATH登録
ENV PATH="/opt/qt6-static/bin:$PATH"

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
    qt6-base-dev \
    cmake \
    ninja-build \
    git \
    curl \
    ca-certificates \
    libx11-dev \
    libfontconfig1-dev \
    libfreetype-dev \
    libgtk-3-dev \
    libx11-dev \
    libx11-xcb-dev \
    libxcb-cursor-dev \
    libxcb-glx0-dev \
    libxcb-icccm4-dev \
    libxcb-image0-dev \
    libxcb-keysyms1-dev \
    libxcb-randr0-dev \
    libxcb-render-util0-dev \
    libxcb-shape0-dev \
    libxcb-shm0-dev \
    libxcb-sync-dev \
    libxcb-util-dev \
    libxcb-xfixes0-dev \
    libxcb-xkb-dev \
    libxcb1-dev \
    libxext-dev \
    libxfixes-dev \
    libxi-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libxrender-dev \
    libxfixes-dev \
    libxi-dev \
    libxrender-dev \
    libxcb1-dev \
    libx11-xcb-dev \
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
    libxcb-util-dev \
    libxcb-cursor-dev \
    libxcb-xkb-dev \
    libxkbcommon-x11-dev \
    libxcb-util-dev \
    libxcb-xinerama0-dev \
    libxkbcommon-dev \
    libfontconfig1-dev \
    libfreetype-dev \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    zlib1g-dev \
    libdbus-1-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libglib2.0-dev \
    libgtk-3-dev \
    libssl-dev \
    libwayland-dev \
    libwayland-egl-backend-dev \
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
      -DFEATURE_dbus=ON \
      -DFEATURE_icu=OFF \
      -DQT_FEATURE_opengl_desktop=OFF \
      -DQT_FEATURE_static=ON \
      -DQT_FEATURE_openssl=ON \
      -DQT_FEATURE_openssl_linked=ON \
      -DFEATURE_png=ON \
      -DFEATURE_jpeg=ON \
      -DFEATURE_freetype=ON \
      -DFEATURE_harfbuzz=ON \
      -DQT_FEATURE_gui=ON \
      -DQT_FEATURE_widgets=ON \
      -DQT_FEATURE_xlib=ON \
      -DQT_FEATURE_xcb=ON \
      -DQT_FEATURE_xkbcommon=ON \
      -DQT_FEATURE_fontconfig=ON \
      -DQT_FEATURE_sessionmanager=ON \
      -DQT_FEATURE_glib=OFF \
      -DQT_FEATURE_xrender=ON \
　　　　-DFEATURE_system_xbc=OFF \
      -DFEATURE_system_zlib=OFF \
      -DFEATURE_system_png=OFF \
      -DFEATURE_system_jpeg=OFF \
      -DFEATURE_system_freetype=OFF \
      -DFEATURE_system_harfbuzz=OFF && \
    cmake --build . --parallel && \
    cmake --install . 

# PATH登録
ENV PATH="/opt/qt6-static/bin:$PATH"

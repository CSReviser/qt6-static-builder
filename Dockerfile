# Dockerfile
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG QT_VERSION=6.9.0
ARG QT_MODULE=qtbase
ENV QT_VERSION=${QT_VERSION}
ENV QT_MODULE=${QT_MODULE}
ENV INSTALL_PREFIX=/opt/qt6-static

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    git \
    curl \
    ca-certificates \
    libx11-dev \
    libxext-dev \
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
    libxkbcommon-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

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
      -DFEATURE_opengl=ON \
      -DFEATURE_png=ON \
      -DFEATURE_jpeg=ON \
      -DFEATURE_freetype=ON \
      -DFEATURE_harfbuzz=ON \
      -DQT_FEATURE_gui=ON \
      -DQT_FEATURE_widgets=ON \
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
    echo "=== CMake configure succeeded ===" && \
    cmake --build . --parallel && \
    echo "=== Build succeeded ===" && \
    cmake --install . && \
    echo "=== Install succeeded ==="
#    cmake --build . --parallel && \
#    cmake --install .

# Set final image with only installed Qt (optional for size)
FROM ubuntu:22.04
COPY --from=0 /opt/qt6-static /opt/qt6-static
ENV PATH="/opt/qt6-static/bin:$PATH"
FROM ubuntu:22.04

# 環境変数
ARG DEBIAN_FRONTEND=noninteractive
ARG QT_VERSION=6.9.0
ARG QT_VERSION1=6.9
ARG QT_MODULE=qtbase
ENV QT_VERSION=${QT_VERSION}
ENV QT_MODULE=${QT_MODULE}
ENV INSTALL_PREFIX=/opt/qt6-static
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:/usr/local/lib/x86_64-linux-gnu/pkgconfig

# 依存インストール
# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    git \
    curl \
    wget \
    ca-certificates \
    libxcb1-dev libxcb-util-dev libx11-dev \
    libxext-dev libxrender-dev libxkbcommon-dev \
    libfontconfig1-dev libfreetype6-dev \
    libpng-dev libjpeg-dev zlib1g-dev \
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


# libpng
RUN wget https://download.sourceforge.net/libpng/libpng-1.6.37.tar.gz && \
    tar -xzf libpng-1.6.37.tar.gz && \
    cd libpng-1.6.37 && \
    ./configure --prefix=/usr/local --disable-shared --enable-static && make -j$(nproc) && make install

# libXext
RUN wget https://xorg.freedesktop.org/archive/individual/lib/libXext-1.3.5.tar.gz && \
    tar -xzf libXext-1.3.5.tar.gz && \
    cd libXext-1.3.5 && \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig \
    ./configure --prefix=/usr/local --disable-shared --enable-static && \
    make -j$(nproc) && make install

# FreeType (static)
RUN wget https://download.savannah.gnu.org/releases/freetype/freetype-2.13.2.tar.gz && \
    tar -xf freetype-2.13.2.tar.gz && cd freetype-2.13.2 && \
    ./configure \
      --prefix=/usr/local \
      --with-harfbuzz=yes \
      --enable-static \
      --disable-shared \
      --with-pic \
      --without-bzip2 \
      HARFBUZZ_CFLAGS="$(pkg-config --cflags harfbuzz)" \
      HARFBUZZ_LIBS="$(pkg-config --libs harfbuzz)" && \
    make -j$(nproc) && \
    make install
    
# fontconfig (static)
RUN wget https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.15.0.tar.gz && \
    tar -xf fontconfig-2.15.0.tar.gz && cd fontconfig-2.15.0 && \
    env \
      PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/lib/x86_64-linux-gnu/pkgconfig" \
      CPPFLAGS="-I/usr/local/include" \
      LDFLAGS="-L/usr/local/lib" \
      CFLAGS="-fPIC" \
    ./configure --prefix=/usr/local --enable-static --disable-shared \
        --enable-libxml2 && \
    make -j$(nproc) && \
    make install


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
      -DQT_FEATURE_static=ON \
      -DQT_FEATURE_gui=ON \
      -DQT_FEATURE_widgets=ON \
      -DQT_FEATURE_dbus=ON \
      -DQT_FEATURE_icu=OFF \
      -DQT_FEATURE_opengl_desktop=OFF \
      -DQT_FEATURE_openssl=ON \
      -DQT_FEATURE_openssl_linked=ON \
      -DQT_FEATURE_png=ON \
      -DQT_FEATURE_jpeg=ON \
      -DQT_FEATURE_freetype=ON \
      -DQT_FEATURE_harfbuzz=ON \
      -DQT_FEATURE_xlib=ON \
      -DQT_FEATURE_xcb=ON \
      -DQT_FEATURE_xkbcommon=ON \
      -DQT_FEATURE_fontconfig=ON \
      -DQT_FEATURE_sessionmanager=ON \
      -DQT_FEATURE_glib=OFF \
      -DQT_FEATURE_xrender=ON \
      -DQT_FEATURE_system_zlib=OFF \
      -DQT_FEATURE_system_png=OFF \
      -DQT_FEATURE_system_jpeg=OFF \
      -DQT_FEATURE_system_freetype=OFF \
      -DQT_FEATURE_system_harfbuzz=OFF && \
    cmake --build . --parallel && \
    cmake --install .

# PATH登録
ENV PATH="/opt/qt6-static/bin:$PATH"

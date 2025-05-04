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
    gperf \
    ca-certificates \
    libxcb1-dev libxcb-util-dev libx11-dev \
    libxext-dev libxrender-dev libxkbcommon-dev \
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

# zlib (静的ビルド強制)
RUN wget https://zlib.net/zlib-1.3.1.tar.gz && \
    tar -xzf zlib-1.3.1.tar.gz && \
    cd zlib-1.3.1 && \
    ./configure --static --prefix=/usr/local && make -j$(nproc) && make install

# libxml2 (static)
RUN wget https://github.com/GNOME/libxml2/archive/refs/tags/v2.14.2.tar.gz && \
    tar -xf v2.14.2.tar.gz && cd libxml2-2.14.2 && \
    cmake -B build -GNinja \
      -D BUILD_SHARED_LIBS=OFF \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D LIBXML2_WITH_PYTHON=OFF \
      -D LIBXML2_WITH_ZLIB=ON \
      -D LIBXML2_WITH_ICONV=OFF && \
    cmake --build build -j$(nproc) && \
    cmake --install build

# libpng
RUN wget https://download.sourceforge.net/libpng/libpng-1.6.37.tar.gz && \
    tar -xzf libpng-1.6.37.tar.gz && \
    cd libpng-1.6.37 && \
    ./configure --prefix=/usr/local --disable-shared --enable-static && make -j$(nproc) && make install

# libjpeg-turbo (static)
RUN wget https://downloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-3.0.2.tar.gz && \
    tar -xzf libjpeg-turbo-3.0.2.tar.gz && cd libjpeg-turbo-3.0.2 && \
    cmake -B build -G"Unix Makefiles" \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DENABLE_SHARED=OFF \
        -DENABLE_STATIC=ON && \
    cmake --build build -j$(nproc) && \
    cmake --install build

# libXext
RUN wget https://xorg.freedesktop.org/archive/individual/lib/libXext-1.3.5.tar.gz && \
    tar -xzf libXext-1.3.5.tar.gz && \
    cd libXext-1.3.5 && \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig \
    ./configure --prefix=/usr/local --disable-shared --enable-static && \
    make -j$(nproc) && make install

# FreeType (static)
RUN wget https://download.savannah.gnu.org/releases/freetype/freetype-2.9.1.tar.gz && \
    tar -xf freetype-2.9.1.tar.gz && cd freetype-2.9.1 && \
    ./configure \
      --prefix=/usr/local \
      --with-harfbuzz=yes \
      --enable-static \
      --disable-shared \
      --with-pic \
      --with-bdfformat \
      --without-bzip2 \
      HARFBUZZ_CFLAGS="$(pkg-config --cflags harfbuzz)" \
      HARFBUZZ_LIBS="$(pkg-config --libs harfbuzz)"

# harfbuzz (static, .pc生成確認)
RUN wget https://github.com/harfbuzz/harfbuzz/releases/download/8.3.0/harfbuzz-8.3.0.tar.xz && \
    tar -xf harfbuzz-8.3.0.tar.xz && cd harfbuzz-8.3.0 && \
    meson setup build \
      --prefix=/usr/local \
      --buildtype=release \
      --libdir=lib \
      -Ddefault_library=static \
      -Dtests=disabled \
      -Ddocs=disabled \
      -Dbenchmark=disabled \
      -Dintrospection=disabled && \
    ninja -C build && \
    ninja -C build install

# fontconfig (static)
RUN wget https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.15.0.tar.gz && \
    tar -xf fontconfig-2.15.0.tar.gz && cd fontconfig-2.15.0 && \
    env \
      PKG_CONFIG_PATH="/usr/local/lib/pkgconfig" \
      CPPFLAGS="-I/usr/local/include" \
      LDFLAGS="-L/usr/local/lib -lxml2 -lfreetype -lz -lpng -lXext" \
      CFLAGS="-fPIC" \
    ./configure \
      --prefix=/usr/local \
      --enable-static \
      --disable-shared \
      --enable-libxml2

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
      -DQT_FEATURE_system_zlib=ON \
      -DQT_FEATURE_system_png=ON \
      -DQT_FEATURE_system_jpeg=OFF \
      -DQT_FEATURE_system_freetype=OM \
      -DQT_FEATURE_system_harfbuzz=ON && \
    cmake --build . --parallel && \
    cmake --install .

# PATH登録
ENV PATH="/opt/qt6-static/bin:$PATH"

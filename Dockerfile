FROM ubuntu:22.04

# 環境変数
ENV DEBIAN_FRONTEND=noninteractive
ENV MAKEFLAGS=-j$(nproc)
ENV QT_VERSION=6.9.0
ENV QT_DIR=/opt/qt6-static

# 依存インストール
RUN apt-get update && apt-get install -y \
    build-essential \
    ninja-build \
    perl \
    python3 \
    git \
    curl \
    ca-certificates \
    libgl1-mesa-dev \
    libxcb1-dev libx11-dev libxext-dev libxfixes-dev libxi-dev libxrender-dev \
    libxcb-glx0-dev libxcb-shm0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-randr0-dev \
    libxcb-image0-dev libxcb-keysyms1-dev libxcb-icccm4-dev libxcb-sync-dev libxcb-xinerama0-dev \
    libxcb-util-dev libxkbcommon-dev libxkbcommon-x11-dev \
    && rm -rf /var/lib/apt/lists/*

# Qt取得 & ビルド
WORKDIR /tmp
RUN curl -LO https://download.qt.io/official_releases/qt/6.9/${QT_VERSION}/single/qt-everywhere-src-${QT_VERSION}.tar.xz \
    && tar -xf qt-everywhere-src-${QT_VERSION}.tar.xz \
    && cd qt-everywhere-src-${QT_VERSION} \
    && ./configure -prefix ${QT_DIR} \
                  -static \
                  -release \
                  -opensource -confirm-license \
                  -nomake tests -nomake examples \
                  -skip qtwebengine \
                  -skip qt3d \
                  -skip qtlocation \
                  -skip qtserialport \
                  -skip qttools \
                  -skip qttranslations \
                  -skip qtquick3d \
                  -skip qtconnectivity \
                  -skip qtdoc \
                  -skip qtremoteobjects \
                  -skip qtwebchannel \
                  -skip qtwebsockets \
                  -skip qtsensors \
                  -skip qtpositioning \
    && cmake --build . --parallel \
    && cmake --install . \
    && cd / && rm -rf /tmp/*

# PATH登録
ENV PATH="${QT_DIR}/bin:$PATH"
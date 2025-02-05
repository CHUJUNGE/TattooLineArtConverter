#!/bin/bash

# 下载并解压 Flutter SDK
FLUTTER_VERSION="3.16.5"
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# 设置环境变量
export PATH="$PATH:$(pwd)/flutter/bin"

# 禁用 Flutter 分析
export FLUTTER_CLI_ANALYTICS=false

# 安装依赖
flutter config --no-analytics
flutter doctor
flutter pub get

# 构建 Web 应用
flutter build web --release

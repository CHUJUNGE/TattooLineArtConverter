#!/bin/bash

# 下载 Flutter SDK
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:$(pwd)/flutter/bin"

# 安装 Flutter 依赖
flutter precache
flutter doctor

# 构建 Web 应用
flutter pub get
flutter build web --release

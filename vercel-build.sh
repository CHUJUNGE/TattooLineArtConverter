#!/bin/bash

# Download Flutter
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"

# Install dependencies and build
flutter pub get
flutter build web --release

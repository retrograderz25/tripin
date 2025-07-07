#!/bin/bash

# Thoát ngay lập tức nếu có lệnh nào thất bại
set -e

# 1. Cài đặt Flutter SDK
echo ">>>> Cloning Flutter repository..."
git clone https://github.com/flutter/flutter.git --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

# 2. Kiểm tra phiên bản Flutter (tùy chọn nhưng hữu ích để debug)
flutter --version

# 3. Kích hoạt Flutter web
echo ">>>> Enabling Flutter web..."
flutter config --enable-web

# 4. Tải các package của dự án
echo ">>>> Getting pub dependencies..."
flutter pub get

# 5. Build dự án Flutter Web
echo ">>>> Building Flutter web..."
flutter build web --release --no-tree-shake-icons
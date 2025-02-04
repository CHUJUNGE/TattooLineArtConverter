# TattooLineArtConverter

一款使用Flutter开发的纹身设计辅助应用，专为纹身师设计，用于将纹身图片转换为黑白线稿，简化转印工作流程。这是一个个人使用的工具，使用免费开发者账号在个人iOS设备上运行。

## 功能特点

- 📸 图片上传：支持从相册选择或直接拍摄纹身图片
- ✏️ 自动线稿转换：将彩色/灰度图片转换为清晰的黑白线稿
- 🎨 线稿编辑：支持调整线条粗细、对比度等参数
- 💾 本地存储：支持将作品保存到本地图库
- 📁 作品管理：便捷的图片管理系统，支持分类和搜索

## 技术栈

- Flutter 3.19+
- Dart 3.0+
- image: ^4.0.17 (图片处理)
- provider: ^6.0.5 (状态管理)
- path_provider: ^2.0.15 (文件存储)
- camera: ^0.10.5+ (相机功能)
- image_picker: ^1.0.4 (图片选择)
- sqflite: ^2.3.0 (本地数据库)

## 开发环境要求

- Flutter SDK 3.19+
- Dart SDK 3.0+
- Android Studio / VS Code
- Windows 10/11
- 免费 Apple Developer 账号

## iOS设备运行说明

1. 在iOS设备上启用开发者模式
2. 使用免费Apple账号签名应用
3. 通过USB连接将应用安装到设备上
4. 注意：应用需要每7天重新安装一次

## 安装说明

1. 克隆仓库
```bash
git clone https://github.com/CHUJUNGE/TattooLineArtConverter.git
```

2. 安装依赖
```bash
flutter pub get
```

3. 运行项目（需要设备连接）
```bash
flutter run
```

## 项目结构

```
TattooLineArtConverter/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── editor_screen.dart
│   │   └── gallery_screen.dart
│   ├── models/
│   ├── services/
│   │   ├── image_processor.dart
│   │   └── storage_service.dart
│   ├── widgets/
│   └── utils/
├── assets/
├── test/
└── pubspec.yaml
```

## 开发计划

- [x] 项目初始化
- [ ] 基础UI搭建
- [ ] 图片选择功能
- [ ] 图片转换算法实现
- [ ] 线稿编辑功能
- [ ] 本地存储实现
- [ ] 作品管理系统

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

# TattooLineArtConverter

一款使用Flutter开发的纹身设计辅助应用，使用开源计算机视觉技术，专为纹身师设计，用于将纹身图片转换为高精度的黑白线稿，简化转印工作流程。这是一个完全免费的个人使用工具。

## 功能特点

- 图片导入：支持从相册选择纹身图片
- 智能线条识别：使用OpenCV进行精确的线条检测和提取
- 智能线稿转换：将彩色/灰度图片转换为清晰的黑白线稿
- 专业线稿编辑：
  - 智能线条优化
  - 自动去噪和平滑处理
  - 支持调整线条粗细、对比度等参数
  - 局部细节增强
- 本地存储：支持将作品保存到本地图库
- 作品管理：便捷的图片管理系统，支持分类和搜索

## 技术栈（全部开源免费）

- Flutter 3.19+ (开源UI框架)
- Dart 3.0+ (开源编程语言)
- opencv: ^4.7.0 (开源计算机视觉库)
- image: ^4.0.17 (图片处理)
- provider: ^6.0.5 (状态管理)
- path_provider: ^2.0.15 (文件存储)
- image_picker: ^1.0.4 (图片选择)
- sqflite: ^2.3.0 (本地数据库)

## 图像处理技术

使用完全开源的解决方案：
- OpenCV进行图像处理：
  - Canny边缘检测
  - 自适应阈值处理
  - 轮廓检测和优化
  - 图像平滑和降噪
- 图像增强算法：
  - 直方图均衡化
  - 自适应对比度调整
  - 形态学处理
  
所有处理都在本地设备完成，无需联网，无需付费服务。

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

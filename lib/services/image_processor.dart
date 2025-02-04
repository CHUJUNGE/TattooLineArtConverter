import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ImageProcessor {
  static const int INPUT_SIZE = 512;
  static Interpreter? _interpreter;
  static bool _isModelLoaded = false;

  static Future<void> initialize() async {
    if (_isModelLoaded) return;

    try {
      // 加载模型
      final modelPath = await _getModel();
      final interpreterOptions = InterpreterOptions()
        ..threads = 4
        ..useNnApiForAndroid = true; // 在Android上使用Neural Networks API
      _interpreter = await Interpreter.fromFile(File(modelPath), options: interpreterOptions);
      _isModelLoaded = true;
      print('TFLite model loaded successfully');
    } catch (e) {
      print('Error initializing TFLite: $e');
      rethrow;
    }
  }

  static Future<String> _getModel() async {
    // 从assets复制模型到本地存储
    final appDir = await getApplicationDocumentsDirectory();
    final modelFile = File('${appDir.path}/model.tflite');

    if (!await modelFile.exists()) {
      final modelBytes = await rootBundle.load('assets/model.tflite');
      await modelFile.writeAsBytes(modelBytes.buffer.asUint8List());
    }

    return modelFile.path;
  }

  static Future<File> processImage(File inputImage) async {
    if (_interpreter == null) {
      throw Exception('TFLite interpreter not initialized');
    }

    // 读取图片
    final image = img.decodeImage(await inputImage.readAsBytes());
    if (image == null) throw Exception('Failed to decode image');

    // 调整图片大小到 512x512
    final resized = img.copyResize(image, width: INPUT_SIZE, height: INPUT_SIZE);

    // 转换为float32数组 [1, 512, 512, 3]
    var inputArray = List.generate(
      1,
      (_) => List.generate(
        INPUT_SIZE,
        (y) => List.generate(
          INPUT_SIZE,
          (x) => List.generate(
            3,
            (c) {
              final pixel = resized.getPixel(x, y);
              // 归一化到 [-1, 1]
              return (c == 0 ? pixel.r : (c == 1 ? pixel.g : pixel.b)) / 127.5 - 1.0;
            },
          ),
        ),
      ),
    );

    // 准备输出tensor [1, 512, 512, 1]
    var outputShape = [1, INPUT_SIZE, INPUT_SIZE, 1];
    var outputArray = List.generate(
      outputShape[0],
      (_) => List.generate(
        outputShape[1],
        (_) => List.generate(
          outputShape[2],
          (_) => List.filled(outputShape[3], 0.0),
        ),
      ),
    );

    // 运行模型
    _interpreter!.run(inputArray, outputArray);

    // 转换输出为图片
    final outputImage = img.Image(width: INPUT_SIZE, height: INPUT_SIZE);
    for (var y = 0; y < INPUT_SIZE; y++) {
      for (var x = 0; x < INPUT_SIZE; x++) {
        // 将输出值从[-1, 1]转换到[0, 255]
        final value = ((outputArray[0][y][x][0] + 1.0) * 127.5).round().clamp(0, 255);
        outputImage.setPixel(x, y, img.ColorRgb8(value, value, value));
      }
    }

    // 调整回原始大小
    final finalImage = img.copyResize(outputImage, width: image.width, height: image.height);

    // 保存结果
    final tempDir = await getTemporaryDirectory();
    final outputFile = File('${tempDir.path}/output.png');
    await outputFile.writeAsBytes(img.encodePng(finalImage));

    return outputFile;
  }

  static Future<String> convertToLineArt(String imagePath, {
    double threshold = 0.5,
  }) async {
    try {
      await initialize();
      final inputFile = File(imagePath);
      final outputFile = await processImage(inputFile);
      return outputFile.path;
    } catch (e) {
      print('Error converting to line art: $e');
      rethrow;
    }
  }

  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isModelLoaded = false;
  }
}

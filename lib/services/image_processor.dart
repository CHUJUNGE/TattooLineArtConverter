import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class ImageProcessor {
  static const String _apiUrl = 'https://api.replicate.com/v1/predictions';
  static const String _modelVersion = '435061a1b5a4c1e26740464bf786efdfa9cb3a3ac488595a2de23e143fdb0117';
  static const String _apiToken = 'r8_2Yd5Vf3lFTp0rvVQpQfALWbVNVxrEsYKRtYEa';

  static Future<String> convertToLineArt(String imagePath, {
    double threshold = 0.5,
  }) async {
    try {
      if (_apiToken.isEmpty) {
        throw Exception('Replicate API token not found.');
      }

      // 读取图片数据
      late Uint8List imageBytes;
      if (kIsWeb) {
        if (imagePath.startsWith('data:image')) {
          final String base64 = imagePath.split(',')[1];
          imageBytes = base64Decode(base64);
        } else {
          throw Exception('Web platform only supports base64 images currently');
        }
      } else {
        throw Exception('This version only supports web platform');
      }

      // 将图片转换为base64
      final base64Image = base64Encode(imageBytes);

      // 创建预测
      final response = await http.post(
        Uri.parse('https://api.replicate.com/v1/predictions'),
        headers: {
          'Authorization': 'Token $_apiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'version': 'a36ad6b92ced6e05ce2c6a71c0543f6a244382a9e3d9312a9771f3a57db92a54',
          'input': {
            'image': 'data:image/png;base64,$base64Image',
          },
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create prediction: ${response.body}');
      }

      final predictionData = jsonDecode(response.body);
      final String predictionId = predictionData['id'];

      // 轮询获取结果
      while (true) {
        final statusResponse = await http.get(
          Uri.parse('https://api.replicate.com/v1/predictions/$predictionId'),
          headers: {
            'Authorization': 'Token $_apiToken',
          },
        );

        if (statusResponse.statusCode != 200) {
          throw Exception('Failed to get prediction status: ${statusResponse.body}');
        }

        final statusData = jsonDecode(statusResponse.body);
        if (statusData['status'] == 'succeeded') {
          final outputUrl = statusData['output'] as String;
          
          // 下载生成的图片
          final imageResponse = await http.get(Uri.parse(outputUrl));
          if (imageResponse.statusCode != 200) {
            throw Exception('Failed to download result image');
          }

          // 返回base64格式的图片数据
          return 'data:image/png;base64,${base64Encode(imageResponse.bodyBytes)}';
        } else if (statusData['status'] == 'failed') {
          throw Exception('Prediction failed: ${statusData['error']}');
        }

        // 等待一秒后再次检查
        await Future.delayed(const Duration(seconds: 1));
      }
    } catch (e) {
      print('Error converting to line art: $e');
      rethrow;
    }
  }

  static Future<String> processImage(String imagePath) async {
    try {
      // 创建预测任务
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Token $_apiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'version': _modelVersion,
          'input': {
            'image': imagePath,
          },
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('创建预测任务失败: ${response.body}');
      }

      final predictionData = jsonDecode(response.body);
      final String predictionId = predictionData['id'];

      // 轮询获取结果
      while (true) {
        final statusResponse = await http.get(
          Uri.parse('$_apiUrl/$predictionId'),
          headers: {
            'Authorization': 'Token $_apiToken',
          },
        );

        if (statusResponse.statusCode != 200) {
          throw Exception('获取预测结果失败: ${statusResponse.body}');
        }

        final statusData = jsonDecode(statusResponse.body);
        final String status = statusData['status'];

        if (status == 'succeeded') {
          return statusData['output'];
        } else if (status == 'failed') {
          throw Exception('预测任务失败: ${statusData['error']}');
        }

        await Future.delayed(const Duration(seconds: 1));
      }
    } catch (e) {
      throw Exception('处理图片时出错: $e');
    }
  }

  static void downloadImage(String url, String fileName) {
    if (kIsWeb) {
      final anchor = html.AnchorElement(
        href: url,
      )
        ..setAttribute('download', fileName)
        ..click();
    }
  }
}

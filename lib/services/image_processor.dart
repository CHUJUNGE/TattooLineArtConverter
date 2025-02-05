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
      final client = http.Client();
      final response = await client.post(
        Uri.parse('https://api.replicate.com/v1/predictions'),
        headers: {
          'Authorization': 'Token $_apiToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: jsonEncode({
          'version': 'a36ad6b92ced6e05ce2c6a71c0543f6a244382a9e3d9312a9771f3a57db92a54',
          'input': {
            'image': 'data:image/png;base64,$base64Image',
          },
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('请求超时，请稍后重试');
        },
      );

      if (response.statusCode != 201) {
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to create prediction: ${errorBody['error'] ?? response.body}');
      }

      final predictionData = jsonDecode(response.body);
      final String predictionId = predictionData['id'];

      // 轮询获取结果
      int retryCount = 0;
      while (retryCount < 30) { // 最多尝试30次，每次等待1秒
        final statusResponse = await client.get(
          Uri.parse('https://api.replicate.com/v1/predictions/$predictionId'),
          headers: {
            'Authorization': 'Token $_apiToken',
            'Accept': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('获取结果超时，请稍后重试');
          },
        );

        if (statusResponse.statusCode != 200) {
          final errorBody = jsonDecode(statusResponse.body);
          throw Exception('Failed to get prediction status: ${errorBody['error'] ?? statusResponse.body}');
        }

        final statusData = jsonDecode(statusResponse.body);
        final String status = statusData['status'];

        if (status == 'succeeded') {
          client.close();
          final outputUrl = statusData['output'] as String;
          
          // 下载生成的图片
          final imageResponse = await http.get(Uri.parse(outputUrl));
          if (imageResponse.statusCode != 200) {
            throw Exception('Failed to download result image');
          }

          // 返回base64格式的图片数据
          return 'data:image/png;base64,${base64Encode(imageResponse.bodyBytes)}';
        } else if (status == 'failed') {
          client.close();
          throw Exception('Prediction failed: ${statusData['error']}');
        }

        await Future.delayed(const Duration(seconds: 1));
        retryCount++;
      }

      client.close();
      throw Exception('处理超时，请稍后重试');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error converting to line art: $e');
    }
  }

  static Future<String> processImage(String imagePath) async {
    try {
      // 创建预测任务
      final client = http.Client();
      final response = await client.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Token $_apiToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: jsonEncode({
          'version': _modelVersion,
          'input': {
            'image': imagePath,
          },
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('请求超时，请稍后重试');
        },
      );

      if (response.statusCode != 201) {
        final errorBody = jsonDecode(response.body);
        throw Exception('创建预测任务失败: ${errorBody['error'] ?? response.body}');
      }

      final predictionData = jsonDecode(response.body);
      final String predictionId = predictionData['id'];

      // 轮询获取结果
      int retryCount = 0;
      while (retryCount < 30) { // 最多尝试30次，每次等待1秒
        final statusResponse = await client.get(
          Uri.parse('$_apiUrl/$predictionId'),
          headers: {
            'Authorization': 'Token $_apiToken',
            'Accept': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('获取结果超时，请稍后重试');
          },
        );

        if (statusResponse.statusCode != 200) {
          final errorBody = jsonDecode(statusResponse.body);
          throw Exception('获取预测结果失败: ${errorBody['error'] ?? statusResponse.body}');
        }

        final statusData = jsonDecode(statusResponse.body);
        final String status = statusData['status'];

        if (status == 'succeeded') {
          client.close();
          return statusData['output'];
        } else if (status == 'failed') {
          client.close();
          throw Exception('预测任务失败: ${statusData['error']}');
        }

        await Future.delayed(const Duration(seconds: 1));
        retryCount++;
      }

      client.close();
      throw Exception('处理超时，请稍后重试');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
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

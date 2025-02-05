import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class ImageProcessor {
  static const String _modelVersion = '435061a1b5a4c1e26740464bf786efdfa9cb3a3ac488595a2de23e143fdb0117';
  static const String _apiToken = 'r8_2Yd5Vf3lFTp0rvVQpQfALWbVNVxrEsYKRtYEa';

  static Future<String> convertToLineArt(String imagePath, {
    double threshold = 0.5,
  }) async {
    try {
      developer.log('开始处理图片', name: 'ImageProcessor');
      developer.log('图片路径: $imagePath', name: 'ImageProcessor');

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

      // 获取当前URL
      final currentUrl = html.window.location.href;
      final uri = Uri.parse(currentUrl);
      final apiUrl = '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}/api/process-image';
      
      developer.log('API URL: $apiUrl', name: 'ImageProcessor');

      // 发送到我们自己的API
      developer.log('发送API请求...', name: 'ImageProcessor');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'image': 'data:image/png;base64,$base64Image',
        }),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          developer.log('请求超时', name: 'ImageProcessor', error: '请求超时，请稍后重试');
          throw Exception('请求超时，请稍后重试');
        },
      );

      developer.log('收到响应: ${response.statusCode}', name: 'ImageProcessor');
      developer.log('响应体: ${response.body}', name: 'ImageProcessor');

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        final errorMessage = '处理图片失败: ${errorBody['error']}';
        developer.log('错误', name: 'ImageProcessor', error: errorMessage);
        throw Exception(errorMessage);
      }

      final result = jsonDecode(response.body);
      final output = result['output'] as String;
      developer.log('处理成功，输出: $output', name: 'ImageProcessor');
      return output;
    } catch (e, stackTrace) {
      developer.log(
        '处理图片时出错',
        name: 'ImageProcessor',
        error: e.toString(),
        stackTrace: stackTrace,
      );
      if (e is Exception) {
        rethrow;
      }
      throw Exception('处理图片时出错: $e');
    }
  }

  static Future<String> processImage(String imagePath) async {
    try {
      developer.log('开始处理图片', name: 'ImageProcessor');
      developer.log('图片路径: $imagePath', name: 'ImageProcessor');

      // 获取当前URL
      final currentUrl = html.window.location.href;
      final uri = Uri.parse(currentUrl);
      final apiUrl = '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}/api/process-image';
      
      developer.log('API URL: $apiUrl', name: 'ImageProcessor');

      // 发送到我们自己的API
      developer.log('发送API请求...', name: 'ImageProcessor');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'image': imagePath,
        }),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          developer.log('请求超时', name: 'ImageProcessor', error: '请求超时，请稍后重试');
          throw Exception('请求超时，请稍后重试');
        },
      );

      developer.log('收到响应: ${response.statusCode}', name: 'ImageProcessor');
      developer.log('响应体: ${response.body}', name: 'ImageProcessor');

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        final errorMessage = '处理图片失败: ${errorBody['error']}';
        developer.log('错误', name: 'ImageProcessor', error: errorMessage);
        throw Exception(errorMessage);
      }

      final result = jsonDecode(response.body);
      final output = result['output'] as String;
      developer.log('处理成功，输出: $output', name: 'ImageProcessor');
      return output;
    } catch (e, stackTrace) {
      developer.log(
        '处理图片时出错',
        name: 'ImageProcessor',
        error: e.toString(),
        stackTrace: stackTrace,
      );
      if (e is Exception) {
        rethrow;
      }
      throw Exception('处理图片时出错: $e');
    }
  }

  static void downloadImage(String url, String fileName) {
    try {
      developer.log('开始下载图片', name: 'ImageProcessor');
      developer.log('URL: $url', name: 'ImageProcessor');
      developer.log('文件名: $fileName', name: 'ImageProcessor');

      if (kIsWeb) {
        final anchor = html.AnchorElement(
          href: url,
        )
          ..setAttribute('download', fileName)
          ..click();
        developer.log('图片下载已触发', name: 'ImageProcessor');
      }
    } catch (e, stackTrace) {
      developer.log(
        '下载图片时出错',
        name: 'ImageProcessor',
        error: e.toString(),
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

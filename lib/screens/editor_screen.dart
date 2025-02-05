import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import '../services/image_processor.dart';

class EditorScreen extends StatefulWidget {
  final String imagePath;

  const EditorScreen({super.key, required this.imagePath});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  String? _processedImagePath;
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _processImage() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final result = await ImageProcessor.processImage(widget.imagePath);
      
      setState(() {
        _processedImagePath = result;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage ?? '处理图片时出错'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _saveImage() async {
    if (_processedImagePath == null) return;

    try {
      if (kIsWeb) {
        ImageProcessor.downloadImage(_processedImagePath!, 'tattoo_line_art.png');
      } else {
        // 移动平台：保存到相册
        final fileName = 'tattoo_line_art_${DateTime.now().millisecondsSinceEpoch}.png';
        final downloadsPath = Directory.current.path;
        final savePath = '$downloadsPath\\$fileName';
        
        await File(_processedImagePath!).copy(savePath);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('图片已保存')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存图片时出错: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑图片'),
        actions: [
          if (_processedImagePath != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveImage,
              tooltip: '保存图片',
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: _isProcessing
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('正在处理图片，请稍候...'),
                        ],
                      )
                    : _errorMessage != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _processImage,
                                child: const Text('重试'),
                              ),
                            ],
                          )
                        : _processedImagePath != null
                            ? Image.network(_processedImagePath!)
                            : kIsWeb
                                ? Image.network(widget.imagePath)
                                : Image.file(File(widget.imagePath)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _processImage,
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('生成线稿'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

  Future<void> _processImage() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final processor = ImageProcessor();
      final result = await processor.processImage(widget.imagePath);
      
      setState(() {
        _processedImagePath = result;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('处理图片时出错: $e')),
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
        // Web平台：触发下载
        final anchor = html.AnchorElement(
          href: _processedImagePath!,
        )
          ..setAttribute('download', 'tattoo_line_art.png')
          ..click();
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
                    ? const CircularProgressIndicator()
                    : _processedImagePath != null
                        ? kIsWeb
                            ? Image.network(_processedImagePath!)
                            : Image.file(File(_processedImagePath!))
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

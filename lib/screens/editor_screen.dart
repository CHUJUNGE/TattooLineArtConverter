import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_processor.dart';

class EditorScreen extends StatefulWidget {
  final String imagePath;

  const EditorScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  double _threshold = 0.5; 
  String? _processedImagePath;
  bool _isProcessing = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _processImage() async {
    _debounceTimer?.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      
      setState(() {
        _isProcessing = true;
      });

      try {
        final processedPath = await ImageProcessor.convertToLineArt(
          widget.imagePath,
          threshold: _threshold,
        );

        if (!mounted) return;
        setState(() {
          _processedImagePath = processedPath;
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('处理图片时出错: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    });
  }

  Future<void> _saveImage() async {
    if (_processedImagePath == null) return;

    try {
      final downloadsPath = '${Platform.environment['USERPROFILE']}\\Downloads';
      final fileName = 'tattoo_line_art_${DateTime.now().millisecondsSinceEpoch}.png';
      final savePath = '$downloadsPath\\$fileName';
      
      await File(_processedImagePath!).copy(savePath);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('图片已保存到: $savePath')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存图片时出错: $e')),
      );
    }
  }

  Widget _buildSlider({
    required String label,
    required String description,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required String leftLabel,
    required String rightLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 100,
          label: value.toStringAsFixed(1),
          onChanged: (newValue) {
            onChanged(newValue);
            _processImage();
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(leftLabel, style: TextStyle(color: Colors.grey[600])),
              Text(rightLabel, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑线稿'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _processedImagePath == null
                ? null
                : _saveImage,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Center(
                  child: _processedImagePath != null
                      ? Image.file(
                          File(_processedImagePath!),
                          fit: BoxFit.contain,
                        )
                      : const Text('处理图片时出错'),
                ),
              ),
              Container(
                color: Colors.grey[100],
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSlider(
                      label: '线条清晰度',
                      description: '调整此值来控制线条的清晰程度和数量',
                      value: _threshold,
                      min: 0.1,  
                      max: 1.0,  
                      onChanged: (value) => setState(() => _threshold = value),
                      leftLabel: '更多细节',
                      rightLabel: '更少细节',
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

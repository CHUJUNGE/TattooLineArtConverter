import 'package:flutter/material.dart';
import 'package:file_picker_web/file_picker_web.dart';
import 'editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _pickImage(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        final file = result.files.first;
        if (!context.mounted) return;
        
        if (file.bytes != null) {
          final base64Image = Uri.dataFromBytes(
            file.bytes!,
            mimeType: 'image/${file.extension}',
          ).toString();
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditorScreen(
                imagePath: base64Image,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择图片时出错: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('纹身线稿生成器'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '选择一张图片开始转换',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _pickImage(context),
              icon: const Icon(Icons.image),
              label: const Text('选择图片'),
            ),
          ],
        ),
      ),
    );
  }
}

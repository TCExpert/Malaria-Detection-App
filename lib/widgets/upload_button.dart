import 'package:flutter/material.dart';

class UploadButton extends StatelessWidget {
  final VoidCallback onUpload;

  const UploadButton({super.key, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onUpload,
      style:
          ButtonStyle(foregroundColor: WidgetStateProperty.all(Colors.white)),
      child: const Text('Upload'),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageController {
  static Future<CroppedFile?> cropImage(XFile? pickedFile) async {
    if (pickedFile == null) {
      return null;
    }

    if (kDebugMode) {
      print('Cropping image...');
    }

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Malaria Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          statusBarColor: Colors.deepOrange,
          // Statusleiste anpassen
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          // Optional: Buttons anpassen
          hideBottomControls: false, // Zeigt die unteren Buttons an
        ),
      ],
    );

    if (kDebugMode && croppedFile != null) {
      print('Image cropped.');
    }

    return croppedFile;
  }
}

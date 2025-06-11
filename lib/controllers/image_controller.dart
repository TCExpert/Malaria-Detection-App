import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/sample.dart';
import '../services/sqlite_service.dart';

class ImageController {
  static Future<String> classifyImage(
      File imageFile, Interpreter interpreter) async {
    if (kDebugMode) {
      print('Start prediction...');
    }

    List<int> inputShape = interpreter.getInputTensor(0).shape;
    if (kDebugMode) {
      print('Input shape: $inputShape');
    }

    img.Image? image = await img.decodeImageFile(imageFile.path);
    if (kDebugMode) {
      print('Got image.');
    }

    img.Image imageInput =
        img.copyResize(image!, width: inputShape[1], height: inputShape[2]);
    if (kDebugMode) {
      print('Resized image.');
    }

    List<List<List<List<double>>>> input = [
      List.generate(
          imageInput.height,
          (int y) => List.generate(imageInput.width, (int x) {
                img.Pixel pixel = imageInput.getPixel(x, y);
                return [(pixel.r) / 255, (pixel.g) / 255, (pixel.b) / 255];
              }))
    ];
    if (kDebugMode) {
      print('Got input list.');
    }

    List output = [
      [0, 0, 0, 0]
    ];

    interpreter.run(input, output);

    String result = '';
    if (output[0][0] > output[0][1] &&
        output[0][0] > output[0][2] &&
        output[0][0] > output[0][3]) {
      result = 'Plasmodium falciparum';
    } else if (output[0][1] > output[0][2] && output[0][1] > output[0][3]) {
      result = 'Plasmodium malariae';
    } else if (output[0][2] > output[0][3]) {
      result = 'Plasmodium ovale';
    } else {
      result = 'Plasmodium vivax';
    }

    return result;
  }

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

    if (kDebugMode) {
      print('Image cropped.');
    }

    return croppedFile;
  }

  static Future<List<Sample>> uploadImages() async {
    if (kDebugMode) {
      print('Uploading an image...');
    }

    final FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);

    if (result == null) {
      return List.empty();
    }

    final List<XFile> pickedFiles = result.files
        .where((file) => file.path != null)
        .map((file) => XFile(file.path!))
        .toList();

    final List<CroppedFile> croppedFiles =
        pickedFiles.map((file) => CroppedFile(file.path)).toList();

    final samples = <Sample>[];

    for (int i = 0; i <= pickedFiles.length; i++) {
      final sample = Sample(
          pickedFile: pickedFiles[i],
          croppedFile: croppedFiles[i],
          originalImage: await File(pickedFiles[i].path).readAsBytes(),
          croppedImage: await File(croppedFiles[i].path).readAsBytes());

      await SqliteService.instance.create(sample);
      sample.name = "Sample ${sample.id}" ?? "";
      samples.add(sample);
    }

    return samples;
  }
}

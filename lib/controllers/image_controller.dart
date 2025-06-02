import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

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
}

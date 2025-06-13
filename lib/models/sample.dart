import 'dart:typed_data';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class Sample {
  late final int? id;
  final XFile pickedFile;
  CroppedFile croppedFile;
  final Uint8List? originalImage;
  Uint8List? croppedImage;
  String? name = "";
  String result = "";

  Sample({
    required this.pickedFile,
    required this.croppedFile,
    this.originalImage,
    this.croppedImage
  });

  Sample.withNameAndResult({
    this.id,
    required this.pickedFile,
    required this.croppedFile,
    this.originalImage,
    this.croppedImage,
    required this.name,
    required this.result
  });

  Map<String, dynamic> toMap() {
    return {
      'pickedPath': pickedFile.path,
      'pickedName': pickedFile.name,
      'croppedPath': croppedFile.path,
      'originalImage': originalImage,
      'croppedImage': croppedImage,
      'name': name,
      'result': result
    };
  }

  static Sample fromMap(Map<String, dynamic> map) {
    return Sample.withNameAndResult(
      id: map['id'],
      pickedFile: XFile(map['pickedPath']),
      croppedFile: CroppedFile(map['croppedPath']),
      originalImage: map['originalImage'],
      croppedImage: map['croppedImage'],
      name: map['name'] ?? "",
      result: map['result'] ?? ""
    );
  }
}

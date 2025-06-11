import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class Sample {
  final XFile pickedFile;
  CroppedFile croppedFile;
  String result = "";

  Sample({required this.pickedFile, required this.croppedFile});
}

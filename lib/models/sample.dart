import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class Sample {
  final XFile pickedFile;
  final CroppedFile croppedFile;
  final String result = "";

  const Sample({required this.pickedFile, required this.croppedFile});
}

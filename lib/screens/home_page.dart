import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:malaria_detection/widgets/sample_list.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../controllers/image_controller.dart';
import '../models/sample.dart';
import '../widgets/image_card.dart';
import '../widgets/sample_list_item.dart';
import '../widgets/uploader_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Sample>? _samples;
  XFile? _pickedFile;
  CroppedFile? _croppedFile;
  String? _result;
  bool _isProcessing = false;
  bool _showResult = false;

  late final Interpreter _interpreter;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('Initializing the interpreter...');
    }
    _loadModel();
  }

  Future<void> _loadModel() async {
    // TODO: Hier evtl. setState() nutzen
    _interpreter =
        await Interpreter.fromAsset('../assets/classification.tflite');
  }

  Future<void> _uploadImage() async {
    if (kDebugMode) {
      print('Uploading an image...');
    }

    final FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);

    if (result == null) {
      return;
    }

    final List<XFile> pickedFiles = result.files
        .where((file) => file.path != null)
        .map((file) => XFile(file.path!))
        .toList();

    final List<CroppedFile> croppedFiles =
        pickedFiles.map((file) => CroppedFile(file.path)).toList();

    setState(() {
      _samples = List.generate(pickedFiles.length, (index) {
        return Sample(
            pickedFile: pickedFiles[index], croppedFile: croppedFiles[index]);
      });

      // TODO: move under following if - when the other stuff works
      _pickedFile = pickedFiles[0];
      _croppedFile = croppedFiles[0];

      // if (pickedFiles.length == 1) {
      //   _croppedFile = croppedFiles[0];
      // }
    });
  }

  Future<void> _classifyImage() async {
    if (_pickedFile == null) return;

    setState(() {
      _isProcessing = true;
      _showResult = false;
    });

    final String result = await ImageController.classifyImage(
      File(_croppedFile!.path),
      _interpreter,
    );

    setState(() {
      _result = result;
      _showResult = true;
      _isProcessing = false;
    });
  }

  void _clear() {
    setState(() {
      _pickedFile = null;
      _croppedFile = null;
      _result = null;
      _showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !kIsWeb ? AppBar(title: Text(widget.title)) : null,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kIsWeb)
            Padding(
              padding: const EdgeInsets.all(kIsWeb ? 24.0 : 16.0),
              child: Text(
                widget.title,
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(color: Theme.of(context).highlightColor),
              ),
            ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() => _samples == null
      ? _uploaderCard()
      : ((_samples!.length > 1) ? _listCard() : _imageCard());

  Widget _uploaderCard() => UploaderCard(
        onUpload: _uploadImage,
      );

  Widget _imageCard() => ImageCard(
        pickedPath: _pickedFile?.path,
        croppedPath: _croppedFile?.path,
        onClear: _clear,
        onCrop: _cropImage,
        onClassify: _classifyImage,
        result: _result,
      );

  Widget _listCard() => Center(
      child: SampleList(
          samples: _samples!,
          onTap: (Sample sample) {
            setState(() {
              _pickedFile = sample.pickedFile;
              _croppedFile = sample.croppedFile;
            });
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => _imageCard()));
          }));

  Future<void> _cropImage() async {
    if (_pickedFile != null) {
      if (kDebugMode) {
        print('Cropping image...');
      }
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
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
      if (croppedFile != null) {
        setState(() => _croppedFile = croppedFile);
        if (kDebugMode) {
          print('Updated _croppedFile.');
        }
      }
    }
  }
}

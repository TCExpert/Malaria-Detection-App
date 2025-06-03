import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:malaria_detection/services/interpreter_service.dart';
import 'package:malaria_detection/widgets/sample_list.dart';

import '../models/sample.dart';
import '../widgets/image_card.dart';
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

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('Initializing the interpreter...');
    }
    InterpreterService().getInterpreter();
  }

  @override
  void dispose() {
    InterpreterService().dispose();
    super.dispose();
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
      : ((_samples!.length > 1) ? _listCard() : _imageCard(_samples![0]));

  Widget _uploaderCard() => UploaderCard(
        onUpload: _uploadImage,
      );

  Widget _imageCard(Sample sample) => ImageCard(
        sample: sample,
        pickedPath: _pickedFile?.path,
        croppedPath: _croppedFile?.path,
        onClear: _body,
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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => _imageCard(sample)));
          }));

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

  void _clear() {
    setState(() {
      _pickedFile = null;
      _croppedFile = null;
      _result = null;
    });
  }
}

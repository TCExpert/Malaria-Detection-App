import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:malaria_detection/controllers/sample_controller.dart';
import 'package:malaria_detection/services/interpreter_service.dart';
import 'package:malaria_detection/services/sqlite_service.dart';
import 'package:malaria_detection/widgets/upload_button.dart';

import '../controllers/image_controller.dart';
import '../models/sample.dart';

enum ButtonName {
  del(name: "Delete"),
  crop(name: "Crop"),
  classify(name: "Classify");

  const ButtonName({required this.name});

  final String name;
}

class SampleCard extends StatefulWidget {
  final Sample sample;
  final Future<void> Function(BuildContext, Sample) onDelete;
  final VoidCallback onUpload;
  final bool showUploadButton;

  const SampleCard(
      {super.key,
      required this.sample,
      required this.onDelete,
      required this.onUpload,
      required this.showUploadButton});

  @override
  State<SampleCard> createState() => _SampleCardState();
}

class _SampleCardState extends State<SampleCard> {
  late TextEditingController _nameController;
  final FocusNode _focusNode = FocusNode();
  String? _result;

  @override
  void initState() {
    super.initState();
    _result = widget.sample.result;
    _nameController = TextEditingController(text: widget.sample.name ?? "Sample X");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: EditableText(
            controller: _nameController,
            focusNode: _focusNode,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            cursorColor: Colors.white,
            backgroundCursorColor: Colors.transparent,
            onChanged: (value) {
              widget.sample.name = value;
              SqliteService.instance.update(widget.sample); // Optional: direkt speichern
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: kIsWeb ? 24.0 : 16.0),
                child: Card(
                  elevation: 4.0,
                  child: Padding(
                      padding: const EdgeInsets.all(kIsWeb ? 24.0 : 16.0),
                      child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 0.8 * screenWidth,
                            maxHeight: 0.7 * screenHeight,
                          ),
                          child: Image.memory(widget.sample.croppedImage!))),
                ),
              ),
              const SizedBox(height: 24.0),
              _menu(context),
            ],
          ),
        ));
  }

  Widget _menu(BuildContext context) => Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: ButtonName.del,
                onPressed: () {
                  widget.onDelete(context, widget.sample);
                },
                backgroundColor: Colors.redAccent,
                tooltip: ButtonName.del.name,
                child: const Icon(Icons.delete),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: FloatingActionButton(
                  heroTag: ButtonName.crop,
                  onPressed: _cropImage,
                  backgroundColor: const Color(0xFFBC764A),
                  tooltip: ButtonName.crop.name,
                  child: const Icon(Icons.crop),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: FloatingActionButton(
                  heroTag: ButtonName.classify,
                  onPressed: _classifyImage,
                  backgroundColor: const Color(0xFF009256),
                  tooltip: ButtonName.classify.name,
                  child: const Icon(Icons.science),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.all(30.0),
            child: const Text('Result:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23)),
          ),
          Text(_result ?? "",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 23)),
          if (widget.showUploadButton)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: UploadButton(onUpload: widget.onUpload))
        ],
      );

  Future<void> _cropImage() async {
    final CroppedFile? cropped =
        await ImageController.cropImage(widget.sample.pickedFile);
    if (cropped != null) {
      final bytes = await File(cropped.path).readAsBytes();
      setState(() {
        widget.sample.croppedFile = cropped;
        widget.sample.croppedImage = bytes;
        _result = null; // reset result if image changed
      });
      await SqliteService.instance.update(widget.sample);
    }
  }

  Future<void> _classifyImage() async {
    final String result = await SampleController.classifySample(
      File(widget.sample.croppedFile.path),
      await InterpreterService().getInterpreter(),
    );
    widget.sample.result = result;
    setState(() {
      _result = result;
    });
    await SqliteService.instance.update(widget.sample);
  }
}

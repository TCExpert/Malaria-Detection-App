import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:malaria_detection/services/interpreter_service.dart';

import '../controllers/image_controller.dart';
import '../models/sample.dart';

enum ButtonName {
  del(name: "Delete"),
  crop(name: "Crop"),
  classify(name: "Classify");

  const ButtonName({required this.name});

  final String name;
}

class ImageCard extends StatefulWidget {
  final Sample sample;
  final String? pickedPath;
  final String? croppedPath;
  final VoidCallback onClear;
  final String? result;

  const ImageCard({
    super.key,
    required this.sample,
    required this.pickedPath,
    required this.croppedPath,
    required this.onClear,
    required this.result,
  });

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  CroppedFile? _croppedFile;
  String? _result;

  @override
  void initState() {
    super.initState();
    _croppedFile = widget.croppedPath != null ? CroppedFile(widget.croppedPath!) : null;
    _result = widget.result;
  }

  // const ImageCard({
  //   super.key,
  //   required this.sample,
  //   required this.pickedPath,
  //   required this.croppedPath,
  //   required this.onClear,
  //   required this.result,
  // });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final String? displayPath = _croppedFile?.path ?? widget.pickedPath;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Sample"),
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
                    child: (displayPath != null)
                        ? ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 0.8 * screenWidth,
                              maxHeight: 0.7 * screenHeight,
                            ),
                            child: kIsWeb
                                ? Image.network(displayPath)
                                : Image.file(File(displayPath)),
                          )
                        : const SizedBox.shrink(),
                  ),
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
                onPressed: widget.onClear,
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
          Text(widget.result ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 23))
        ],
      );

  Future<void> _cropImage() async {
    final CroppedFile? cropped = await ImageController.cropImage(widget.sample.pickedFile);
    if (cropped != null) {
      setState(() {
        _croppedFile = cropped;
        _result = null; // reset result if image changed
      });
    }
  }

  Future<void> _classifyImage() async {
    final String result = await ImageController.classifyImage(
      File(widget.sample.croppedFile.path),
      await InterpreterService().getInterpreter(),
    );
    setState(() {
      _result = result;
    });
  }
}

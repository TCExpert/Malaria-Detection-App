import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:malaria_detection/controllers/image_controller.dart';
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
        onUpload: _uploadImages,
      );

  Widget _imageCard(Sample sample) => ImageCard(sample: sample, onClear: _body);

  Widget _listCard() => Center(
      child: SampleList(
          samples: _samples!,
          onTap: (Sample sample) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => _imageCard(sample)));
          }));

  Future<void> _uploadImages() async {
    List<Sample> samples = await ImageController.uploadImages();
    setState(() {
      _samples = samples;
    });
  }
}

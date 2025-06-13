import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:malaria_detection/controllers/sample_controller.dart';
import 'package:malaria_detection/services/interpreter_service.dart';
import 'package:malaria_detection/services/sqlite_service.dart';
import 'package:malaria_detection/widgets/sample_list.dart';

import '../models/sample.dart';
import '../utils.dart';
import '../widgets/sample_card.dart';
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
    _loadSamples();
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

  Widget _body() => (_samples == null || _samples!.isEmpty)
      ? _uploaderCard()
      : ((_samples!.length > 1) ? _listCard() : _imageCard(_samples![0]));

  Widget _uploaderCard() => UploaderCard(onUpload: _upload);

  Widget _imageCard(Sample sample) => SampleCard(
      sample: sample,
      onDelete: (BuildContext context, Sample sample) async {
        await _deleteSample(context, sample);
      },
      onUpload: _upload,
      showUploadButton: (_samples!.length > 1) ? false : true);

  Widget _listCard() => Center(
          child: SampleList(
        samples: _samples!,
        onTap: (Sample sample) async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (context) => _imageCard(sample)));
          await _loadSamples();
        },
        onDelete: (BuildContext context, Sample sample) async {
          await _deleteSample(context, sample);
        },
        onUpload: _upload,
      ));

  Future<void> _upload() async {
    List<Sample> samples = await SampleController.uploadSamples();
    setState(() {
      _samples?.addAll(samples);
    });
  }

  /// Loads samples from database
  Future<void> _loadSamples() async {
    final samples = await SqliteService.instance.queryAll();
    setState(() => _samples = samples);
  }

  Future<void> _deleteSample(BuildContext context, Sample sample) async {
    if (await Utils.showAlertDialog(
        context, "Do you want to delete this sample?")) {
      setState(() {
        _samples!.remove(sample);
      });

      await SqliteService.instance.delete(sample.id);

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:malaria_detection/controllers/image_controller.dart';
import 'package:malaria_detection/services/interpreter_service.dart';
import 'package:malaria_detection/services/sqlite_service.dart';
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

  Widget _imageCard(Sample sample) => ImageCard(
        sample: sample,
        onClear: () async {
          if (await showAlertDialog(
              context, "Do you want to delete this sample?")) {
            setState(() {
              _samples!.remove(sample);
            });
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          }
        },
        onUpload: _upload,
        showUploadButton: (_samples!.length > 1) ? false : true
      );

  Widget _listCard() => Center(
      child: SampleList(
          samples: _samples!,
          onTap: (Sample sample) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => _imageCard(sample)));
          },
          onUpload: _upload,
      ));

  Future<bool> showAlertDialog(BuildContext context, String message) async {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      onPressed: () {
        // returnValue = false;
        Navigator.of(context).pop(false);
      },
      style:
          ButtonStyle(foregroundColor: WidgetStateProperty.all(Colors.white)),
      child: const Text("Cancel"),
    );
    Widget continueButton = ElevatedButton(
      onPressed: () {
        // returnValue = true;
        Navigator.of(context).pop(true);
      },
      style:
          ButtonStyle(foregroundColor: WidgetStateProperty.all(Colors.white)),
      child: const Text("Yes"),
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(message),
      titleTextStyle: const TextStyle(fontSize: 15, color: Color(0xFFBC764A)),
      actions: [
        cancelButton,
        continueButton,
      ],
    ); // show the dialog
    final result = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    return result ?? false;
  }

  Future<void> _upload() async {
    List<Sample> samples = await ImageController.uploadImages();
    setState(() {
      _samples = samples;
    });
  }

  /// Loads samples from database
  Future<void> _loadSamples() async {
    final samples = await SqliteService.instance.readAll();
    setState(() => _samples = samples);
  }
}

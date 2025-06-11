import 'package:flutter/material.dart';
import 'package:malaria_detection/widgets/upload_button.dart';
import '../models/sample.dart';
import 'sample_list_item.dart';

class SampleList extends StatelessWidget {
  final List<Sample> samples;
  final void Function(Sample) onTap;
  final VoidCallback onUpload;

  const SampleList(
      {super.key,
      required this.samples,
      required this.onTap,
      required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Die Liste der Samples
            for (final sample in samples)
              Dismissible(
                  key: Key(sample.id.toString()),
                  child: InkWell(
                    onTap: () => onTap(sample),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: SampleListItem(sample: sample),
                    ),
                  )),

            // Der Upload-Button ganz unten
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: UploadButton(onUpload: onUpload),
            ),
          ],
        ),
      ),
    );
  }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: const Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/sample.dart';
import 'sample_list_item.dart';

class SampleList extends StatelessWidget {
  final List<Sample> samples;
  final void Function(Sample) onTap;

  const SampleList({
    super.key,
    required this.samples,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: samples.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => onTap(samples[index]),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: SampleListItem(sample: samples[index]),
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import '../models/sample.dart';

class SampleListItem extends StatelessWidget {
  final Sample sample;

  const SampleListItem({super.key, required this.sample});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.memory(
          sample.croppedImage!,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sample.name ?? "Sample X",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
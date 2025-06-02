import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  final String? pickedPath;
  final String? croppedPath;
  final VoidCallback onClear;
  final VoidCallback onCrop;
  final VoidCallback onClassify;
  final String? result;

  const ImageCard({
    super.key,
    required this.pickedPath,
    required this.croppedPath,
    required this.onClear,
    required this.onCrop,
    required this.onClassify,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final String? displayPath = croppedPath ?? pickedPath;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: kIsWeb ? 24.0 : 16.0),
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
    );
  }

  Widget _menu(BuildContext context) => Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                onPressed: onClear,
                backgroundColor: Colors.redAccent,
                tooltip: 'Delete',
                child: const Icon(Icons.delete),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: FloatingActionButton(
                  onPressed: onCrop,
                  backgroundColor: const Color(0xFFBC764A),
                  tooltip: 'Crop',
                  child: const Icon(Icons.crop),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: FloatingActionButton(
                  onPressed: onClassify,
                  backgroundColor: const Color(0xFF009256),
                  tooltip: 'Classify',
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
          Text(result ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 23))
        ],
      );
}

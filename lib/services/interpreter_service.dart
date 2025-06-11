import 'package:tflite_flutter/tflite_flutter.dart';

class InterpreterService {
  static final InterpreterService _instance = InterpreterService._internal();

  factory InterpreterService() => _instance;

  InterpreterService._internal();

  Interpreter? _interpreter;

  Future<Interpreter> getInterpreter() async {
    _interpreter ??= await Interpreter.fromAsset('assets/classification.tflite');
    return _interpreter!;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

class TFLiteService {
  static Interpreter? _interpreter;
  static const List<int> _inputShape = [1, 256, 256, 3];
  static const int _outputSize =
      2; // For binary classification (Addicted/Not Addicted)

  static Future<String> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/model.tflite');
      final inputTensor = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);

      print('Model loaded successfully');
      print('Input tensor shape: ${inputTensor.shape}');
      print('Output tensor shape: ${outputTensor.shape}');

      return 'Model loaded successfully';
    } catch (e) {
      print('Error loading model: $e');
      return 'Error loading model: $e';
    }
  }

  static void closeModel() {
    _interpreter?.close();
    _interpreter = null;
  }

  static Future<String> predict(File imageFile) async {
    if (_interpreter == null) return 'Model not loaded';

    try {
      if (!await imageFile.exists()) {
        return 'Error: Image file does not exist';
      }

      // Load and preprocess image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return 'Error: Unable to decode image';

      // Resize image to match model input
      final resizedImage = img.copyResize(
        image,
        width: _inputShape[1],
        height: _inputShape[2],
      );

      // Prepare input data as a flat array
      var inputArray = Float32List(
        _inputShape[0] * _inputShape[1] * _inputShape[2] * _inputShape[3],
      );
      var inputIndex = 0;

      // Convert image to normalized float array
      for (var y = 0; y < _inputShape[1]; y++) {
        for (var x = 0; x < _inputShape[2]; x++) {
          final pixel = resizedImage.getPixel(x, y);
          inputArray[inputIndex++] = pixel.r / 255.0;
          inputArray[inputIndex++] = pixel.g / 255.0;
          inputArray[inputIndex++] = pixel.b / 255.0;
        }
      }

      // Reshape input to match model requirements [1, 256, 256, 3]
      var input = [inputArray.reshape(_inputShape)];
      final output = [Float32List(_outputSize)];

      // Run inference
      final stopwatch = Stopwatch()..start();
      _interpreter!.run(input, output);
      stopwatch.stop();

      // Process results - get probability for each class
      final addictedProb = output[0][0]; // Class 0 is Addicted
      final notAddictedProb = output[0][1]; // Class 1 is Not Addicted
      final confidence =
          notAddictedProb > addictedProb ? notAddictedProb : addictedProb;

      print('Inference time: ${stopwatch.elapsedMilliseconds}ms');
      print('Raw confidence: $confidence');
      print(
        'Not Addicted Prob: $notAddictedProb, Addicted Prob: $addictedProb',
      );

      // Format prediction result based on labels.txt mapping
      final result =
          notAddictedProb > 0.5
              ? 'Not Addicted (${(notAddictedProb * 100).toStringAsFixed(1)}% confidence)'
              : 'Addicted (${(addictedProb * 100).toStringAsFixed(1)}% confidence)';

      return result;
    } catch (e) {
      print('Prediction error: $e');
      return 'Prediction failed: $e';
    }
  }
}

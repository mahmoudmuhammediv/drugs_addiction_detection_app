import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../utils/image_utils.dart';
import '../constants/app_constants.dart';

/// A class that handles the TensorFlow Lite model operations for addiction detection
class Classifier {
  late Interpreter _interpreter;
  bool _isModelLoaded = false;

  /// Initializes the classifier
  Classifier() {
    _loadModel();
  }

  /// Loads the TensorFlow Lite model from assets
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(AppConstants.modelPath);
      _isModelLoaded = true;
    } catch (e) {
      _isModelLoaded = false;
      throw Exception('Failed to load model: $e');
    }
  }

  /// Predicts whether the person in the image shows signs of addiction
  /// Returns "Addicted" or "Not Addicted"
  /// Throws an exception if the model is not loaded or if processing fails
  Future<String> predict(File imageFile) async {
    if (!_isModelLoaded) {
      throw Exception('Model not loaded');
    }

    try {
      // Validate image
      if (!await ImageUtils.isValidImage(imageFile)) {
        throw Exception('Invalid image file');
      }

      // Process image for model input
      final processedImage = await ImageUtils.processImageForModel(imageFile);

      // Pre-allocate input tensor with known size for better performance
      final input = [
        List.generate(
          AppConstants.imageWidth,
          (i) => List.generate(
            AppConstants.imageHeight,
            (j) => List.filled(3, 0.0),
          ),
        ),
      ];

      // Read and normalize image pixels
      final imageBytes = await processedImage.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);

      if (decodedImage == null) {
        throw Exception('Failed to decode processed image');
      }

      for (int y = 0; y < AppConstants.imageHeight; y++) {
        for (int x = 0; x < AppConstants.imageWidth; x++) {
          final pixel = decodedImage.getPixel(x, y);
          input[0][y][x][0] = pixel.r / 255.0;
          input[0][y][x][1] = pixel.g / 255.0;
          input[0][y][x][2] = pixel.b / 255.0;
        }
      }

      // Prepare output tensor
      var output = List.filled(1, List.filled(1, 0.0));

      // Run inference
      _interpreter.run(input, output);

      // Clean up temporary files
      await ImageUtils.cleanupTempImages();

      // Return prediction
      return output[0][0] > 0.5 ? "Not Addicted" : "Addicted";
    } catch (e) {
      throw Exception('${AppConstants.modelError}: $e');
    }
  }

  /// Disposes of the interpreter when the classifier is no longer needed
  void dispose() {
    if (_isModelLoaded) {
      _interpreter.close();
    }
  }
}

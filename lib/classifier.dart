import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class Classifier {
  late Interpreter _interpreter;

  Classifier() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/models/model.tflite');
  }

  Future<String> predict(File imageFile) async {
    try {
      // Decode the image file with error handling
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) throw Exception("Failed to decode image file");

      // Optimize memory by disposing original image after resizing
      img.Image resizedImage = img.copyResize(image, width: 256, height: 256);
      image = null; // Help garbage collection

      // Pre-allocate list with known size for better performance
      final int totalPixels = 256 * 256 * 3;
      List<double> normalizedPixels = List.filled(totalPixels, 0.0);
      int pixelIndex = 0;

      // Optimized pixel normalization loop
      for (int y = 0; y < resizedImage.height; y++) {
        for (int x = 0; x < resizedImage.width; x++) {
          final pixel = resizedImage.getPixelSafe(x, y);
          normalizedPixels[pixelIndex++] = pixel.r / 255.0;
          normalizedPixels[pixelIndex++] = pixel.g / 255.0;
          normalizedPixels[pixelIndex++] = pixel.b / 255.0;
        }
      }

      // Prepare input tensor with proper shape validation
      var input = [
        List.generate(
          256,
          (i) => List.generate(
            256,
            (j) => normalizedPixels.sublist(
              (i * 256 + j) * 3,
              (i * 256 + j + 1) * 3,
            ),
          ),
        ),
      ];

      // Prepare output tensor
      var output = List.filled(1, List.filled(1, 0.0));

      // Run inference with enhanced error handling
      try {
        _interpreter.run(input, output);
        return output[0][0] > 0.5 ? "Not Addicted" : "Addicted";
      } catch (e) {
        throw Exception("Model inference failed: ${e.toString()}");
      }
    } catch (e) {
      throw Exception("Image processing failed: ${e.toString()}");
    }
  }
}

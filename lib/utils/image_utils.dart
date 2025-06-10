import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';
import 'package:flutter/foundation.dart';

class ImageUtils {
  /// Processes and resizes an image file for model input
  /// Returns a new File with the processed image
  static Future<File> processImageForModel(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        throw Exception("Failed to decode image");
      }

      final resizedImage = img.copyResize(
        decodedImage,
        width: AppConstants.imageWidth,
        height: AppConstants.imageHeight,
      );

      final resizedBytes = img.encodeJpg(resizedImage);
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempPath = '${tempDir.path}/resized_image_$timestamp.jpg';

      return File(tempPath)..writeAsBytesSync(resizedBytes);
    } catch (e) {
      debugPrint('Image processing error: $e');
      throw Exception('${AppConstants.imageProcessError}: $e');
    }
  }

  /// Validates image file
  static Future<bool> isValidImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return img.decodeImage(bytes) != null;
    } catch (e) {
      return false;
    }
  }

  /// Cleans up temporary image files
  static Future<void> cleanupTempImages() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      for (var file in files) {
        if (file is File && file.path.contains('resized_image_')) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up temp files: $e');
    }
  }
}

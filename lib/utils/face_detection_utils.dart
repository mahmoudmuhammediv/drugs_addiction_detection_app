import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionUtils {
  static final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableTracking: true,
      minFaceSize: 0.15,
    ),
  );

  /// Detects faces in the image
  /// Returns true if exactly one face is found
  /// Throws an exception if no face is found or if multiple faces are detected
  static Future<bool> detectFace(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        throw Exception('No face found in image');
      }

      if (faces.length > 1) {
        throw Exception(
          'Multiple faces detected. Please use an image with only one face.',
        );
      }

      return true;
    } catch (e) {
      throw Exception('Face detection failed: $e');
    }
  }

  /// Disposes of the face detector
  static void dispose() {
    _faceDetector.close();
  }
}

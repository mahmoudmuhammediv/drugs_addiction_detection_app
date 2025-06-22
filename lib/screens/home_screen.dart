import 'dart:io';
import 'package:flutter/material.dart';
import '../models/classifier.dart';
import '../models/prediction_result.dart';
import '../services/auth_service.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/analysis_result_widget.dart';
import '../widgets/medical_disclaimer_widget.dart';
import '../constants/app_constants.dart';
import '../utils/face_detection_utils.dart';
import 'info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  PredictionResult? _predictionResult;
  bool _isProcessing = false;
  final Classifier _classifier = Classifier();
  final _authService = AuthService();

  Future<void> _predict() async {
    if (_image == null) return;

    setState(() {
      _isProcessing = true;
      _predictionResult = null;
    });

    try {
      // First check if there's a face in the image
      final hasFace = await FaceDetectionUtils.detectFace(_image!);
      if (!hasFace) {
        throw Exception('No face found in image');
      }

      // Then run prediction on the original image
      final result = await _classifier.predict(_image!);
      setState(() => _predictionResult = result);
    } catch (e) {
      if (!mounted) return;

      String errorMessage = e.toString();
      if (errorMessage.contains('No face found')) {
        errorMessage =
            'No face found in image. Please try again with a clearer image of a face.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      setState(() => _predictionResult = null);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
      // No need to navigate - AuthWrapper will handle it
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is authenticated
    if (_authService.currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return LoadingOverlay(
      isLoading: _isProcessing,
      message: "Analyzing image...",
      child: Scaffold(
        backgroundColor: const Color(AppConstants.primaryColor),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const InfoScreen()),
                  ),
              tooltip: 'About This App',
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _handleLogout,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                const MedicalDisclaimerWidget(),
                const SizedBox(height: 32),
                ImagePickerWidget(
                  image: _image,
                  onImagePicked: (File? file) {
                    setState(() {
                      _image = file;
                      _predictionResult = null;
                    });
                  },
                  isProcessing: _isProcessing,
                ),
                const SizedBox(height: 32),
                _buildAnalyzeButton(),
                if (_predictionResult != null) ...[
                  const SizedBox(height: 32),
                  AnalysisResultWidget(result: _predictionResult!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome ${_authService.currentUser?.displayName ?? 'User'}",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Addiction Detection",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Upload an image to analyze and detect potential signs of addiction.",
          style: TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing || _image == null ? null : _predict,
        icon: const Icon(Icons.analytics_rounded, color: Colors.white),
        label: const Text(
          "Analyze Image",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppConstants.accentColor),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

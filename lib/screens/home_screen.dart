import 'dart:io';
import 'package:flutter/material.dart';
import '../models/classifier.dart';
import '../services/auth_service.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/loading_overlay.dart';
import '../constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  String _prediction = "";
  bool _isProcessing = false;
  final Classifier _classifier = Classifier();
  final _authService = AuthService();

  Future<void> _predict() async {
    if (_image == null) return;

    setState(() {
      _isProcessing = true;
      _prediction = "Analyzing image...";
    });

    try {
      final prediction = await _classifier.predict(_image!);
      setState(() => _prediction = prediction);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
      setState(() => _prediction = "");
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
                const SizedBox(height: 40),
                ImagePickerWidget(
                  image: _image,
                  onImagePicked: (File? file) {
                    setState(() {
                      _image = file;
                      _prediction = "";
                    });
                  },
                  isProcessing: _isProcessing,
                ),
                const SizedBox(height: 32),
                _buildAnalyzeButton(),
                if (_prediction.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _buildResult(),
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

  Widget _buildResult() {
    final isAddicted = _prediction.toLowerCase().contains("addicted");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color:
            isAddicted ? Colors.red.withAlpha(25) : Colors.green.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isAddicted
                  ? Colors.red.withAlpha(77)
                  : Colors.green.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Analysis Result",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isAddicted ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _prediction,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isAddicted ? Colors.red : Colors.green,
            ),
          ),
          if (isAddicted) ...[
            const SizedBox(height: 16),
            const Text(
              "Please seek professional help if you or someone you know is struggling with addiction.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

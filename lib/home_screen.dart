import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'classifier.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  String _prediction = "";
  bool _isProcessing = false;
  final Classifier _classifier = Classifier();

  Future<void> _pickImage({required ImageSource source}) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _prediction = ""; // Reset prediction
        });
      }
    } catch (e) {
      _showError("Error picking image: $e");
    }
  }

  Future<void> _predict() async {
    if (_image == null) return;

    setState(() {
      _isProcessing = true;
      _prediction = "Analyzing image...";
    });

    try {
      final bytes = await _image!.readAsBytes();
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        throw Exception("Failed to decode image");
      }

      final resizedImage = img.copyResize(
        decodedImage,
        width: 256,
        height: 256,
      );

      final resizedBytes = img.encodeJpg(resizedImage);
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempPath = '${tempDir.path}/resized_image_$timestamp.jpg';
      final resizedFile = File(tempPath)..writeAsBytesSync(resizedBytes);

      setState(() {
        _image = resizedFile;
      });

      final prediction = await _classifier.predict(resizedFile);
      setState(() => _prediction = prediction);
    } catch (error) {
      _showError(error.toString());
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _reset() {
    setState(() {
      _image = null;
      _prediction = "";
      _isProcessing = false;
    });
  }


  void _showError(String message) {
    setState(() => _prediction = "Error: $message");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 40),
              _buildImageSection(),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 32),
              _buildResultSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: () => _pickImage(source: ImageSource.gallery),
      child: Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child:
            _image != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(_image!, fit: BoxFit.contain),
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 64,
                      color: Color(0xFF4F566B),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Tap to upload an image",
                      style: TextStyle(color: Color(0xFF4F566B), fontSize: 16),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(source: ImageSource.gallery),
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: const Text("Gallery", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF635BFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(source: ImageSource.camera),
                icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
                label: const Text("Camera", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isProcessing || _image == null ? null : _predict,
                icon: const Icon(Icons.analytics_rounded, color: Colors.white),
                label: const Text("Analyze", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF32325D),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _image == null ? null : _reset,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text("Reset", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildResultSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child:
          _isProcessing
              ? Column(
                children: const [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF635BFF),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Analyzing image...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Analysis Result",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _prediction.isNotEmpty
                        ? _prediction
                        : "Upload an image to see the analysis result",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4F566B),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
    );
  }
}

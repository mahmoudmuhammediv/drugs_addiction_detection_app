import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/tflite_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  String? _result;
  bool _isLoading = true;
  bool _isPredicting = false;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    final result = await TFLiteService.loadModel();
    setState(() {
      _isLoading = false;
      _result = result;
    });
  }

  Future<void> _selectImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _result = null;
        });
      }
    } catch (e) {
      setState(() => _result = 'Error selecting image: $e');
    }
  }

  Future<void> _runPrediction() async {
    if (_image == null) return;

    setState(() => _isPredicting = true);
    try {
      final prediction = await TFLiteService.predict(_image!);
      setState(() {
        _result = prediction;
        _isPredicting = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Prediction error: $e';
        _isPredicting = false;
      });
    }
  }

  @override
  void dispose() {
    TFLiteService.closeModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width > 600 ? 32.0 : 24.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: Colors.green),
                          const SizedBox(height: 16),
                          Text(
                            'Initializing model...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Text(
                            'Detect Drug Addiction',
                            style: TextStyle(
                              fontSize: screenSize.width > 600 ? 32 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Upload an image to analyze for signs of drug addiction.',
                            style: TextStyle(
                              fontSize: screenSize.width > 600 ? 18 : 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _selectImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.image, color: Colors.white),
                                SizedBox(width: 12),
                                Text(
                                  'Select Image',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_image != null) ...[
                            const SizedBox(height: 24),
                            Container(
                              constraints: BoxConstraints(
                                maxHeight: screenSize.height * 0.4,
                                maxWidth: screenSize.width * 0.8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_image!, fit: BoxFit.contain),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _runPrediction,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.psychology, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text(
                                    'Analyze Image',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (_isPredicting)
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Column(
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.green,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Analyzing image...',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          else if (_result != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      _result!.contains('Not Addicted')
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        _result!.contains('Not Addicted')
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                                child: Text(
                                  _result!,
                                  style: TextStyle(
                                    fontSize: screenSize.width > 600 ? 20 : 18,
                                    color:
                                        _result!.contains('Not Addicted')
                                            ? Colors.green
                                            : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

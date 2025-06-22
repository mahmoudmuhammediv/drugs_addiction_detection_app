import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.primaryColor),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "About This App",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildSection(
                "How It Works",
                Icons.psychology_rounded,
                "This app uses artificial intelligence and machine learning to analyze facial features in images and identify potential signs of addiction. The AI model has been trained on a dataset of images to recognize patterns associated with substance use disorders.",
              ),
              const SizedBox(height: 24),
              _buildSection(
                "Important Limitations",
                Icons.warning_rounded,
                "• This is NOT a medical diagnosis\n"
                    "• Results are for informational purposes only\n"
                    "• The AI may not be 100% accurate\n"
                    "• Many factors can affect facial appearance\n"
                    "• Professional medical assessment is always recommended",
              ),
              const SizedBox(height: 24),
              _buildSection(
                "When to Seek Help",
                Icons.health_and_safety_rounded,
                "If you or someone you know is struggling with addiction:\n\n"
                    "• Contact a healthcare professional\n"
                    "• Reach out to addiction support services\n"
                    "• Speak with a mental health specialist\n"
                    "• Contact local treatment centers\n"
                    "• Call addiction helplines for immediate support",
              ),
              const SizedBox(height: 24),
              _buildSection(
                "Confidence Levels",
                Icons.analytics_rounded,
                "The app provides confidence levels for each analysis:\n\n"
                    "• High (80%+): Strong confidence in the prediction\n"
                    "• Medium (60-79%): Moderate confidence, professional consultation recommended\n"
                    "• Low (<60%): Low confidence, professional assessment strongly advised",
              ),
              const SizedBox(height: 24),
              _buildSection(
                "Privacy & Security",
                Icons.security_rounded,
                "• Images are processed locally on your device\n"
                    "• No images are stored or transmitted to external servers\n"
                    "• Analysis results are not shared with third parties\n"
                    "• Your privacy is protected throughout the process",
              ),
              const SizedBox(height: 24),
              _buildSection(
                "Medical Disclaimer",
                Icons.medical_information_rounded,
                "This application is designed for educational and informational purposes only. "
                    "It is not intended to provide medical advice, diagnosis, or treatment. "
                    "Always consult with qualified healthcare professionals for proper assessment and treatment of addiction or any other medical condition. "
                    "The developers are not responsible for any decisions made based on the app's analysis results.",
              ),
              const SizedBox(height: 32),
              _buildEmergencyContact(),
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
          "Addiction Detection App",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "AI-Powered Analysis Tool",
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withAlpha(40),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withAlpha(120)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_rounded, color: Colors.amber, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "This app is for informational purposes only and should not replace professional medical advice.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContact() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withAlpha(120)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emergency_rounded, color: Colors.red, size: 24),
              SizedBox(width: 12),
              Text(
                "Emergency Support - Egypt",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "If you or someone you know is in crisis or needs immediate help:\n\n"
            "• Emergency Services: 123\n"
            "• Police: 122\n"
            "• Ambulance: 123\n"
            "• Fire Department: 180\n"
            "• Egyptian Red Crescent: 123\n"
            "• Addiction Treatment Centers:\n"
            "  - Al-Azhar University Hospital: 02-2268-XXXX\n"
            "  - Cairo University Hospital: 02-2368-XXXX\n"
            "  - Ain Shams University Hospital: 02-2482-XXXX\n\n"
            "• Mental Health Support:\n"
            "  - Egyptian Mental Health Association\n"
            "  - National Institute of Mental Health\n\n"
            "• Crisis Helplines:\n"
            "  - National Crisis Hotline: 16000\n"
            "  - Youth Helpline: 16023\n\n"
            "Remember: You are not alone, and help is available in Egypt.",
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }
}

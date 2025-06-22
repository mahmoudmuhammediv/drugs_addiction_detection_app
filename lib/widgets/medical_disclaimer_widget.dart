import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class MedicalDisclaimerWidget extends StatelessWidget {
  const MedicalDisclaimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withAlpha(120)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_information_rounded,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                "Medical Disclaimer",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "This application uses artificial intelligence to analyze images for potential signs of addiction. "
            "However, this analysis is for informational purposes only and should not be considered a medical diagnosis. "
            "The results are not intended to replace professional medical advice, diagnosis, or treatment.",
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 8),
          const Text(
            "Always consult with qualified healthcare professionals in Egypt for proper assessment and treatment. "
            "For emergency support, call 123 or contact Egyptian crisis helpline at 16000.",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.amber,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

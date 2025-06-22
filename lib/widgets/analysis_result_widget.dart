import 'package:flutter/material.dart';
import '../models/prediction_result.dart';
import '../constants/app_constants.dart';

class AnalysisResultWidget extends StatelessWidget {
  final PredictionResult result;

  const AnalysisResultWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isAddicted = result.prediction.toLowerCase().contains("addicted");

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
          // Main Result Header
          Row(
            children: [
              Icon(
                isAddicted ? Icons.warning_rounded : Icons.check_circle_rounded,
                color: isAddicted ? Colors.red : Colors.green,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Analysis Result",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isAddicted ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Prediction
          Text(
            result.prediction,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isAddicted ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(height: 16),

          // Confidence Level
          _buildConfidenceSection(),
          const SizedBox(height: 16),

          // Medical Disclaimer
          _buildDisclaimerSection(),
          const SizedBox(height: 16),

          // Professional Recommendations
          if (isAddicted) _buildRecommendationsSection(),
        ],
      ),
    );
  }

  Widget _buildConfidenceSection() {
    Color confidenceColor;
    switch (result.confidenceLevel.toLowerCase()) {
      case "high":
        confidenceColor = Colors.green;
        break;
      case "medium":
        confidenceColor = Colors.orange;
        break;
      case "low":
        confidenceColor = Colors.red;
        break;
      default:
        confidenceColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: confidenceColor.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: confidenceColor.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, color: confidenceColor, size: 20),
              const SizedBox(width: 8),
              Text(
                "Confidence Level",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: confidenceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                result.confidenceLevel,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: confidenceColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "(${result.confidencePercentage})",
                style: TextStyle(
                  fontSize: 16,
                  color: confidenceColor.withAlpha(200),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            result.confidenceDescription,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_information_rounded,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Important Notice",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            result.disclaimer,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.health_and_safety_rounded,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Professional Recommendations - Egypt",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "• Consult with qualified healthcare professionals in Egypt\n"
            "• Contact Egyptian addiction treatment centers:\n"
            "  - Al-Azhar University Hospital\n"
            "  - Cairo University Hospital\n"
            "  - Ain Shams University Hospital\n"
            "• Reach out to Egyptian Mental Health Association\n"
            "• Contact National Institute of Mental Health\n"
            "• Call Egyptian crisis helplines: 16000\n"
            "• Emergency services: 123",
            style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }
}

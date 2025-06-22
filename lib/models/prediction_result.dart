/// Represents the result of an addiction detection analysis
class PredictionResult {
  final String prediction;
  final double confidence;
  final String confidenceLevel;
  final DateTime timestamp;
  final String disclaimer;

  const PredictionResult({
    required this.prediction,
    required this.confidence,
    required this.confidenceLevel,
    required this.timestamp,
    required this.disclaimer,
  });

  /// Creates a PredictionResult from raw model output
  factory PredictionResult.fromModelOutput(double modelOutput) {
    final isAddicted = modelOutput <= 0.5;
    final prediction = isAddicted ? "Addicted" : "Not Addicted";

    // Calculate confidence based on distance from threshold
    final distanceFromThreshold = (modelOutput - 0.5).abs();
    final confidence = (distanceFromThreshold * 2).clamp(0.0, 1.0);

    // Determine confidence level
    String confidenceLevel;
    if (confidence >= 0.8) {
      confidenceLevel = "High";
    } else if (confidence >= 0.6) {
      confidenceLevel = "Medium";
    } else {
      confidenceLevel = "Low";
    }

    return PredictionResult(
      prediction: prediction,
      confidence: confidence,
      confidenceLevel: confidenceLevel,
      timestamp: DateTime.now(),
      disclaimer:
          "This analysis is for informational purposes only and should not be considered a medical diagnosis. Please consult with a qualified healthcare professional for proper assessment and treatment.",
    );
  }

  /// Returns the confidence percentage as a formatted string
  String get confidencePercentage =>
      "${(confidence * 100).toStringAsFixed(1)}%";

  /// Returns the color for the confidence level
  String get confidenceColor {
    switch (confidenceLevel.toLowerCase()) {
      case "high":
        return "green";
      case "medium":
        return "orange";
      case "low":
        return "red";
      default:
        return "grey";
    }
  }

  /// Returns a detailed description of the confidence level
  String get confidenceDescription {
    switch (confidenceLevel.toLowerCase()) {
      case "high":
        return "The model is highly confident in this prediction based on the analyzed features.";
      case "medium":
        return "The model shows moderate confidence in this prediction. Consider consulting a professional.";
      case "low":
        return "The model has low confidence in this prediction. Professional assessment is strongly recommended.";
      default:
        return "Confidence level could not be determined.";
    }
  }
}

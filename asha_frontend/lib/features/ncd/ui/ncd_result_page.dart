import 'package:flutter/material.dart';
import '../../../core/ml/ncd_risk_engine.dart';

class NcdResultPage extends StatelessWidget {
  final NcdPrediction result;

  const NcdResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor();
    final riskIcon = _getRiskIcon();
    final riskLabel = _getRiskLabel(); // human readable label

    return Scaffold(
      appBar: AppBar(
        title: const Text("NCD Screening Result"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== RISK CARD =====
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: riskColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(riskIcon, color: Colors.white, size: 46),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "$riskLabel\nRisk Score: ${result.riskScore}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ===== PROBLEMS =====
            const Text(
              "Identified Risk Factors",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (result.problems.isEmpty)
              const Text(
                "• No major risk factors identified",
                style: TextStyle(fontSize: 16),
              )
            else
              ...result.problems.map(
                    (p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    "• ${_localizeNcdProblem(p)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

            const SizedBox(height: 28),

            // ===== SUGGESTIONS =====
            const Text(
              "Recommended Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (result.suggestions.isEmpty)
              const Text(
                "• No suggestions available",
                style: TextStyle(fontSize: 16),
              )
            else
              ...result.suggestions.map(
                    (s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    "• ${_localizeNcdSuggestion(s)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ===== helpers =====
  Color _getRiskColor() {
    switch (result.riskLevelKey) {
      case "risk_low":
        return Colors.green;
      case "risk_moderate":
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  IconData _getRiskIcon() {
    switch (result.riskLevelKey) {
      case "risk_low":
        return Icons.check_circle;
      case "risk_moderate":
        return Icons.warning_amber;
      default:
        return Icons.warning;
    }
  }

  String _getRiskLabel() {
    switch (result.riskLevelKey) {
      case "risk_low":
        return "Low NCD Risk";
      case "risk_moderate":
        return "Moderate NCD Risk";
      default:
        return "High NCD Risk";
    }
  }
}

String _localizeNcdProblem(String key) {
  switch (key) {
    case "ncd_problem_high_blood_pressure":
      return "High blood pressure (hypertension)";
    case "ncd_problem_pre_hypertension":
      return "Borderline / pre-hypertensive blood pressure";
    case "ncd_problem_very_high_blood_sugar":
      return "Very high random blood sugar (possible diabetes)";
    case "ncd_problem_moderately_high_blood_sugar":
      return "Moderately raised blood sugar";
    case "ncd_problem_obesity":
      return "Obesity (high BMI)";
    case "ncd_problem_overweight":
      return "Overweight (raised BMI)";
    case "ncd_problem_tobacco_use":
      return "Tobacco use increases NCD risk";
    case "ncd_problem_alcohol_use":
      return "Alcohol use may increase NCD risk";
    case "ncd_problem_extra_salt_little":
      return "Extra salt intake in food";
    case "ncd_problem_extra_salt_high":
      return "High extra salt intake in food";
    case "ncd_problem_low_physical_activity":
      return "Low physical activity";
    case "ncd_problem_sedentary_lifestyle":
      return "Sedentary lifestyle (no regular exercise)";
    default:
      return key; // fallback
  }
}

String _localizeNcdSuggestion(String key) {
  switch (key) {
    case "ncd_suggest_regular_screening":
      return "Continue regular BP, sugar, and weight screening.";
    case "ncd_suggest_urgent_referral":
      return "Refer to PHC/doctor for detailed NCD evaluation.";
    case "ncd_suggest_bp_management":
      return "Monitor blood pressure and follow hypertension management advice.";
    case "ncd_suggest_blood_sugar_evaluation":
      return "Advise confirmatory tests and follow-up for high blood sugar.";
    case "ncd_suggest_diet_and_weight_management":
      return "Provide counselling on diet and weight management.";
    case "ncd_suggest_tobacco_cessation":
      return "Advise and support tobacco cessation.";
    case "ncd_suggest_limit_alcohol":
      return "Advise to limit or avoid alcohol use.";
    case "ncd_suggest_reduce_salt":
      return "Encourage reducing extra salt intake in food.";
    case "ncd_suggest_increase_activity":
      return "Encourage regular physical activity (walking, exercise).";
    default:
      return key; // fallback
  }
}

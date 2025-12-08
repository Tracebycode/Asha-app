import 'package:flutter/material.dart';
import '../../../core/ml/tb_risk_engine.dart';

class TbResultPage extends StatelessWidget {
  final TbPrediction result;

  const TbResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor();
    final riskIcon = _getRiskIcon();
    final riskLabel = _getRiskLabel(); // human readable label

    return Scaffold(
      appBar: AppBar(
        title: const Text("TB Screening Result"),
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
                      "Risk Score: ${result.riskScore}",
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
                "• No major symptoms reported",
                style: TextStyle(fontSize: 16),
              )
            else
              ...result.problems.map(
                    (p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    "• ${_localizeProblem(p)}",
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
                    "• ${_localizeSuggestion(s)}",
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
        return "Low TB Risk";
      case "risk_moderate":
        return "Moderate TB Risk";
      default:
        return "High TB Risk";
    }
  }
}

// ===================================================================
// Simple key → human readable mapping
// Later you can replace this with proper localization / .arb files
// ===================================================================

String _localizeProblem(String key) {
  switch (key) {
    case "tb_problem_prolonged_cough_2w":
      return "Cough lasting 2 weeks or more";
    case "tb_problem_prolonged_cough_3w":
      return "Cough lasting 3 weeks or more";
    case "tb_problem_hemoptysis":
      return "Coughing up blood in sputum";
    case "tb_problem_persistent_fever":
      return "Persistent fever for 7 days or more";
    case "tb_problem_continuous_fever":
      return "Continuous fever pattern";
    case "tb_problem_weight_loss":
      return "Unintentional weight loss";
    case "tb_problem_significant_weight_loss":
      return "Significant weight loss (≥ 3 kg)";
    case "tb_problem_recent_weight_loss":
      return "Recent weight loss in last few weeks";
    case "tb_problem_chest_pain_with_cough":
      return "Chest pain associated with cough";
    case "tb_problem_tb_contact":
      return "Close contact with a TB patient at home";
    case "tb_problem_past_tb_history":
      return "History of TB in the past";
    default:
      return key; // fallback: show raw key
  }
}

String _localizeSuggestion(String key) {
  switch (key) {
    case "tb_suggest_regular_followup":
      return "Continue regular follow-up and monitor symptoms.";
    case "tb_suggest_urgent_referral":
      return "Urgent referral to PHC/doctor for TB evaluation.";
    case "tb_suggest_sputum_test":
      return "Advise sputum examination / CBNAAT as per protocol.";
    case "tb_suggest_medical_evaluation":
      return "Advise medical evaluation for persistent fever and symptoms.";
    case "tb_suggest_nutrition_and_screening":
      return "Counsel on nutrition and assess for underlying TB or other causes.";
    case "tb_suggest_contact_tracing_and_testing":
      return "Screen family members and close contacts for TB.";
    default:
      return key; // fallback
  }
}

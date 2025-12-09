import 'package:flutter/material.dart';
import 'package:asha_frontend/localization/app_localization.dart';
import '../../../core/ml/ncd_risk_engine.dart';

class NcdResultPage extends StatelessWidget {
  final NcdPrediction result;

  const NcdResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalization.of(context).t;

    return Scaffold(
      appBar: AppBar(
        title: Text(t("ncd_result_title")),
        backgroundColor: Colors.blue,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // RISK CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getRiskColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(_getRiskIcon(), color: Colors.white, size: 46),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "${t(_getRiskLabelKey())}\n${t("risk_score")}: ${result.riskScore}",
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

            // PROBLEMS
            Text(t("ncd_identified_risks"),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            if (result.problems.isEmpty)
              Text("• ${t("ncd_no_risk_found")}",
                  style: const TextStyle(fontSize: 16))
            else
              ...result.problems.map(
                    (p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    "• ${t(p)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

            const SizedBox(height: 28),

            // SUGGESTIONS
            Text(t("ncd_suggestions"),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            if (result.suggestions.isEmpty)
              Text("• ${t("ncd_no_suggestions")}",
                  style: const TextStyle(fontSize: 16))
            else
              ...result.suggestions.map(
                    (s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    "• ${t(s)}",
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

  // =======================
  // RISK LEVEL UI HELPERS
  // =======================

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

  // JSON keys instead of English text
  String _getRiskLabelKey() {
    switch (result.riskLevelKey) {
      case "risk_low":
        return "ncd_risk_low";
      case "risk_moderate":
        return "ncd_risk_moderate";
      default:
        return "ncd_risk_high";
    }
  }
}

import 'package:flutter/material.dart';
import '../../../core/ml/pnc_risk_engine.dart';

class PncResultPage extends StatelessWidget {
  final PncPrediction result;

  const PncResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PNC Risk Result"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== RISK CARD =====
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _getRiskColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(_getRiskIcon(), color: Colors.white, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Risk Score: ${result.riskScore}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ===== PROBLEMS =====
            const Text(
              "Identified Risk Factors",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (result.problems.isEmpty)
              const Text(
                "• No major problems detected",
                style: TextStyle(fontSize: 16),
              ),
            ...result.problems.map(
                  (p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text("• $p", style: const TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 24),

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
              ),
            ...result.suggestions.map(
                  (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text("• $s", style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}

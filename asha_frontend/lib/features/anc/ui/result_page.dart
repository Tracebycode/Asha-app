import 'package:flutter/material.dart';
import '../../../core/ml/anc_risk_engine.dart';

class AncResultPage extends StatelessWidget {
  final AncPrediction result;

  const AncResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ANC Risk Result"),
        backgroundColor: Colors.blue,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

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
                  Text(
                    "Risk Score: ${result.riskScore}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text("Identified Problems",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            ...result.problems.map(
                  (p) => Text("• $p", style: const TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 24),
            const Text("Suggestions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            ...result.suggestions.map(
                  (s) => Text("• $s", style: const TextStyle(fontSize: 16)),
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

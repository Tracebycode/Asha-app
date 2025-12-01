import 'package:flutter/material.dart';

class CriticalCard extends StatelessWidget {
  final bool isCritical;

  const CriticalCard({super.key, required this.isCritical});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isCritical ? Colors.red.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isCritical ? Icons.warning : Icons.check_circle,
              color: isCritical ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 12),
            Text(
              isCritical ? "Critical Case" : "Stable Case",
              style: TextStyle(
                color: isCritical ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

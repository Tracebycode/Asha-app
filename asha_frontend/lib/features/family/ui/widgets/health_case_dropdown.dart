import 'package:flutter/material.dart';

class HealthCaseDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;
  final List<Map<String, dynamic>> healthCases;

  const HealthCaseDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.healthCases,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            hintText: 'Select Health Case',
            prefixIcon: const Icon(Icons.medical_services_outlined, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
          ),
          value: value,
          items: healthCases.map((caseItem) {
            return DropdownMenuItem<String>(
              value: caseItem['value'],
              child: Row(
                children: <Widget>[
                  Icon(caseItem['icon'], color: const Color(0xFF2A5A9E)),
                  const SizedBox(width: 10),
                  Text(caseItem['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

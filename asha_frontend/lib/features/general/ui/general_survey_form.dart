import 'package:flutter/material.dart';
import 'package:asha_frontend/features/general/state/general_survey_controller.dart';

class GeneralSurveyForm extends StatefulWidget {
  final GeneralSurveyController controller;
  const GeneralSurveyForm({super.key, required this.controller});

  @override
  State<GeneralSurveyForm> createState() => _GeneralSurveyFormState();
}

class _GeneralSurveyFormState extends State<GeneralSurveyForm> {
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "General Household Survey",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // ------- Household Conditions -------
        _sectionTitle("Household Condition"),
        _switchTile("House Clean?", c.houseClean,
                (v) => setState(() => c.houseClean = v)),
        _switchTile("Safe Drinking Water?", c.drinkingWaterSafe,
                (v) => setState(() => c.drinkingWaterSafe = v)),
        _switchTile("Toilet Available?", c.toiletAvailable,
                (v) => setState(() => c.toiletAvailable = v)),
        _switchTile("Proper Waste Disposal?", c.wasteDisposalProper,
                (v) => setState(() => c.wasteDisposalProper = v)),

        const SizedBox(height: 20),

        // ------- Members Present -------
        _sectionTitle("Members Present"),
        _switchTile("Pregnant Woman Present?", c.pregnantWomanPresent,
                (v) => setState(() => c.pregnantWomanPresent = v)),
        _switchTile("Newborn Present?", c.newbornPresent,
                (v) => setState(() => c.newbornPresent = v)),
        _switchTile("Elderly Present?", c.elderlyPresent,
                (v) => setState(() => c.elderlyPresent = v)),

        const SizedBox(height: 20),

        // ------- Symptoms -------
        _sectionTitle("Symptoms (Select all that apply)"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: c.symptomsList.map((sym) {
            final selected = c.symptoms.contains(sym);
            return ChoiceChip(
              label: Text(sym),
              selected: selected,
              selectedColor: Colors.blue,
              onSelected: (v) {
                setState(() {
                  v ? c.symptoms.add(sym) : c.symptoms.remove(sym);
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // ------- Vitals -------
        _sectionTitle("Vitals (if measured)"),
        _textField("Temperature (°F)", c.tempController),
        const SizedBox(height: 12),
        _textField("Weight (kg)", c.weightController),
        const SizedBox(height: 12),
        _textField("BP (e.g., 120/80)", c.bpController),

        const SizedBox(height: 20),

        // ------- Notes -------
        _sectionTitle("General Notes"),
        TextFormField(
          controller: c.notesController,
          maxLines: 3,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Any observations...",
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        const SizedBox(height: 20),

        if (c.isCritical)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text("Critical case detected!",
                    style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ),
      ],
    );
  }

  // ------------ Helpers -------------

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold)),
  );

  Widget _switchTile(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Switch(value: value, onChanged: onChanged)
      ],
    );
  }

  Widget _textField(String label, TextEditingController c) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

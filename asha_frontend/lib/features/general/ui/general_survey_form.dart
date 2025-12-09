import 'package:flutter/material.dart';
import 'package:asha_frontend/localization/app_localization.dart';
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
    final t = AppLocalization.of(context).t;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t("general_household_survey"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // ------- Household Conditions -------
        _sectionTitle(t("household_condition")),
        _switchTile(t("house_clean"), c.houseClean,
                (v) => setState(() => c.houseClean = v)),
        _switchTile(t("safe_drinking_water"), c.drinkingWaterSafe,
                (v) => setState(() => c.drinkingWaterSafe = v)),
        _switchTile(t("toilet_available"), c.toiletAvailable,
                (v) => setState(() => c.toiletAvailable = v)),
        _switchTile(t("proper_waste_disposal"), c.wasteDisposalProper,
                (v) => setState(() => c.wasteDisposalProper = v)),

        const SizedBox(height: 20),

        // ------- Members Present -------
        _sectionTitle(t("members_present")),
        _switchTile(t("pregnant_woman_present"), c.pregnantWomanPresent,
                (v) => setState(() => c.pregnantWomanPresent = v)),
        _switchTile(t("newborn_present"), c.newbornPresent,
                (v) => setState(() => c.newbornPresent = v)),
        _switchTile(t("elderly_present"), c.elderlyPresent,
                (v) => setState(() => c.elderlyPresent = v)),

        const SizedBox(height: 20),

        // ------- Symptoms -------
        _sectionTitle(t("symptoms_select_all")),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: c.symptomsList.map((sym) {
            final selected = c.symptoms.contains(sym);

            return ChoiceChip(
              label: Text(t(sym)), // <-- SYMptoms also localized
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
        _sectionTitle(t("vitals_if_measured")),
        _textField(t("temperature_f"), c.tempController),
        const SizedBox(height: 12),
        _textField(t("weight_kg"), c.weightController),
        const SizedBox(height: 12),
        _textField(t("bp_example"), c.bpController),

        const SizedBox(height: 20),

        // ------- Notes -------
        _sectionTitle(t("general_notes")),
        TextFormField(
          controller: c.notesController,
          maxLines: 3,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: t("any_observations"),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  t("critical_case_detected"),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ------------ Helpers -------------

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
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

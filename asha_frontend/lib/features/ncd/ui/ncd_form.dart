import 'package:flutter/material.dart';
import 'package:asha_frontend/features/ncd/state/ncd_controller.dart';
import 'package:asha_frontend/features/ncd/ui/ncd_result_page.dart';
import 'package:asha_frontend/localization/app_localization.dart';

class NcdForm extends StatefulWidget {
  final NcdController controller;
  const NcdForm({super.key, required this.controller});

  @override
  State<NcdForm> createState() => _NcdFormState();
}

class _NcdFormState extends State<NcdForm> {
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final t = AppLocalization.of(context).t;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t("ncd_screening_title"),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),

        const SizedBox(height: 16),
        _metricCard(
          title: t("blood_pressure"),
          icon: Icons.monitor_heart,
          children: [
            _field(t("systolic"), c.systolic),
            const SizedBox(height: 12),
            _field(t("diastolic"), c.diastolic),
          ],
        ),

        const SizedBox(height: 16),
        _metricCard(
          title: t("bmi"),
          icon: Icons.square_foot,
          children: [
            _field(t("weight"), c.weight),
            const SizedBox(height: 12),
            _field(t("height"), c.height),
          ],
        ),

        const SizedBox(height: 16),
        _metricCard(
          title: t("blood_sugar"),
          icon: Icons.water_drop,
          children: [
            _field(t("random_blood_sugar"), c.randomBloodSugar),
          ],
        ),

        const SizedBox(height: 16),
        _metricCard(
          title: t("tobacco_alcohol"),
          icon: Icons.smoke_free,
          children: [
            _switchTile(
              title: t("uses_tobacco"),
              value: c.usesTobacco,
              onChanged: (v) => setState(() => c.usesTobacco = v),
            ),
            const Divider(),
            _switchTile(
              title: t("consumes_alcohol"),
              value: c.consumesAlcohol,
              onChanged: (v) => setState(() => c.consumesAlcohol = v),
            ),
          ],
        ),

        const SizedBox(height: 16),
        _metricCard(
          title: t("diet"),
          icon: Icons.restaurant_menu,
          children: [
            Text(t("extra_salt")),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                "none",
                "little",
                "a_lot",
              ].map((key) {
                return _choiceChip(
                  label: t(key),
                  selected: c.extraSaltIntake == key,
                  onSelected: () => setState(() => c.extraSaltIntake = key),
                );
              }).toList(),
            ),
          ],
        ),

        const SizedBox(height: 16),
        _metricCard(
          title: t("physical_activity"),
          icon: Icons.directions_run,
          children: [
            Text(t("exercise_frequency")),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                "daily",
                "few_times_week",
                "rarely",
                "never",
              ].map((key) {
                return _choiceChip(
                  label: t(key),
                  selected: c.exerciseFrequency == key,
                  onSelected: () =>
                      setState(() => c.exerciseFrequency = key),
                );
              }).toList(),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // CRITICAL WARNING
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
                  t("critical_detected"),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),

        // ===== PREDICT BUTTON =====
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.analytics),
            label: Text(t("calculate_ncd_risk")),
            onPressed: () {
              final prediction = c.calculateRisk();

              if (prediction == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t("enter_ncd_details"))),
                );
                return;
              }

              setState(() {}); // update warning banner

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NcdResultPage(result: prediction),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ------------ UI Helpers -------------

  Widget _field(String label, TextEditingController c) {
    return TextFormField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2A5A9E)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title), Switch(value: value, onChanged: onChanged)],
    );
  }

  Widget _choiceChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(color: selected ? Colors.white : Colors.black),
      ),
      selected: selected,
      selectedColor: const Color(0xFF2A5A9E),
      onSelected: (_) => onSelected(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:asha_frontend/features/ncd/state/ncd_controller.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("NCD Screening",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),

        const SizedBox(height: 16),
        _metricCard(
          title: "Blood Pressure",
          icon: Icons.monitor_heart,
          children: [
            _field("Systolic (mmHg)", c.systolic),
            const SizedBox(height: 12),
            _field("Diastolic (mmHg)", c.diastolic),
          ],
        ),

        const SizedBox(height: 16),
        _metricCard(
          title: "BMI",
          icon: Icons.square_foot,
          children: [
            _field("Weight (kg)", c.weight),
            const SizedBox(height: 12),
            _field("Height (cm)", c.height),
          ],
        ),

        const SizedBox(height: 16),
        _metricCard(
          title: "Blood Sugar",
          icon: Icons.water_drop,
          children: [
            _field("Random Blood Sugar (mg/dL)", c.randomBloodSugar),
          ],
        ),

        const SizedBox(height: 16),
        _metricCard(
          title: "Tobacco & Alcohol",
          icon: Icons.smoke_free,
          children: [
            _switchTile(
              title: "Uses Tobacco?",
              value: c.usesTobacco,
              onChanged: (v) => setState(() => c.usesTobacco = v),
            ),
            const Divider(),
            _switchTile(
              title: "Consumes Alcohol?",
              value: c.consumesAlcohol,
              onChanged: (v) => setState(() => c.consumesAlcohol = v),
            ),
          ],
        ),

        const SizedBox(height: 16),
        _metricCard(
          title: "Diet",
          icon: Icons.restaurant_menu,
          children: [
            const Text("How much extra salt do you add?"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ["None", "A little", "A lot"].map((label) {
                return _choiceChip(
                  label: label,
                  selected: c.extraSaltIntake == label,
                  onSelected: () => setState(() => c.extraSaltIntake = label),
                );
              }).toList(),
            ),
          ],
        ),

        const SizedBox(height: 16),
        _metricCard(
          title: "Physical Activity",
          icon: Icons.directions_run,
          children: [
            const Text("Exercise frequency"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ["Daily", "Few times a week", "Rarely", "Never"]
                  .map((label) {
                return _choiceChip(
                  label: label,
                  selected: c.exerciseFrequency == label,
                  onSelected: () =>
                      setState(() => c.exerciseFrequency = label),
                );
              }).toList(),
            ),
          ],
        ),

        const SizedBox(height: 20),

        if (c.isCritical)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12)),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text("Critical values detected",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ],
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

  Widget _metricCard(
      {required String title,
        required IconData icon,
        required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Icon(icon, color: Color(0xFF2A5A9E)),
            const SizedBox(width: 8),
            Text(title,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const Divider(height: 24),
        ...children,
      ]),
    );
  }

  Widget _switchTile(
      {required String title,
        required bool value,
        required Function(bool) onChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title), Switch(value: value, onChanged: onChanged)],
    );
  }

  Widget _choiceChip(
      {required String label,
        required bool selected,
        required VoidCallback onSelected}) {
    return ChoiceChip(
      label: Text(label,
          style: TextStyle(color: selected ? Colors.white : Colors.black)),
      selected: selected,
      selectedColor: const Color(0xFF2A5A9E),
      onSelected: (_) => onSelected(),
    );
  }
}

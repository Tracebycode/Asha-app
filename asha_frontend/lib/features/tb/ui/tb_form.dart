import 'package:flutter/material.dart';
import 'package:asha_frontend/features/tb/state/tb_controller.dart';

class TbForm extends StatefulWidget {
  final TbController controller;
  const TbForm({super.key, required this.controller});

  @override
  State<TbForm> createState() => _TbFormState();
}

class _TbFormState extends State<TbForm> {
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ---------------- COUGH --------------------
        const Text('Does the patient have a cough?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        _yesNo(c.hasCough, (v) => setState(() => c.hasCough = v)),

        if (c.hasCough == true) ...[
          const SizedBox(height: 12),
          _textField("Cough Duration", c.coughDuration,
              icon: Icons.timer, type: TextInputType.number),

          const SizedBox(height: 8),
          Row(
            children: [
              const Text("Unit: "),
              DropdownButton<String>(
                value: c.coughDurationUnit,
                items: ["Days", "Weeks"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => c.coughDurationUnit = v!),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Text("Cough Type"),
          _check("Dry", c.coughTypes),
          _check("With Phlegm", c.coughTypes),
          _check("With Blood", c.coughTypes),
        ],

        const Divider(height: 32),

        // ---------------- FEVER --------------------
        const Text('Does the patient have a fever?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        _yesNo(c.hasFever, (v) => setState(() => c.hasFever = v)),

        if (c.hasFever == true) ...[
          const SizedBox(height: 12),
          _textField("Fever Duration", c.feverDuration,
              icon: Icons.timer, type: TextInputType.number),

          const SizedBox(height: 8),
          Row(
            children: [
              const Text("Unit: "),
              DropdownButton<String>(
                value: c.feverDurationUnit,
                items: ["Days", "Weeks", "Months"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => c.feverDurationUnit = v!),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Text("Fever Pattern"),
          _chip("Continuous", c),
          _chip("Intermittent", c),
          _chip("Remittent", c),
        ],

        const Divider(height: 32),

        // ---------------- WEIGHT LOSS --------------------
        const Text('Unintentional weight loss?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        _yesNo(c.hasWeightLoss, (v) => setState(() => c.hasWeightLoss = v)),

        if (c.hasWeightLoss == true) ...[
          const SizedBox(height: 12),
          _textField("Weight Loss (kg)", c.weightLossAmount,
              icon: Icons.scale, type: TextInputType.number),

          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: c.weightLossPeriod,
            items: [
              "Last 2 weeks",
              "Last month",
              "Last 3 months",
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => c.weightLossPeriod = v!),
          ),
        ],

        const Divider(height: 32),

        // ---------------- CHEST PAIN --------------------
        const Text('Chest pain?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        _yesNo(c.hasChestPain, (v) => setState(() => c.hasChestPain = v)),

        const Divider(height: 32),

        // ---------------- TB EXPOSURE --------------------
        const Text('Any TB patient at home?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        _yesNo(c.hasTbPatientAtHome,
                (v) => setState(() => c.hasTbPatientAtHome = v)),

        const SizedBox(height: 12),
        const Text('Had TB in the past?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        _yesNo(c.hadTbInPast, (v) => setState(() => c.hadTbInPast = v)),

        const SizedBox(height: 24),

        // ---------------- CRITICAL --------------------
        if (c.isCritical)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                    child: Text("⚠ Critical Symptoms Detected",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
      ],
    );
  }

  // ---------- Helper Widgets ----------

  Widget _yesNo(bool? value, Function(bool?) onChanged) {
    return Row(
      children: [
        ChoiceChip(
          label: const Text("Yes"),
          selected: value == true,
          onSelected: (_) => onChanged(true),
        ),
        const SizedBox(width: 12),
        ChoiceChip(
          label: const Text("No"),
          selected: value == false,
          onSelected: (_) => onChanged(false),
        ),
      ],
    );
  }

  Widget _check(String label, Set<String> set) {
    return CheckboxListTile(
      title: Text(label),
      value: set.contains(label),
      onChanged: (v) {
        setState(() {
          v! ? set.add(label) : set.remove(label);
        });
      },
    );
  }

  Widget _chip(String text, TbController c) {
    return ChoiceChip(
      label: Text(text),
      selected: c.feverPattern == text,
      onSelected: (_) => setState(() => c.feverPattern = text),
    );
  }

  Widget _textField(String label, TextEditingController c,
      {IconData? icon, TextInputType? type}) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

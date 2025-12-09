import 'package:flutter/material.dart';
import '../../../localization/app_localization.dart';
import '../../../core/ml/tb_risk_engine.dart';
import 'package:asha_frontend/features/tb/ui/tb_result_page.dart';
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
    final t = AppLocalization.of(context).t;
    final c = widget.controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------- COUGH --------------------
        Text(
          t("tb_cough_question"),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        _yesNo(c.hasCough, (v) => setState(() => c.hasCough = v)),

        if (c.hasCough == true) ...[
          const SizedBox(height: 12),
          _textField(
            t("tb_cough_duration"),
            c.coughDuration,
            icon: Icons.timer,
            type: TextInputType.number,
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              Text(t("tb_unit")),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: c.coughDurationUnit,
                items: [
                  t("tb_days"),
                  t("tb_weeks"),
                ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => c.coughDurationUnit = v!),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Text(t("tb_cough_type")),
          _check(t("tb_cough_dry"), c.coughTypes),
          _check(t("tb_cough_phlegm"), c.coughTypes),
          _check(t("tb_cough_blood"), c.coughTypes),
        ],

        const Divider(height: 32),

        // ---------------- FEVER --------------------
        Text(
          t("tb_fever_question"),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        _yesNo(c.hasFever, (v) => setState(() => c.hasFever = v)),

        if (c.hasFever == true) ...[
          const SizedBox(height: 12),
          _textField(
            t("tb_fever_duration"),
            c.feverDuration,
            icon: Icons.timer,
            type: TextInputType.number,
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              Text(t("tb_unit")),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: c.feverDurationUnit,
                items: [
                  t("tb_days"),
                  t("tb_weeks"),
                  t("tb_months"),
                ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => c.feverDurationUnit = v!),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Text(t("tb_fever_pattern")),
          _chip(t("tb_fever_continuous"), c),
          _chip(t("tb_fever_intermittent"), c),
          _chip(t("tb_fever_remittent"), c),
        ],

        const Divider(height: 32),

        // ---------------- WEIGHT LOSS --------------------
        Text(
          t("tb_weight_loss_question"),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        _yesNo(c.hasWeightLoss, (v) => setState(() => c.hasWeightLoss = v)),

        if (c.hasWeightLoss == true) ...[
          const SizedBox(height: 12),
          _textField(
            t("tb_weight_loss_amount"),
            c.weightLossAmount,
            icon: Icons.scale,
            type: TextInputType.number,
          ),

          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: c.weightLossPeriod,
            items: [
              t("tb_last_2_weeks"),
              t("tb_last_month"),
              t("tb_last_3_months"),
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => c.weightLossPeriod = v!),
          ),
        ],

        const Divider(height: 32),

        // ---------------- CHEST PAIN --------------------
        Text(
          t("tb_chest_pain"),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        _yesNo(c.hasChestPain, (v) => setState(() => c.hasChestPain = v)),

        const Divider(height: 32),

        // ---------------- TB EXPOSURE --------------------
        Text(
          t("tb_patient_at_home"),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        _yesNo(c.hasTbPatientAtHome,
                (v) => setState(() => c.hasTbPatientAtHome = v)),

        const SizedBox(height: 12),
        Text(
          t("tb_past_tb"),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        _yesNo(c.hadTbInPast, (v) => setState(() => c.hadTbInPast = v)),

        const SizedBox(height: 24),

        // ---------------- CRITICAL BANNER --------------------
        if (c.isCritical)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t("tb_critical_detected"),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 24),

        // ---------------- PREDICT BUTTON --------------------
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.analytics),
            label: Text(t("tb_calculate_risk")),
            onPressed: () {
              final prediction = c.calculateRisk();

              if (prediction == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t("tb_fill_details"))),
                );
                return;
              }

              setState(() {}); // refresh banner

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TbResultPage(result: prediction),
                ),
              );
            },
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

  Widget _textField(
      String label,
      TextEditingController c, {
        IconData? icon,
        TextInputType? type,
      }) {
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

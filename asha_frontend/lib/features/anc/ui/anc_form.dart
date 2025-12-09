import 'package:flutter/material.dart';
import '../../../core/ml/anc_risk_engine.dart';
import 'package:asha_frontend/features/anc/ui/result_page.dart';
import '../state/anc_controller.dart';
import 'package:asha_frontend/localization/app_localization.dart';

class AncForm extends StatefulWidget {
  final AncController controller;

  const AncForm({super.key, required this.controller});

  @override
  State<AncForm> createState() => _AncFormState();
}

class _AncFormState extends State<AncForm> {

  void _calculateRisk() {
    final t = AppLocalization.of(context).t;
    final c = widget.controller;

    int bpSys = 0;
    int bpDia = 0;

    try {
      if (c.bp.text.contains("/")) {
        final parts = c.bp.text.split("/");
        bpSys = int.tryParse(parts[0]) ?? 0;
        bpDia = int.tryParse(parts[1]) ?? 0;
      }
    } catch (_) {}

    int lmpDays = 0;
    if (c.lmpDate != null) {
      lmpDays = DateTime.now().difference(c.lmpDate!).inDays;
    }

    final step1 = {
      "gravida": c.gravida,
      "parity": c.para,
      "living": c.living,
      "abortions": c.abortions,
    };

    final step2 = {
      "bpSys": bpSys,
      "bpDia": bpDia,
      "weight": int.tryParse(c.weight.text) ?? 0,
      "hemoglobin": int.tryParse(c.hemoglobin.text) ?? 0,
      "sugar": int.tryParse(c.bloodSugar.text) ?? 0,
      "lmpDays": lmpDays,
    };

    final step3 = {
      "bleeding": c.symptoms.contains(t("bleeding")) ? 1.0 : 0.0,
      "severe_headache": c.symptoms.contains(t("severe_headache")) ? 1.0 : 0.0,
      "swelling": c.symptoms.contains(t("swelling")) ? 1.0 : 0.0,
      "blurred_vision": c.symptoms.contains(t("blurred_vision")) ? 1.0 : 0.0,
      "fever": c.symptoms.contains(t("fever")) ? 1.0 : 0.0,
      "convulsions": c.symptoms.contains(t("convulsions")) ? 1.0 : 0.0,
      "prev_cesarean": c.previousCesarean ? 1.0 : 0.0,
      "prev_stillbirth": c.previousStillbirth ? 1.0 : 0.0,
      "prev_complications": c.previousComplications ? 1.0 : 0.0,
    };

    final result = calculateAncRisk(
      step1: step1,
      step2: step2,
      step3: step3,
      age: c.age,
      gender: c.gender,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AncResultPage(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final t = AppLocalization.of(context).t;

    final symptomsList = [
      t("bleeding"),
      t("severe_headache"),
      t("swelling"),
      t("blurred_vision"),
      t("fever"),
      t("convulsions"),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(t("mother_details"),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 16),

        // Row 1
        Row(
          children: [
            _counter(t("gravida"), c.gravida,
                    () => setState(() => c.gravida++),
                    () => setState(() => c.gravida > 0 ? c.gravida-- : 0)),

            const SizedBox(width: 16),

            _counter(t("para"), c.para,
                    () => setState(() => c.para++),
                    () => setState(() => c.para > 0 ? c.para-- : 0)),
          ],
        ),

        const SizedBox(height: 16),

        // Row 2
        Row(
          children: [
            _counter(t("living"), c.living,
                    () => setState(() => c.living++),
                    () => setState(() => c.living > 0 ? c.living-- : 0)),

            const SizedBox(width: 16),

            _counter(t("abortions"), c.abortions,
                    () => setState(() => c.abortions++),
                    () => setState(() => c.abortions > 0 ? c.abortions-- : 0)),
          ],
        ),

        const SizedBox(height: 24),

        _datePicker(
          label: t("lmp"),
          selected: c.lmpDate,
          onPick: (date) {
            setState(() {
              c.lmpDate = date;
              c.updateEdd();
            });
          },
        ),

        const SizedBox(height: 16),

        // EDD Display
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
          child: Text(
            c.eddDate == null
                ? t("auto_calculated")
                : "${c.eddDate!.day}/${c.eddDate!.month}/${c.eddDate!.year}",
            style: const TextStyle(fontSize: 16),
          ),
        ),

        const SizedBox(height: 24),

        _textField(t("bp_label"), c.bp, t("bp_hint")),
        const SizedBox(height: 16),

        _textField(t("weight_label"), c.weight, t("weight_hint")),
        const SizedBox(height: 16),

        _textField(t("hemoglobin_label"), c.hemoglobin, t("hemoglobin_hint")),
        const SizedBox(height: 16),

        _textField(t("sugar_label"), c.bloodSugar, t("sugar_hint")),

        const SizedBox(height: 24),

        Text(t("current_symptoms"),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          children: symptomsList.map((sym) {
            final isSelected = c.symptoms.contains(sym);
            return Padding(
              padding: const EdgeInsets.all(4),
              child: FilterChip(
                label: Text(sym),
                selected: isSelected,
                onSelected: (v) {
                  setState(() {
                    v ? c.symptoms.add(sym) : c.symptoms.remove(sym);
                  });
                },
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        _toggle(t("prev_cesarean"), c.previousCesarean,
                (v) => setState(() => c.previousCesarean = v)),
        _toggle(t("prev_stillbirth"), c.previousStillbirth,
                (v) => setState(() => c.previousStillbirth = v)),
        _toggle(t("prev_complications"), c.previousComplications,
                (v) => setState(() => c.previousComplications = v)),

        const SizedBox(height: 24),

        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _calculateRisk,
            child: Text(t("calculate_risk"),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }

  Widget _counter(String label, int value, VoidCallback add, VoidCallback remove) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: remove, icon: const Icon(Icons.remove)),
                Text("$value"),
                IconButton(onPressed: add, icon: const Icon(Icons.add)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _textField(String label, TextEditingController c, String hint,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: c,
          maxLines: maxLines,
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: hint,
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        )
      ],
    );
  }

  Widget _datePicker({
    required String label,
    required DateTime? selected,
    required Function(DateTime?) onPick,
  }) {
    final t = AppLocalization.of(context).t;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selected ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now().add(const Duration(days: 300)),
            );
            onPick(picked);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Text(
              selected == null
                  ? t("select_date")
                  : "${selected.day}/${selected.month}/${selected.year}",
            ),
          ),
        ),
      ],
    );
  }

  Widget _toggle(String label, bool value, Function(bool) onChange) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Switch(value: value, onChanged: onChange),
      ],
    );
  }
}

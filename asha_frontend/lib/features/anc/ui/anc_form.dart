import 'package:flutter/material.dart';
import '../../../core/ml/anc_risk_engine.dart';
import 'package:asha_frontend/features/anc/ui/result_page.dart';
import '../state/anc_controller.dart';

class AncForm extends StatefulWidget {
  final AncController controller;

  const AncForm({super.key, required this.controller});

  @override
  State<AncForm> createState() => _AncFormState();
}

class _AncFormState extends State<AncForm> {

  // ------------------ ML CALCULATE FUNCTION ------------------
  void _calculateRisk() {
    final c = widget.controller;

    // ---- Parse BP ----
    int bpSys = 0;
    int bpDia = 0;
    try {
      if (c.bp.text.contains("/")) {
        final parts = c.bp.text.split("/");
        bpSys = int.tryParse(parts[0]) ?? 0;
        bpDia = int.tryParse(parts[1]) ?? 0;
      }
    } catch (e) {
      print("DEBUG: BP parse error: $e");
    }

    // ---- LMP DAYS ----
    int lmpDays = 0;
    if (c.lmpDate != null) {
      lmpDays = DateTime.now().difference(c.lmpDate!).inDays;
    }

    // ---- STEP 1 ----
    final step1 = {
      "gravida": c.gravida,
      "parity": c.para,
      "living": c.living,
      "abortions": c.abortions,
    };

    // ---- STEP 2 ----
    final step2 = {
      "bpSys": bpSys,
      "bpDia": bpDia,
      "weight": int.tryParse(c.weight.text) ?? 0,
      "hemoglobin": int.tryParse(c.hemoglobin.text) ?? 0,
      "sugar": int.tryParse(c.bloodSugar.text) ?? 0,
      "lmpDays": lmpDays,
    };

    // ---- STEP 3 ----
    final step3 = {
      "bleeding": c.symptoms.contains("Bleeding") ? 1.0 : 0.0,
      "severe_headache": c.symptoms.contains("Severe Headache") ? 1.0 : 0.0,
      "swelling": c.symptoms.contains("Swelling") ? 1.0 : 0.0,
      "blurred_vision": c.symptoms.contains("Blurred Vision") ? 1.0 : 0.0,
      "fever": c.symptoms.contains("Fever") ? 1.0 : 0.0,
      "convulsions": c.symptoms.contains("Convulsions") ? 1.0 : 0.0,
      "prev_cesarean": c.previousCesarean ? 1.0 : 0.0,
      "prev_stillbirth": c.previousStillbirth ? 1.0 : 0.0,
      "prev_complications": c.previousComplications ? 1.0 : 0.0,
    };

    print("DEBUG STEP1 => $step1");
    print("DEBUG STEP2 => $step2");
    print("DEBUG STEP3 => $step3");

    // ---- ML ENGINE CALL ----
    final result = calculateAncRisk(
      step1: step1,
      step2: step2,
      step3: step3,
      age: c.age,
      gender: c.gender,
    );

    print("DEBUG RISK SCORE => ${result.riskScore}");
    print("DEBUG RISK LEVEL => ${result.riskLevelKey}");

    // ---- REDIRECT TO RESULT PAGE ----
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AncResultPage(result: result),
      ),
    );
  }

  // ------------------ UI FORM ------------------
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text("Mother's Details",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 16),

        // Gravida / Para
        Row(
          children: [
            _counter("Gravida", c.gravida,
                    () => setState(() => c.gravida++),
                    () => setState(() => c.gravida > 0 ? c.gravida-- : 0)),
            const SizedBox(width: 16),
            _counter("Para", c.para,
                    () => setState(() => c.para++),
                    () => setState(() => c.para > 0 ? c.para-- : 0)),
          ],
        ),

        const SizedBox(height: 16),

        // Living / Abortions
        Row(
          children: [
            _counter("Living", c.living,
                    () => setState(() => c.living++),
                    () => setState(() => c.living > 0 ? c.living-- : 0)),
            const SizedBox(width: 16),
            _counter("Abortions", c.abortions,
                    () => setState(() => c.abortions++),
                    () => setState(() => c.abortions > 0 ? c.abortions-- : 0)),
          ],
        ),

        const SizedBox(height: 24),

        // LMP
        _datePicker(
          label: "Last Menstrual Period (LMP)",
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
                ? "Auto-calculated"
                : "${c.eddDate!.day}/${c.eddDate!.month}/${c.eddDate!.year}",
            style: const TextStyle(fontSize: 16),
          ),
        ),

        const SizedBox(height: 24),

        _textField("BP (Systolic / Diastolic)", c.bp, "120/80"),
        const SizedBox(height: 16),
        _textField("Weight (kg)", c.weight, "Enter weight"),
        const SizedBox(height: 16),
        _textField("Hemoglobin (g/dL)", c.hemoglobin, "Enter Hb"),
        const SizedBox(height: 16),
        _textField("Blood Sugar (mg/dL)", c.bloodSugar, "Enter sugar"),

        const SizedBox(height: 24),

        // Symptoms
        const Text("Current Symptoms",
            style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          children: [
            "Bleeding",
            "Severe Headache",
            "Swelling",
            "Blurred Vision",
            "Fever",
            "Convulsions"
          ].map((sym) {
            final isSelected = c.symptoms.contains(sym);
            return Padding(
              padding: const EdgeInsets.all(4),
              child: FilterChip(
                label: Text(sym),
                selected: isSelected,
                onSelected: (val) {
                  setState(() {
                    val ? c.symptoms.add(sym) : c.symptoms.remove(sym);
                  });
                },
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Previous complications
        _toggle("Previous Cesarean", c.previousCesarean,
                (v) => setState(() => c.previousCesarean = v)),
        _toggle("Previous Stillbirth", c.previousStillbirth,
                (v) => setState(() => c.previousStillbirth = v)),
        _toggle("Previous Complications", c.previousComplications,
                (v) => setState(() => c.previousComplications = v)),

        const SizedBox(height: 24),

        // ---------------- BUTTON ----------------
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _calculateRisk,
            child: const Text("Calculate Risk",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }

  // ---------------- Helper Widgets ----------------

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

  Widget _datePicker(
      {required String label,
        required DateTime? selected,
        required Function(DateTime?) onPick}) {
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
            child: Text(selected == null
                ? "Select date"
                : "${selected.day}/${selected.month}/${selected.year}"),
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
        Switch(value: value, onChanged: (v) => onChange(v))
      ],
    );
  }
}

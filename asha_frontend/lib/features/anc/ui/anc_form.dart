import 'package:flutter/material.dart';
import '../state/anc_controller.dart';

class AncForm extends StatefulWidget {
  final AncController controller;

  const AncForm({super.key, required this.controller});

  @override
  State<AncForm> createState() => _AncFormState();
}

class _AncFormState extends State<AncForm> {

  @override
  Widget build(BuildContext context) {
    final c = widget.controller; // shortcut

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // --------------------- PARITY -----------------------
        const Text("Mother's Details",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 16),

        Row(
          children: [
            _counter("Gravida", c.gravida, () {
              setState(() => c.gravida++);
            }, () {
              setState(() => c.gravida > 0 ? c.gravida-- : 0);
            }),
            const SizedBox(width: 16),
            _counter("Para", c.para, () {
              setState(() => c.para++);
            }, () {
              setState(() => c.para > 0 ? c.para-- : 0);
            }),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            _counter("Living", c.living, () {
              setState(() => c.living++);
            }, () {
              setState(() => c.living > 0 ? c.living-- : 0);
            }),
            const SizedBox(width: 16),
            _counter("Abortions", c.abortions, () {
              setState(() => c.abortions++);
            }, () {
              setState(() => c.abortions > 0 ? c.abortions-- : 0);
            }),
          ],
        ),

        const SizedBox(height: 24),

        // --------------------- LMP + EDD -----------------------
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

        const Text("Estimated Delivery Date (EDD)",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            c.eddDate != null
                ? "${c.eddDate!.day}/${c.eddDate!.month}/${c.eddDate!.year}"
                : "Auto-calculated",
            style: const TextStyle(fontSize: 16),
          ),
        ),

        const SizedBox(height: 24),

        // ------------------- VITALS ------------------------
        _textField("BP (Systolic / Diastolic)", c.bp, "120/80"),
        const SizedBox(height: 16),
        _textField("Weight (kg)", c.weight, "Enter weight"),
        const SizedBox(height: 16),
        _textField("Hemoglobin (g/dL)", c.hemoglobin, "Enter Hb"),
        const SizedBox(height: 16),
        _textField("Blood Sugar (mg/dL)", c.bloodSugar, "Enter sugar"),

        const SizedBox(height: 24),

        // ------------------- SUPPLEMENTS ------------------------
        _textField("IFA Tablets Received", c.ifaTablets, "Number"),
        const SizedBox(height: 16),
        _textField("Calcium Tablets Received", c.calciumTablets, "Number"),

        const SizedBox(height: 24),

        // ------------------- VACCINATION ------------------------
        const Text("TT/TD Vaccination Dose",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          children: ["None", "TT-1", "TT-2", "Booster"].map((dose) {
            final selected = c.selectedVaccineDose == dose;
            return ChoiceChip(
              label: Text(dose),
              selected: selected,
              selectedColor: Colors.blue,
              onSelected: (_) {
                setState(() => c.selectedVaccineDose = dose);
              },
            );
          }).toList(),
        ),

        if (c.selectedVaccineDose != null &&
            c.selectedVaccineDose != "None") ...[
          const SizedBox(height: 12),
          _datePicker(
            label: "Date of Vaccination",
            selected: c.vaccinationDate,
            onPick: (d) => setState(() => c.vaccinationDate = d),
          ),
        ],

        const SizedBox(height: 24),

        // ------------------- SYMPTOMS ------------------------
        const Text("Current Symptoms",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            "Bleeding",
            "Severe Headache",
            "Swelling",
            "Blurred Vision",
            "Fever",
            "Convulsions"
          ].map((sym) {
            final selected = c.symptoms.contains(sym);
            return FilterChip(
              label: Text(sym),
              selected: selected,
              onSelected: (v) {
                setState(() {
                  v ? c.symptoms.add(sym) : c.symptoms.remove(sym);
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 24),
        _textField("Other Symptoms", c.otherSymptoms, "Describe…", maxLines: 3),

        const SizedBox(height: 24),

        // ------------------- PREGNANCY HISTORY ------------------------
        _toggle("Previous Cesarean", c.previousCesarean,
                (v) => setState(() => c.previousCesarean = v)),
        const Divider(),
        _toggle("Previous Stillbirth", c.previousStillbirth,
                (v) => setState(() => c.previousStillbirth = v)),
        const Divider(),
        _toggle("Previous Complications", c.previousComplications,
                (v) => setState(() => c.previousComplications = v)),

        const SizedBox(height: 24),

        // ------------------- CRITICAL CARD ------------------------
        _criticalCard(c.isCritical),
      ],
    );
  }

  // UI HELPERS BELOW ----------------------------------------

  Widget _counter(String label, int value, VoidCallback add, VoidCallback remove) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: remove, icon: const Icon(Icons.remove)),
                Text("$value",
                    style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(onPressed: add, icon: const Icon(Icons.add)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(String label, TextEditingController c, String hint,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: c,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selected ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now().add(const Duration(days: 300)),
            );
            onPick(date);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              selected == null
                  ? "Select date"
                  : "${selected.day}/${selected.month}/${selected.year}",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _toggle(String label, bool? value, Function(bool) onChange) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        ToggleButtons(
          isSelected: [value == true, value == false],
          onPressed: (i) => onChange(i == 0),
          borderRadius: BorderRadius.circular(8),
          children: const [
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Yes")),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("No")),
          ],
        )
      ],
    );
  }

  Widget _criticalCard(bool isCritical) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCritical ? Colors.red[100] : Colors.green[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(isCritical ? Icons.warning : Icons.check_circle,
              color: isCritical ? Colors.red : Colors.green, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isCritical
                  ? "Critical case! Immediate attention required."
                  : "Non-critical case.",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCritical ? Colors.red : Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}

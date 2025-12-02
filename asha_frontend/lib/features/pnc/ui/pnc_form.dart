import 'package:flutter/material.dart';
import 'package:asha_frontend/features/pnc/state/pnc_controller.dart';

class PncForm extends StatefulWidget {
  final PncController controller;
  const PncForm({super.key, required this.controller});

  @override
  State<PncForm> createState() => _PncFormState();
}

class _PncFormState extends State<PncForm> {
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // -----------------------------------------------------
        // MOTHER CHECKUP
        // -----------------------------------------------------
        const Padding(
          padding: EdgeInsets.only(top:16,bottom:16),
          child: Text("Post-Natal Survey: Mother Check",
              style: TextStyle(fontSize:20,fontWeight: FontWeight.bold,color: Color(0xFF2A5A9E))),
        ),

        _datePicker(
          label: "Date of checkup",
          selected: c.checkupDate,
          onPick: (d)=> setState(()=> c.checkupDate = d),
        ),

        const SizedBox(height: 24),
        const Text("Vital Signs", style: TextStyle(fontWeight:FontWeight.bold)),

        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _textField("Blood Pressure", c.bp, "e.g. 120/80")),
            const SizedBox(width: 16),
            Expanded(child: _textField("Pulse Rate", c.pulse, "e.g. 72")),
          ],
        ),

        const SizedBox(height: 24),
        const Text("Physical Assessment", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        _yesNo("Signs of excessive bleeding?", c.excessiveBleeding,
                (v)=> setState(()=> c.excessiveBleeding = v)),

        const SizedBox(height: 16),

        _yesNo("Breast health normal?", c.breastHealthNormal,
                (v)=> setState(()=> c.breastHealthNormal = v)),


        const SizedBox(height: 24),
        const Text("How is the mother feeling?",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _feelingCard("Happy", Icons.sentiment_very_satisfied),
            _feelingCard("Neutral", Icons.sentiment_neutral),
            _feelingCard("Sad", Icons.sentiment_very_dissatisfied),
          ],
        ),

        const Divider(height:40),


        // -----------------------------------------------------
        // BABY CHECK
        // -----------------------------------------------------
        const Text("Post-Natal Survey: Baby Check",
            style: TextStyle(fontSize:20,fontWeight: FontWeight.bold,color: Color(0xFF2A5A9E))),
        const SizedBox(height:12),

        _textField("Baby Weight (kg)", c.babyWeight, "kg", type: TextInputType.number),
        const SizedBox(height:16),
        _textField("Temperature (°C)", c.babyTemp, "°C", type: TextInputType.number),

        const SizedBox(height:24),

        const Text("General Condition", style: TextStyle(fontWeight:FontWeight.bold)),
        const SizedBox(height:12),

        _toggle2("Is baby active?", "Active", "Lethargic",
            c.babyActivity, (v)=> setState(()=> c.babyActivity = v)),

        const SizedBox(height:12),

        _toggle2("Breathing status", "Normal", "Fast",
            c.babyBreathing, (v)=> setState(()=> c.babyBreathing = v)),

        const SizedBox(height:12),

        _toggle2("Skin color", "Normal", "Jaundiced",
            c.babySkinColor, (v)=> setState(()=> c.babySkinColor = v)),


        const SizedBox(height:24),
        const Text("Feeding Assessment", style: TextStyle(fontWeight:FontWeight.bold)),
        const SizedBox(height:12),

        _toggleBool("Breastfeeding?", c.breastfeeding,
                (v)=> setState(()=> c.breastfeeding = v)),

        const SizedBox(height:12),

        _toggleBool("Good attachment?", c.goodAttachment,
                (v)=> setState(()=> c.goodAttachment = v)),

        const Divider(height:40),


        // -----------------------------------------------------
        // DANGER SIGNS
        // -----------------------------------------------------
        const Text("Mother's Danger Signs", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        ..._dangerSignsMother(c),

        const SizedBox(height: 24),
        const Text("Baby's Danger Signs", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        ..._dangerSignsBaby(c),

        const SizedBox(height: 24),
        _textField("Notes (Optional)", c.notes, "Add notes...", maxLines: 4),

        const Divider(height:40),

        // -----------------------------------------------------
        // FOLLOW UP
        // -----------------------------------------------------
        const Text("Follow-up Details",
            style: TextStyle(fontWeight: FontWeight.bold,fontSize:18)),
        const SizedBox(height:12),

        _datePicker(
          label: "Follow up date",
          selected: c.followUpDate,
          onPick: (d)=> setState(()=> c.followUpDate = d),
        ),
        const SizedBox(height:16),

        _timePicker("Follow-up time", c.followUpTime,
                (t)=> setState(()=> c.followUpTime = t)),

        const SizedBox(height: 24),

        _yesNo("Any complications observed?",
            c.complicationsObserved,
                (v)=> setState(()=> c.complicationsObserved = v)),

        const SizedBox(height: 16),

        _textField("Follow-up BP", c.followUpBp, "e.g. 120/80"),

        const SizedBox(height: 24),
        const Text("Newborn’s Health", style: TextStyle(fontWeight:FontWeight.bold)),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Immunizations up to date?"),
            Switch(
              value: c.immunizationsUpToDate,
              onChanged: (v)=> setState(()=> c.immunizationsUpToDate = v),
            )
          ],
        ),

        _textField("Weight (kg)", c.newbornWeight, "3.1", type: TextInputType.number),

        const SizedBox(height:20),

        _criticalCard(c.isCritical),
      ],
    );
  }

  // -------------------------------------------------------------------
  // UI HELPERS
  // -------------------------------------------------------------------

  Widget _textField(String label, TextEditingController c, String hint,
      {int maxLines = 1, TextInputType? type}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: c,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              )
          ),
        )
      ],
    );
  }

  Widget _datePicker({required String label, required DateTime? selected, required Function(DateTime?) onPick}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: selected ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            onPick(d);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12)
            ),
            child: Text(
              selected == null
                  ? "Select date"
                  : "${selected.day}/${selected.month}/${selected.year}",
            ),
          ),
        )
      ],
    );
  }

  Widget _timePicker(String label, TimeOfDay? selected, Function(TimeOfDay?) onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final t = await showTimePicker(
              context: context,
              initialTime: selected ?? TimeOfDay.now(),
            );
            onPick(t);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12)
            ),
            child: Text(
              selected == null ? "Select time" : selected.format(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _yesNo(String label, bool? val, Function(bool) onSelect) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label)),
        ToggleButtons(
          isSelected: [val == true, val == false],
          onPressed: (i)=> onSelect(i==0),
          borderRadius: BorderRadius.circular(8),
          children: const [
            Padding(padding: EdgeInsets.symmetric(horizontal:16),child:Text("Yes")),
            Padding(padding: EdgeInsets.symmetric(horizontal:16),child:Text("No")),
          ],
        ),
      ],
    );
  }

  Widget _toggle2(String label, String a, String b, String? value, Function(String) onSelect){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _toggleCard(a, value == a, ()=> onSelect(a))),
            const SizedBox(width: 12),
            Expanded(child: _toggleCard(b, value == b, ()=> onSelect(b))),
          ],
        )
      ],
    );
  }

  Widget _toggleBool(String label, bool? value, Function(bool) onSelect) {
    return _toggle2(label, "Yes", "No",
        value == true ? "Yes" : value == false ? "No" : null,
            (v)=> onSelect(v=="Yes"));
  }

  Widget _toggleCard(String text, bool selected, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? Colors.blue : Colors.grey),
          borderRadius: BorderRadius.circular(12),
          color: selected ? Colors.blue.shade50 : Colors.white,
        ),
        child: Center(child: Text(text, style: TextStyle(
            color: selected ? Colors.blue : Colors.black,
            fontWeight: FontWeight.bold
        ))),
      ),
    );
  }

  Widget _feelingCard(String feeling, IconData icon) {
    final c = widget.controller;
    final selected = c.motherFeeling == feeling;

    return GestureDetector(
      onTap: ()=> setState(()=> c.motherFeeling = feeling),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            border: Border.all(color: selected ? Colors.blue : Colors.grey),
            borderRadius: BorderRadius.circular(12),
            color: selected ? Colors.blue.shade50 : Colors.white),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.blue : Colors.grey, size: 30),
            Text(feeling)
          ],
        ),
      ),
    );
  }

  List<Widget> _dangerSignsMother(PncController c) {
    final List<List<dynamic>> items = [
      ["Fever", Icons.thermostat],
      ["Severe Bleeding", Icons.opacity],
      ["Foul-smelling Discharge", Icons.medical_services_outlined],
      ["Severe Headache", Icons.sentiment_dissatisfied],
      ["Convulsions", Icons.flash_on],
    ];

    return items.map((i) {
      final title = i[0] as String;
      final icon = i[1] as IconData;

      return CheckboxListTile(
        title: Text(title),
        secondary: Icon(icon),
        value: c.motherDangerSigns.contains(title),
        onChanged: (v) {
          setState(() {
            if (v!) {
              c.motherDangerSigns.add(title);
            } else {
              c.motherDangerSigns.remove(title);
            }
          });
        },
      );
    }).toList();
  }

  List<Widget> _dangerSignsBaby(PncController c) {
    final List<List<dynamic>> items = [
      ["Difficulty Breathing", Icons.air],
      ["High/Low Temperature", Icons.thermostat_auto],
      ["Not Feeding Well", Icons.no_food],
      ["Yellow Skin/Eyes", Icons.face],
    ];

    return items.map((i) {
      final title = i[0] as String;
      final icon = i[1] as IconData;

      return CheckboxListTile(
        title: Text(title),
        secondary: Icon(icon),
        value: c.babyDangerSigns.contains(title),
        onChanged: (v) {
          setState(() {
            if (v!) {
              c.babyDangerSigns.add(title);
            } else {
              c.babyDangerSigns.remove(title);
            }
          });
        },
      );
    }).toList();
  }


  Widget _criticalCard(bool isCritical){
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCritical ? Colors.red[100] : Colors.green[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(isCritical ? Icons.warning : Icons.check_circle,
              size: 30,
              color: isCritical ? Colors.red : Colors.green),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isCritical
                  ? "Critical case! Immediate attention required."
                  : "Non-critical case.",
              style: TextStyle(
                  color: isCritical ? Colors.red : Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
              ),
            ),
          )
        ],
      ),
    );
  }
}

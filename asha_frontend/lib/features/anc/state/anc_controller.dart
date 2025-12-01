import 'package:flutter/material.dart';

class AncController {
  // parity
  int gravida = 0;
  int para = 0;
  int living = 0;
  int abortions = 0;

  // ---------- LMP & EDD ----------
  DateTime? lmpDate;
  DateTime? eddDate;

  // ---------- Vitals ----------
  final bp = TextEditingController();              // 120/80 format
  final weight = TextEditingController();          // kg
  final hemoglobin = TextEditingController();      // g/dL
  final bloodSugar = TextEditingController();      // mg/dL

  // ---------- Supplements ----------
  final ifaTablets = TextEditingController();
  final calciumTablets = TextEditingController();

  // ---------- Vaccination ----------
  String? selectedVaccineDose;       // TT1 / TT2 / Booster / None
  DateTime? vaccinationDate;

  // ---------- Symptoms ----------
  Set<String> symptoms = {};    // eg: “Bleeding”, “Convulsions”, “Fever”
  final otherSymptoms = TextEditingController();

  // ---------- Pregnancy History ----------
  bool? previousCesarean;       // Yes/No
  bool? previousStillbirth;     // Yes/No
  bool? previousComplications;  // Yes/No

  // ---------- Cleanup ----------
  void dispose() {
    bp.dispose();
    weight.dispose();
    hemoglobin.dispose();
    bloodSugar.dispose();
    ifaTablets.dispose();
    calciumTablets.dispose();
    otherSymptoms.dispose();
  }

  void updateEdd() {
    if (lmpDate != null) {
      eddDate = lmpDate!.add(const Duration(days: 280));
    }
  }
  bool get isCritical {
    // BP check
    if (bp.text.contains("/")) {
      final parts = bp.text.split("/");
      final s = int.tryParse(parts[0]);
      final d = int.tryParse(parts[1]);
      if ((s ?? 0) >= 140 || (d ?? 0) >= 90) return true;
    }

    // Critical symptoms
    if (symptoms.contains("Bleeding")) return true;
    if (symptoms.contains("Convulsions")) return true;
    if (symptoms.contains("Blurred Vision")) return true;
    if (symptoms.contains("Severe Headache")) return true;

    // History based criticality
    if (previousStillbirth == true) return true;
    if (previousComplications == true) return true;

    return false;
  }

}

import 'package:flutter/material.dart';

class AncController {
  // ---------- Parity ----------
  int gravida = 0;
  int para = 0;
  int living = 0;
  int abortions = 0;

  // ---------- LMP & EDD ----------
  DateTime? lmpDate;
  DateTime? eddDate;

  // ---------- Vitals ----------
  final bp = TextEditingController();
  final weight = TextEditingController();
  final hemoglobin = TextEditingController();
  final bloodSugar = TextEditingController();

  // ---------- Supplements ----------
  final ifaTablets = TextEditingController();
  final calciumTablets = TextEditingController();

  // ---------- Vaccination ----------
  String? selectedVaccineDose;
  DateTime? vaccinationDate;

  // ---------- Symptoms ----------
  Set<String> symptoms = {};
  final otherSymptoms = TextEditingController();

  // ---------- Pregnancy History ----------
  bool? previousCesarean;
  bool? previousStillbirth;
  bool? previousComplications;

  // ---------- Clean up ----------
  void dispose() {
    bp.dispose();
    weight.dispose();
    hemoglobin.dispose();
    bloodSugar.dispose();
    ifaTablets.dispose();
    calciumTablets.dispose();
    otherSymptoms.dispose();
  }

  // ---------- Auto update ----------
  void updateEdd() {
    if (lmpDate != null) {
      eddDate = lmpDate!.add(const Duration(days: 280));
    }
  }

  // ---------- Check danger ----------
  bool get isCritical {
    if (bp.text.contains("/")) {
      final parts = bp.text.split("/");
      final s = int.tryParse(parts[0]);
      final d = int.tryParse(parts[1]);
      if ((s ?? 0) >= 140 || (d ?? 0) >= 90) return true;
    }

    if (symptoms.contains("Bleeding")) return true;
    if (symptoms.contains("Convulsions")) return true;
    if (symptoms.contains("Blurred Vision")) return true;
    if (symptoms.contains("Severe Headache")) return true;

    if (previousStillbirth == true) return true;
    if (previousComplications == true) return true;

    return false;
  }

  // ================================================================
  // 🔥 PART 1 — Convert ANC form to JSON (Save Member)
  // ================================================================
  Map<String, dynamic> toMap() {
    return {
      // parity
      "gravida": gravida,
      "para": para,
      "living": living,
      "abortions": abortions,

      // dates
      "lmpDate": lmpDate?.toIso8601String(),
      "eddDate": eddDate?.toIso8601String(),

      // vitals
      "bp": bp.text,
      "weight": weight.text,
      "hemoglobin": hemoglobin.text,
      "bloodSugar": bloodSugar.text,

      // supplements
      "ifaTablets": ifaTablets.text,
      "calciumTablets": calciumTablets.text,

      // vaccination
      "selectedVaccineDose": selectedVaccineDose,
      "vaccinationDate": vaccinationDate?.toIso8601String(),

      // symptoms
      "symptoms": symptoms.toList(),
      "otherSymptoms": otherSymptoms.text,

      // history
      "previousCesarean": previousCesarean,
      "previousStillbirth": previousStillbirth,
      "previousComplications": previousComplications,
    };
  }

  // ================================================================
  // 🔥 PART 2 — Load JSON into ANC form (Edit Member)
  // ================================================================
  void loadFromMap(Map<String, dynamic>? data) {
    if (data == null) return;

    // parity
    gravida = data["gravida"] ?? 0;
    para = data["para"] ?? 0;
    living = data["living"] ?? 0;
    abortions = data["abortions"] ?? 0;

    // dates
    lmpDate = data["lmpDate"] != null ? DateTime.tryParse(data["lmpDate"]) : null;
    eddDate = data["eddDate"] != null ? DateTime.tryParse(data["eddDate"]) : null;

    // vitals
    bp.text = data["bp"] ?? "";
    weight.text = data["weight"] ?? "";
    hemoglobin.text = data["hemoglobin"] ?? "";
    bloodSugar.text = data["bloodSugar"] ?? "";

    // supplements
    ifaTablets.text = data["ifaTablets"] ?? "";
    calciumTablets.text = data["calciumTablets"] ?? "";

    // vaccination
    selectedVaccineDose = data["selectedVaccineDose"];
    vaccinationDate = data["vaccinationDate"] != null
        ? DateTime.tryParse(data["vaccinationDate"])
        : null;

    // symptoms
    symptoms = (data["symptoms"] != null)
        ? Set<String>.from(data["symptoms"])
        : {};

    otherSymptoms.text = data["otherSymptoms"] ?? "";

    // history
    previousCesarean = data["previousCesarean"];
    previousStillbirth = data["previousStillbirth"];
    previousComplications = data["previousComplications"];
  }
}

import 'package:flutter/material.dart';

class AncController {
  // ---------- Required by ML Engine ----------
  int age = 25;          // MUST HAVE
  String gender = "Female"; // MUST HAVE

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
  bool previousCesarean = false;
  bool previousStillbirth = false;
  bool previousComplications = false;

  // ---------- Dispose ----------
  void dispose() {
    bp.dispose();
    weight.dispose();
    hemoglobin.dispose();
    bloodSugar.dispose();
    ifaTablets.dispose();
    calciumTablets.dispose();
    otherSymptoms.dispose();
  }

  // ---------- Auto-update ----------
  void updateEdd() {
    if (lmpDate != null) {
      eddDate = lmpDate!.add(const Duration(days: 280));
    }
  }

  // ---------- Danger Check ----------
  bool get isCritical {
    if (bp.text.contains("/")) {
      final parts = bp.text.split("/");
      final s = int.tryParse(parts[0]) ?? 0;
      final d = int.tryParse(parts[1]) ?? 0;
      if (s >= 140 || d >= 90) return true;
    }

    if (symptoms.contains("Bleeding")) return true;
    if (symptoms.contains("Convulsions")) return true;
    if (symptoms.contains("Blurred Vision")) return true;
    if (symptoms.contains("Severe Headache")) return true;

    if (previousStillbirth) return true;
    if (previousComplications) return true;

    return false;
  }

  // ================================================================
  // Save ANC Form → Map
  // ================================================================
  Map<String, dynamic> toMap() {
    return {
      "age": age,
      "gender": gender,

      "gravida": gravida,
      "para": para,
      "living": living,
      "abortions": abortions,

      "lmpDate": lmpDate?.toIso8601String(),
      "eddDate": eddDate?.toIso8601String(),

      "bp": bp.text,
      "weight": weight.text,
      "hemoglobin": hemoglobin.text,
      "bloodSugar": bloodSugar.text,

      "ifaTablets": ifaTablets.text,
      "calciumTablets": calciumTablets.text,

      "selectedVaccineDose": selectedVaccineDose,
      "vaccinationDate": vaccinationDate?.toIso8601String(),

      "symptoms": symptoms.toList(),
      "otherSymptoms": otherSymptoms.text,

      "previousCesarean": previousCesarean,
      "previousStillbirth": previousStillbirth,
      "previousComplications": previousComplications,
    };
  }

  // ================================================================
  // Load Map → ANC Form
  // ================================================================
  void loadFromMap(Map<String, dynamic>? data) {
    if (data == null) return;

    age = data["age"] ?? 25;
    gender = data["gender"] ?? "Female";

    gravida = data["gravida"] ?? 0;
    para = data["para"] ?? 0;
    living = data["living"] ?? 0;
    abortions = data["abortions"] ?? 0;

    lmpDate = data["lmpDate"] != null ? DateTime.parse(data["lmpDate"]) : null;
    eddDate = data["eddDate"] != null ? DateTime.parse(data["eddDate"]) : null;

    bp.text = data["bp"] ?? "";
    weight.text = data["weight"] ?? "";
    hemoglobin.text = data["hemoglobin"] ?? "";
    bloodSugar.text = data["bloodSugar"] ?? "";

    ifaTablets.text = data["ifaTablets"] ?? "";
    calciumTablets.text = data["calciumTablets"] ?? "";

    selectedVaccineDose = data["selectedVaccineDose"];
    vaccinationDate = data["vaccinationDate"] != null
        ? DateTime.tryParse(data["vaccinationDate"])
        : null;

    symptoms = data["symptoms"] != null
        ? Set<String>.from(data["symptoms"])
        : {};

    otherSymptoms.text = data["otherSymptoms"] ?? "";

    previousCesarean = data["previousCesarean"] ?? false;
    previousStillbirth = data["previousStillbirth"] ?? false;
    previousComplications = data["previousComplications"] ?? false;
  }
}

import 'package:flutter/material.dart';

class TbController {
  // ---------------- Cough ----------------
  bool? hasCough;
  final coughDuration = TextEditingController();
  String coughDurationUnit = "Days";   // Days / Weeks
  Set<String> coughTypes = {};         // Dry, Phlegm, With Blood

  // ---------------- Fever ----------------
  bool? hasFever;
  final feverDuration = TextEditingController();
  String feverDurationUnit = "Days";   // Days / Weeks / Months
  String feverPattern = "";            // Continuous / Intermittent / Remittent

  // ---------------- Weight Loss ----------------
  bool? hasWeightLoss;
  final weightLossAmount = TextEditingController();
  String weightLossPeriod = "Last 2 weeks";

  // ---------------- Chest Pain ----------------
  bool? hasChestPain;

  // ---------------- TB Exposure ----------------
  bool? hasTbPatientAtHome;
  bool? hadTbInPast;

  // ---------------- Dispose ----------------
  void dispose() {
    coughDuration.dispose();
    feverDuration.dispose();
    weightLossAmount.dispose();
  }

  // ---------------- Critical ----------------
  bool get isCritical {
    if (coughTypes.contains("With Blood")) return true;

    if (feverDuration.text.isNotEmpty &&
        int.tryParse(feverDuration.text) != null) {
      final d = int.parse(feverDuration.text);
      if (feverDurationUnit == "Days" && d > 14) return true;
    }

    if (hasChestPain == true) return true;
    return false;
  }

  // ============================================================
  // 🔥 Convert TB form → Map (Save Member)
  // ============================================================
  Map<String, dynamic> toMap() {
    return {
      // cough
      "hasCough": hasCough,
      "coughDuration": coughDuration.text,
      "coughDurationUnit": coughDurationUnit,
      "coughTypes": coughTypes.toList(),

      // fever
      "hasFever": hasFever,
      "feverDuration": feverDuration.text,
      "feverDurationUnit": feverDurationUnit,
      "feverPattern": feverPattern,

      // weight loss
      "hasWeightLoss": hasWeightLoss,
      "weightLossAmount": weightLossAmount.text,
      "weightLossPeriod": weightLossPeriod,

      // chest pain
      "hasChestPain": hasChestPain,

      // tb exposure
      "hasTbPatientAtHome": hasTbPatientAtHome,
      "hadTbInPast": hadTbInPast,
    };
  }

  // ============================================================
  // 🔥 Load Map → TB Form (Edit Member)
  // ============================================================
  void loadFromMap(Map<String, dynamic>? data) {
    if (data == null) return;

    // cough
    hasCough = data["hasCough"];
    coughDuration.text = data["coughDuration"] ?? "";
    coughDurationUnit = data["coughDurationUnit"] ?? "Days";

    coughTypes
      ..clear()
      ..addAll(List<String>.from(data["coughTypes"] ?? []));

    // fever
    hasFever = data["hasFever"];
    feverDuration.text = data["feverDuration"] ?? "";
    feverDurationUnit = data["feverDurationUnit"] ?? "Days";
    feverPattern = data["feverPattern"] ?? "";

    // weight loss
    hasWeightLoss = data["hasWeightLoss"];
    weightLossAmount.text = data["weightLossAmount"] ?? "";
    weightLossPeriod = data["weightLossPeriod"] ?? "Last 2 weeks";

    // chest pain
    hasChestPain = data["hasChestPain"];

    // exposure
    hasTbPatientAtHome = data["hasTbPatientAtHome"];
    hadTbInPast = data["hadTbInPast"];
  }
}

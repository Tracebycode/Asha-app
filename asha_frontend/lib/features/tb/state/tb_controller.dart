import 'package:flutter/material.dart';
import '../../../core/ml/tb_risk_engine.dart';

class TbController {
  // ---------------- Cough ----------------
  bool? hasCough;
  final coughDuration = TextEditingController();
  String coughDurationUnit = "Days"; // Days / Weeks
  Set<String> coughTypes = {}; // "Dry", "With Phlegm", "With Blood"

  // ---------------- Fever ----------------
  bool? hasFever;
  final feverDuration = TextEditingController();
  String feverDurationUnit = "Days"; // Days / Weeks / Months
  String feverPattern = ""; // "Continuous" / "Intermittent" / "Remittent"

  // ---------------- Weight Loss ----------------
  bool? hasWeightLoss;
  final weightLossAmount = TextEditingController();
  String weightLossPeriod = "Last 2 weeks"; // "Last 2 weeks" / "Last month" / "Last 3 months"

  // ---------------- Chest Pain ----------------
  bool? hasChestPain;

  // ---------------- TB Exposure ----------------
  bool? hasTbPatientAtHome;
  bool? hadTbInPast;

  // ---------------- TB Risk Output (from ML engine) ----------------
  double? tbRiskScore; // 0–1
  String? tbRiskLevelKey; // "risk_low" / "risk_moderate" / "risk_high"
  List<String> tbProblems = [];
  List<String> tbSuggestions = [];

  // ---------------- Dispose ----------------
  void dispose() {
    coughDuration.dispose();
    feverDuration.dispose();
    weightLossAmount.dispose();
  }

  bool get isCritical {
    // Prefer ML+rule hybrid output if we have it
    if (tbRiskLevelKey == "risk_high") return true;

    // Fallback to your original rule-based criticality
    if (coughTypes.contains("With Blood")) return true;

    if (feverDuration.text.isNotEmpty &&
        int.tryParse(feverDuration.text) != null) {
      final d = int.parse(feverDuration.text);
      if (feverDurationUnit == "Days" && d > 14) return true;
    }

    if (hasChestPain == true) return true;
    return false;
  }

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

  int _safeParseInt(String text) {
    final v = int.tryParse(text.trim());
    return v ?? 0;
  }

  double _safeParseDouble(String text) {
    final v = double.tryParse(text.trim());
    return v ?? 0.0;
  }

  // Convert duration to days based on unit
  int _durationToDays(String text, String unit) {
    final value = _safeParseInt(text);
    if (value <= 0) return 0;
    switch (unit) {
      case "Weeks":
        return value * 7;
      case "Months":
        return value * 30;
      case "Days":
      default:
        return value;
    }
  }

  TbPrediction? calculateRisk() {
    // If key symptom group is completely empty, avoid nonsense prediction
    if (hasCough == null &&
        hasFever == null &&
        hasWeightLoss == null &&
        hasChestPain == null &&
        hasTbPatientAtHome == null &&
        hadTbInPast == null) {
      return null;
    }

    final coughDurationDays =
    _durationToDays(coughDuration.text, coughDurationUnit);
    final feverDurationDays =
    _durationToDays(feverDuration.text, feverDurationUnit);
    final weightKg = _safeParseDouble(weightLossAmount.text);

    final prediction = calculateTbRisk(
      hasCough: hasCough == true,
      coughDurationDays: coughDurationDays.toDouble(),
      coughDry: coughTypes.contains("Dry"),
      coughWithPhlegm: coughTypes.contains("With Phlegm"),
      coughWithBlood: coughTypes.contains("With Blood"),
      hasFever: hasFever == true,
      feverDurationDays: feverDurationDays.toDouble(),
      feverPattern: feverPattern.isEmpty ? null : feverPattern,
      hasWeightLoss: hasWeightLoss == true,
      weightLossKg: weightKg,
      weightLossPeriod:
      weightLossPeriod.isEmpty ? null : weightLossPeriod,
      hasChestPain: hasChestPain == true,
      hasTbPatientAtHome: hasTbPatientAtHome == true,
      hadTbInPast: hadTbInPast == true,
    );

    tbRiskScore = prediction.riskScore;
    tbRiskLevelKey = prediction.riskLevelKey;
    tbProblems = prediction.problems;
    tbSuggestions = prediction.suggestions;

    return prediction;
  }
}

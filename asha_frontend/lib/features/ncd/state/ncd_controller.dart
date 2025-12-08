import 'package:flutter/material.dart';
import '../../../core/ml/ncd_risk_engine.dart';

class NcdController {
  // ---- BP ----
  final systolic = TextEditingController();
  final diastolic = TextEditingController();

  // ---- BMI ----
  final weight = TextEditingController();
  final height = TextEditingController();

  // ---- Blood Sugar ----
  final randomBloodSugar = TextEditingController();

  // ---- Lifestyle ----
  bool usesTobacco = false;
  bool consumesAlcohol = false;

  // "None" / "A little" / "A lot"
  String? extraSaltIntake;

  // "Daily" / "Few times a week" / "Rarely" / "Never"
  String? exerciseFrequency;

  // ---- NCD Risk Output (from ML engine) ----
  double? ncdRiskScore;       // 0–1
  String? ncdRiskLevelKey;    // "risk_low" / "risk_moderate" / "risk_high"
  List<String> ncdProblems = [];
  List<String> ncdSuggestions = [];

  // ---- Dispose ----
  void dispose() {
    systolic.dispose();
    diastolic.dispose();
    weight.dispose();
    height.dispose();
    randomBloodSugar.dispose();
  }

  // ---- Critical case logic (hybrid) ----
  bool get isCritical {
    // Prefer ML-based label if available
    if (ncdRiskLevelKey == "risk_high") return true;

    // Fallback to original hard thresholds
    final sys = int.tryParse(systolic.text);
    if (sys != null && sys > 160) return true;

    final rbs = int.tryParse(randomBloodSugar.text);
    if (rbs != null && rbs > 250) return true;

    return false;
  }

  Map<String, dynamic> toMap() {
    return {
      // BP
      "systolic": systolic.text,
      "diastolic": diastolic.text,

      // BMI
      "weight": weight.text,
      "height": height.text,

      // Sugar
      "randomBloodSugar": randomBloodSugar.text,

      // Lifestyle
      "usesTobacco": usesTobacco,
      "consumesAlcohol": consumesAlcohol,
      "extraSaltIntake": extraSaltIntake,
      "exerciseFrequency": exerciseFrequency,
    };
  }

  void loadFromMap(Map<String, dynamic>? data) {
    if (data == null) return;

    systolic.text = data["systolic"] ?? "";
    diastolic.text = data["diastolic"] ?? "";

    weight.text = data["weight"] ?? "";
    height.text = data["height"] ?? "";

    randomBloodSugar.text = data["randomBloodSugar"] ?? "";

    usesTobacco = data["usesTobacco"] ?? false;
    consumesAlcohol = data["consumesAlcohol"] ?? false;

    extraSaltIntake = data["extraSaltIntake"];
    exerciseFrequency = data["exerciseFrequency"];
  }

  double _safeParseDouble(String text) {
    final v = double.tryParse(text.trim());
    return v ?? 0.0;
  }

  NcdPrediction? calculateRisk() {
    // If form is totally empty, avoid nonsense prediction
    if (systolic.text.trim().isEmpty &&
        diastolic.text.trim().isEmpty &&
        weight.text.trim().isEmpty &&
        height.text.trim().isEmpty &&
        randomBloodSugar.text.trim().isEmpty) {
      return null;
    }

    final double sys = _safeParseDouble(systolic.text);
    final double dia = _safeParseDouble(diastolic.text);
    final double wt = _safeParseDouble(weight.text);
    final double ht = _safeParseDouble(height.text);
    final double rbs = _safeParseDouble(randomBloodSugar.text);

    final String salt = extraSaltIntake ?? "None";
    final String exercise = exerciseFrequency ?? "Daily";

    final prediction = calculateNcdRisk(
      systolicMmHg: sys,
      diastolicMmHg: dia,
      weightKg: wt,
      heightCm: ht,
      randomBloodSugarMgDl: rbs,
      usesTobacco: usesTobacco,
      consumesAlcohol: consumesAlcohol,
      extraSaltIntake: salt,
      exerciseFrequency: exercise,
    );

    ncdRiskScore = prediction.riskScore;
    ncdRiskLevelKey = prediction.riskLevelKey;
    ncdProblems = prediction.problems;
    ncdSuggestions = prediction.suggestions;

    return prediction;
  }
}

import 'package:flutter/material.dart';

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

  String? extraSaltIntake;
  String? exerciseFrequency;

  // ---- Dispose ----
  void dispose() {
    systolic.dispose();
    diastolic.dispose();
    weight.dispose();
    height.dispose();
    randomBloodSugar.dispose();
  }

  // ---- Critical case logic ----
  bool get isCritical {
    if (int.tryParse(systolic.text) != null &&
        int.tryParse(systolic.text)! > 160) return true;

    if (int.tryParse(randomBloodSugar.text) != null &&
        int.tryParse(randomBloodSugar.text)! > 250) return true;

    return false;
  }

  // ================================================================
  // 🔥 PART 1 — Convert NCD form to JSON (Save Member)
  // ================================================================
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

  // ================================================================
  // 🔥 PART 2 — Load JSON back to controller (Edit Member)
  // ================================================================
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
}

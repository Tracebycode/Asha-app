import 'package:flutter/material.dart';

class GeneralSurveyController {
  // ---------------- Household Condition ----------------
  bool houseClean = false;
  bool drinkingWaterSafe = false;
  bool toiletAvailable = false;
  bool wasteDisposalProper = false;

  // ---------------- Members Present ----------------
  bool pregnantWomanPresent = false;
  bool newbornPresent = false;
  bool elderlyPresent = false;

  // ---------------- Symptoms ----------------
  final List<String> symptoms = [];
  final List<String> symptomsList = const [
    "Fever",
    "Cough",
    "Cold",
    "Weakness",
    "Pain in body",
    "Breathlessness",
    "Skin rash"
  ];

  // ---------------- Vitals ----------------
  final tempController = TextEditingController();
  final weightController = TextEditingController();
  final bpController = TextEditingController();

  // ---------------- Notes ----------------
  final notesController = TextEditingController();

  // ---------------- Dispose ----------------
  void dispose() {
    tempController.dispose();
    weightController.dispose();
    bpController.dispose();
    notesController.dispose();
  }

  // ---------------- Critical Logic ----------------
  bool get isCritical {
    final temp = double.tryParse(tempController.text);
    final bp = bpController.text;

    if (temp != null && temp > 103) return true;

    if (bp.contains("/")) {
      final parts = bp.split("/");
      final sys = int.tryParse(parts[0]);
      if (sys != null && sys > 160) return true;
    }

    return false;
  }

  // ============================================================
  // 🔥 Convert → Map (for saving)
  // ============================================================
  Map<String, dynamic> toMap() {
    return {
      // household
      "houseClean": houseClean,
      "drinkingWaterSafe": drinkingWaterSafe,
      "toiletAvailable": toiletAvailable,
      "wasteDisposalProper": wasteDisposalProper,

      // members present
      "pregnantWomanPresent": pregnantWomanPresent,
      "newbornPresent": newbornPresent,
      "elderlyPresent": elderlyPresent,

      // symptoms
      "symptoms": symptoms,

      // vitals
      "temperature": tempController.text,
      "weight": weightController.text,
      "bp": bpController.text,

      // notes
      "notes": notesController.text,
    };
  }

  // ============================================================
  // 🔥 Load → Controller (edit mode)
  // ============================================================
  void loadFromMap(Map<String, dynamic>? data) {
    if (data == null) return;

    // household
    houseClean = data["houseClean"] ?? false;
    drinkingWaterSafe = data["drinkingWaterSafe"] ?? false;
    toiletAvailable = data["toiletAvailable"] ?? false;
    wasteDisposalProper = data["wasteDisposalProper"] ?? false;

    // members present
    pregnantWomanPresent = data["pregnantWomanPresent"] ?? false;
    newbornPresent = data["newbornPresent"] ?? false;
    elderlyPresent = data["elderlyPresent"] ?? false;

    // symptoms
    symptoms
      ..clear()
      ..addAll(List<String>.from(data["symptoms"] ?? []));

    // vitals
    tempController.text = data["temperature"] ?? "";
    weightController.text = data["weight"] ?? "";
    bpController.text = data["bp"] ?? "";

    // notes
    notesController.text = data["notes"] ?? "";
  }
}

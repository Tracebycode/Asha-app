import 'package:flutter/material.dart';

class PncController {
  // ------------------- Mother Checkup -------------------
  DateTime? checkupDate;
  final bp = TextEditingController();
  final pulse = TextEditingController();
  bool? excessiveBleeding;
  bool? breastHealthNormal;
  String? motherFeeling;

  // Danger signs (mother)
  final Set<String> motherDangerSigns = {};

  // ------------------- Baby Section -------------------
  final babyWeight = TextEditingController();
  final babyTemp = TextEditingController();
  String? babyActivity;       // Active | Lethargic
  String? babyBreathing;      // Normal | Fast
  String? babySkinColor;      // Normal | Jaundiced
  bool? breastfeeding;
  bool? goodAttachment;

  // Danger signs (baby)
  final Set<String> babyDangerSigns = {};

  // ------------------- Notes -------------------
  final notes = TextEditingController();

  // ------------------- Follow-up -------------------
  DateTime? followUpDate;
  TimeOfDay? followUpTime;
  bool? complicationsObserved;
  final followUpBp = TextEditingController();

  // ------------------- Newborn Immunization -------------------
  bool immunizationsUpToDate = true;
  final newbornWeight = TextEditingController();

  // ------------------- Critical -------------------
  bool get isCritical {
    return motherDangerSigns.isNotEmpty || babyDangerSigns.isNotEmpty;
  }

  // ------------------- Dispose -------------------
  void dispose() {
    bp.dispose();
    pulse.dispose();
    babyWeight.dispose();
    babyTemp.dispose();
    notes.dispose();
    followUpBp.dispose();
    newbornWeight.dispose();
  }

  // ============================================================
  // 🔥 Convert PNC Form to Map (Save Member)
  // ============================================================
  Map<String, dynamic> toMap() {
    return {
      // mother checkup
      "checkupDate": checkupDate?.toIso8601String(),
      "bp": bp.text,
      "pulse": pulse.text,
      "excessiveBleeding": excessiveBleeding,
      "breastHealthNormal": breastHealthNormal,
      "motherFeeling": motherFeeling,

      // mother danger signs
      "motherDangerSigns": motherDangerSigns.toList(),

      // baby section
      "babyWeight": babyWeight.text,
      "babyTemp": babyTemp.text,
      "babyActivity": babyActivity,
      "babyBreathing": babyBreathing,
      "babySkinColor": babySkinColor,
      "breastfeeding": breastfeeding,
      "goodAttachment": goodAttachment,

      // baby danger signs
      "babyDangerSigns": babyDangerSigns.toList(),

      // notes
      "notes": notes.text,

      // follow-up
      "followUpDate": followUpDate?.toIso8601String(),
      "followUpTime": followUpTime == null
          ? null
          : "${followUpTime!.hour}:${followUpTime!.minute}",
      "complicationsObserved": complicationsObserved,
      "followUpBp": followUpBp.text,

      // immunization
      "immunizationsUpToDate": immunizationsUpToDate,
      "newbornWeight": newbornWeight.text,
    };
  }

  // ============================================================
  // 🔥 Load Map back into PNC form (Edit Member)
  // ============================================================
  void loadFromMap(Map<String, dynamic>? data) {
    if (data == null) return;

    // mother checkup
    checkupDate = data["checkupDate"] != null
        ? DateTime.tryParse(data["checkupDate"])
        : null;

    bp.text = data["bp"] ?? "";
    pulse.text = data["pulse"] ?? "";
    excessiveBleeding = data["excessiveBleeding"];
    breastHealthNormal = data["breastHealthNormal"];
    motherFeeling = data["motherFeeling"];

    // mother danger signs
    motherDangerSigns
      ..clear()
      ..addAll(List<String>.from(data["motherDangerSigns"] ?? []));

    // baby
    babyWeight.text = data["babyWeight"] ?? "";
    babyTemp.text = data["babyTemp"] ?? "";
    babyActivity = data["babyActivity"];
    babyBreathing = data["babyBreathing"];
    babySkinColor = data["babySkinColor"];
    breastfeeding = data["breastfeeding"];
    goodAttachment = data["goodAttachment"];

    // baby danger signs
    babyDangerSigns
      ..clear()
      ..addAll(List<String>.from(data["babyDangerSigns"] ?? []));

    // notes
    notes.text = data["notes"] ?? "";

    // follow-up
    followUpDate = data["followUpDate"] != null
        ? DateTime.tryParse(data["followUpDate"])
        : null;

    if (data["followUpTime"] != null && data["followUpTime"] is String) {
      final parts = data["followUpTime"].split(":");
      if (parts.length == 2) {
        followUpTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    complicationsObserved = data["complicationsObserved"];
    followUpBp.text = data["followUpBp"] ?? "";

    // immunization
    immunizationsUpToDate = data["immunizationsUpToDate"] ?? true;
    newbornWeight.text = data["newbornWeight"] ?? "";
  }
}

import 'package:flutter/material.dart';

class PncController {
  DateTime? checkupDate;
  final bp = TextEditingController();      // "120/80"
  final pulse = TextEditingController();   // "72"
  bool? excessiveBleeding;                // Yes/No
  bool? breastHealthNormal;               // Yes/No
  String? motherFeeling;                  // "Happy" | "Neutral" | "Sad"

  final Set<String> motherDangerSigns = {};

  final babyWeight = TextEditingController(); // kg
  final babyTemp = TextEditingController();   // °C
  String? babyActivity;       // "Active" | "Lethargic"
  String? babyBreathing;      // "Normal" | "Fast"
  String? babySkinColor;      // "Normal" | "Jaundiced"
  bool? breastfeeding;        // Yes/No
  bool? goodAttachment;       // Yes/No

  final Set<String> babyDangerSigns = {};

  final notes = TextEditingController();

  DateTime? followUpDate;
  TimeOfDay? followUpTime;
  bool? complicationsObserved;            // Yes/No
  final followUpBp = TextEditingController();

  bool immunizationsUpToDate = true;
  final newbornWeight = TextEditingController(); // kg

  bool get isCritical {
    return motherDangerSigns.isNotEmpty || babyDangerSigns.isNotEmpty;
  }

  void dispose() {
    bp.dispose();
    pulse.dispose();
    babyWeight.dispose();
    babyTemp.dispose();
    notes.dispose();
    followUpBp.dispose();
    newbornWeight.dispose();
  }

  Map<String, dynamic> toMap() {
    return {
      "checkupDate": checkupDate?.toIso8601String(),
      "bp": bp.text,
      "pulse": pulse.text,
      "excessiveBleeding": excessiveBleeding,
      "breastHealthNormal": breastHealthNormal,
      "motherFeeling": motherFeeling,

      "motherDangerSigns": motherDangerSigns.toList(),

      "babyWeight": babyWeight.text,
      "babyTemp": babyTemp.text,
      "babyActivity": babyActivity,
      "babyBreathing": babyBreathing,
      "babySkinColor": babySkinColor,
      "breastfeeding": breastfeeding,
      "goodAttachment": goodAttachment,

      "babyDangerSigns": babyDangerSigns.toList(),

      "notes": notes.text,

      "followUpDate": followUpDate?.toIso8601String(),
      "followUpTime": followUpTime == null
          ? null
          : "${followUpTime!.hour}:${followUpTime!.minute}",
      "complicationsObserved": complicationsObserved,
      "followUpBp": followUpBp.text,

      "immunizationsUpToDate": immunizationsUpToDate,
      "newbornWeight": newbornWeight.text,
    };
  }

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

    motherDangerSigns
      ..clear()
      ..addAll(List<String>.from(data["motherDangerSigns"] ?? []));

    babyWeight.text = data["babyWeight"] ?? "";
    babyTemp.text = data["babyTemp"] ?? "";
    babyActivity = data["babyActivity"];
    babyBreathing = data["babyBreathing"];
    babySkinColor = data["babySkinColor"];
    breastfeeding = data["breastfeeding"];
    goodAttachment = data["goodAttachment"];

    babyDangerSigns
      ..clear()
      ..addAll(List<String>.from(data["babyDangerSigns"] ?? []));

    notes.text = data["notes"] ?? "";

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

    immunizationsUpToDate = data["immunizationsUpToDate"] ?? true;
    newbornWeight.text = data["newbornWeight"] ?? "";
  }
}

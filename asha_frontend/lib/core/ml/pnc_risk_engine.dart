import 'dart:math' as math;

class PncPrediction {
  final double riskScore;
  final String riskLevelKey; // translation key
  final List<String> problems; // translation keys
  final List<String> suggestions; // translation keys

  PncPrediction({
    required this.riskScore,
    required this.riskLevelKey,
    required this.problems,
    required this.suggestions,
  });
}

///
/// Hybrid PNC risk engine (rule-based + logistic regression).
///
/// IMPORTANT:
/// - All inputs should already be numeric / encoded like in your dataset:
///   * bpSys, bpDia, pulse: double
///   * excessive_bleeding, breast_health_normal, baby_active, ...: 0/1
///   * mother_feeling: 0=Happy, 1=Neutral, 2=Sad
///   * weights are in the same order as featureNames below
///
PncPrediction calculatePncRisk({
  required double bpSys,
  required double bpDia,
  required double pulse,
  required double excessiveBleeding, // 0/1
  required double breastHealthNormal, // 1=normal, 0=abnormal
  required int motherFeeling, // 0=Happy,1=Neutral,2=Sad
  required double babyWeight,
  required double babyTemp,
  required double babyActive, // 1=active,0=lethargic
  required double babyBreathingFast, // 1=fast,0=normal
  required double babySkinJaundiced, // 1=jaundiced,0=normal
  required double breastfeeding, // 1=yes,0=no
  required double goodAttachment, // 1=yes,0=no
  required double dsMotherFever, // 0/1
  required double dsMotherSevereBleeding, // 0/1
  required double dsMotherFoulSmellingDischarge, // 0/1
  required double dsMotherSevereHeadache, // 0/1
  required double dsMotherConvulsions, // 0/1
  required double dsBabyDifficultyBreathing, // 0/1
  required double dsBabyTempAbnormal, // 0/1
  required double dsBabyNotFeedingWell, // 0/1
  required double dsBabyJaundiced, // 0/1
  required double complicationsObserved, // 0/1
  required double immunizationsUpToDate, // 1=yes,0=no
  required double newbornWeight,
}) {
  double ruleRisk = 0.0;
  final problems = <String>[];
  final suggestions = <String>[];

  final bool hasExcessiveBleeding = excessiveBleeding == 1.0;
  final bool breastAbnormal = breastHealthNormal == 0.0;
  final bool babyIsLethargic = babyActive == 0.0;
  final bool babyFastBreathing = babyBreathingFast == 1.0;
  final bool babyIsJaundiced = babySkinJaundiced == 1.0;
  final bool isBreastfeeding = breastfeeding == 1.0;
  final bool hasGoodAttachment = goodAttachment == 1.0;

  final bool motherFever = dsMotherFever == 1.0;
  final bool motherSevereBleeding = dsMotherSevereBleeding == 1.0;
  final bool motherFoulDischarge = dsMotherFoulSmellingDischarge == 1.0;
  final bool motherSevereHeadache = dsMotherSevereHeadache == 1.0;
  final bool motherConvulsions = dsMotherConvulsions == 1.0;

  final bool babyDiffBreathing = dsBabyDifficultyBreathing == 1.0;
  final bool babyTempAbnormal = dsBabyTempAbnormal == 1.0;
  final bool babyNotFeedingWell = dsBabyNotFeedingWell == 1.0;
  final bool babyDangerJaundiced = dsBabyJaundiced == 1.0;

  final bool hasComplications = complicationsObserved == 1.0;
  final bool immuUpToDate = immunizationsUpToDate == 1.0;

  // ---------------- RULE ENGINE (PNC specific) ----------------

  // Very high-risk maternal signs
  if (motherSevereBleeding || motherConvulsions || hasExcessiveBleeding) {
    ruleRisk += 0.35;
    problems.add("pnc_problem_maternal_hemorrhage_or_convulsions");
  }

  // Sepsis / infection signs
  if (motherFever || motherFoulDischarge) {
    ruleRisk += 0.20;
    problems.add("pnc_problem_maternal_infection");
  }

  // Preeclampsia/postpartum hypertension clues
  if (bpSys >= 140 || bpDia >= 90) {
    ruleRisk += 0.20;
    problems.add("pnc_problem_maternal_hypertension");
  }
  if (motherSevereHeadache) {
    ruleRisk += 0.10;
    problems.add("pnc_problem_maternal_headache");
  }

  // Maternal wellbeing / mental health
  if (motherFeeling == 2 /* Sad */ ) {
    ruleRisk += 0.05;
    problems.add("pnc_problem_maternal_low_mood");
  }

  // Newborn critical signs
  if (babyDiffBreathing || babyFastBreathing) {
    ruleRisk += 0.30;
    problems.add("pnc_problem_baby_breathing");
  }
  if (babyTempAbnormal) {
    ruleRisk += 0.20;
    problems.add("pnc_problem_baby_temperature");
  }
  if (babyNotFeedingWell) {
    ruleRisk += 0.20;
    problems.add("pnc_problem_baby_feeding");
  }

  // Jaundice + low birth weight
  if (babyDangerJaundiced || babyIsJaundiced) {
    ruleRisk += 0.15;
    problems.add("pnc_problem_baby_jaundice");
  }
  if (babyWeight < 2.5 || newbornWeight < 2.5) {
    ruleRisk += 0.10;
    problems.add("pnc_problem_low_birth_weight");
  }

  // Complications flag from follow-up
  if (hasComplications) {
    ruleRisk += 0.20;
    problems.add("pnc_problem_complications_observed");
  }

  // Protective: immunisations up to date (just slightly reduce risk)
  if (immuUpToDate) {
    ruleRisk -= 0.05;
  }

  // Bound ruleRisk to [0,1]
  if (ruleRisk < 0) ruleRisk = 0;
  if (ruleRisk > 1) ruleRisk = 1;

  // ---------------- ML ENGINE (logistic regression) ----------------

  // Order MUST match your training script feature_cols (25 features)
  final featureNames = <String>[
    "bpSys",
    "bpDia",
    "pulse",
    "excessive_bleeding",
    "breast_health_normal",
    "mother_feeling",
    "baby_weight",
    "baby_temp",
    "baby_active",
    "baby_breathing_fast",
    "baby_skin_jaundiced",
    "breastfeeding",
    "good_attachment",
    "ds_mother_fever",
    "ds_mother_severe_bleeding",
    "ds_mother_foul_smelling_discharge",
    "ds_mother_severe_headache",
    "ds_mother_convulsions",
    "ds_baby_difficulty_breathing",
    "ds_baby_temp_abnormal",
    "ds_baby_not_feeding_well",
    "ds_baby_jaundiced",
    "complications_observed",
    "immunizations_up_to_date",
    "newborn_weight",
  ];

  // Your PNC weights (same order as featureNames)
  final weights = <double>[
    0.020787674470705383,
    -0.036313641272973,
    0.01607934370894543,
    1.5101427157491756,
    -0.2716265830894325,
    0.023721962019804956,
    0.2434664499397589,
    0.07456393504468763,
    -0.5752213056896547,
    1.7396850754609918,
    0.5576455109081374,
    -0.6628055014314301,
    -0.14074798335779154,
    1.7631347346299997,
    0.9802379170677605,
    0.6269261603216619,
    0.7553595419828258,
    -0.17170446382811522,
    0.1369252298552525,
    1.9905311651853328,
    1.5338182049591371,
    0.5576455109081374,
    1.3787181390897245,
    0.09298789652842905,
    -0.1470882846306248,
  ];

  // TODO: replace this with the actual intercept printed by your Python script
  const double intercept = -5.361524398754781;

  // Build feature map
  final mlFeatures = <String, double>{
    "bpSys": bpSys,
    "bpDia": bpDia,
    "pulse": pulse,
    "excessive_bleeding": excessiveBleeding,
    "breast_health_normal": breastHealthNormal,
    "mother_feeling": motherFeeling.toDouble(),
    "baby_weight": babyWeight,
    "baby_temp": babyTemp,
    "baby_active": babyActive,
    "baby_breathing_fast": babyBreathingFast,
    "baby_skin_jaundiced": babySkinJaundiced,
    "breastfeeding": breastfeeding,
    "good_attachment": goodAttachment,
    "ds_mother_fever": dsMotherFever,
    "ds_mother_severe_bleeding": dsMotherSevereBleeding,
    "ds_mother_foul_smelling_discharge": dsMotherFoulSmellingDischarge,
    "ds_mother_severe_headache": dsMotherSevereHeadache,
    "ds_mother_convulsions": dsMotherConvulsions,
    "ds_baby_difficulty_breathing": dsBabyDifficultyBreathing,
    "ds_baby_temp_abnormal": dsBabyTempAbnormal,
    "ds_baby_not_feeding_well": dsBabyNotFeedingWell,
    "ds_baby_jaundiced": dsBabyJaundiced,
    "complications_observed": complicationsObserved,
    "immunizations_up_to_date": immunizationsUpToDate,
    "newborn_weight": newbornWeight,
  };

  double z = intercept;
  for (int i = 0; i < weights.length; i++) {
    final name = featureNames[i];
    final value = mlFeatures[name] ?? 0.0;
    z += weights[i] * value;
  }

  final double mlScore = 1.0 / (1.0 + math.exp(-z));

  // ---------------- HYBRID SCORE ----------------

  double finalScore = 0.6 * ruleRisk + 0.4 * mlScore;
  if (finalScore < 0) finalScore = 0;
  if (finalScore > 1) finalScore = 1;

  final String riskKey = finalScore < 0.33
      ? "risk_low"
      : finalScore < 0.66
      ? "risk_moderate"
      : "risk_high";

  // ---------------- SUGGESTIONS ----------------

  final suggestionKeys = <String>[
    "pnc_suggest_regular_followup",
    if (riskKey == "risk_high") "pnc_suggest_urgent_referral",
    if (motherFever || motherFoulDischarge) "pnc_suggest_infection_check",
    if (bpSys >= 140 || bpDia >= 90) "pnc_suggest_monitor_bp",
    if (!isBreastfeeding || !hasGoodAttachment)
      "pnc_suggest_breastfeeding_support",
    if (babyNotFeedingWell || babyDiffBreathing || babyTempAbnormal)
      "pnc_suggest_immediate_baby_assessment",
  ];

  return PncPrediction(
    riskScore: double.parse(finalScore.toStringAsFixed(2)),
    riskLevelKey: riskKey,
    problems: problems.toSet().toList(),
    suggestions: suggestionKeys.toSet().toList(),
  );
}

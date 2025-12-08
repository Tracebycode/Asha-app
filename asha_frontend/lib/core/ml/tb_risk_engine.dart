import 'dart:math' as math;

class TbPrediction {
  final double riskScore;
  final String riskLevelKey; // "risk_low" / "risk_moderate" / "risk_high"
  final List<String> problems; // translation keys
  final List<String> suggestions; // translation keys

  TbPrediction({
    required this.riskScore,
    required this.riskLevelKey,
    required this.problems,
    required this.suggestions,
  });
}

TbPrediction calculateTbRisk({
  required bool hasCough,
  required double coughDurationDays,
  required bool coughDry,
  required bool coughWithPhlegm,
  required bool coughWithBlood,
  required bool hasFever,
  required double feverDurationDays,
  required String? feverPattern, // "Continuous" / "Intermittent" / "Remittent"
  required bool hasWeightLoss,
  required double weightLossKg,
  required String? weightLossPeriod, // "Last 2 weeks" / "Last month" / "Last 3 months"
  required bool hasChestPain,
  required bool hasTbPatientAtHome,
  required bool hadTbInPast,
}) {
  double ruleRisk = 0.0;
  final problems = <String>[];
  final suggestions = <String>[];

  final bool coughProlonged14 = hasCough && coughDurationDays >= 14;
  final bool coughProlonged21 = hasCough && coughDurationDays >= 21;
  final bool bloodInSputum = coughWithBlood;
  final bool weightRecent2w = hasWeightLoss && weightLossPeriod == "Last 2 weeks";
  final bool weightRecent1m = hasWeightLoss && weightLossPeriod == "Last month";
  final bool weightRecent3m = hasWeightLoss && weightLossPeriod == "Last 3 months";

  final bool feverContinuous = hasFever && feverPattern == "Continuous";
  final bool feverLong = hasFever && feverDurationDays >= 7;

  final bool tbContact = hasTbPatientAtHome;
  final bool tbHistory = hadTbInPast;

  // ---------------- RULE ENGINE (TB specific) ----------------

  // Prolonged cough
  if (coughProlonged14) {
    ruleRisk += 0.25;
    problems.add("tb_problem_prolonged_cough_2w");
  }
  if (coughProlonged21) {
    ruleRisk += 0.10;
    problems.add("tb_problem_prolonged_cough_3w");
  }

  // Blood in sputum
  if (bloodInSputum) {
    ruleRisk += 0.35;
    problems.add("tb_problem_hemoptysis");
  }

  // Fever patterns
  if (feverLong) {
    ruleRisk += 0.20;
    problems.add("tb_problem_persistent_fever");
  }
  if (feverContinuous) {
    ruleRisk += 0.15;
    problems.add("tb_problem_continuous_fever");
  }

  // Weight loss
  if (hasWeightLoss) {
    ruleRisk += 0.20;
    problems.add("tb_problem_weight_loss");
    if (weightLossKg >= 3.0) {
      ruleRisk += 0.10;
      problems.add("tb_problem_significant_weight_loss");
    }
    if (weightRecent2w || weightRecent1m) {
      ruleRisk += 0.05;
      problems.add("tb_problem_recent_weight_loss");
    }
  }

  // Chest pain with cough
  if (hasChestPain && hasCough) {
    ruleRisk += 0.15;
    problems.add("tb_problem_chest_pain_with_cough");
  }

  // TB exposure and past TB
  if (tbContact) {
    ruleRisk += 0.35;
    problems.add("tb_problem_tb_contact");
  }
  if (tbHistory) {
    ruleRisk += 0.35;
    problems.add("tb_problem_past_tb_history");
  }

  // Bound ruleRisk to [0,1]
  if (ruleRisk < 0) ruleRisk = 0;
  if (ruleRisk > 1) ruleRisk = 1;

  final featureNames = <String>[
    "has_cough",
    "cough_duration_days",
    "cough_dry",
    "cough_phlegm",
    "cough_blood",
    "has_fever",
    "fever_duration_days",
    "fever_continuous",
    "fever_intermittent",
    "fever_remittent",
    "has_weight_loss",
    "weight_loss_kg",
    "weight_loss_period_2w",
    "weight_loss_period_1m",
    "weight_loss_period_3m",
    "has_chest_pain",
    "tb_patient_at_home",
    "had_tb_in_past",
  ];

  final weights = <double>[
    -0.23276670562369953,
    0.20496223284601806,
    -0.4201218189558425,
    1.323898213565093,
    3.2891868989583894,
    1.1504770024587099,
    0.09992063596093201,
    1.1489698696286859,
    -0.47574218520674016,
    0.477249318036752,
    1.274163104099777,
    0.9447286969063182,
    0.760859104165282,
    0.2024336053138926,
    0.31087039462059896,
    1.2597164157728344,
    4.800759481957341,
    4.243398673142793
  ];

  const double intercept = -8.077840289270883;

  // Build ML features map from the given inputs (0/1 encoding)
  final int feverContinuousInt = feverContinuous ? 1 : 0;
  final int feverIntermittentInt =
  hasFever && feverPattern == "Intermittent" ? 1 : 0;
  final int feverRemittentInt =
  hasFever && feverPattern == "Remittent" ? 1 : 0;

  final int weight2wInt = weightRecent2w ? 1 : 0;
  final int weight1mInt = weightRecent1m ? 1 : 0;
  final int weight3mInt = weightRecent3m ? 1 : 0;

  final mlFeatures = <String, double>{
    "has_cough": hasCough ? 1.0 : 0.0,
    "cough_duration_days": coughDurationDays,
    "cough_dry": coughDry ? 1.0 : 0.0,
    "cough_phlegm": coughWithPhlegm ? 1.0 : 0.0,
    "cough_blood": coughWithBlood ? 1.0 : 0.0,
    "has_fever": hasFever ? 1.0 : 0.0,
    "fever_duration_days": feverDurationDays,
    "fever_continuous": feverContinuousInt.toDouble(),
    "fever_intermittent": feverIntermittentInt.toDouble(),
    "fever_remittent": feverRemittentInt.toDouble(),
    "has_weight_loss": hasWeightLoss ? 1.0 : 0.0,
    "weight_loss_kg": weightLossKg,
    "weight_loss_period_2w": weight2wInt.toDouble(),
    "weight_loss_period_1m": weight1mInt.toDouble(),
    "weight_loss_period_3m": weight3mInt.toDouble(),
    "has_chest_pain": hasChestPain ? 1.0 : 0.0,
    "tb_patient_at_home": hasTbPatientAtHome ? 1.0 : 0.0,
    "had_tb_in_past": hadTbInPast ? 1.0 : 0.0,
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

  final suggestionKeys = <String>[
    "tb_suggest_regular_followup",
    if (riskKey == "risk_high") "tb_suggest_urgent_referral",
    if (coughProlonged14 || bloodInSputum) "tb_suggest_sputum_test",
    if (feverLong || feverContinuous) "tb_suggest_medical_evaluation",
    if (hasWeightLoss) "tb_suggest_nutrition_and_screening",
    if (tbContact || tbHistory) "tb_suggest_contact_tracing_and_testing",
  ];

  return TbPrediction(
    riskScore: double.parse(finalScore.toStringAsFixed(2)),
    riskLevelKey: riskKey,
    problems: problems.toSet().toList(),
    suggestions: suggestionKeys.toSet().toList(),
  );
}

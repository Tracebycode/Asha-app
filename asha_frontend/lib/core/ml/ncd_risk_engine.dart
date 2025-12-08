import 'dart:math' as math;

class NcdPrediction {
  final double riskScore;      // 0–1
  final String riskLevelKey;   // "risk_low" / "risk_moderate" / "risk_high"
  final List<String> problems; // translation keys
  final List<String> suggestions; // translation keys

  NcdPrediction({
    required this.riskScore,
    required this.riskLevelKey,
    required this.problems,
    required this.suggestions,
  });
}

///
/// Hybrid NCD risk engine (rule-based + logistic regression).
///
/// Inputs:
///   systolicMmHg, diastolicMmHg, weightKg, heightCm, randomBloodSugarMgDl
///   usesTobacco, consumesAlcohol: bool
///   extraSaltIntake: "None" / "A little" / "A lot"
///   exerciseFrequency: "Daily" / "Few times a week" / "Rarely" / "Never"
///
NcdPrediction calculateNcdRisk({
  required double systolicMmHg,
  required double diastolicMmHg,
  required double weightKg,
  required double heightCm,
  required double randomBloodSugarMgDl,
  required bool usesTobacco,
  required bool consumesAlcohol,
  required String extraSaltIntake,
  required String exerciseFrequency,
}) {
  double ruleRisk = 0.0;
  final problems = <String>[];
  final suggestions = <String>[];

  // ---------------- Derived metrics ----------------
  final double heightM = heightCm > 0 ? heightCm / 100.0 : 0.0;
  final double bmi =
  (heightM > 0) ? (weightKg / (heightM * heightM)) : 0.0;

  final bool highBp = systolicMmHg >= 140 || diastolicMmHg >= 90;
  final bool preHighBp = !highBp && (systolicMmHg >= 130 || diastolicMmHg >= 85);

  final bool veryHighSugar = randomBloodSugarMgDl >= 200;
  final bool moderatelyHighSugar =
      !veryHighSugar && randomBloodSugarMgDl >= 140;

  final bool overweight = bmi >= 25 && bmi < 30;
  final bool obese = bmi >= 30;

  final bool tobaccoUser = usesTobacco;
  final bool alcoholUser = consumesAlcohol;

  final bool extraSaltNone = extraSaltIntake == "None";
  final bool extraSaltLittle = extraSaltIntake == "A little";
  final bool extraSaltLot = extraSaltIntake == "A lot";

  final bool exerciseDaily = exerciseFrequency == "Daily";
  final bool exerciseFewPerWeek =
      exerciseFrequency == "Few times a week";
  final bool exerciseRarely = exerciseFrequency == "Rarely";
  final bool exerciseNever = exerciseFrequency == "Never";

  if (highBp) {
    ruleRisk += 0.35;
    problems.add("ncd_problem_high_blood_pressure");
  } else if (preHighBp) {
    ruleRisk += 0.20;
    problems.add("ncd_problem_pre_hypertension");
  }

  // Blood sugar
  if (veryHighSugar) {
    ruleRisk += 0.35;
    problems.add("ncd_problem_very_high_blood_sugar");
  } else if (moderatelyHighSugar) {
    ruleRisk += 0.20;
    problems.add("ncd_problem_moderately_high_blood_sugar");
  }

  if (obese) {
    ruleRisk += 0.30;
    problems.add("ncd_problem_obesity");
  } else if (overweight) {
    ruleRisk += 0.15;
    problems.add("ncd_problem_overweight");
  }

  if (tobaccoUser) {
    ruleRisk += 0.20;
    problems.add("ncd_problem_tobacco_use");
  }
  if (alcoholUser) {
    ruleRisk += 0.10;
    problems.add("ncd_problem_alcohol_use");
  }

  if (extraSaltLittle) {
    ruleRisk += 0.10;
    problems.add("ncd_problem_extra_salt_little");
  } else if (extraSaltLot) {
    ruleRisk += 0.20;
    problems.add("ncd_problem_extra_salt_high");
  }

  if (exerciseRarely) {
    ruleRisk += 0.10;
    problems.add("ncd_problem_low_physical_activity");
  } else if (exerciseNever) {
    ruleRisk += 0.20;
    problems.add("ncd_problem_sedentary_lifestyle");
  }

  if (ruleRisk < 0) ruleRisk = 0;
  if (ruleRisk > 1) ruleRisk = 1;

  final featureNames = <String>[
    "systolic_mmHg",
    "diastolic_mmHg",
    "weight_kg",
    "height_cm",
    "random_blood_sugar_mg_dl",
    "uses_tobacco",
    "consumes_alcohol",
    "extra_salt_intake_level",
    "exercise_frequency_level",
  ];


  final weights = <double>[
    0.09599085281424069,
    0.07355317677091931,
    0.17453668689450585,
    -0.15120019574480703,
    0.041535223057754464,
    2.7356849287364966,
    1.4475466355700721,
    1.0536178603018498,
    0.9904465677285321
  ];

  const double intercept = -14.216823736523626;

  // Encode categorical levels the same way as in synthetic generator/training:
  // extra_salt_intake_level: 0=None, 1=A little, 2=A lot
  int extraSaltLevel = 0;
  if (extraSaltLittle) {
    extraSaltLevel = 1;
  } else if (extraSaltLot) {
    extraSaltLevel = 2;
  }

  // exercise_frequency_level: 0=Daily,1=Few/week,2=Rarely,3=Never
  int exerciseLevel = 0;
  if (exerciseFewPerWeek) {
    exerciseLevel = 1;
  } else if (exerciseRarely) {
    exerciseLevel = 2;
  } else if (exerciseNever) {
    exerciseLevel = 3;
  }

  final mlFeatures = <String, double>{
    "systolic_mmHg": systolicMmHg,
    "diastolic_mmHg": diastolicMmHg,
    "weight_kg": weightKg,
    "height_cm": heightCm,
    "random_blood_sugar_mg_dl": randomBloodSugarMgDl,
    "uses_tobacco": tobaccoUser ? 1.0 : 0.0,
    "consumes_alcohol": alcoholUser ? 1.0 : 0.0,
    "extra_salt_intake_level": extraSaltLevel.toDouble(),
    "exercise_frequency_level": exerciseLevel.toDouble(),
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
    "ncd_suggest_regular_screening",
    if (riskKey == "risk_high") "ncd_suggest_urgent_referral",
    if (highBp || preHighBp) "ncd_suggest_bp_management",
    if (veryHighSugar || moderatelyHighSugar)
      "ncd_suggest_blood_sugar_evaluation",
    if (overweight || obese) "ncd_suggest_diet_and_weight_management",
    if (tobaccoUser) "ncd_suggest_tobacco_cessation",
    if (alcoholUser) "ncd_suggest_limit_alcohol",
    if (extraSaltLittle || extraSaltLot) "ncd_suggest_reduce_salt",
    if (exerciseRarely || exerciseNever) "ncd_suggest_increase_activity",
  ];

  return NcdPrediction(
    riskScore: double.parse(finalScore.toStringAsFixed(2)), // 0–1, not %
    riskLevelKey: riskKey,
    problems: problems.toSet().toList(),
    suggestions: suggestionKeys.toSet().toList(),
  );
}

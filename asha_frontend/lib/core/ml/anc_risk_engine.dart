import 'dart:math' as math;

class AncPrediction {
  final double riskScore;
  final String riskLevelKey;      // translation key
  final List<String> problems;    // translation keys
  final List<String> suggestions; // translation keys

  AncPrediction({
    required this.riskScore,
    required this.riskLevelKey,
    required this.problems,
    required this.suggestions,
  });
}

AncPrediction calculateAncRisk({
  required Map<String, dynamic> step1,
  required Map<String, dynamic> step2,
  required Map<String, dynamic> step3,
  required int age,
  required String gender,
}) {
  double ruleRisk = 0.0;
  final problems = <String>[];
  final suggestions = <String>[];

  // Extract data
  final gravida = step1["gravida"] ?? 0;
  final parity = step1["parity"] ?? 0;
  final living = step1["living"] ?? 0;
  final abortions = step1["abortions"] ?? 0;

  final bpSys = step2["bpSys"] ?? 0;
  final bpDia = step2["bpDia"] ?? 0;
  final weight = step2["weight"] ?? 0;
  final hb = step2["hemoglobin"] ?? 0;
  final sugar = step2["sugar"] ?? 0;
  final lmpDays = step2["lmpDays"] ?? 0;

  bool bleeding = step3["bleeding"] == 1.0;
  bool severeHeadache = step3["severe_headache"] == 1.0;
  bool swelling = step3["swelling"] == 1.0;
  bool blurredVision = step3["blurred_vision"] == 1.0;
  bool fever = step3["fever"] == 1.0;
  bool convulsions = step3["convulsions"] == 1.0;

  bool prevCesarean = step3["prev_cesarean"] == 1.0;
  bool prevStillbirth = step3["prev_stillbirth"] == 1.0;
  bool prevComplications = step3["prev_complications"] == 1.0;

  // ---------------- RULE ENGINE ----------------

  if (age < 18 || age > 35) {
    ruleRisk += 0.15;
    problems.add("problem_age_risk");
  }

  if (bpSys >= 140 || bpDia >= 90) {
    ruleRisk += 0.20;
    problems.add("problem_hypertension");
  }

  if (hb < 10) {
    ruleRisk += 0.15;
    problems.add("problem_low_hemoglobin");
  }

  if (sugar > 140) {
    ruleRisk += 0.15;
    problems.add("problem_high_sugar");
  }

  if (bleeding) {
    ruleRisk += 0.25;
    problems.add("problem_bleeding");
  }

  if (convulsions) {
    ruleRisk += 0.30;
    problems.add("problem_convulsions");
  }

  if (severeHeadache || swelling || blurredVision) {
    ruleRisk += 0.10;
    problems.add("problem_preeclampsia_symptoms");
  }

  if (fever) {
    ruleRisk += 0.10;
    problems.add("problem_fever_infection");
  }

  if (prevStillbirth) {
    ruleRisk += 0.15;
    problems.add("problem_prev_stillbirth");
  }

  if (prevComplications) {
    ruleRisk += 0.10;
    problems.add("problem_prev_complications");
  }

  if (ruleRisk > 1.0) ruleRisk = 1.0;

  // ---------------- ML ENGINE (unchanged) ----------------

  final featureNames = [
    "age","gravida","parity","living","abortions",
    "bpSys","bpDia","weight","hemoglobin","sugar","lmpDays",
    "bleeding","severe_headache","swelling","blurred_vision",
    "fever","convulsions","prev_cesarean","prev_stillbirth","prev_complications"
  ];

  final weights = [
    0.11305537872262199,
    -0.5726888743592077,
    -0.21645070037504655,
    -0.31178184434924894,
    1.2419654716555864,
    0.14390459720386864,
    0.12385534679247706,
    0.034935125627683646,
    -0.4850079880874098,
    0.043266634882847835,
    -0.0004435999616238252,
    0.6276987088344358,
    0.32555676372470027,
    0.3369172477253379,
    0.07985092984875387,
    0.32688666704844194,
    0.43124803084482183,
    -0.450566225977738,
    0.5021825945387258,
    0.3805807581628659
  ];

  const intercept = -29.170230947986283;

  double z = intercept;

  final mlFeatures = {
    "age": age.toDouble(),
    "gravida": gravida.toDouble(),
    "parity": parity.toDouble(),
    "living": living.toDouble(),
    "abortions": abortions.toDouble(),
    "bpSys": bpSys.toDouble(),
    "bpDia": bpDia.toDouble(),
    "weight": weight.toDouble(),
    "hemoglobin": hb.toDouble(),
    "sugar": sugar.toDouble(),
    "lmpDays": lmpDays.toDouble(),
    "bleeding": bleeding ? 1.0 : 0.0,
    "severe_headache": severeHeadache ? 1.0 : 0.0,
    "swelling": swelling ? 1.0 : 0.0,
    "blurred_vision": blurredVision ? 1.0 : 0.0,
    "fever": fever ? 1.0 : 0.0,
    "convulsions": convulsions ? 1.0 : 0.0,
    "prev_cesarean": prevCesarean ? 1.0 : 0.0,
    "prev_stillbirth": prevStillbirth ? 1.0 : 0.0,
    "prev_complications": prevComplications ? 1.0 : 0.0
  };

  for (int i = 0; i < weights.length; i++) {
    z += weights[i] * (mlFeatures[featureNames[i]] ?? 0.0);
  }

  double mlScore = 1.0 / (1.0 + math.exp(-z));

  // ---------------- HYBRID SCORE ----------------

  double finalScore = 0.6 * ruleRisk + 0.4 * mlScore;
  if (finalScore > 1) finalScore = 1;

  String riskKey =
  finalScore < 0.33 ? "risk_low"
      : finalScore < 0.66 ? "risk_moderate"
      : "risk_high";

  // Suggestions (translated using keys)
  final suggestionKeys = <String>[
    "suggest_regular_checkups",
    if (riskKey == "risk_high") "suggest_urgent_referral",
    if (hb < 10) "suggest_increase_iron",
    if (bpSys > 140) "suggest_monitor_bp",
    if (sugar > 140) "suggest_control_sugar",
  ];

  return AncPrediction(
    riskScore: double.parse(finalScore.toStringAsFixed(2)),
    riskLevelKey: riskKey,
    problems: problems.toSet().toList(),
    suggestions: suggestionKeys.toSet().toList(),
  );
}

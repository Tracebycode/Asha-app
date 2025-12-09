import 'package:flutter/material.dart';
import 'package:asha_frontend/localization/app_localization.dart';

class DailySurveyPage extends StatelessWidget {
  const DailySurveyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalization.of(context).t;

    return Scaffold(
      appBar: AppBar(
        title: Text(t("daily_survey")),
      ),
      body: Center(
        child: Text(t("daily_survey_placeholder")),
      ),
    );
  }
}

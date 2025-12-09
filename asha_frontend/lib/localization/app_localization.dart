import 'dart:convert';
import 'package:flutter/services.dart';

class AppLocalization {
  final String locale;

  static AppLocalization? _instance;
  static Map<String, dynamic> _localizedStrings = {};

  AppLocalization(this.locale);

  /// Accessor
  static AppLocalization of(context) => _instance!;

  /// Load JSON language file
  static Future<void> load(String locale) async {
    _instance = AppLocalization(locale); // Save locale in instance

    final jsonString =
    await rootBundle.loadString('assets/lang/$locale.json');

    _localizedStrings = json.decode(jsonString);
  }

  /// Translation by key
  String t(String key) => _localizedStrings[key] ?? key;
}

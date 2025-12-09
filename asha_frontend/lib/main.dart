import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Your files:
import 'package:asha_frontend/auth/providers/auth_provider.dart';
import 'package:asha_frontend/auth/pages/login_page.dart';
import 'package:asha_frontend/features/home/ui/home_page.dart';
import 'package:asha_frontend/localization/app_localization.dart';

/// 🔥 Global navigator key to restart app after logout
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved language
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString("lang_code") ?? "en";

  // Preload localization file
  await AppLocalization.load(savedLang);

  runApp(MyApp(initialLang: savedLang));
}

class MyApp extends StatefulWidget {
  final String initialLang;

  const MyApp({super.key, required this.initialLang});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String currentLang;

  @override
  void initState() {
    super.initState();
    currentLang = widget.initialLang;
  }

  /// 🔥 CHANGE LANGUAGE FUNCTION (refreshes UI)
  Future<void> changeLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();

    // Save new language
    await prefs.setString("lang_code", lang);

    // Load new localization file
    await AppLocalization.load(lang);

    setState(() {
      currentLang = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        navigatorKey: appNavigatorKey, // ⬅ important
        debugShowCheckedModeBanner: false,
        title: 'ASHA Health Tracker',

        home: AuthWrapper(
          onLanguageChanged: changeLanguage,
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final Function(String) onLanguageChanged;

  const AuthWrapper({super.key, required this.onLanguageChanged});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (auth.isAuthenticated) {
          return HomePage(onLanguageChanged: onLanguageChanged);
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

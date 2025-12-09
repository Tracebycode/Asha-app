import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asha_frontend/localization/app_localization.dart';

import '../auth/pages/login_page.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Select Language"),
        backgroundColor: const Color(0xFF2A5A9E),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            _languageTile(context,
                langCode: "en",
                title: "English",
                subtitle: "Use app in English",
                flag: "🇬🇧"),

            const SizedBox(height: 16),

            _languageTile(context,
                langCode: "hi",
                title: "हिन्दी",
                subtitle: "ऐप हिंदी में उपयोग करें",
                flag: "🇮🇳"),

            const SizedBox(height: 16),

            _languageTile(context,
                langCode: "mr",
                title: "मराठी",
                subtitle: "अ‍ॅप मराठीत वापरा",
                flag: "🇮🇳"),
          ],
        ),
      ),
    );
  }

  Widget _languageTile(
      BuildContext context, {
        required String langCode,
        required String title,
        required String subtitle,
        required String flag,
      }) {
    return InkWell(
      onTap: () async {
        // Load new language
        await AppLocalization.load(langCode);

        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("first_time_open", false);

        // Navigate to Login Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      },

      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

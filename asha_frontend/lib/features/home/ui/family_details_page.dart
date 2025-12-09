import 'package:flutter/material.dart';
import 'package:asha_frontend/features/home/ui/existing_family_page.dart';
import 'package:asha_frontend/features/home/ui/daily_survey.dart';
import 'package:asha_frontend/features/family/ui/add_family_page.dart';
import 'package:asha_frontend/localization/app_localization.dart';

class FamilyDetailsPage extends StatelessWidget {
  const FamilyDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalization.of(context).t;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(t("start_new_survey")),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.wifi_off),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildListTile(
              context: context,
              icon: Icons.people_outline,
              title: t("select_existing_family"),
              subtitle: t("select_existing_family_sub"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExistingFamilyPage()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildListTile(
              context: context,
              icon: Icons.person_add_alt_1_outlined,
              title: t("add_new_family"),
              subtitle: t("add_new_family_sub"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddFamilyPage()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildListTile(
              context: context,
              icon: Icons.rule_sharp,
              title: t("view_survey_tasks"),
              subtitle: t("view_survey_tasks_sub"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DailySurveyPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 2.0,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:asha_frontend/auth/session.dart';
import 'package:asha_frontend/auth/providers/auth_provider.dart';

import 'package:asha_frontend/features/home/ui/family_details_page.dart';
import 'package:asha_frontend/debug/families_test.dart';

import 'package:asha_frontend/sync/sync_families_service.dart';
import 'package:asha_frontend/sync/member_sync_service.dart';
import 'package:asha_frontend/sync/health_record_sync_service.dart';

import 'package:asha_frontend/localization/app_localization.dart';

class HomePage extends StatefulWidget {
  final Function(String) onLanguageChanged;

  const HomePage({super.key, required this.onLanguageChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final syncFamilies = SyncFamiliesService();
  final syncMembers = MemberSyncService();
  final syncHealth = HealthRecordSyncService();

  bool _syncing = false;

  Future<void> performFullSync() async {
    if (_syncing) return;

    setState(() => _syncing = true);

    await syncFamilies.syncFamilies();
    await syncMembers.syncMembers();
    await syncHealth.syncHealthRecords();

    setState(() => _syncing = false);

    if (mounted) {
      final t = AppLocalization.of(context).t;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t("sync_completed"))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalization.of(context).t;

    return Scaffold(
      drawer: _buildDrawer(context),

      // ------------------ APP BAR ---------------------
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A5A9E),
        title: Text(t("app_title"), style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),

        actions: [
          // 🔄 SYNC BUTTON
          IconButton(
            icon: _syncing
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.sync, color: Colors.white),
            onPressed: _syncing ? null : performFullSync,
          ),

          // 👤 PROFILE BUTTON
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      // ------------------ BODY ---------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildUserInfo(context),
            const SizedBox(height: 16),
            _buildDashboardGrid(context),
            const SizedBox(height: 16),
            _buildTasksFromSupervisor(context),
          ],
        ),
      ),

      // ------------------ ADD FAMILY BUTTON ---------------------
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2A5A9E),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FamilyDetailsPage()),
          );
        },
      ),
    );
  }

  // ============================================================
  // DRAWER UI (LEFT MENU)
  // ============================================================
  Widget _buildDrawer(BuildContext context) {
    final t = AppLocalization.of(context).t;

    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF2A5A9E)),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            accountName: Text(Session.instance.name ?? "ASHA Worker"),
            accountEmail: Text(Session.instance.areaName ?? ""),
          ),

          // 🌐 LANGUAGE DROPDOWN
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Change Language",
                border: OutlineInputBorder(),
              ),
              value: AppLocalization.of(context).locale,
              items: const [
                DropdownMenuItem(value: "en", child: Text("English")),
                DropdownMenuItem(value: "mr", child: Text("मराठी")),
                DropdownMenuItem(value: "hi", child: Text("हिन्दी")),
              ],
              onChanged: (lang) {
                if (lang != null) widget.onLanguageChanged(lang);
              },
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(t("settings")),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title:
            Text(t("logout"), style: const TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGOUT FUNCTION
  // ============================================================
  void _logout(BuildContext context) {
    Navigator.pop(context);

    Session.instance.clear();

    Provider.of<AuthProvider>(context, listen: false).logout();
  }

  // ============================================================
  // USER CARD
  // ============================================================
  Widget _buildUserInfo(BuildContext context) {
    final t = AppLocalization.of(context).t;
    final s = Session.instance;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.name ?? t("unknown_asha"),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  s.areaName ?? t("no_area"),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const Spacer(),

            Chip(
              avatar: const Icon(Icons.wifi, color: Colors.green, size: 14),
              label:
              Text(t("online"), style: const TextStyle(color: Colors.green)),
              backgroundColor: Colors.green.withOpacity(0.1),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DASHBOARD GRID
  // ============================================================
  Widget _buildDashboardGrid(BuildContext context) {
    final t = AppLocalization.of(context).t;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _gridCard(
          Icons.post_add,
          t("new_survey"),
          t("start_new_survey"),
          Colors.blue,
              () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FamilyDetailsPage()),
          ),
        ),
        _gridCard(Icons.hourglass_top, t("pending"), t("pending_count"),
            Colors.orange, () {}),
        _gridCard(Icons.check_circle_outline, t("completed"),
            t("completed_count"), Colors.green, () {}),
        _gridCard(Icons.home, t("households"), t("view_families"),
            Colors.blue, () {}),
        _gridCard(Icons.sync, t("sync_data"), t("last_sync"), Colors.purple,
                () {}),
        _gridCard(Icons.notifications, t("risk_alerts"), t("new_alerts"),
            Colors.red, () {}, highlight: true),
      ],
    );
  }

  Widget _gridCard(IconData icon, String title, String subtitle, Color color,
      VoidCallback onTap,
      {bool highlight = false}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: highlight
            ? const BorderSide(color: Colors.orange, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(height: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
        ),
      ),
    );
  }

  // ============================================================
  // SUPERVISOR TASKS
  // ============================================================
  Widget _buildTasksFromSupervisor(BuildContext context) {
    final t = AppLocalization.of(context).t;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.rule, color: Color(0xFF2A5A9E)),
              const SizedBox(width: 12),
              Column(children: [
                Text(t("tasks_from_supervisor"),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(t("new_task"),
                    style: const TextStyle(color: Colors.grey)),
              ]),
            ]),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => FamiliesTest()));
              },
              child: Text(t("open_families_test")),
            ),
          ],
        ),
      ),
    );
  }
}

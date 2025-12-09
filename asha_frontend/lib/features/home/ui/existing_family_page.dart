import 'package:flutter/material.dart';
import 'package:asha_frontend/data/local/dao/families_dao.dart';
import 'package:asha_frontend/data/local/dao/members_dao.dart';
import 'package:asha_frontend/data/local/dao/health_records_dao.dart';
import 'package:asha_frontend/core/services/api_service.dart';
import 'package:asha_frontend/features/family/ui/add_family_page.dart';
import 'package:asha_frontend/localization/app_localization.dart';

class ExistingFamilyPage extends StatefulWidget {
  const ExistingFamilyPage({super.key});

  @override
  State<ExistingFamilyPage> createState() => _ExistingFamilyPageState();
}

class _ExistingFamilyPageState extends State<ExistingFamilyPage>
    with SingleTickerProviderStateMixin {
  final FamiliesDao familiesDao = FamiliesDao();
  final MembersDao membersDao = MembersDao();
  final HealthRecordsDao healthDao = HealthRecordsDao();
  final ApiClient api = ApiClient();

  List<Map<String, dynamic>> offlineFamilies = [];
  List<Map<String, dynamic>> onlineFamilies = [];

  String search = "";
  bool _isLoadingOnline = false;
  String? _onlineError;

  @override
  void initState() {
    super.initState();
    loadFamilies();
  }

  // SAFE POP
  void safePopLoader() {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> loadFamilies() async {
    offlineFamilies = await familiesDao.getDownloadedFamilies();
    setState(() {});

    _isLoadingOnline = true;
    _onlineError = null;
    setState(() {});

    try {
      final serverList = await api.getOnlineFamilies();

      final localServerIds =
      offlineFamilies.map((f) => f["client_id"]).toSet();

      onlineFamilies = serverList
          .where((f) => !localServerIds.contains(f["id"]))
          .map((f) => f as Map<String, dynamic>)
          .toList();
    } catch (e) {
      final t = AppLocalization.of(context).t;
      _onlineError = t("could_not_load_online");
      onlineFamilies = [];
    }

    _isLoadingOnline = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalization.of(context).t;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Existing Families"),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Online Families"),
              Tab(text: "Offline Families"),
            ],
          ),
        ),

        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: TextField(
                decoration: InputDecoration(
                  hintText: t("search_hint"),
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (v) => setState(() => search = v.toLowerCase()),
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  _buildOnlineList(),
                  _buildOfflineList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // ONLINE LIST
  // ---------------------------------------------------
  Widget _buildOnlineList() {
    if (_isLoadingOnline) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_onlineError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_onlineError!),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: loadFamilies,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (onlineFamilies.isEmpty) {
      return const Center(child: Text("No Online Families"));
    }

    final filtered = onlineFamilies.where((f) {
      final head = (f["head_name"] ?? "").toString().toLowerCase();
      final addr = (f["address_line"] ?? "").toString().toLowerCase();
      return head.contains(search) || addr.contains(search);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final fam = filtered[index];

        return _familyCard(
          title: fam["head_name"] ?? "No Head Name",
          subtitle: fam["address_line"] ?? "",
          icon: Icons.cloud_download,
          iconColor: Colors.blue,
          onTap: () => _downloadAndOpenFamily(fam),
        );
      },
    );
  }

  // SAFE DOWNLOAD + NAVIGATE
  Future<void> _downloadAndOpenFamily(Map<String, dynamic> fam) async {
    try {
      // Show loader dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Fetch full bundle
      final fullBundle = await api.getFamilyFullBundle(fam["id"]);

      final family =
      Map<String, dynamic>.from(fullBundle["family"] ?? {});

      final members = (fullBundle["members"] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      final health = (fullBundle["health_records"] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      // Save
      await familiesDao.saveDownloadedFamilyBundle(
        family: family,
        members: members,
        healthRecords: health,
      );

      // CLOSE popup safely
      safePopLoader();

      if (!mounted) return;

      await loadFamilies();

      final localList = await familiesDao.getDownloadedFamilies();
      final local =
      localList.firstWhere((x) => x["client_id"] == fam["id"]);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddFamilyPage(existingFamily: local),
        ),
      );

      if (mounted) {
        await loadFamilies();
      }
    } catch (e) {
      safePopLoader();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // ---------------------------------------------------
  // OFFLINE LIST
  // ---------------------------------------------------
  Widget _buildOfflineList() {
    final filtered = offlineFamilies.where((f) {
      final head = (f["head_name"] ?? "").toString().toLowerCase();
      final addr = (f["address_line"] ?? "").toString().toLowerCase();
      return head.contains(search) || addr.contains(search);
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("No Offline Families"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final fam = filtered[index];

        return _familyCard(
          title: fam["head_name"] ?? "No Head Name",
          subtitle: fam["address_line"] ?? "",
          icon: Icons.edit,
          iconColor: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddFamilyPage(existingFamily: fam),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------
  // CARD WIDGET
  // ---------------------------------------------------
  Widget _familyCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(icon, color: iconColor),
        onTap: onTap,
      ),
    );
  }
}
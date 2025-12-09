import 'package:flutter/material.dart';
import 'package:asha_frontend/data/local/dao/families_dao.dart';
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

  Future<void> loadFamilies() async {
    offlineFamilies = await familiesDao.getAllFamilies();
    setState(() {});

    _isLoadingOnline = true;
    _onlineError = null;
    setState(() {});

    try {
      final serverList = await api.getOnlineFamilies();

      final localServerIds = offlineFamilies
          .where((f) => f["client_id"] != null)
          .map((f) => f["client_id"])
          .toSet();

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
          title: Text(t("existing_families")),
          bottom: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: t("online_families")),
              Tab(text: t("offline_families")),
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
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (v) => setState(() => search = v.toLowerCase()),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: TabBarView(
                children: [
                  _buildOnlineList(context),
                  _buildOfflineList(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineList(BuildContext context) {
    final t = AppLocalization.of(context).t;

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
              child: Text(t("retry")),
            ),
          ],
        ),
      );
    }

    if (onlineFamilies.isEmpty) {
      return Center(child: Text(t("no_online_families")));
    }

    final filtered = onlineFamilies.where((f) {
      final head = (f["head_name"] ?? "").toString().toLowerCase();
      final addr = (f["address_line"] ?? "").toString().toLowerCase();
      return head.contains(search) || addr.contains(search);
    }).toList();

    if (filtered.isEmpty) {
      return Center(child: Text(t("no_match")));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final fam = filtered[index];
        return _familyCard(
          title: fam["head_name"] ?? t("no_head_name"),
          subtitle: fam["address_line"] ?? "",
          icon: Icons.cloud_download,
          iconColor: Colors.blue,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddFamilyPage(existingFamily: fam),
              ),
            );
            loadFamilies();
          },
        );
      },
    );
  }

  Widget _buildOfflineList(BuildContext context) {
    final t = AppLocalization.of(context).t;

    if (offlineFamilies.isEmpty) {
      return Center(child: Text(t("no_offline_families")));
    }

    final filtered = offlineFamilies.where((f) {
      final head = (f["head_name"] ?? "").toString().toLowerCase();
      final addr = (f["address_line"] ?? "").toString().toLowerCase();
      return head.contains(search) || addr.contains(search);
    }).toList();

    if (filtered.isEmpty) {
      return Center(child: Text(t("no_match")));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final fam = filtered[index];
        return _familyCard(
          title: fam["head_name"] ?? t("no_head_name"),
          subtitle: fam["address_line"] ?? "",
          icon: Icons.edit,
          iconColor: Colors.green,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddFamilyPage(existingFamily: fam),
              ),
            );
            loadFamilies();
          },
        );
      },
    );
  }

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

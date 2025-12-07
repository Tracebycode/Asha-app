import 'package:flutter/material.dart';
import 'package:asha_frontend/data/local/dao/families_dao.dart';
import 'package:asha_frontend/core/services/api_service.dart';
import 'package:asha_frontend/features/family/ui/add_family_page.dart';

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
    // 1️⃣ Load offline families (local SQLite)
    offlineFamilies = await familiesDao.getAllFamilies();
    setState(() {});

    // 2️⃣ Load online families from server
    _isLoadingOnline = true;
    _onlineError = null;
    setState(() {});

    try {
      final serverList = await api.getOnlineFamilies();

      // Local server IDs to skip online duplicates
      final localServerIds = offlineFamilies
          .where((f) => f["client_id"] != null)
          .map((f) => f["client_id"])
          .toSet();

      onlineFamilies = serverList
          .where((f) => !localServerIds.contains(f["id"]))
          .map((f) => f as Map<String, dynamic>)
          .toList();
    } catch (e) {
      _onlineError = "Could not load online families";
      onlineFamilies = [];
    }

    _isLoadingOnline = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search by Head Name / Address",
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

  // -------------------------------
  // ONLINE FAMILIES LIST
  // -------------------------------
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

    if (filtered.isEmpty) {
      return const Center(child: Text("No matching results"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final fam = filtered[index];
        return _familyCard(
          title: fam["head_name"] ?? "No head name",
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

  // -------------------------------
  // OFFLINE FAMILIES LIST
  // -------------------------------
  Widget _buildOfflineList() {
    if (offlineFamilies.isEmpty) {
      return const Center(child: Text("No Offline Families"));
    }

    final filtered = offlineFamilies.where((f) {
      final head = (f["head_name"] ?? "").toString().toLowerCase();
      final addr = (f["address_line"] ?? "").toString().toLowerCase();
      return head.contains(search) || addr.contains(search);
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("No matching results"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final fam = filtered[index];
        return _familyCard(
          title: fam["head_name"] ?? "No head name",
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

  // -------------------------------
  // REUSABLE FAMILY CARD WIDGET
  // -------------------------------
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

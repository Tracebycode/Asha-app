import 'package:flutter/material.dart';
import 'package:asha_frontend/data/local/dao/families_dao.dart';
import 'package:asha_frontend/data/local/dao/members_dao.dart';
import 'package:asha_frontend/data/local/dao/health_records_dao.dart';
import 'package:asha_frontend/data/repositories/members_repository.dart';
import 'package:uuid/uuid.dart';

class FamiliesTest extends StatefulWidget {
  const FamiliesTest({super.key});

  @override
  State<FamiliesTest> createState() => _FamiliesTestState();
}

class _FamiliesTestState extends State<FamiliesTest> {
  final familiesDao = FamiliesDao();
  final membersRepo = MembersRepository(MembersDao());
  final healthDao = HealthRecordsDao();

  List<Map<String, dynamic>> families = [];
  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> healthRecords = [];

  // ---------------------------------------------------------
  // TEST 1 — SAVE FAMILY + MEMBERS
  // ---------------------------------------------------------
  Future<void> _testSaveFamilyAndMembers() async {
    final familyClientId = "fam_${const Uuid().v4()}";

    await familiesDao.insertFamily({
      "client_id": familyClientId,
      "address_line": "Test Address",
      "landmark": "Test Landmark",
      "phone": "9999999999",
      "device_created_at": DateTime.now().toIso8601String(),
      "device_updated_at": DateTime.now().toIso8601String(),
      "is_dirty": 1,
      "dirty_operation": "insert",
      "local_updated_at": DateTime.now().toIso8601String(),
    });

    print("🔥 FAMILY SAVED => $familyClientId");

    await membersRepo.createMember(
      familyClientId: familyClientId,
      member: {
        "name": "Rohan",
        "age": 30,
        "gender": "Male",
        "relation": "Head",
        "aadhaar": "1234",
        "phone": "9999999999",
      },
    );

    await membersRepo.createMember(
      familyClientId: familyClientId,
      member: {
        "name": "Priya",
        "age": 25,
        "gender": "Female",
        "relation": "Wife",
        "aadhaar": "5678",
        "phone": "8888888888",
      },
    );

    print("🔥 2 MEMBERS SAVED for $familyClientId");

    await _refreshViewer();
  }

  // ---------------------------------------------------------
  // TEST 2 — SAVE HEALTH RECORD
  // ---------------------------------------------------------
  Future<void> _testSaveHealthRecord() async {
    final recordId = "hr_test_${DateTime.now().millisecondsSinceEpoch}";

    final dummyRecord = {
      "id": recordId,
      "member_client_id": "mem_test_123",
      "visit_type": "ANC",
      "data_json": {
        "bp": "120/80",
        "hb": "11",
        "weight": "52",
        "notes": "Test ANC health record",
      },
      "is_dirty": 1,
      "dirty_operation": "insert",
      "device_created_at": DateTime.now().toIso8601String(),
      "device_updated_at": DateTime.now().toIso8601String(),
      "local_updated_at": DateTime.now().toIso8601String(),
    };

    await healthDao.insertRecord(dummyRecord);

    print("💾 HEALTH RECORD SAVED => $recordId");

    await _refreshViewer();
  }

  // ---------------------------------------------------------
  // REFRESH LOCAL DB VIEWER
  // ---------------------------------------------------------
  Future<void> _refreshViewer() async {
    families = await familiesDao.getAllFamilies();
    members = await MembersDao().getAllMembers();
    healthRecords = await healthDao.getAllRecords();

    print("📌 Families => $families");
    print("📌 Members => $members");
    print("📌 Health => $healthRecords");

    setState(() {});
  }

  // ---------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _refreshViewer();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Families Test"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Families"),
              Tab(text: "Members"),
              Tab(text: "Health Records"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildListView(families),
            _buildListView(members),
            _buildListView(healthRecords),
          ],
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              heroTag: "1",
              onPressed: _testSaveFamilyAndMembers,
              label: const Text("Test Family+Members"),
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              heroTag: "2",
              onPressed: _testSaveHealthRecord,
              label: const Text("Test Health Record"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const Center(child: Text("No data"));
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (_, i) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            data[i].toString(),
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }
}

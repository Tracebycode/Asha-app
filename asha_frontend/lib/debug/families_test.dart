import 'package:flutter/material.dart';
import 'package:asha_frontend/data/local/dao/families_dao.dart';
import 'package:asha_frontend/data/local/dao/members_dao.dart';
import 'package:asha_frontend/data/local/dao/health_records_dao.dart';
import 'package:asha_frontend/data/repositories/members_repository.dart';
import 'package:asha_frontend/sync/sync_service.dart';
import 'package:asha_frontend/sync/member_sync_service.dart';
import 'package:asha_frontend/data/local/db/app_db.dart';
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
  final syncService = SyncService();

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
  Future<void> _createAndSync() async {
    print("🚀 Creating dummy family + members...");

    await _createDummyFamilyWithMembers();
    await _refreshViewer();

    print("🔄 Syncing FAMILY...");
    await syncService.syncFamilies();

    print("🔄 Syncing MEMBERS...");
    await MemberSyncService().syncMembers();

    print("✅ DONE: FAMILY + MEMBERS SYNCED");
    await _refreshViewer();
  }

  Future<void> _createDummyFamilyWithMembers() async {
    final familiesDao = FamiliesDao();
    final membersDao = MembersDao();

    // 🔥 Use REAL VALUES from your screenshot
    const phcId = "6fa8051e-a511-4788-8c12-bfe2e71ce025";
    const areaId = "3657fe1d-9a77-4488-9028-160b844a5042";
    const ashaId = "1b53ef62-d4a5-4dd7-98a5-cc61ed2ca003";
    const anmId = "611e2f26-9212-4f54-a7a3-3c7906052720";


    // 1) Create dummy family
    final famId = "fam_test_${DateTime.now().millisecondsSinceEpoch}";

    await familiesDao.insertFamily({
      "client_id": famId,
      "address_line": "Test Sync Address",
      "landmark": "Test Landmark",
      "phone": "1111111111",

      // REQUIRED SERVER FIELDS 👇
      "phc_id": "6fa8051e-a511-4788-8c12-bfe2e71ce025",
      "area_id":"3657fe1d-9a77-4488-9028-160b844a5042",
      "asha_worker_id":"1b53ef62-d4a5-4dd7-98a5-cc61ed2ca003",
      "anm_worker_id": "611e2f26-9212-4f54-a7a3-3c7906052720",

      "device_created_at": DateTime.now().toIso8601String(),
      "device_updated_at": DateTime.now().toIso8601String(),
      "is_dirty": 1,
      "dirty_operation": "insert",
      "local_updated_at": DateTime.now().toIso8601String(),
    });

    // 2) Add offline members
    await membersDao.insertMember({
      "client_id": "mem_test_1",
      "family_client_id": famId,
      "family_id": null,
      "name": "Rohan Test",
      "age": 30,
      "gender": "Male",
      "relation": "Head",
      "aadhaar": "252236259524",
      "phone": "9999999999",
      "is_alive": 1,
      "dob": null,
      "is_dirty": 1,
      "dirty_operation": "insert",
      "device_created_at": DateTime.now().toIso8601String(),
      "device_updated_at": DateTime.now().toIso8601String(),
      "local_updated_at": DateTime.now().toIso8601String(),
    });

    await membersDao.insertMember({
      "client_id": "mem_test_2",
      "family_client_id": famId,
      "family_id": null,
      "name": "Priya Test",
      "age": 25,
      "gender": "Female",
      "relation": "Wife",
      "aadhaar": "252236259525",   // 12 digits required!
      "phone": "8888888888",
      "is_alive": 1,
      "dob": null,
      "is_dirty": 1,
      "dirty_operation": "insert",
      "device_created_at": DateTime.now().toIso8601String(),
      "device_updated_at": DateTime.now().toIso8601String(),
      "local_updated_at": DateTime.now().toIso8601String(),
    });


    print("🔥 Local dummy family created => $famId");

    final members = await membersDao.getMembersByFamily(famId);
    print("👨‍👩‍👧 Members => $members");
  }
  Future<void> _wipeLocalDb() async {
    final db = await AppDatabase.instance.database;
    await db.delete("families");
    await db.delete("family_members");
    await db.delete("health_records");
    print("🧹 LOCAL DB WIPED");
    await _refreshViewer();
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
              onPressed: _createDummyFamilyWithMembers,
              label: const Text("Create Dummy Family"),
              icon: const Icon(Icons.add_home),
            ),
            const SizedBox(height: 12),

            FloatingActionButton.extended(
              heroTag: "2",
              onPressed: _createAndSync,
              label: const Text("SYNC FAMILY + MEMBERS"),
              icon: const Icon(Icons.sync),
            ),
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
            ElevatedButton(
              onPressed: () async {
                await syncService.syncFamilies();
              },
              child: const Text("RUN FAMILY SYNC"),
            ),
            ElevatedButton(
              onPressed: () async {
                await MemberSyncService().syncMembers();
              },
              child: const Text("SYNC MEMBERS"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _createDummyFamilyWithMembers();
              },
              child: const Text("CREATE DUMMY FAMILY + MEMBERS"),
            ),
            ElevatedButton(
              onPressed: _wipeLocalDb,
              child: const Text("WIPE LOCAL DB"),
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

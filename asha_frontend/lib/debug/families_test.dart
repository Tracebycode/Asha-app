import 'package:flutter/material.dart';
import 'package:asha_frontend/data/local/dao/families_dao.dart';
import 'package:asha_frontend/data/local/dao/members_dao.dart';
import 'package:asha_frontend/data/local/dao/health_records_dao.dart';
import 'package:asha_frontend/data/repositories/members_repository.dart';
import 'package:asha_frontend/sync/sync_families_service.dart';
import 'package:asha_frontend/sync/member_sync_service.dart';
import 'package:asha_frontend/sync/health_record_sync_service.dart';
import 'package:asha_frontend/data/local/db/app_db.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';


class FamiliesTest extends StatefulWidget {
  const FamiliesTest({super.key});

  @override
  State<FamiliesTest> createState() => _FamiliesTestState();
}

class _FamiliesTestState extends State<FamiliesTest> {
  final familiesDao = FamiliesDao();
  final membersRepo = MembersRepository(MembersDao());
  final healthDao = HealthRecordsDao();

  // ✔ FIXED — proper sync service instances
  final syncFamilies = SyncFamiliesService();
  final syncMembers = MemberSyncService();
  final syncHealth = HealthRecordSyncService();

  List<Map<String, dynamic>> families = [];
  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> healthRecords = [];

  // ---------------------------------------------------------
  // TEST 1 — SAVE FAMILY + MEMBERS
  // ---------------------------------------------------------
  Future<void> _testSaveFamilyAndMembers() async {
    final familiesDao = FamiliesDao();
    final membersRepo = MembersRepository(MembersDao());

    final String localFamilyId = const Uuid().v4();
    final now = DateTime.now().toIso8601String();

    // 1) CREATE FAMILY
    await familiesDao.insertFamily({
      "id": localFamilyId,
      "client_id": null,

      "address_line": "Test Address",
      "landmark": "Test Landmark",
      "phone": "9999999999",

      "phc_id": "6fa8051e-a511-4788-8c12-bfe2e71ce025",
      "area_id": "3657fe1d-9a77-4488-9028-160b844a5042",
      "asha_worker_id": "1b53ef62-d4a5-4dd7-98a5-cc61ed2ca003",
      "anm_worker_id": "611e2f26-9212-4f54-a7a3-3c7906052720",

      "device_created_at": now,
      "device_updated_at": now,
      "is_dirty": 1,
      "dirty_operation": "insert",
      "local_updated_at": now,
    });

    print("🔥 FAMILY CREATED => $localFamilyId");

    // 2) ADD MEMBERS
    await membersRepo.createMember(
      localFamilyId: localFamilyId,
      member: {
        "name": "Rohan",
        "age": 30,
        "gender": "Male",
        "relation": "Head",
        "aadhaar": "123456789012",
        "phone": "9999999999",
        "dob": null,
      },
    );

    await membersRepo.createMember(
      localFamilyId: localFamilyId,
      member: {
        "name": "Priya",
        "age": 25,
        "gender": "Female",
        "relation": "Wife",
        "aadhaar": "123456789013",
        "phone": "8888888888",
        "dob": null,
      },
    );

    print("🔥 Members CREATED for => $localFamilyId");

    await _refreshViewer();
  }

  // ---------------------------------------------------------
  // TEST 2 — SAVE HEALTH RECORD LOCALLY
  // ---------------------------------------------------------
  Future<void> _testSaveHealthRecord() async {
    print("🩺 TESTING LOCAL HEALTH RECORD SAVE...");

    // 1) Get ANY synced/unsynced member
    final allMembers = await MembersDao().getAllMembers();
    if (allMembers.isEmpty) {
      print("❌ No members! Create dummy family first.");
      return;
    }

    final m = allMembers.first;
    final localMemberId = m["id"];          // LOCAL MEMBER ID
    final localFamilyId = m["family_id"];   // LOCAL FAMILY ID

    final recordId = "hr_${const Uuid().v4()}";
    final now = DateTime.now().toIso8601String();

    await healthDao.insertRecord({
      "id": recordId,
      "client_id": null,

      "family_id": localFamilyId,
      "family_client_id": m["family_client_id"],

      "member_id": localMemberId,
      "member_client_id": m["client_id"],

      "phc_id": m["phc_id"] ?? "6fa8051e-a511-4788-8c12-bfe2e71ce025",
      "area_id": m["area_id"] ?? "3657fe1d-9a77-4488-9028-160b844a5042",
      "asha_worker_id": "1b53ef62-d4a5-4dd7-98a5-cc61ed2ca003",
      "anm_worker_id": "611e2f26-9212-4f54-a7a3-3c7906052720",

      "task_id": null,
      "visit_type": "ANC",

      "data_json": jsonEncode({
        "bp": "120/80",
        "hb": "11",
        "weight": "55",
        "notes": "Test health from test page"
      }),

      "device_created_at": now,
      "device_updated_at": now,

      "is_dirty": 1,
      "dirty_operation": "insert",
      "local_updated_at": now
    });

    print("💾 HEALTH SAVED → $recordId");

    await _refreshViewer();
  }



  // ---------------------------------------------------------
  // REFRESH VIEWER
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
  // FULL CREATE + SYNC FLOW
  // ---------------------------------------------------------
  Future<void> _createAndSync() async {
    print("🚀 Creating dummy family + members...");

    await _createDummyFamilyWithMembers();
    await _refreshViewer();

    // ⭐ AUTO CREATE HEALTH RECORD
    final firstMember = members.first;
    await healthDao.insertRecord({
      "id": "hr_${const Uuid().v4()}",
      "client_id": null,
      "family_id": firstMember["family_id"],
      "family_client_id": firstMember["family_client_id"],
      "member_id": firstMember["id"],
      "member_client_id": firstMember["client_id"],
      "visit_type": "ANC",
      "task_id": null,
      "data_json": jsonEncode({
        "bp": "120/80",
        "hb": "11",
        "weight": "58",
        "notes": "Auto-created test health record"
      }),
      "is_dirty": 1,
      "dirty_operation": "insert",
      "device_created_at": DateTime.now().toIso8601String(),
      "device_updated_at": DateTime.now().toIso8601String(),
      "local_updated_at": DateTime.now().toIso8601String()
    });

    await _refreshViewer();

    print("🔄 Syncing FAMILY...");
    await syncFamilies.syncFamilies();

    print("🔄 Syncing MEMBERS...");
    await syncMembers.syncMembers();

    print("🔄 Syncing HEALTH...");
    await syncHealth.syncHealthRecords();

    print("✅ DONE: ALL SYNCED");
    await _refreshViewer();
  }


  // ---------------------------------------------------------
  // CREATE DUMMY DATA
  // ---------------------------------------------------------
  Future<void> _createDummyFamilyWithMembers() async {
    final familiesDao = FamiliesDao();
    final membersRepo = MembersRepository(MembersDao());

    final String localFamilyId = const Uuid().v4();
    final now = DateTime.now().toIso8601String();

    await familiesDao.insertFamily({
      "id": localFamilyId,
      "client_id": null,

      "address_line": "Dummy Address",
      "landmark": "Dummy Landmark",
      "phone": "1111111111",

      "phc_id": "6fa8051e-a511-4788-8c12-bfe2e71ce025",
      "area_id": "3657fe1d-9a77-4488-9028-160b844a5042",
      "asha_worker_id": "1b53ef62-d4a5-4dd7-98a5-cc61ed2ca003",
      "anm_worker_id": "611e2f26-9212-4f54-a7a3-3c7906052720",

      "device_created_at": now,
      "device_updated_at": now,
      "is_dirty": 1,
      "dirty_operation": "insert",
      "local_updated_at": now,
    });

    // Add 2 dummy members
    await membersRepo.createMember(
      localFamilyId: localFamilyId,
      member: {
        "name": "Dummy 1",
        "age": 28,
        "gender": "Male",
        "relation": "Head",
        "aadhaar": "123456781111",
        "phone": "9000000000",
      },
    );

    await membersRepo.createMember(
      localFamilyId: localFamilyId,
      member: {
        "name": "Dummy 2",
        "age": "25",
        "gender": "Female",
        "relation": "Wife",
        "aadhaar": "123456781112",
        "phone": "9000000001",
      },
    );

    print("🔥 Created Dummy Family + Members => $localFamilyId");
    await _refreshViewer();
  }

  // ---------------------------------------------------------
  // WIPE DB
  // ---------------------------------------------------------
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

  // ---------------------------------------------------------
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
              label: const Text("SYNC FAMILY + MEMBERS + HEALTH"),
              icon: const Icon(Icons.sync),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () async {
                await syncFamilies.syncFamilies();
              },
              child: const Text("RUN FAMILY SYNC"),
            ),

            ElevatedButton(
              onPressed: () async {
                await syncMembers.syncMembers();
              },
              child: const Text("SYNC MEMBERS"),
            ),

            ElevatedButton(
              onPressed: () async {
                await syncHealth.syncHealthRecords();
              },
              child: const Text("SYNC HEALTH"),
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

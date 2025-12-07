import 'package:uuid/uuid.dart';
import '../local/dao/health_records_dao.dart';
import '../local/dao/members_dao.dart';
import '../local/dao/families_dao.dart';

class HealthRecordsRepository {
  final HealthRecordsDao dao;
  final MembersDao membersDao;
  final FamiliesDao familiesDao;

  HealthRecordsRepository(
      this.dao,
      this.membersDao,
      this.familiesDao,
      );

  // -------------------------------------------------------------
  // 1️⃣ SAVE HEALTH RECORD (LOCAL ONLY - OFFLINE)
  // -------------------------------------------------------------
  Future<String> saveHealthRecord({
    required String localMemberId,
    required String visitType,
    required Map<String, dynamic> dataJson,
    String? taskId,
  }) async {
    final now = DateTime.now().toIso8601String();
    final localHealthId = const Uuid().v4();

    // -----------------------------------------------------
    // 1. FETCH THE LOCAL MEMBER
    // -----------------------------------------------------
    final member = await membersDao.getMemberByLocalId(localMemberId);
    if (member == null) {
      throw Exception("Member not found: $localMemberId");
    }

    // CORRECT MAPPING:
    final localFamilyId = member["family_client_id"]; // LOCAL family
    final serverFamilyId = member["family_id"];       // SERVER family
    final serverMemberId = member["client_id"];       // SERVER member

    // -----------------------------------------------------
    // 2. FETCH LOCAL FAMILY
    // -----------------------------------------------------
    final families = await familiesDao.getAllFamilies();
    final family = families.firstWhere(
          (f) => f["id"] == localFamilyId,
      orElse: () => throw Exception("Family not found: $localFamilyId"),
    );

    final phcId = family["phc_id"];
    final areaId = family["area_id"];
    final ashaId = family["asha_worker_id"];
    final anmId = family["anm_worker_id"];

    // -----------------------------------------------------
    // 3. BUILD CORRECT HEALTH RECORD (consistent with DAO)
    // -----------------------------------------------------
    final record = {
      "id": localHealthId,       // LOCAL
      "client_id": null,         // SERVER after sync

      // ---------------------------------------------------
      // Correct relationship mapping
      // ---------------------------------------------------
      "member_id": serverMemberId,        // SERVER MEMBER ID (can be null before sync)
      "member_client_id": localMemberId,  // LOCAL MEMBER ID

      "family_id": serverFamilyId,        // SERVER FAMILY ID (can be null before sync)
      "family_client_id": localFamilyId,  // LOCAL FAMILY ID

      "phc_id": phcId,
      "area_id": areaId,
      "asha_worker_id": ashaId,
      "anm_worker_id": anmId,

      "task_id": taskId,
      "visit_type": visitType,
      "data_json": dataJson,  // DAO will encode JSON

      "device_created_at": now,
      "device_updated_at": now,
      "local_updated_at": now,
      "is_dirty": 1,
      "dirty_operation": "insert",
    };

    await dao.insertRecord(record);

    print("💾 HEALTH RECORD SAVED LOCALLY: $localHealthId");
    return localHealthId;
  }

  // -------------------------------------------------------------
  // 2️⃣ GETTERS
  // -------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getAllRecords() {
    return dao.getAllRecords();
  }

  Future<List<Map<String, dynamic>>> getUnsynced() {
    return dao.getUnsyncedRecords();
  }
}

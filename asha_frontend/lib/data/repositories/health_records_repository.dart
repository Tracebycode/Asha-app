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

  Future<String> saveHealthRecord({
    required String localMemberId,       // LOCAL MEMBER ID
    required String visitType,           // ANC / PNC / NCD / TB / ...
    required Map<String, dynamic> dataJson,
    String? taskId,                      // optional
  }) async {
    final String localHealthId = const Uuid().v4();
    final now = DateTime.now().toIso8601String();

    // -----------------------------------------------------
    // 1. FETCH MEMBER (must use LOCAL member_id)
    // -----------------------------------------------------
    final allMembers = await membersDao.getAllMembers();
    final member = allMembers.firstWhere(
          (m) => m['id'] == localMemberId,
      orElse: () => throw Exception("Member not found: $localMemberId"),
    );

    final localFamilyId = member['family_id'];              // LOCAL FK
    final serverMemberId = member['client_id'];             // SERVER FK
    final serverFamilyId = member['family_client_id'];      // SERVER FK

    // -----------------------------------------------------
    // 2. FETCH FAMILY
    // -----------------------------------------------------
    final allFamilies = await familiesDao.getAllFamilies();
    final family = allFamilies.firstWhere(
          (f) => f['id'] == localFamilyId,
      orElse: () => throw Exception("Family not found: $localFamilyId"),
    );

    final phcId = family['phc_id'];
    final areaId = family['area_id'];
    final ashaId = family['asha_worker_id'];
    final anmId = family['anm_worker_id'];

    // -----------------------------------------------------
    // 3. BUILD HEALTH RECORD (LOCAL)
    // -----------------------------------------------------
    final record = {
      "id": localHealthId,               // LOCAL PK
      "client_id": null,                 // SERVER UUID after sync

      // --- Linking ---
      "member_id": localMemberId,        // LOCAL PK
      "member_client_id": serverMemberId, // SERVER PK (nullable)

      "family_id": localFamilyId,        // LOCAL FK
      "family_client_id": serverFamilyId, // SERVER FK (nullable)

      "phc_id": phcId,
      "area_id": areaId,
      "asha_worker_id": ashaId,
      "anm_worker_id": anmId,

      "task_id": taskId,                 // can be null
      "visit_type": visitType,
      "data_json": dataJson,             // stored as JSON by DAO

      // --- Sync meta ---
      "device_created_at": now,
      "device_updated_at": now,
      "local_updated_at": now,
      "is_dirty": 1,
      "dirty_operation": "insert",
    };

    await dao.insertRecord(record);

    print("💾 HEALTH RECORD SAVED => $localHealthId");
    return localHealthId;
  }

  Future<List<Map<String, dynamic>>> getAllRecords() async {
    return await dao.getAllRecords();
  }

  Future<List<Map<String, dynamic>>> getUnsynced() async {
    return await dao.getUnsyncedRecords();
  }
}

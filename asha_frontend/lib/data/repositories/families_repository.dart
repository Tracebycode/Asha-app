import 'package:uuid/uuid.dart';
import '../local/dao/families_dao.dart';
import '../local/dao/members_dao.dart';
import '../local/dao/health_records_dao.dart';
import 'package:asha_frontend/core/services/api_service.dart';

class FamilyInput {
  final String areaId;
  final String addressLine;
  final String landmark;

  FamilyInput({
    required this.areaId,
    required this.addressLine,
    required this.landmark,
  });
}

class FamiliesRepository {
  final FamiliesDao familiesDao;
  final MembersDao membersDao;
  final HealthRecordsDao healthDao;
  final ApiClient api;

  FamiliesRepository({
    required this.familiesDao,
    required this.membersDao,
    required this.healthDao,
    required this.api,
  });

  // ------------------------------------------------------------------
  // 1️⃣ CREATE LOCAL FAMILY (OFFLINE)
  // ------------------------------------------------------------------
  Future<String> create(
      FamilyInput input, {
        required String phcId,
        required String ashaWorkerId,
        required String? anmWorkerId,
      }) async {
    final now = DateTime.now().toIso8601String();
    final String localId = const Uuid().v4();

    await familiesDao.insertFamily({
      "id": localId,
      "client_id": null,

      "area_id": input.areaId,
      "phc_id": phcId,
      "asha_worker_id": ashaWorkerId,
      "anm_worker_id": anmWorkerId,

      "address_line": input.addressLine,
      "landmark": input.landmark,

      "device_created_at": now,
      "device_updated_at": now,
      "is_dirty": 1,
      "dirty_operation": "insert",
      "local_updated_at": now,
    });

    return localId;
  }

  // ------------------------------------------------------------------
  // 2️⃣ RETURN DOWNLOADED FAMILIES (LOCAL)
  // ------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getDownloadedFamilies() {
    return familiesDao.getDownloadedFamilies();
  }

  // ------------------------------------------------------------------
  // 3️⃣ SEARCH ONLINE FAMILIES
  // ------------------------------------------------------------------
  Future<List<dynamic>> searchOnlineFamilies(String search) async {
    final result = await api.get("/families/search?search=$search&page=1&limit=100");
    return result["families"];
  }

  // ------------------------------------------------------------------
  // 4️⃣ MERGED RESULT FOR UI
  // ------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getMergedFamilies(String search) async {
    final online = await searchOnlineFamilies(search);
    final downloaded = await familiesDao.getDownloadedFamilies();

    final downloadedIds = downloaded.map((f) => f["client_id"]).toSet();

    List<Map<String, dynamic>> result = [];

    for (var f in online) {
      final serverId = f["id"];

      result.add({
        "id": serverId,
        "address": f["address_line"],
        "landmark": f["landmark"],
        "head_name": f["head_name"],
        "head_phone": f["head_phone"],
        "updated_at": f["updated_at"],

        "isDownloaded": downloadedIds.contains(serverId),

        "localFamilyId": downloaded
            .firstWhere(
              (x) => x["client_id"] == serverId,
          orElse: () => {"id": null},
        )["id"],
      });
    }

    return result;
  }

  // ------------------------------------------------------------------
  // 5️⃣ DOWNLOAD FULL FAMILY FROM SERVER
  // ------------------------------------------------------------------
  Future<Map<String, dynamic>> downloadFullFamily(String serverFamilyId) async {
    final resp = await api.get("/families/$serverFamilyId/full");
    return {
      "family": resp["family"],
      "members": resp["members"],
      "health_records": resp["health_records"],
    };
  }

  // ------------------------------------------------------------------
  // 6️⃣ SAVE FULL DOWNLOAD TO SQLITE (IN ONE TRANSACTION)
  // ------------------------------------------------------------------
  Future<void> saveDownloadedBundle(Map<String, dynamic> bundle) async {
    await familiesDao.saveDownloadedFamilyBundle(
      family: bundle["family"],
      members: bundle["members"],
      healthRecords: bundle["health_records"],
    );
  }
}

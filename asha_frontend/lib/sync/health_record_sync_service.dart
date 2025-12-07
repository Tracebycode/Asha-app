import 'dart:convert';
import 'package:asha_frontend/data/local/dao/health_records_dao.dart';
import 'package:asha_frontend/core/services/api_service.dart';

class HealthRecordSyncService {
  final HealthRecordsDao healthDao = HealthRecordsDao();
  final ApiClient api = ApiClient();

  Future<void> syncHealthRecords() async {
    final unsynced = await healthDao.getUnsyncedRecords();

    if (unsynced.isEmpty) {
      print("🔄 No health records to sync.");
      return;
    }

    print("🔄 Syncing ${unsynced.length} health records...\n");

    for (final row in unsynced) {
      final localHealthId = row["id"];

      // SERVER IDs
      final serverMemberId = row["member_id"];     // SERVER MEMBER ID
      final serverFamilyId = row["family_id"];     // SERVER FAMILY ID

      if (serverMemberId == null) {
        print("⚠ Skipping $localHealthId → MEMBER NOT SYNCED");
        continue;
      }

      if (serverFamilyId == null) {
        print("⚠ Skipping $localHealthId → FAMILY NOT SYNCED");
        continue;
      }

      final jsonData = row["data_json"] is String
          ? jsonDecode(row["data_json"])
          : row["data_json"];

      final payload = {
        "member_id": serverMemberId,
        "task_id": row["task_id"],
        "visit_type": row["visit_type"],
        "data_json": jsonData,
      };

      print("📤 Uploading HEALTH RECORD → $localHealthId");

      try {
        // ApiClient now accepts a single map
        final data = await api.createHealthRecordFromLocal(payload);
        print("🩺 SERVER HEALTH RESPONSE: $data");  // <--- ADD THIS

        final record = data["record"];
        if (record == null) {
          print("❌ ERROR: Backend did not return 'record'");
          continue;
        }

        final serverHealthId = record["id"];
        if (serverHealthId == null) {
          print("❌ ERROR: record['id'] missing in backend response");
          continue;
        }

        print("🌐 HEALTH SYNCED → $localHealthId → $serverHealthId");

        await healthDao.updateAfterSync(
          localHealthId,
          {
            "client_id": serverHealthId,
            "is_dirty": 0,
            "dirty_operation": "synced",
            "local_updated_at": DateTime.now().toIso8601String(),
          },
        );
      } catch (e) {
        print("💥 Exception syncing $localHealthId → $e");
      }
    }

    print("✅ Health Record Sync Complete");
  }
}

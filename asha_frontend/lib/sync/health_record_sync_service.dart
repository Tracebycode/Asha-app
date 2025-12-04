import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:asha_frontend/data/local/dao/health_records_dao.dart';
import 'package:asha_frontend/core/services/api_service.dart';

class HealthRecordSyncService {
  final HealthRecordsDao healthDao = HealthRecordsDao();
  final ApiService api = ApiService();

  Future<void> syncHealthRecords() async {
    final unsynced = await healthDao.getUnsyncedRecords();

    if (unsynced.isEmpty) {
      print("🔄 No health records to sync.");
      return;
    }

    print("🔄 Syncing ${unsynced.length} health records...\n");

    for (final row in unsynced) {
      final String localHealthId = row["id"];
      final String? serverMemberId = row["member_client_id"];
      final String? serverFamilyId = row["family_client_id"];

      // --------------------------------------------------
      // 1) Member must be synced first
      // --------------------------------------------------
      if (serverMemberId == null) {
        print("⚠ Skipping $localHealthId → member NOT synced yet");
        continue;
      }

      // --------------------------------------------------
      // 2) Family must be synced first
      // --------------------------------------------------
      if (serverFamilyId == null) {
        print("⚠ Skipping $localHealthId → family NOT synced yet");
        continue;
      }

      // --------------------------------------------------
      // 3) Prepare payload
      // --------------------------------------------------
      final dataJson = row["data_json"] is String
          ? jsonDecode(row["data_json"])
          : row["data_json"];

      final payload = {
        "member_id": serverMemberId,
        "task_id": row["task_id"],
        "visit_type": row["visit_type"],
        "data_json": dataJson,
      };

      print("📤 Uploading HEALTH RECORD → $localHealthId");

      try {
        // --------------------------------------------------
        // 4) SEND TO BACKEND
        // --------------------------------------------------
        final http.Response resp =
        await api.createHealthRecordFromLocal(payload);

        if (resp.statusCode == 200 || resp.statusCode == 201) {
          final json = jsonDecode(resp.body);

          final record = json["record"] ?? json;

          final String serverHealthId = record["id"];

          print("🌐 HEALTH SYNCED → $localHealthId → $serverHealthId");

          // --------------------------------------------------
          // 5) FULL UPDATE IN LOCAL DB
          // --------------------------------------------------
          await healthDao.updateAfterSync(localHealthId, {
            "client_id": serverHealthId,

            "phc_id": record["phc_id"],
            "asha_worker_id": record["asha_worker_id"],
            "anm_worker_id": record["anm_worker_id"],
            "area_id": record["area_id"],

            "synced_at": DateTime.now().toIso8601String(),
            "is_dirty": 0,
            "dirty_operation": "synced",
          });
        }

        // --------------------------------------------------
        // ❌ FAILURE
        // --------------------------------------------------
        else {
          print("❌ Failed → ${resp.statusCode} | ${resp.body}");
        }
      } catch (e) {
        print("💥 Exception syncing $localHealthId → $e");
      }
    }

    print("✅ Health Record Sync Complete");
  }
}

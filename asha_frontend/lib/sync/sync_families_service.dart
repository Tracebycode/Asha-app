import 'dart:convert';
import 'package:asha_frontend/data/local/dao/families_dao.dart';
import 'package:asha_frontend/data/local/dao/members_dao.dart';
import 'package:asha_frontend/data/local/dao/health_records_dao.dart';
import 'package:asha_frontend/core/services/api_service.dart';

class SyncFamiliesService {
  final FamiliesDao familiesDao = FamiliesDao();
  final MembersDao membersDao = MembersDao();
  final HealthRecordsDao healthDao = HealthRecordsDao();
  final ApiClient api = ApiClient();

  Future<void> syncFamilies() async {
    final unsynced = await familiesDao.getUnsyncedFamilies();

    if (unsynced.isEmpty) {
      print("🔄 No families to sync");
      return;
    }

    print("🔄 Syncing ${unsynced.length} families...\n");

    for (final row in unsynced) {
      final String localFamilyId = row["id"];

      print("📤 Sync → FAMILY local_id = $localFamilyId");

      try {
        // ---------------------------------------------------------
        // 1️⃣ SEND TO SERVER
        // ---------------------------------------------------------
        final Map<String, dynamic> data =
        await api.createFamilyFromLocal(row);

        // Get server ID robustly
        final newServerId =
            data["family"]?["id"] ??
                data["id"] ??
                data["family_id"];

        if (newServerId == null) {
          print("❌ SERVER DID NOT RETURN FAMILY ID");
          continue;
        }

        print(
            "🌐 FAMILY SYNCED: local($localFamilyId) → server($newServerId)");

        // ---------------------------------------------------------
        // 2️⃣ UPDATE FAMILY (MARK AS SYNCED)
        // ---------------------------------------------------------
        await familiesDao.markAsSynced(
          localId: localFamilyId,
          serverId: newServerId,
        );

        // ---------------------------------------------------------
        // 3️⃣ UPDATE MEMBERS WITH SERVER FAMILY ID
        // ---------------------------------------------------------
        await membersDao.updateFamilyServerId(
          localFamilyId: localFamilyId,
          serverFamilyId: newServerId,
        );

        print("👨‍👩‍👧 Members updated → server family_id = $newServerId");

        // ---------------------------------------------------------
        // 4️⃣ UPDATE HEALTH RECORDS WITH SERVER FAMILY ID
        // ---------------------------------------------------------
        await healthDao.updateFamilyServerIdOnHealth(
          localFamilyId: localFamilyId,
          serverFamilyId: newServerId,
        );

        print("🩺 Health updated → server family_id = $newServerId\n");
      } catch (e) {
        print("💥 FAMILY SYNC ERROR ($localFamilyId): $e");
      }
    }

    print("✅ FAMILY SYNC COMPLETE\n\n");
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:asha_frontend/data/local/dao/families_dao.dart';
import 'package:asha_frontend/data/local/dao/members_dao.dart';
import 'package:asha_frontend/data/local/dao/health_records_dao.dart';
import 'package:asha_frontend/core/services/api_service.dart';

class SyncFamiliesService {
  final FamiliesDao familiesDao = FamiliesDao();
  final MembersDao membersDao = MembersDao();
  final HealthRecordsDao healthDao = HealthRecordsDao();
  final ApiService api = ApiService();

  Future<void> syncFamilies() async {
    final unsynced = await familiesDao.getUnsyncedFamilies();

    if (unsynced.isEmpty) {
      print("🔄 No families to sync");
      return;
    }

    print("🔄 Syncing ${unsynced.length} families...\n");

    for (final row in unsynced) {
      final String localFamilyId = row["id"];          // LOCAL Primary Key
      final String? serverFamilyId = row["client_id"]; // Null before sync

      print("📤 Syncing FAMILY → local_id = $localFamilyId");

      try {
        // ---------------------------------------------------------
        // 1️⃣ CALL BACKEND
        // backend: POST /families/create
        // ---------------------------------------------------------
        final http.Response resp = await api.createFamilyFromLocal(row);

        if (resp.statusCode == 200 || resp.statusCode == 201) {
          final data = jsonDecode(resp.body);

          // backend returns { family: { id: ... } }
          final String? newServerId =
              data["family"]?["id"] ?? data["id"];

          if (newServerId == null) {
            print("⚠️ Server did NOT send family.id !");
            continue;
          }

          print("🌐 FAMILY SYNC SUCCESS → local:$localFamilyId → server:$newServerId");

          // ---------------------------------------------------------
          // 2️⃣ UPDATE family row with server ID
          // ---------------------------------------------------------
          await familiesDao.markAsSynced(
            localId: localFamilyId,
            serverId: newServerId,
          );

          // ---------------------------------------------------------
          // 3️⃣ UPDATE ALL MEMBERS → assign server family id
          // ---------------------------------------------------------
          await membersDao.updateFamilyServerId(
            localFamilyId: localFamilyId,
            serverFamilyId: newServerId,
          );

          print("👨‍👩‍👧 Linked members to server family_id → $newServerId");

          // ---------------------------------------------------------
          // 4️⃣ UPDATE health_records → assign server family id
          // ---------------------------------------------------------
          await healthDao.updateFamilyServerIdOnHealth(
            localFamilyId: localFamilyId,
            serverFamilyId: newServerId,
          );

          print("🩺 Updated health_records with server family_id\n");
        }

        // ---------------------------------------------------------
        // ❌ FAILURE
        // ---------------------------------------------------------
        else {
          print("❌ FAMILY SYNC FAILED ($localFamilyId) => "
              "${resp.statusCode} | ${resp.body}");
        }
      } catch (e) {
        print("💥 Exception syncing family $localFamilyId => $e");
      }
    }

    print("✅ FAMILY SYNC COMPLETE");
  }
}

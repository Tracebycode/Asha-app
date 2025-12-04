import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:asha_frontend/data/local/dao/members_dao.dart';
import 'package:asha_frontend/data/local/dao/health_records_dao.dart';
import 'package:asha_frontend/core/services/api_service.dart';

class MemberSyncService {
  final MembersDao membersDao = MembersDao();
  final HealthRecordsDao healthDao = HealthRecordsDao();
  final ApiService api = ApiService();

  Future<void> syncMembers() async {
    final unsynced = await membersDao.getUnsyncedMembers();

    if (unsynced.isEmpty) {
      print("🔄 No members to sync.");
      return;
    }

    print("🔄 Syncing ${unsynced.length} members...\n");

    for (final m in unsynced) {
      final String localMemberId = m["id"];          // local PK
      final String? serverMemberId = m["client_id"]; // null before sync
      final String? serverFamilyId = m["family_client_id"];

      // -----------------------------------------------------------
      // 1️⃣ FAMILY MUST BE SYNCED FIRST
      // -----------------------------------------------------------
      if (serverFamilyId == null) {
        print("⚠ Skipping $localMemberId → family NOT synced yet");
        continue;
      }

      try {
        print("📤 Uploading MEMBER → local_id=$localMemberId");

        // -----------------------------------------------------------
        // 2️⃣ SEND TO BACKEND
        // -----------------------------------------------------------
        final http.Response resp = await api.createMemberFromLocal(m);

        if (resp.statusCode == 200 || resp.statusCode == 201) {
          final data = jsonDecode(resp.body);

          // backend returns: { member: { id: "..." } }
          final String? newServerId =
              data["member"]?["id"] ?? data["id"];

          if (newServerId == null) {
            print("⚠ Server returned NO member.id");
            continue;
          }

          print("🌐 MEMBER SYNCED → $localMemberId → $newServerId");

          // -----------------------------------------------------------
          // 3️⃣ UPDATE LOCAL MEMBER WITH SERVER ID
          // -----------------------------------------------------------
          await membersDao.markAsSynced(
            localId: localMemberId,
            serverId: newServerId,
          );

          // -----------------------------------------------------------
          // 4️⃣ UPDATE health_records.member_client_id
          // -----------------------------------------------------------
          await healthDao.updateMemberServerIdOnHealth(
            localMemberId: localMemberId,
            serverMemberId: newServerId,
          );

          print("🩺 Updated health_records for member → $newServerId\n");
        }

        // -----------------------------------------------------------
        // ❌ FAILURE
        // -----------------------------------------------------------
        else {
          print("❌ Member sync FAILED ($localMemberId) → "
              "${resp.statusCode} | ${resp.body}");
        }
      } catch (e) {
        print("💥 Exception syncing member $localMemberId → $e");
      }
    }

    print("✅ Member Sync Complete");
  }
}

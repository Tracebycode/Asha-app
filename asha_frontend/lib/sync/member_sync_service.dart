import 'package:asha_frontend/data/local/dao/members_dao.dart';
import 'package:asha_frontend/data/local/dao/health_records_dao.dart';
import 'package:asha_frontend/core/services/api_service.dart';

class MemberSyncService {
  final MembersDao membersDao = MembersDao();
  final HealthRecordsDao healthDao = HealthRecordsDao();
  final ApiClient api = ApiClient();

  Future<void> syncMembers() async {
    final unsynced = await membersDao.getUnsyncedMembers();

    if (unsynced.isEmpty) {
      print("🔄 No members to sync.");
      return;
    }

    print("🔄 Syncing ${unsynced.length} members...\n");

    for (final m in unsynced) {
      final String localMemberId = m["id"];       // LOCAL UUID
      final String? serverMemberId = m["client_id"]; // null before sync
      final String? serverFamilyId = m["family_id"]; // server family id

      // -----------------------------------------------------------
      // 1️⃣ FAMILY MUST BE SYNCED FIRST
      // -----------------------------------------------------------
      if (serverFamilyId == null) {
        print("⚠ SKIPPED MEMBER $localMemberId → FAMILY NOT SYNCED");
        continue;
      }

      try {
        print("📤 Uploading MEMBER → local_id=$localMemberId");

        // -----------------------------------------------------------
        // 2️⃣ SEND TO BACKEND (returns Map)
        // -----------------------------------------------------------
        final data = await api.createMemberFromLocal(m);

        // backend returns:
        // { member: { id: xxx } }  OR  { id: xxx }
        final String? newServerId =
            data["member"]?["id"] ??
                data["id"];

        if (newServerId == null) {
          print("⚠ Server returned NO member id.");
          continue;
        }

        print("🌐 MEMBER SYNCED → $localMemberId → $newServerId");

        // -----------------------------------------------------------
        // 3️⃣ UPDATE LOCAL MEMBER RECORD
        // -----------------------------------------------------------
        await membersDao.markAsSynced(
          localId: localMemberId,
          serverId: newServerId,
        );

        // -----------------------------------------------------------
        // 4️⃣ UPDATE HEALTH RECORD RELATIONS
        //
        // health_records:
        //    member_id         = serverMemberId
        //    member_client_id  = localMemberId
        // -----------------------------------------------------------
        await healthDao.updateMemberServerIdOnHealth(
          localMemberId: localMemberId,
          serverMemberId: newServerId,
        );

        print("🩺 Updated health_records for member → server_id=$newServerId\n");
      }

      catch (e) {
        print("💥 Exception syncing member $localMemberId → $e");
      }
    }

    print("✅ Member Sync Complete");
  }
}

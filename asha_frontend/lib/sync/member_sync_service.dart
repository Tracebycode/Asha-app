import 'dart:convert';
import 'package:asha_frontend/data/local/dao/members_dao.dart';
import 'package:asha_frontend/core/services/api_service.dart';

class MemberSyncService {
  final MembersDao membersDao = MembersDao();
  final ApiService api = ApiService();

  Future<void> syncMembers() async {
    final unsynced = await membersDao.getUnsyncedMembers();

    print("🔄 Syncing ${unsynced.length} members...");

    for (final m in unsynced) {
      final clientId = m["client_id"];

      try {
        // family_id null hai = family abhi server pe create hi nahi hui
        if (m["family_id"] == null) {
          print("⚠ Skipping $clientId: family_id is null (family not yet synced)");
          continue;
        }

        // 🔥 Ab API helper ko poora row de rahe hain
        final res = await api.createMemberFromLocal(m);

        if (res.statusCode == 201 || res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final serverMemberId = data["member"]["id"];

          await membersDao.markAsSynced(clientId, serverMemberId);
          print("✅ Member $clientId synced as $serverMemberId");
        } else {
          print("❌ Failed $clientId: ${res.statusCode} ${res.body}");
        }
      } catch (e) {
        print("💥 Exception while syncing member $clientId: $e");
      }
    }
  }
}

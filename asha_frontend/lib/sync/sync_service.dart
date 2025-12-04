import 'dart:convert';
import 'package:asha_frontend/data/local/dao/families_dao.dart';
import 'package:asha_frontend/core/services/api_service.dart';
import 'package:asha_frontend/data/local/dao/members_dao.dart';
import 'package:asha_frontend/sync/family_id_mapping.dart';
import 'package:http/http.dart' as http;

class SyncService {
  final FamiliesDao _familiesDao = FamiliesDao();
  final ApiService _api = ApiService();

  Future<void> syncFamilies() async {
    final unsynced = await _familiesDao.getUnsyncedFamilies();

    if (unsynced.isEmpty) {
      print("🔄 No families to sync.");
      return;
    }

    print("🔄 Syncing ${unsynced.length} families...");

    for (final row in unsynced) {
      final clientId = row["client_id"] as String;

      try {
        final http.Response resp = await _api.createFamilyFromLocal(row);

        if (resp.statusCode == 201 || resp.statusCode == 200) {
          final data = jsonDecode(resp.body);

          // 🔥 BACKEND RESPONSE SE SERVER ID NIKALO
          // adjust according to your API
          final serverId =
              data["id"] ?? data["family"]?["id"]; // tweak if needed

          if (serverId == null) {
            print("⚠️ No serverId in response for family $clientId");
            continue;
          }

          await _familiesDao.markAsSynced(
            clientId: clientId,
            serverId: serverId,
          );
          await FamilyIdMapping.saveMapping(clientId, serverId);

          await MembersDao ().updateMembersFamilyId(
            clientFamilyId: clientId,   // old (local) ID
            serverFamilyId: serverId,   // new (server) ID
          );

          print("🔗 Members linked to server family $serverId");

          print("✅ Family $clientId synced as $serverId");

          print("✅ Family $clientId synced as $serverId");
        } else {
          print(
              "❌ Failed to sync family $clientId: ${resp.statusCode} ${resp.body}");
        }
      } catch (e) {
        print("💥 Exception while syncing family $clientId: $e");
      }
    }
  }
}

import '../local/dao/members_dao.dart';
import 'package:uuid/uuid.dart';

class MembersRepository {
  final MembersDao dao;
  MembersRepository(this.dao);

  /// -------------------------------------------------------------
  /// CREATE MEMBER (LOCAL ONLY)
  /// -------------------------------------------------------------
  /// Creates a member using LOCAL FAMILY ID.
  /// Marks record dirty so SyncMembersService will push it online.
  ///
  Future<String> createMember({
    required String localFamilyId,
    required Map<String, dynamic> member,
  }) async {
    final String localMemberId = const Uuid().v4();
    final now = DateTime.now().toIso8601String();

    final data = {
      /// ↓ Primary keys
      "id": localMemberId,               // LOCAL PK
      "client_id": null,                 // SERVER MEMBER ID (after sync)

      /// ↓ Family linkage
      "family_id": localFamilyId,        // LOCAL FAMILY FK
      "family_client_id": null,          // SERVER FAMILY FK (after sync)

      /// ↓ Member fields
      "name": member["name"],
      "age": member["age"],
      "gender": member["gender"],
      "relation": member["relation"],
      "aadhaar": member["aadhaar"],      // local column name
      "phone": member["phone"],
      "is_alive": 1,
      "dob": member["dob"],

      /// ↓ Device meta
      "device_created_at": now,
      "device_updated_at": now,

      /// ↓ Offline sync flags
      "is_dirty": 1,
      "dirty_operation": "insert",
      "local_updated_at": now,
    };

    await dao.insertMember(data);

    return localMemberId; // return LOCAL ID for UI
  }

  /// -------------------------------------------------------------
  /// GET MEMBERS by LOCAL FAMILY ID
  /// -------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getMembers(String localFamilyId) {
    return dao.getMembersByServerFamilyId(localFamilyId);
  }
}

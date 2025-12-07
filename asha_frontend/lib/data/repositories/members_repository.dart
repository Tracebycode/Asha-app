import 'package:uuid/uuid.dart';
import '../local/dao/members_dao.dart';

class MembersRepository {
  final MembersDao dao;
  MembersRepository(this.dao);

  // -------------------------------------------------------------
  // 1️⃣ CREATE LOCAL MEMBER (OFFLINE)
  // -------------------------------------------------------------
  Future<String> createMember({
    required String localFamilyId,
    required Map<String, dynamic> member,
  }) async {
    final String localMemberId = const Uuid().v4();
    final now = DateTime.now().toIso8601String();

    final data = {
      "id": localMemberId,
      "client_id": null,        // no server id yet

      // ---------------------------------------------------
      // CORRECT ASSOCIATION
      // ---------------------------------------------------
      "family_id": null,            // SERVER FAMILY ID (will come after sync)
      "family_client_id": localFamilyId,   // LOCAL FAMILY ID (correct!)

      "name": member["name"],
      "age": member["age"],
      "gender": member["gender"],
      "relation": member["relation"],
      "aadhaar": member["aadhaar"],
      "phone": member["phone"],
      "is_alive": 1,
      "dob": member["dob"],

      "device_created_at": now,
      "device_updated_at": now,

      "is_dirty": 1,
      "dirty_operation": "insert",
      "local_updated_at": now,
    };

    await dao.insertMember(data);
    return localMemberId;
  }

  // -------------------------------------------------------------
  // 2️⃣ GET ALL MEMBERS OF LOCAL FAMILY
  // -------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getMembersByLocalFamily(
      String localFamilyId) {
    return dao.getMembersByLocalFamilyId(localFamilyId);
  }

  // -------------------------------------------------------------
  // 3️⃣ GET MEMBERS OF DOWNLOADED FAMILY (SERVER FAMILY)
  // -------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getMembersByServerFamily(
      String serverFamilyId) {
    return dao.getMembersByServerFamilyId(serverFamilyId);
  }

  // -------------------------------------------------------------
  // 4️⃣ GET SINGLE LOCAL MEMBER
  // -------------------------------------------------------------
  Future<Map<String, dynamic>?> getMember(String localMemberId) {
    return dao.getMemberByLocalId(localMemberId);
  }

  // -------------------------------------------------------------
  // 5️⃣ GET UNSYNCED MEMBERS
  // -------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getUnsyncedMembers() {
    return dao.getUnsyncedMembers();
  }
}

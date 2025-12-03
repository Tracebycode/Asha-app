import '../local/dao/members_dao.dart';
import 'package:uuid/uuid.dart';

class MembersRepository {
  final MembersDao dao;
  MembersRepository(this.dao);

  Future<String> createMember({
    required String familyClientId,
    required Map<String, dynamic> member,
  }) async {
    final String clientId = "mem_${const Uuid().v4()}";

    final data = {
      "client_id": clientId,
      "family_client_id": familyClientId,

      "name": member["name"],
      "age": member["age"],
      "gender": member["gender"],
      "relation": member["relation"],
      "aadhaar": member["aadhaar"],
      "phone": member["phone"],

      "device_created_at": DateTime.now().toIso8601String(),
      "device_updated_at": DateTime.now().toIso8601String(),
      "is_dirty": 1,
      "dirty_operation": "insert",
      "local_updated_at": DateTime.now().toIso8601String(),
    };

    await dao.insertMember(data);
    return clientId;
  }

  Future<List<Map<String, dynamic>>> getMembers(String familyClientId) {
    return dao.getMembersByFamily(familyClientId);
  }
}

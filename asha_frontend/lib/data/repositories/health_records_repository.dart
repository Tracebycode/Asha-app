import 'package:uuid/uuid.dart';
import '../local/dao/health_records_dao.dart';

class HealthRecordsRepository {
  final HealthRecordsDao dao;

  HealthRecordsRepository(this.dao);

  Future<void> saveHealthRecord({
    required String memberClientId,
    required String visitType, // ANC, PNC, NCD, TB etc.
    required Map<String, dynamic> dataJson,
  }) async {
    final String id = const Uuid().v4();
    final now = DateTime.now().toIso8601String();

    final record = {
      "id": id,
      "member_client_id": memberClientId,
      "visit_type": visitType,
      "data_json": dataJson,
      "is_dirty": 1,
      "dirty_operation": "insert",
      "device_created_at": now,
      "device_updated_at": now,
      "local_updated_at": now,
    };

    await dao.insertRecord(record);

    print("💾 HEALTH RECORD SAVED LOCALLY => $id");
  }

  Future<List<Map<String, dynamic>>> getAllRecords() async {
    return await dao.getAllRecords();
  }

  Future<List<Map<String, dynamic>>> getUnsynced() async {
    return await dao.getUnsyncedRecords();
  }
}

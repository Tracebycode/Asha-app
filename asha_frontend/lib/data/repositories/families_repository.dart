import 'package:uuid/uuid.dart';
import '../local/dao/families_dao.dart';

class FamilyInput {
  final String areaId;
  final String addressLine;
  final String landmark;

  FamilyInput({
    required this.areaId,
    required this.addressLine,
    required this.landmark,
  });
}

class FamiliesRepository {
  final FamiliesDao dao;
  FamiliesRepository(this.dao);

  /// -------------------------------------------------------------
  /// CREATE FAMILY (LOCAL ONLY)
  /// -------------------------------------------------------------
  /// IMPORTANT:
  /// Backend does NOT accept phc_id / asha_worker_id / anm_worker_id
  /// from the app — it derives them from JWT token.
  ///
  /// So we only store them LOCALLY for reference, not for sync payload.
  ///
  Future<String> create(FamilyInput input, {
    required String phcId,
    required String ashaWorkerId,
    required String? anmWorkerId,
  }) async {

    final now = DateTime.now().toIso8601String();
    final String localId = const Uuid().v4();

    await dao.insertFamily({
      // Primary keys
      'id': localId,             // LOCAL PK
      'client_id': null,         // SERVER ID after sync

      // Location / worker mapping (local only)
      'area_id': input.areaId,
      'phc_id': phcId,
      'asha_worker_id': ashaWorkerId,
      'anm_worker_id': anmWorkerId,

      // UI fields
      'address_line': input.addressLine,
      'landmark': input.landmark,

      // device meta
      'device_created_at': now,
      'device_updated_at': now,

      // offline sync flags
      'is_dirty': 1,
      'dirty_operation': 'insert',
      'local_updated_at': now,
    });

    return localId;   // Return LOCAL FAMILY ID for UI
  }

  Future<List<Map<String, dynamic>>> getAll() {
    return dao.getAllFamilies();
  }
}

import 'package:uuid/uuid.dart';
import '../local/dao/families_dao.dart';

class FamilyInput {
  final String areaId;
  final String phcId;
  final String ashaWorkerId;
  final String? anmWorkerId;
  final String? addressLine;
  final String? landmark;

  FamilyInput({
    required this.areaId,
    required this.phcId,
    required this.ashaWorkerId,
    this.anmWorkerId,
    this.addressLine,
    this.landmark,
  });
}

class FamiliesRepository {
  final FamiliesDao dao;
  FamiliesRepository(this.dao);

  Future<void> create(FamilyInput input) async {
    final now = DateTime.now().toIso8601String();
    final clientId = const Uuid().v4();

    await dao.insertFamily({
      'client_id': clientId,
      'id': null,
      'area_id': input.areaId,
      'phc_id': input.phcId,
      'asha_worker_id': input.ashaWorkerId,
      'anm_worker_id': input.anmWorkerId,
      'address_line': input.addressLine,
      'landmark': input.landmark,
      'device_created_at': now,
      'device_updated_at': now,
      'is_dirty': 1,
      'dirty_operation': 'CREATE',
      'local_updated_at': now,
    });
  }

  Future<List<Map<String, dynamic>>> getAll() {
    return dao.getAllFamilies();
  }
}

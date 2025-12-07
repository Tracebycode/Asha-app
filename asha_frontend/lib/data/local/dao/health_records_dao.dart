import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../db/app_db.dart';
import 'package:uuid/uuid.dart';

class HealthRecordsDao {
  Future<Database> get _db async => await AppDatabase.instance.database;
  final uuid = Uuid();

  // -------------------------------------------------------
  // INSERT LOCAL HEALTH RECORD
  // -------------------------------------------------------
  Future<void> insertRecord(Map<String, dynamic> data) async {
    final db = await _db;

    if (data["data_json"] is Map) {
      data["data_json"] = jsonEncode(data["data_json"]);
    }

    await db.insert(
      "health_records",
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // -------------------------------------------------------
  // GET ALL LOCAL RECORDS
  // -------------------------------------------------------
  Future<List<Map<String, dynamic>>> getAllRecords() async {
    final db = await _db;
    return db.query(
      "health_records",
      orderBy: "local_updated_at DESC",
    );
  }

  // -------------------------------------------------------
  // GET UNSYNCED RECORDS
  // -------------------------------------------------------
  Future<List<Map<String, dynamic>>> getUnsyncedRecords() async {
    final db = await _db;

    return db.query(
      "health_records",
      where: "is_dirty = ?",
      whereArgs: [1],
      orderBy: "local_updated_at ASC",
    );
  }

  // -------------------------------------------------------
  // MARK AS SYNCED
  // -------------------------------------------------------
  Future<int> markAsSynced({
    required String localId,
    required String serverId,
  }) async {
    final db = await _db;

    return db.update(
      "health_records",
      {
        "client_id": serverId,
        "is_dirty": 0,
        "dirty_operation": "synced",
        "local_updated_at": DateTime.now().toIso8601String(),
      },
      where: "id = ?",
      whereArgs: [localId],
    );
  }

  // -------------------------------------------------------
  // AFTER MEMBER SYNC → UPDATE SERVER MEMBER ID
  // -------------------------------------------------------
  Future<void> updateMemberServerIdOnHealth({
    required String localMemberId,
    required String serverMemberId,
  }) async {
    final db = await _db;

    await db.update(
      "health_records",
      {
        "member_id": serverMemberId,
        "member_client_id": localMemberId,
        "local_updated_at": DateTime.now().toIso8601String(),
      },
      where: "member_client_id = ?",   // match local member
      whereArgs: [localMemberId],
    );
  }

  // -------------------------------------------------------
  // AFTER FAMILY SYNC → UPDATE SERVER FAMILY ID
  // -------------------------------------------------------
  Future<void> updateFamilyServerIdOnHealth({
    required String localFamilyId,
    required String serverFamilyId,
  }) async {
    final db = await _db;

    await db.update(
      "health_records",
      {
        "family_id": serverFamilyId,
        "family_client_id": localFamilyId,
        "local_updated_at": DateTime.now().toIso8601String(),
      },
      where: "family_client_id = ?",  // match local family id
      whereArgs: [localFamilyId],
    );
  }

  // -------------------------------------------------------
  // INSERT DOWNLOADED SERVER HEALTH RECORDS
  // -------------------------------------------------------
  Future<void> insertDownloadedHealthRecords(
      List<Map<String, dynamic>> records,
      String localFamilyId,
      String serverFamilyId,
      Map<String, String> memberLocalMap,     // server → local
      ) async {
    final db = await _db;

    for (var r in records) {
      final serverRecordId = r["id"];
      final serverMemberId = r["member_id"];
      final localMemberId = memberLocalMap[serverMemberId]!;

      final localRecordId = uuid.v4();

      final encodedJson = (r["data_json"] is Map)
          ? jsonEncode(r["data_json"])
          : r["data_json"].toString();

      await db.insert(
        "health_records",
        {
          "id": localRecordId,              // local UUID
          "client_id": serverRecordId,      // server health id

          "family_id": serverFamilyId,      // server family id
          "family_client_id": localFamilyId, // local family id

          "member_id": serverMemberId,      // server member id
          "member_client_id": localMemberId, // local member id

          "visit_type": r["visit_type"],
          "data_json": encodedJson,

          "is_dirty": 0,
          "dirty_operation": "synced",
          "local_updated_at": DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // -------------------------------------------------------
  // GET DOWNLOADED HEALTH BY *SERVER MEMBER ID*
  // -------------------------------------------------------
  Future<List<Map<String, dynamic>>> getDownloadedHealthRecords(
      String serverMemberId) async {
    final db = await _db;

    return db.query(
      "health_records",
      where: "member_id = ? AND is_dirty = 0",
      whereArgs: [serverMemberId],
      orderBy: "local_updated_at DESC",
    );
  }

  // -------------------------------------------------------
  // EDIT LOCAL RECORD
  // -------------------------------------------------------
  Future<void> updateAfterSync(String id, Map<String, dynamic> data) async {
    final db = await _db;

    if (data["data_json"] is Map) {
      data["data_json"] = jsonEncode(data["data_json"]);
    }

    await db.update(
      'health_records',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // -------------------------------------------------------
// GET HEALTH BY LOCAL MEMBER ID  (needed for edit mode)
// -------------------------------------------------------
  Future<List<Map<String, dynamic>>> getHealthByLocalMemberId(String localMemberId) async {
    final db = await _db;

    return db.query(
      "health_records",
      where: "member_client_id = ?",  // local member id
      whereArgs: [localMemberId],
      orderBy: "local_updated_at DESC",
    );
  }

}

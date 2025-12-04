import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../db/app_db.dart';

class HealthRecordsDao {
  Future<Database> get _db async => await AppDatabase.instance.database;

  // -------------------------------------------------------
  // INSERT HEALTH RECORD (local only)
  // -------------------------------------------------------
  Future<void> insertRecord(Map<String, dynamic> data) async {
    final db = await _db;

    // Convert map → JSON string
    if (data["data_json"] != null && data["data_json"] is Map) {
      data["data_json"] = jsonEncode(data["data_json"]);
    }

    await db.insert(
      "health_records",
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // -------------------------------------------------------
  // GET ALL RECORDS
  // -------------------------------------------------------
  Future<List<Map<String, dynamic>>> getAllRecords() async {
    final db = await _db;
    return await db.query(
      "health_records",
      orderBy: "local_updated_at DESC",
    );
  }

  // -------------------------------------------------------
  // GET UNSYNCED RECORDS
  // -------------------------------------------------------
  Future<List<Map<String, dynamic>>> getUnsyncedRecords() async {
    final db = await _db;

    return await db.query(
      "health_records",
      where: "is_dirty = ?",
      whereArgs: [1],
      orderBy: "local_updated_at ASC",
    );
  }

  // -------------------------------------------------------
  // HEALTH SYNC COMPLETE → set server health record ID
  // -------------------------------------------------------
  Future<int> markAsSynced({
    required String localId,
    required String serverId,
  }) async {
    final db = await _db;

    return await db.update(
      "health_records",
      {
        "client_id": serverId, // SERVER RECORD UUID
        "is_dirty": 0,
        "dirty_operation": "synced",
        "synced_at": DateTime.now().toIso8601String(),
        "local_updated_at": DateTime.now().toIso8601String(),
      },
      where: "id = ?",
      whereArgs: [localId],
    );
  }

  // -------------------------------------------------------
  // When MEMBER SYNC completes → update SERVER MEMBER ID
  //
  // LOCAL member_id stays same
  // SERVER member id goes → member_client_id
  // -------------------------------------------------------
  Future<void> updateMemberServerIdOnHealth({
    required String localMemberId,
    required String serverMemberId,
  }) async {
    final db = await _db;

    await db.update(
      "health_records",
      {
        "member_client_id": serverMemberId, // SERVER MEMBER ID
        "local_updated_at": DateTime.now().toIso8601String(),
      },
      where: "member_id = ?",
      whereArgs: [localMemberId],
    );
  }

  // -------------------------------------------------------
  // When FAMILY SYNC completes → update SERVER FAMILY ID
  //
  // LOCAL family_id stays same
  // SERVER family id goes → family_client_id
  // -------------------------------------------------------
  Future<void> updateFamilyServerIdOnHealth({
    required String localFamilyId,
    required String serverFamilyId,
  }) async {
    final db = await _db;

    await db.update(
      "health_records",
      {
        "family_client_id": serverFamilyId, // SERVER FAMILY ID
        "local_updated_at": DateTime.now().toIso8601String(),
      },
      where: "family_id = ?",
      whereArgs: [localFamilyId],
    );
  }


  Future<void> updateAfterSync(String id, Map<String, dynamic> data) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'health_records',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}

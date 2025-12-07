import 'package:sqflite/sqflite.dart';
import '../db/app_db.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class FamiliesDao {
  final uuid = Uuid();

  Future<Database> get _db async => await AppDatabase.instance.database;

  // ----------------------------------------------------------
  // INSERT FAMILY (LOCAL ONLY)
  // ----------------------------------------------------------
  Future<void> insertFamily(Map<String, dynamic> data) async {
    final db = await _db;
    await db.insert(
      'families',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ----------------------------------------------------------
  // SELECTORS
  // ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> getAllFamilies() async {
    final db = await _db;
    return db.query('families', orderBy: "local_updated_at DESC");
  }

  Future<List<Map<String, dynamic>>> getUnsyncedFamilies() async {
    final db = await _db;
    return db.query(
      "families",
      where: "is_dirty = ?",
      whereArgs: [1],
      orderBy: "local_updated_at ASC",
    );
  }

  // ----------------------------------------------------------
  // MARK SYNCED
  // ----------------------------------------------------------
  Future<int> markAsSynced({
    required String localId,
    required String serverId,
  }) async {
    final db = await _db;

    return db.update(
      "families",
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

  Future<int> updateServerFamilyId(String localId, String serverId) async {
    final db = await _db;

    return db.update(
      "families",
      {
        "client_id": serverId,
        "local_updated_at": DateTime.now().toIso8601String(),
      },
      where: "id = ?",
      whereArgs: [localId],
    );
  }

  // ==========================================================
  // DOWNLOADED FAMILY SUPPORT
  // ==========================================================

  Future<bool> isFamilyDownloaded(String serverId) async {
    final db = await _db;
    final result = await db.query(
      "families",
      where: "client_id = ? AND is_dirty = 0",
      whereArgs: [serverId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // ----------------------------------------------------------
  // SAVE DOWNLOADED FAMILY BUNDLE (CORRECT MAPPING)
  // ----------------------------------------------------------
  Future<void> saveDownloadedFamilyBundle({
    required Map<String, dynamic> family,
    required List<Map<String, dynamic>> members,
    required List<Map<String, dynamic>> healthRecords,
  }) async {
    final db = await _db;

    await db.transaction((txn) async {
      // ------------------------------------------------------
      // Generate local family ID
      // ------------------------------------------------------
      final serverFamilyId = family["id"];
      final localFamilyId = uuid.v4();

      // SAVE FAMILY
      await txn.insert(
        "families",
        {
          "id": localFamilyId,
          "client_id": serverFamilyId,
          "area_id": family["area_id"],
          "address_line": family["address_line"],
          "landmark": family["landmark"],
          "asha_worker_id": family["asha_worker_id"],
          "anm_worker_id": family["anm_worker_id"],
          "phc_id": family["phc_id"],
          "is_dirty": 0,
          "dirty_operation": "synced",
          "local_updated_at": DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // ------------------------------------------------------
      // CREATE MEMBER MAPPING
      // serverMemberId → localMemberId
      // ------------------------------------------------------
      final Map<String, String> memberIdMap = {};

      for (var m in members) {
        final serverMemberId = m["id"];
        final localMemberId = uuid.v4();

        memberIdMap[serverMemberId] = localMemberId;

        await txn.insert(
          "family_members",
          {
            "id": localMemberId,
            "client_id": serverMemberId,
            "family_id": serverFamilyId,
            "family_client_id": localFamilyId,
            "name": m["name"],
            "phone": m["phone"],
            "age": m["age"],
            "gender": m["gender"],
            "relation": m["relation"],
            "aadhaar": m["aadhaar"],
            "dob": m["dob"],
            "is_dirty": 0,
            "dirty_operation": "synced",
            "local_updated_at": DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // ------------------------------------------------------
      // SAVE HEALTH RECORDS
      // ------------------------------------------------------
      for (var h in healthRecords) {
        final serverRecordId = h["id"];
        final localRecordId = uuid.v4();

        final serverMemberId = h["member_id"];
        final localMemberId = memberIdMap[serverMemberId];

        await txn.insert(
          "health_records",
          {
            "id": localRecordId,
            "client_id": serverRecordId,
            "family_id": serverFamilyId,
            "family_client_id": localFamilyId,

            "member_id": serverMemberId,
            "member_client_id": localMemberId,

            "visit_type": h["visit_type"],
            "data_json": jsonEncode(h["data_json"]),

            "is_dirty": 0,
            "dirty_operation": "synced",
            "local_updated_at": DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // ----------------------------------------------------------
  // GET DOWNLOADED FAMILIES (client_id NOT NULL AND synced)
  // ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> getDownloadedFamilies() async {
    final db = await _db;

    return await db.query(
      "families",
      where: "client_id IS NOT NULL AND is_dirty = 0",
      orderBy: "local_updated_at DESC",
    );
  }
  // Future<List<Map<String, dynamic>>> getAllFamilies() async {
  //   final db = await DatabaseService().database;
  //   return db.query("families_local");
  // }
// ----------------------------------------------------------
// UPDATE FAMILY (LOCAL EDIT)
// ----------------------------------------------------------
  Future<int> updateFamily(String localId, Map<String, dynamic> updates) async {
    final db = await _db;

    updates["local_updated_at"] = DateTime.now().toIso8601String();
    updates["is_dirty"] = 1;
    updates["dirty_operation"] = "update";

    return db.update(
      "families",
      updates,
      where: "id = ?",
      whereArgs: [localId],
    );
  }



}

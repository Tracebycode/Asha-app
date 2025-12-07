import 'package:sqflite/sqflite.dart';
import '../db/app_db.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class MembersDao {
  final uuid = Uuid();

  Future<Database> get _db async => await AppDatabase.instance.database;

  // ----------------------------------------------------------
  // INSERT LOCAL-ONLY MEMBER
  // ----------------------------------------------------------
  Future<void> insertMember(Map<String, dynamic> data) async {
    final db = await _db;
    await db.insert(
      "family_members",
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ----------------------------------------------------------
  // GET MEMBERS BY LOCAL FAMILY ID (family_client_id)
  // ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> getMembersByLocalFamilyId(
      String localFamilyId) async {
    final db = await _db;

    return await db.query(
      "family_members",
      where: "family_client_id = ?",
      whereArgs: [localFamilyId],
      orderBy: "local_updated_at DESC",
    );
  }

  // ----------------------------------------------------------
  // GET MEMBERS BY *SERVER FAMILY ID*
  // ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> getMembersByServerFamilyId(
      String serverFamilyId) async {
    final db = await _db;

    return await db.query(
      "family_members",
      where: "family_id = ?",
      whereArgs: [serverFamilyId],
      orderBy: "local_updated_at DESC",
    );
  }

  // ----------------------------------------------------------
  // GET ALL MEMBERS
  // ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> getAllMembers() async {
    final db = await _db;
    return await db.query(
      "family_members",
      orderBy: "local_updated_at DESC",
    );
  }

  // ----------------------------------------------------------
  // GET UNSYNCED MEMBERS
  // ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> getUnsyncedMembers() async {
    final db = await _db;

    return await db.query(
      "family_members",
      where: "is_dirty = ?",
      whereArgs: [1],
      orderBy: "local_updated_at ASC",
    );
  }

  // ----------------------------------------------------------
  // MARK MEMBER AS SYNCED
  // ----------------------------------------------------------
  Future<void> markAsSynced({
    required String localId,
    required String serverId,
  }) async {
    final db = await _db;

    await db.update(
      "family_members",
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

  // ----------------------------------------------------------
  // UPDATE FAMILY SERVER ID AFTER FAMILY SYNC
  // ----------------------------------------------------------
  Future<void> updateFamilyServerId({
    required String localFamilyId,
    required String serverFamilyId,
  }) async {
    final db = await _db;

    await db.update(
      "family_members",
      {
        "family_id": serverFamilyId, // update server family id
        "local_updated_at": DateTime.now().toIso8601String(),
      },
      where: "family_client_id = ?", // match local id
      whereArgs: [localFamilyId],
    );
  }

  // ==========================================================
  // INSERT DOWNLOADED MEMBERS (Perfect mapping)
  // Returns: Map<serverMemberId → localMemberId>
  // ==========================================================
  Future<Map<String, String>> insertDownloadedMembers(
      List<Map<String, dynamic>> members,
      String localFamilyId,
      String serverFamilyId,
      ) async {
    final db = await _db;
    Map<String, String> memberIdMap = {};

    for (var m in members) {
      final serverMemberId = m["id"];
      final localMemberId = uuid.v4();

      memberIdMap[serverMemberId] = localMemberId;

      await db.insert(
        "family_members",
        {
          "id": localMemberId,            // local member uuid
          "client_id": serverMemberId,    // server member id

          "family_id": serverFamilyId,        // SERVER family id
          "family_client_id": localFamilyId,  // LOCAL family id

          "name": m["name"],
          "phone": m["phone"],
          "age": m["age"],
          "gender": m["gender"],
          "relation": m["relation"],
          "aadhaar": m["adhar_number"],  // backend field → sqlite column

          "dob": m["dob"],

          "is_dirty": 0,
          "dirty_operation": "synced",
          "local_updated_at": DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    return memberIdMap;
  }

  // ----------------------------------------------------------
  // GET DOWNLOADED MEMBERS (offline)
  // ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> getDownloadedMembers(
      String serverFamilyId) async {
    final db = await _db;

    return await db.query(
      "family_members",
      where: "family_id = ? AND is_dirty = 0",
      whereArgs: [serverFamilyId],
      orderBy: "local_updated_at DESC",
    );
  }

  // ----------------------------------------------------------
  // GET LOCAL MEMBER BY ID
  // ----------------------------------------------------------
  Future<Map<String, dynamic>?> getMemberByLocalId(String localId) async {
    final db = await _db;

    final result = await db.query(
      "family_members",
      where: "id = ?",
      whereArgs: [localId],
      limit: 1,
    );

    return result.isNotEmpty ? result.first : null;
  }
  // -------------------------------------------------------
// GET MEMBERS BY LOCAL FAMILY ID (id column)
// -------------------------------------------------------
  Future<List<Map<String, dynamic>>> getMembersByFamilyId(String localFamilyId) async {
    final db = await _db;

    return db.query(
      "family_members",
      where: "family_client_id = ?",   // local family id
      whereArgs: [localFamilyId],
      orderBy: "local_updated_at DESC",
    );
  }

}

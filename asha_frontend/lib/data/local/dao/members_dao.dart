import 'package:sqflite/sqflite.dart';
import '../db/app_db.dart';

class MembersDao {
  Future<Database> get _db async => await AppDatabase.instance.database;

  // ----------------------------------------------------------
  // INSERT MEMBER (local only)
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
  // GET MEMBERS BY LOCAL FAMILY ID
  // family_client_id = LOCAL FAMILY ID
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
  // GET MEMBERS BY SERVER FAMILY ID
  // family_id = SERVER FAMILY ID
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
  // MEMBER SYNCED → SET SERVER MEMBER ID
  // client_id = server member id
  // ----------------------------------------------------------
  Future<void> markAsSynced({
    required String localId,
    required String serverId,
  }) async {
    final db = await _db;

    await db.update(
      "family_members",
      {
        "client_id": serverId,                 // SERVER MEMBER ID
        "is_dirty": 0,
        "dirty_operation": "synced",
        "synced_at": DateTime.now().toIso8601String(),
        "local_updated_at": DateTime.now().toIso8601String(),
      },
      where: "id = ?",
      whereArgs: [localId],
    );
  }

  // ----------------------------------------------------------
  // AFTER FAMILY SYNC → UPDATE SERVER FAMILY ID IN MEMBERS
  //
  // family_client_id = LOCAL FAMILY ID (unchanged)
  // family_id        = SERVER FAMILY ID (updated)
  // ----------------------------------------------------------
  Future<void> updateFamilyServerId({
    required String localFamilyId,
    required String serverFamilyId,
  }) async {
    final db = await _db;

    await db.update(
      "family_members",
      {
        "family_client_id": serverFamilyId,  // ✔ CORRECT COLUMN
        "local_updated_at": DateTime.now().toIso8601String(),
      },
      where: "family_id = ?",   // local id match
      whereArgs: [localFamilyId],
    );
  }

}

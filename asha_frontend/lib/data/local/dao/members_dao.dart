import 'package:sqflite/sqflite.dart';
import '../db/app_db.dart';

class MembersDao {
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<void> insertMember(Map<String, dynamic> data) async {
    final db = await _db;

    await db.insert(
      "family_members",
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMembersByFamily(String familyClientId) async {
    final db = await _db;

    return await db.query(
      "family_members",
      where: "family_client_id = ?",
      whereArgs: [familyClientId],
      orderBy: "local_updated_at DESC",
    );
  }

  Future<List<Map<String, dynamic>>> getAllMembers() async {
    final db = await _db;
    return await db.query("family_members");
  }

  Future<List<Map<String, dynamic>>> getUnsyncedMembers() async {
    final db = await _db;

    return await db.query(
      "family_members",
      where: "is_dirty = ?",
      whereArgs: [1],
    );
  }

  Future<void> markAsSynced(String clientId, String serverId) async {
    final db = await _db;

    await db.update(
      "family_members",
      {
        "server_id": serverId,
        "is_dirty": 0,
        "dirty_operation": "synced",
        "synced_at": DateTime.now().toIso8601String(),
      },
      where: "client_id = ?",
      whereArgs: [clientId],
    );
  }
  Future<void> updateMembersFamilyId({
    required String clientFamilyId,
    required String serverFamilyId,
  }) async {
    final db = await _db;

    await db.update(
      "family_members",
      {
        "family_id": serverFamilyId,
        "is_dirty": 1,
        "dirty_operation": "update",
        "local_updated_at": DateTime.now().toIso8601String(),
      },
      where: "family_client_id = ?",
      whereArgs: [clientFamilyId],
    );
  }

}

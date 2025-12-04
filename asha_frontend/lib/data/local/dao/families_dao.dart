import 'package:sqflite/sqflite.dart';
import '../db/app_db.dart';

class FamiliesDao {
  Future<Database> get _db async => await AppDatabase.instance.database;

  // ----------------------------------------------------------
  // INSERT FAMILY (local only)
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
  // GET ALL FAMILIES
  // ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> getAllFamilies() async {
    final db = await _db;
    return db.query(
      'families',
      orderBy: "local_updated_at DESC",
    );
  }

  // ----------------------------------------------------------
  // GET UNSYNCED FAMILIES (dirty = 1)
  // ----------------------------------------------------------
  Future<List<Map<String, dynamic>>> getUnsyncedFamilies() async {
    final db = await _db;

    return await db.query(
      "families",
      where: "is_dirty = ?",
      whereArgs: [1],
      orderBy: "local_updated_at ASC",
    );
  }

  // ----------------------------------------------------------
  // MARK FAMILY AS SYNCED
  // Set client_id = server UUID
  // ----------------------------------------------------------
  Future<int> markAsSynced({
    required String localId,
    required String serverId,
  }) async {
    final db = await _db;

    return await db.update(
      "families",
      {
        "client_id": serverId, // server UUID stored here
        "is_dirty": 0,
        "dirty_operation": "synced",
        "local_updated_at": DateTime.now().toIso8601String(),
      },
      where: "id = ?",
      whereArgs: [localId],
    );
  }

  // ----------------------------------------------------------
  // SPECIAL: Update server family ID after sync
  // This is used by Members & Health sync
  // ----------------------------------------------------------
  Future<int> updateServerFamilyId(String localId, String serverId) async {
    final db = await _db;

    return await db.update(
      "families",
      {
        "client_id": serverId,
        "local_updated_at": DateTime.now().toIso8601String(),
      },
      where: "id = ?",
      whereArgs: [localId],
    );
  }
}

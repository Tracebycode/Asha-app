import 'package:sqflite/sqflite.dart';
import '../db/app_db.dart';

class FamiliesDao {
  Future<void> insertFamily(Map<String, dynamic> data) async {
    final db = await AppDatabase.instance.database;
    await db.insert(
      'families',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllFamilies() async {
    final db = await AppDatabase.instance.database;
    return db.query('families');
  }

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<void> insertFamily_toserverdb(Map<String, dynamic> data) async {
    final db = await _db;

    await db.insert(
      "families",
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllFamilies_toserverdb() async {
    final db = await _db;
    return await db.query("families");
  }

  // 🔥 1A: UNSYNCED FAMILIES (last 48 hours)
  Future<List<Map<String, dynamic>>> getUnsyncedFamilies() async {
    final db = await _db;

    return await db.query(
      "families",
      where:
      "is_dirty = 1 AND datetime(local_updated_at) > datetime('now', '-48 hours')",
      orderBy: "local_updated_at ASC",
    );
  }

  // 🔥 1B: MARK FAMILY AS SYNCED + SET SERVER ID
  Future<int> markAsSynced({
    required String clientId,
    required String serverId,
  }) async {
    final db = await _db;

    return await db.update(
      "families",
      {
        "id": serverId,               // server UUID
        "is_dirty": 0,
        "dirty_operation": "synced",
        "local_updated_at": DateTime.now().toIso8601String(),
      },
      where: "client_id = ?",
      whereArgs: [clientId],
    );
  }
}

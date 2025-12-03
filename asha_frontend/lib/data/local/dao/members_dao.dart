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
}

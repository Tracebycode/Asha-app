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
}

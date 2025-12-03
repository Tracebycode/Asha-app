import 'package:sqflite/sqflite.dart';
import '../db/app_db.dart';
import 'dart:convert';


class HealthRecordsDao {
  Future<void> insertRecord(Map<String, dynamic> data) async {
    final db = await AppDatabase.instance.database;

    // Convert MAP → JSON STRING
    if (data["data_json"] != null && data["data_json"] is Map) {
      data["data_json"] = jsonEncode(data["data_json"]);
    }

    await db.insert("health_records", data);
  }


  Future<List<Map<String, dynamic>>> getAllRecords() async {
    final db = await AppDatabase.instance.database;
    return await db.query("health_records");
  }

  Future<List<Map<String, dynamic>>> getUnsyncedRecords() async {
    final db = await AppDatabase.instance.database;
    return await db.query(
      "health_records",
      where: "is_dirty = ?",
      whereArgs: [1],
    );
  }

  Future<int> markAsSynced(String id) async {
    final db = await AppDatabase.instance.database;

    return await db.update(
      "health_records",
      {
        "is_dirty": 0,
        "synced_at": DateTime.now().toIso8601String(),
        "dirty_operation": "synced",
      },
      where: "id = ?",
      whereArgs: [id],
    );
  }
}

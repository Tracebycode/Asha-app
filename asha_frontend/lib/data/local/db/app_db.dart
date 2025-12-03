import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _db;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "asha_local.db");

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE families (
        client_id TEXT PRIMARY KEY,
        id TEXT,
        phone TEXT,
        address_line TEXT,
        landmark TEXT,
        phc_id TEXT,
        area_id TEXT,
        asha_worker_id TEXT,
        anm_worker_id TEXT,
        device_created_at TEXT,
        device_updated_at TEXT,
        is_dirty INTEGER DEFAULT 1,
        dirty_operation TEXT,
        local_updated_at TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE family_members (
        client_id TEXT PRIMARY KEY,
        id TEXT,
        family_client_id TEXT,
        family_id TEXT,
        name TEXT,
        gender TEXT,
        age INTEGER,
        relation TEXT,
         aadhaar TEXT,
          phone TEXT,
        is_alive INTEGER,
        dob TEXT,
        device_created_at TEXT,
        device_updated_at TEXT,
        is_dirty INTEGER DEFAULT 1,
        dirty_operation TEXT,
        local_updated_at TEXT
      );
    ''');

    await db.execute('''
     CREATE TABLE IF NOT EXISTS health_records (
  id TEXT PRIMARY KEY,
  phc_id TEXT,
  member_id TEXT,
  member_client_id TEXT,
  asha_worker_id TEXT,
  anm_worker_id TEXT,
  area_id TEXT,
  task_id TEXT,
  visit_type TEXT,
  data_json TEXT,
  device_created_at TEXT,
  device_updated_at TEXT,
  synced_at TEXT,
  dirty_operation TEXT,
  is_dirty INTEGER DEFAULT 1,
  local_updated_at TEXT
);
    ''');
  }
}

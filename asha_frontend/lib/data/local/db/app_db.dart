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
      version: 3, // ⬅️ BUMPED
      onCreate: _createTables,
      onUpgrade: (db, oldVersion, newVersion) async {
        // DEV PHASE: simplest = drop & recreate
        // (Agar data preserve karna hai to baad me migration likhenge)
        if (oldVersion < 3) {
          await db.execute("DROP TABLE IF EXISTS health_records;");
          await db.execute("DROP TABLE IF EXISTS family_members;");
          await db.execute("DROP TABLE IF EXISTS families;");
          await _createTables(db, newVersion);
        }
      },
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // ----------------------------
    // 1. FAMILIES
    // ----------------------------
    await db.execute('''
      CREATE TABLE families (
        id TEXT PRIMARY KEY,              -- local UUID
        client_id TEXT,                   -- server UUID

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

    // ----------------------------
    // 2. FAMILY MEMBERS
    // ----------------------------
    await db.execute('''
      CREATE TABLE family_members (
        id TEXT PRIMARY KEY,             -- local UUID
        client_id TEXT,                  -- server UUID

        family_id TEXT,                  -- local family id
        family_client_id TEXT,           -- server family id

        name TEXT,
        age INTEGER,
        gender TEXT,
        relation TEXT,
        aadhaar TEXT,                    -- local field; API mein adhar_number map karenge
        phone TEXT,
        is_alive INTEGER,
        dob TEXT,

        device_created_at TEXT,
        device_updated_at TEXT,
        is_dirty INTEGER DEFAULT 1,
        dirty_operation TEXT,
        local_updated_at TEXT,
        synced_at TEXT
      );
    ''');

    // ----------------------------
    // 3. HEALTH RECORDS
    // ----------------------------
    await db.execute('''
      CREATE TABLE health_records (
        id TEXT PRIMARY KEY,             -- local UUID
        client_id TEXT,                  -- server UUID

        family_id TEXT,                  -- local family id
        family_client_id TEXT,           -- server family id
        member_id TEXT,                  -- local member id
        member_client_id TEXT,           -- server member id

        phc_id TEXT,
        asha_worker_id TEXT,
        anm_worker_id TEXT,
        area_id TEXT,
        task_id TEXT,
        visit_type TEXT,
        data_json TEXT,                  -- JSON string

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

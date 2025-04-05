import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

final logger = Logger();

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static const _dbName = 'medtrack.db';
  static const _dbVersion = 1;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_dbName);
    await _validateDB(_database!);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _validateDB(Database db) async {
    try {
      await db.rawQuery('SELECT 1 FROM patients LIMIT 1');
      logger.i("✅ Database tables validated");
    } on DatabaseException catch (e) {
      logger.w("⚠️ Missing tables, recreating...");
      await _createDB(db, _dbVersion);
    }
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      logger.i("🔧 Creating database tables...");
      await db.execute('''
        CREATE TABLE patients (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          age INTEGER NOT NULL,
          gender TEXT NOT NULL,
          id_number INTEGER UNIQUE NOT NULL,
          phone TEXT NOT NULL,
          email TEXT,
          residence TEXT NOT NULL,
          visit_date TEXT NOT NULL,
          diagnosis TEXT NOT NULL,
          prescription TEXT NOT NULL,
          administration TEXT NOT NULL,
          duration INTEGER NOT NULL,
          payment_method TEXT NOT NULL,
          amount_paid REAL NOT NULL,
          balance REAL NOT NULL
        )
      ''');

      await db.execute('CREATE INDEX idx_patients_id ON patients(id)');
      await db.execute('CREATE INDEX idx_patients_date ON patients(visit_date)');
      logger.i("✅ Database tables created successfully");
    } catch (e) {
      logger.e("❌ Database creation failed: $e");
      rethrow;
    }
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    logger.i("🔄 Upgrading database from $oldVersion to $newVersion");
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE patients ADD COLUMN notes TEXT');
    }
  }

  Future<int> insertPatient(Map<String, dynamic> patient) async {
    final db = await database;
    try {
      // Normalize email on insert (only additive change)
      if (patient.containsKey('email') && patient['email'] != null) {
        patient['email'] = patient['email'].toString().trim().toLowerCase();
      }

      return await db.insert(
        'patients',
        patient,
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } on DatabaseException catch (e) {
      logger.e("Insert failed: $e");
      if (e.isUniqueConstraintError()) {
        throw "ID Number already exists";
      } else if (e.isNotNullConstraintError()) {
        throw "Required fields missing";
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllPatients() async {
    final db = await database;
    try {
      return await db.query('patients', orderBy: "id DESC");
    } catch (e) {
      logger.e("Fetch failed: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchRecentRecords() async {
    final db = await database;
    try {
      return await db.query('patients', orderBy: "id DESC", limit: 5);
    } catch (e) {
      logger.e("Fetch recent failed: $e");
      rethrow;
    }
  }

  Future<int> deletePatient(int id) async {
    final db = await database;
    try {
      return await db.delete(
        'patients',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      logger.e("Delete failed: $e");
      rethrow;
    }
  }

  Future<int> updatePatient(int id, Map<String, dynamic> patient) async {
    final db = await database;
    try {
      return await db.update(
        'patients',
        patient,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      logger.e("Update failed: $e");
      rethrow;
    }
  }
  
  Future<List<Map<String, dynamic>>> searchPatients(String query) async {
    final db = await database;
    return await db.query(
      'patients',
      where: 'name LIKE ? OR phone LIKE ? OR id_number LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
    );
  }

  Future<Map<String, dynamic>?> fetchPatient(int id) async {
    final db = await database;
    final results = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  Future<List<Map<String, dynamic>>> getPatientRecords(String email) async {
    final db = await database;
    final normalizedEmail = email.trim().toLowerCase();
    debugPrint('🗃️ Querying records for email: $normalizedEmail');

    try {
      // First try exact match
      var records = await db.query(
        'patients',
        where: 'email = ?',
        whereArgs: [normalizedEmail],
        orderBy: 'visit_date DESC',
      );

      // Fallback to case-insensitive if no results
      if (records.isEmpty) {
        debugPrint('   ⚠️ No exact matches, trying case-insensitive search');
        records = await db.query(
          'patients',
          where: 'email COLLATE NOCASE = ?',
          whereArgs: [normalizedEmail],
          orderBy: 'visit_date DESC',
        );
      }

      debugPrint('   ➡️ Found ${records.length} records');
      return records;
    } catch (e) {
      debugPrint('❌ Query error: $e');
      rethrow;
    }
  }
}
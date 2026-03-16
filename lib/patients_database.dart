import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PatientDatabase {
  static final PatientDatabase instance = PatientDatabase._init();
  static Database? _database;

  PatientDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('patients.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // ✅ FIX: Use application documents directory (writable location)
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, filePath);

    print('📂 Database path: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    print('🔨 Creating database tables...');

    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        bmi REAL NOT NULL,
        bmr REAL NOT NULL,
        bodyFat REAL NOT NULL,
        minCal REAL NOT NULL,
        maxCal REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    print('✅ Database tables created successfully');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    print('🔄 Upgrading database from v$oldVersion to v$newVersion');
    // Add migration logic here if needed in future versions
  }

  // Insert a new patient
  Future<int> insertPatient(Map<String, dynamic> patient) async {
    try {
      final db = await database;
      print('💾 Inserting patient: ${patient['name']}');

      final id = await db.insert(
        'patients',
        patient,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('✅ Patient inserted with ID: $id');
      return id;
    } catch (e) {
      print('❌ Error inserting patient: $e');
      rethrow;
    }
  }

  // Get all patients
  Future<List<Map<String, dynamic>>> getPatients() async {
    try {
      final db = await database;
      print('📖 Fetching all patients...');

      final result = await db.query(
        'patients',
        orderBy: 'date DESC',
      );

      print('✅ Found ${result.length} patients');
      return result;
    } catch (e) {
      print('❌ Error fetching patients: $e');
      rethrow;
    }
  }

  // Get single patient by ID
  Future<Map<String, dynamic>?> getPatient(int id) async {
    try {
      final db = await database;
      final result = await db.query(
        'patients',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return result.first;
      }
      return null;
    } catch (e) {
      print('❌ Error fetching patient: $e');
      rethrow;
    }
  }

  // Update patient
  Future<int> updatePatient(Map<String, dynamic> patient) async {
    try {
      final db = await database;
      print('📝 Updating patient ID: ${patient['id']}');

      return await db.update(
        'patients',
        patient,
        where: 'id = ?',
        whereArgs: [patient['id']],
      );
    } catch (e) {
      print('❌ Error updating patient: $e');
      rethrow;
    }
  }

  // Delete patient
  Future<int> deletePatient(int id) async {
    try {
      final db = await database;
      print('🗑️ Deleting patient ID: $id');

      final result = await db.delete(
        'patients',
        where: 'id = ?',
        whereArgs: [id],
      );

      print('✅ Patient deleted');
      return result;
    } catch (e) {
      print('❌ Error deleting patient: $e');
      rethrow;
    }
  }

  // Delete all patients (for testing/reset)
  Future<void> deleteAllPatients() async {
    try {
      final db = await database;
      await db.delete('patients');
      print('🗑️ All patients deleted');
    } catch (e) {
      print('❌ Error deleting all patients: $e');
      rethrow;
    }
  }

  // Close database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
      print('🔒 Database closed');
    }
  }

  // Get database statistics
  Future<Map<String, dynamic>> getStats() async {
    try {
      final db = await database;
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM patients'),
      );

      return {
        'totalPatients': count ?? 0,
        'databasePath': await getDatabasesPath(),
      };
    } catch (e) {
      print('❌ Error getting stats: $e');
      rethrow;
    }
  }
}
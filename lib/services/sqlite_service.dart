import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/sample.dart';

class SqliteService {
  static final SqliteService instance = SqliteService._init();

  static Database? _database;

  SqliteService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('samples.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE samples (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pickedPath TEXT NOT NULL,
        pickedName TEXT NOT NULL,
        croppedPath TEXT,
        originalImage BLOB,
        croppedImage BLOB,
        name TEXT,
        result TEXT
      );
    ''');
  }

  Future<int> create(Sample sample) async {
    final db = await instance.database;
    return await db.insert('samples', sample.toMap());
  }

  Future<int> update(Sample sample) async {
    final db = await database;
    return await db.update(
      'samples',
      sample.toMap(),
      where: 'id = ?',
      whereArgs: [sample.id],
    );
  }

  Future<Map<String, dynamic>> queryById(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results =
        await db.query('samples', where: 'id = ?', whereArgs: [id]);

    return results.single;
  }

  Future<List<Sample>> queryAll() async {
    final db = await instance.database;
    final result = await db.query('samples');
    return result.map((map) => Sample.fromMap(map)).toList();
  }

  Future<void> delete(int? sampleId) async {
    if (sampleId == null) return;
    final db = await instance.database;
    await db.delete(
      'samples',
      where: 'id = ?',
      whereArgs: [sampleId],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

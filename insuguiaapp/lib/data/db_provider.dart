import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProvider {
  static final DBProvider _instance = DBProvider._internal();
  factory DBProvider() => _instance;
  DBProvider._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'insuguia.db');

    // openDatabase irá chamar onCreate se o .db não existir
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Este método só é chamado na primeira vez que o DB é criado
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medicos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        senha TEXT NOT NULL,
        criado_em TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE pacientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        sexo TEXT,
        idade INTEGER,
        peso REAL,
        altura REAL,
        creatinina REAL,
        sensibilidade TEXT,
        criado_em TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }
}

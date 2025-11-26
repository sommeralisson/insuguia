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

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

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
        altura INTEGER,
        creatinina REAL,
        local_internacao TEXT,
        classificacao_clinica TEXT,
        sensibilidade TEXT,
        criado_em TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE glicemias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_id INTEGER NOT NULL,
        valor INTEGER NOT NULL,
        horario TEXT NOT NULL,
        tipo TEXT NOT NULL,
        criado_em TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (paciente_id) REFERENCES pacientes(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE prescricoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_id INTEGER NOT NULL,

        tipo_basal TEXT,
        step REAL,
        tdd REAL,
        basal_total REAL,
        prandial_total REAL,
        prandial_por_refeicao REAL,

        dieta TEXT,
        corticoide TEXT,
        doenca_hepatica INTEGER,
        classificacao_clinica TEXT,

        insulina_basal_schedule TEXT,
        insulina_rapida_tipo TEXT,
        bolus_prandial TEXT,

        notas TEXT,
        criado_em TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }
}

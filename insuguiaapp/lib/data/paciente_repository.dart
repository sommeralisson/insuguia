import 'package:sqflite/sqflite.dart';
import '../models/paciente.dart';
import 'db_provider.dart';

class PacienteRepository {
  final DBProvider _dbProvider = DBProvider();

  Future<int> inserir(Paciente p) async {
    final db = await _dbProvider.database;
    return await db.insert('pacientes', p.toMap());
  }

  Future<List<Paciente>> listar() async {
    final db = await _dbProvider.database;
    final maps = await db.query('pacientes', orderBy: 'id DESC');
    return maps.map((m) => Paciente.fromMap(m)).toList();
  }

  Future<int> deletar(int id) async {
    final db = await _dbProvider.database;
    return await db.delete('pacientes', where: 'id = ?', whereArgs: [id]);
  }
}

import 'package:sqflite/sqflite.dart';
import '../models/glicemia.dart';
import 'db_provider.dart';

class GlicemiaRepository {
  final DBProvider _dbProvider = DBProvider();

  Future<int> inserir(Glicemia g) async {
    final db = await _dbProvider.database;
    return await db.insert('glicemias', g.toMap());
  }

  Future<List<Glicemia>> listarPorPaciente(int pacienteId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'glicemias',
      where: 'paciente_id = ?',
      orderBy: 'criado_em DESC',
      whereArgs: [pacienteId],
    );
    return maps.map((m) => Glicemia.fromMap(m)).toList();
  }

  Future<int> deletar(int id) async {
    final db = await _dbProvider.database;
    return await db.delete('glicemias', where: 'id = ?', whereArgs: [id]);
  }
}

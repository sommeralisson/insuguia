import 'package:sqflite/sqflite.dart';
import '../models/prescricao.dart';
import 'db_provider.dart';

class PrescricaoRepository {
  final DBProvider _dbProvider = DBProvider();

  Future<int> inserir(Prescricao p) async {
    final db = await _dbProvider.database;
    return await db.insert('prescricoes', p.toMap());
  }

  Future<List<Prescricao>> listarPorPaciente(int pacienteId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'prescricoes',
      where: 'paciente_id = ?',
      whereArgs: [pacienteId],
    );
    return maps.map((m) => Prescricao.fromMap(m)).toList();
  }

  Future<int> deletar(int id) async {
    final db = await _dbProvider.database;
    return await db.delete('prescricoes', where: 'id = ?', whereArgs: [id]);
  }
}

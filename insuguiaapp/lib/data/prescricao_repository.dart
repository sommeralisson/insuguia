import 'package:sqflite/sqflite.dart';
import './db_provider.dart';
import '../models/prescricao.dart';

class PrescricaoRepository {
  Future<Database> get _db async => await DBProvider().database;

  Future<int> inserir(Prescricao p) async {
    final db = await _db;
    return await db.insert('prescricoes', p.toMap());
  }

  Future<List<Prescricao>> listarPorPaciente(int pacienteId) async {
    final db = await _db;

    final res = await db.query(
      'prescricoes',
      where: 'paciente_id = ?',
      whereArgs: [pacienteId],
      orderBy: 'id ASC',
    );

    return res.map((m) => Prescricao.fromMap(m)).toList();
  }

  Future<int> deletar(int id) async {
    final db = await _db;
    return await db.delete('prescricoes', where: 'id = ?', whereArgs: [id]);
  }
}

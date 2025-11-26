import 'package:sqflite/sqflite.dart';
import './db_provider.dart';
import '../models/glicemia.dart';

class GlicemiaRepository {
  Future<int> inserir(Glicemia g) async {
    final db = await DBProvider().database;
    return await db.insert(
      'glicemias',
      g.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Glicemia>> listarPorPaciente(int pacienteId) async {
    final db = await DBProvider().database;

    final res = await db.query(
      'glicemias',
      where: 'paciente_id = ?',
      whereArgs: [pacienteId],
      orderBy: 'id DESC',
    );

    return res.map((json) => Glicemia.fromMap(json)).toList();
  }

  Future<int> deletar(int id) async {
    final db = await DBProvider().database;
    return await db.delete('glicemias', where: 'id = ?', whereArgs: [id]);
  }
}

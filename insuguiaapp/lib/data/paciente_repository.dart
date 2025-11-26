import 'package:sqflite/sqflite.dart';
import './db_provider.dart';
import '../models/paciente.dart';

class PacienteRepository {
  Future<int> inserir(Paciente paciente) async {
    final db = await DBProvider().database;
    return await db.insert('pacientes', paciente.toMap());
  }

  Future<List<Paciente>> listar() async {
    final db = await DBProvider().database;
    final res = await db.query('pacientes', orderBy: "id DESC");

    return res.map((map) => Paciente.fromMap(map)).toList();
  }

  Future<int> atualizar(Paciente paciente) async {
    final db = await DBProvider().database;
    return await db.update(
      'pacientes',
      paciente.toMap(),
      where: 'id = ?',
      whereArgs: [paciente.id],
    );
  }

  Future<int> deletar(int id) async {
    final db = await DBProvider().database;
    return await db.delete('pacientes', where: 'id = ?', whereArgs: [id]);
  }
}

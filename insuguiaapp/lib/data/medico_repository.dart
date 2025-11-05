import 'package:sqflite/sqflite.dart';
import '../models/medico.dart';
import 'db_provider.dart'; // Assumindo que este é o caminho correto

class MedicoRepository {
  // DBProvider idealmente deveria ser um singleton,
  // mas vamos manter assim por enquanto.
  final DBProvider _dbProvider = DBProvider();

  Future<int> cadastrar(Medico medico) async {
    final db = await _dbProvider.database;
    return await db.insert(
      'medicos',
      medico.toMap(),
      // MUDANÇA IMPORTANTE AQUI:
      // 'fail' garante que uma DatabaseException seja lançada
      // em caso de conflito (como e-mail único),
      // permitindo que a UI capture o erro.
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<Medico?> login(String email, String senha) async {
    final db = await _dbProvider.database;
    final result = await db.query(
      'medicos',
      where: 'email = ? AND senha = ?',
      whereArgs: [email.trim().toLowerCase(), senha], // Garante consistência
    );
    if (result.isNotEmpty) {
      return Medico.fromMap(result.first);
    }
    return null;
  }
}

import 'package:sqflite/sqflite.dart';

import '../../constants/db_tables.dart';
import '../sqlite_service.dart';

class PaieDao {
  PaieDao({SQLiteService? sqlite}) : _sqlite = sqlite ?? SQLiteService();

  final SQLiteService _sqlite;

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await _sqlite.db;
    return db.insert(DbTables.paieSalaires, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(String id, Map<String, dynamic> data) async {
    final db = await _sqlite.db;
    return db.update(DbTables.paieSalaires, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String id) async {
    final db = await _sqlite.db;
    return db.delete(DbTables.paieSalaires, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final db = await _sqlite.db;
    final rows = await db.query(DbTables.paieSalaires, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<List<Map<String, dynamic>>> list({int? limit, int? offset, String? orderBy}) async {
    final db = await _sqlite.db;
    return db.query(
      DbTables.paieSalaires,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }
}

import 'package:sqflite/sqflite.dart';

import '../../constants/db_tables.dart';
import '../sqlite_service.dart';

class PaieParametresDao {
  PaieParametresDao({SQLiteService? sqlite}) : _sqlite = sqlite ?? SQLiteService();

  final SQLiteService _sqlite;

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await _sqlite.db;
    return db.insert(DbTables.paieParametres, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(String id, Map<String, dynamic> data) async {
    final db = await _sqlite.db;
    return db.update(DbTables.paieParametres, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String id) async {
    final db = await _sqlite.db;
    return db.delete(DbTables.paieParametres, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getByCode(String code) async {
    final db = await _sqlite.db;
    final rows = await db.query(DbTables.paieParametres, where: 'code = ?', whereArgs: [code], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<List<Map<String, dynamic>>> list({int? limit, int? offset, String? orderBy}) async {
    final db = await _sqlite.db;
    return db.query(
      DbTables.paieParametres,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }
}

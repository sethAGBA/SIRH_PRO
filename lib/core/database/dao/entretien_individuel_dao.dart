import 'package:sqflite/sqflite.dart';

import '../../constants/db_tables.dart';
import '../sqlite_service.dart';

class EntretienIndividuelDao {
  EntretienIndividuelDao({SQLiteService? sqlite}) : _sqlite = sqlite ?? SQLiteService();

  final SQLiteService _sqlite;

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await _sqlite.db;
    return db.insert(DbTables.entretiensIndividuels, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(String id, Map<String, dynamic> data) async {
    final db = await _sqlite.db;
    return db.update(DbTables.entretiensIndividuels, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String id) async {
    final db = await _sqlite.db;
    return db.delete(DbTables.entretiensIndividuels, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final db = await _sqlite.db;
    final rows = await db.query(DbTables.entretiensIndividuels, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<List<Map<String, dynamic>>> list({int? limit, int? offset, String? orderBy}) async {
    final db = await _sqlite.db;
    return db.query(
      DbTables.entretiensIndividuels,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> search({
    String? query,
    String? status,
    String? type,
    int? startDate,
    int? endDate,
    int? limit,
    int? offset,
    String? orderBy,
  }) async {
    final db = await _sqlite.db;
    final where = <String>[];
    final args = <Object?>[];

    if (query != null && query.trim().isNotEmpty) {
      where.add('(employe_nom LIKE ? OR poste LIKE ? OR manager LIKE ?)');
      final like = '%${query.trim()}%';
      args.add(like);
      args.add(like);
      args.add(like);
    }
    if (status != null && status.isNotEmpty) {
      where.add('statut = ?');
      args.add(status);
    }
    if (type != null && type.isNotEmpty) {
      where.add('type = ?');
      args.add(type);
    }
    if (startDate != null) {
      where.add('date >= ?');
      args.add(startDate);
    }
    if (endDate != null) {
      where.add('date <= ?');
      args.add(endDate);
    }

    return db.query(
      DbTables.entretiensIndividuels,
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: orderBy ?? 'date DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<int> count({
    String? query,
    String? status,
    String? type,
    int? startDate,
    int? endDate,
  }) async {
    final db = await _sqlite.db;
    final where = <String>[];
    final args = <Object?>[];

    if (query != null && query.trim().isNotEmpty) {
      where.add('(employe_nom LIKE ? OR poste LIKE ? OR manager LIKE ?)');
      final like = '%${query.trim()}%';
      args.add(like);
      args.add(like);
      args.add(like);
    }
    if (status != null && status.isNotEmpty) {
      where.add('statut = ?');
      args.add(status);
    }
    if (type != null && type.isNotEmpty) {
      where.add('type = ?');
      args.add(type);
    }
    if (startDate != null) {
      where.add('date >= ?');
      args.add(startDate);
    }
    if (endDate != null) {
      where.add('date <= ?');
      args.add(endDate);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM ${DbTables.entretiensIndividuels}'
      '${where.isEmpty ? '' : ' WHERE ${where.join(' AND ')}'}',
      args,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

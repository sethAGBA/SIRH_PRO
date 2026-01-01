import 'package:sqflite/sqflite.dart';

import '../../constants/db_tables.dart';
import '../sqlite_service.dart';

class RecrutementDao {
  RecrutementDao({SQLiteService? sqlite}) : _sqlite = sqlite ?? SQLiteService();

  final SQLiteService _sqlite;

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await _sqlite.db;
    return db.insert(DbTables.recrutements, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(String id, Map<String, dynamic> data) async {
    final db = await _sqlite.db;
    return db.update(DbTables.recrutements, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String id) async {
    final db = await _sqlite.db;
    return db.delete(DbTables.recrutements, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final db = await _sqlite.db;
    final rows = await db.query(DbTables.recrutements, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<List<Map<String, dynamic>>> list({int? limit, int? offset, String? orderBy}) async {
    final db = await _sqlite.db;
    return db.query(
      DbTables.recrutements,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> search({
    String? query,
    String? posteId,
    String? status,
    String? stage,
    String? source,
    int? limit,
    int? offset,
    String? orderBy,
  }) async {
    final db = await _sqlite.db;
    final where = <String>[];
    final args = <Object?>[];

    if (query != null && query.trim().isNotEmpty) {
      where.add('(candidat_nom LIKE ? OR poste_nom LIKE ?)');
      final like = '%${query.trim()}%';
      args.add(like);
      args.add(like);
    }
    if (posteId != null && posteId.isNotEmpty) {
      where.add('poste_id = ?');
      args.add(posteId);
    }
    if (status != null && status.isNotEmpty) {
      where.add('statut = ?');
      args.add(status);
    }
    if (stage != null && stage.isNotEmpty) {
      where.add('stage = ?');
      args.add(stage);
    }
    if (source != null && source.isNotEmpty) {
      where.add('source = ?');
      args.add(source);
    }

    return db.query(
      DbTables.recrutements,
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: orderBy ?? 'created_at DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<int> count({
    String? query,
    String? posteId,
    String? status,
    String? stage,
    String? source,
  }) async {
    final db = await _sqlite.db;
    final where = <String>[];
    final args = <Object?>[];

    if (query != null && query.trim().isNotEmpty) {
      where.add('(candidat_nom LIKE ? OR poste_nom LIKE ?)');
      final like = '%${query.trim()}%';
      args.add(like);
      args.add(like);
    }
    if (posteId != null && posteId.isNotEmpty) {
      where.add('poste_id = ?');
      args.add(posteId);
    }
    if (status != null && status.isNotEmpty) {
      where.add('statut = ?');
      args.add(status);
    }
    if (stage != null && stage.isNotEmpty) {
      where.add('stage = ?');
      args.add(stage);
    }
    if (source != null && source.isNotEmpty) {
      where.add('source = ?');
      args.add(source);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM ${DbTables.recrutements}'
      '${where.isEmpty ? '' : ' WHERE ${where.join(' AND ')}'}',
      args,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

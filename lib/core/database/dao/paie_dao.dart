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

  Future<List<Map<String, dynamic>>> search({
    String? query,
    String? period,
    String? status,
    int? limit,
    int? offset,
    String? orderBy,
  }) async {
    final db = await _sqlite.db;
    final where = <String>[];
    final args = <Object?>[];
    if (query != null && query.trim().isNotEmpty) {
      final like = '%${query.trim()}%';
      where.add('(e.nom_complet LIKE ? OR e.matricule LIKE ?)');
      args.addAll([like, like]);
    }
    if (period != null && period.isNotEmpty) {
      where.add('p.periode = ?');
      args.add(period);
    }
    if (status != null && status.isNotEmpty) {
      where.add('p.statut = ?');
      args.add(status);
    }
    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final orderClause = orderBy == null || orderBy.isEmpty ? 'p.created_at DESC' : orderBy;
    final limitClause = limit == null ? '' : 'LIMIT $limit';
    final offsetClause = offset == null ? '' : 'OFFSET $offset';
    return db.rawQuery(
      '''
      SELECT p.*
      FROM ${DbTables.paieSalaires} p
      LEFT JOIN ${DbTables.employes} e ON e.id = p.employe_id
      $whereClause
      ORDER BY $orderClause
      $limitClause
      $offsetClause
      ''',
      args,
    );
  }

  Future<int> count({String? query, String? period, String? status}) async {
    final db = await _sqlite.db;
    final where = <String>[];
    final args = <Object?>[];
    if (query != null && query.trim().isNotEmpty) {
      final like = '%${query.trim()}%';
      where.add('(e.nom_complet LIKE ? OR e.matricule LIKE ?)');
      args.addAll([like, like]);
    }
    if (period != null && period.isNotEmpty) {
      where.add('p.periode = ?');
      args.add(period);
    }
    if (status != null && status.isNotEmpty) {
      where.add('p.statut = ?');
      args.add(status);
    }
    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM ${DbTables.paieSalaires} p
      LEFT JOIN ${DbTables.employes} e ON e.id = p.employe_id
      $whereClause
      ''',
      args,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<String>> listPeriods() async {
    final db = await _sqlite.db;
    final rows = await db.rawQuery(
      '''
      SELECT DISTINCT periode
      FROM ${DbTables.paieSalaires}
      WHERE periode IS NOT NULL AND periode != ''
      ORDER BY periode DESC
      ''',
    );
    return rows.map((row) => (row['periode'] as String?) ?? '').where((p) => p.isNotEmpty).toList();
  }
}

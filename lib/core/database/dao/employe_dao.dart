import 'package:sqflite/sqflite.dart';

import '../../constants/db_tables.dart';
import '../sqlite_service.dart';

class EmployeDao {
  EmployeDao({SQLiteService? sqlite}) : _sqlite = sqlite ?? SQLiteService();

  final SQLiteService _sqlite;

  _WhereClause _buildWhere({
    String? department,
    String? role,
    String? contractType,
    String? status,
    int? hireDateStart,
    int? hireDateEnd,
    String? name,
    String? matricule,
    String? phone,
    String? email,
    String? skills,
    String? excludeId,
  }) {
    final parts = <String>[];
    final args = <Object?>[];

    if (department != null && department.isNotEmpty) {
      parts.add('departement_id = ?');
      args.add(department);
    }
    if (role != null && role.isNotEmpty) {
      parts.add('poste_id = ?');
      args.add(role);
    }
    if (contractType != null && contractType.isNotEmpty) {
      parts.add('contract_type = ?');
      args.add(contractType);
    }
    if (status != null && status.isNotEmpty) {
      parts.add('statut_employe = ?');
      args.add(status);
    }
    if (hireDateStart != null && hireDateEnd != null) {
      parts.add('date_embauche BETWEEN ? AND ?');
      args.add(hireDateStart);
      args.add(hireDateEnd);
    } else if (hireDateStart != null) {
      parts.add('date_embauche >= ?');
      args.add(hireDateStart);
    } else if (hireDateEnd != null) {
      parts.add('date_embauche <= ?');
      args.add(hireDateEnd);
    }

    if (name != null && name.trim().isNotEmpty) {
      parts.add('nom_complet LIKE ? COLLATE NOCASE');
      args.add('%${name.trim()}%');
    }
    if (matricule != null && matricule.trim().isNotEmpty) {
      parts.add('matricule LIKE ? COLLATE NOCASE');
      args.add('%${matricule.trim()}%');
    }
    if (phone != null && phone.trim().isNotEmpty) {
      parts.add('telephone LIKE ?');
      args.add('%${phone.trim()}%');
    }
    if (email != null && email.trim().isNotEmpty) {
      parts.add('email LIKE ? COLLATE NOCASE');
      args.add('%${email.trim()}%');
    }
    if (skills != null && skills.trim().isNotEmpty) {
      parts.add('skills LIKE ? COLLATE NOCASE');
      args.add('%${skills.trim()}%');
    }

    if (excludeId != null && excludeId.isNotEmpty) {
      parts.add('id != ?');
      args.add(excludeId);
    }

    final where = parts.isEmpty ? '' : parts.join(' AND ');
    return _WhereClause(where, args);
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await _sqlite.db;
    return db.insert(DbTables.employes, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(String id, Map<String, dynamic> data) async {
    final db = await _sqlite.db;
    return db.update(DbTables.employes, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String id) async {
    final db = await _sqlite.db;
    return db.delete(DbTables.employes, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final db = await _sqlite.db;
    final rows = await db.query(DbTables.employes, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<List<Map<String, dynamic>>> list({int? limit, int? offset, String? orderBy}) async {
    final db = await _sqlite.db;
    return db.query(
      DbTables.employes,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> search({
    String? department,
    String? role,
    String? contractType,
    String? status,
    int? hireDateStart,
    int? hireDateEnd,
    String? name,
    String? matricule,
    String? phone,
    String? email,
    String? skills,
    int? limit,
    int? offset,
    String? orderBy,
  }) async {
    final db = await _sqlite.db;
    final clause = _buildWhere(
      department: department,
      role: role,
      contractType: contractType,
      status: status,
      hireDateStart: hireDateStart,
      hireDateEnd: hireDateEnd,
      name: name,
      matricule: matricule,
      phone: phone,
      email: email,
      skills: skills,
    );
    return db.query(
      DbTables.employes,
      where: clause.where.isEmpty ? null : clause.where,
      whereArgs: clause.args,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> count({
    String? department,
    String? role,
    String? contractType,
    String? status,
    int? hireDateStart,
    int? hireDateEnd,
    String? name,
    String? matricule,
    String? phone,
    String? email,
    String? skills,
  }) async {
    final db = await _sqlite.db;
    final clause = _buildWhere(
      department: department,
      role: role,
      contractType: contractType,
      status: status,
      hireDateStart: hireDateStart,
      hireDateEnd: hireDateEnd,
      name: name,
      matricule: matricule,
      phone: phone,
      email: email,
      skills: skills,
    );
    final whereSql = clause.where.isEmpty ? '' : 'WHERE ${clause.where}';
    final rows = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DbTables.employes} $whereSql',
      clause.args,
    );
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  Future<bool> existsByEmail(String email, {String? excludeId}) async {
    final db = await _sqlite.db;
    final parts = <String>['LOWER(email) = LOWER(?)'];
    final args = <Object?>[email];
    if (excludeId != null && excludeId.isNotEmpty) {
      parts.add('id != ?');
      args.add(excludeId);
    }
    final rows = await db.query(
      DbTables.employes,
      where: parts.join(' AND '),
      whereArgs: args,
      columns: const ['id'],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<bool> existsByMatricule(String matricule, {String? excludeId}) async {
    final db = await _sqlite.db;
    final parts = <String>['matricule = ?'];
    final args = <Object?>[matricule];
    if (excludeId != null && excludeId.isNotEmpty) {
      parts.add('id != ?');
      args.add(excludeId);
    }
    final rows = await db.query(
      DbTables.employes,
      where: parts.join(' AND '),
      whereArgs: args,
      columns: const ['id'],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}

class _WhereClause {
  const _WhereClause(this.where, this.args);

  final String where;
  final List<Object?> args;
}

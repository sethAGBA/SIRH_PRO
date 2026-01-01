import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../database/sqlite_service.dart';

class AuthResult {
  AuthResult({required this.success, this.message, this.user, this.mustChangePassword = false});

  final bool success;
  final String? message;
  final Map<String, dynamic>? user;
  final bool mustChangePassword;
}

class AuthService {
  AuthService({SQLiteService? sqlite}) : _sqlite = sqlite ?? SQLiteService();

  final SQLiteService _sqlite;

  Future<AuthResult> login(String email, String password, {bool rememberMe = false}) async {
    final identifier = email.trim();
    if (identifier.isEmpty || password.trim().isEmpty) {
      return AuthResult(success: false, message: 'Email ou identifiant requis.');
    }

    final db = await _sqlite.db;
    final rows = await _findUser(db, identifier);
    if (rows.isEmpty) {
      return AuthResult(success: false, message: 'Compte introuvable.');
    }

    final user = rows.first;
    final status = (user['statut'] as String?) ?? 'Actif';
    if (status != 'Actif') {
      return AuthResult(success: false, message: 'Compte desactive.');
    }

    final storedHash = user['password_hash'] as String?;
    if (storedHash == null || storedHash.isEmpty) {
      return AuthResult(success: false, message: 'Mot de passe non defini.');
    }

    final inputHash = sha256.convert(utf8.encode(password)).toString();
    if (storedHash != inputHash) {
      return AuthResult(success: false, message: 'Email ou mot de passe incorrect.');
    }

    await db.update(
      'utilisateurs_systeme',
      {'last_login': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [user['id']],
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', rememberMe);
    if (rememberMe) {
      await prefs.setString('remember_email', identifier);
    } else {
      await prefs.remove('remember_email');
    }
    await prefs.setString('current_user_name', (user['nom'] as String?) ?? 'Utilisateur');
    await prefs.setString('current_user_email', (user['email'] as String?) ?? '');

    final mustChange = (user['must_change_password'] as int?) == 1;
    return AuthResult(success: true, user: user, mustChangePassword: mustChange);
  }

  Future<List<Map<String, Object?>>> _findUser(Database db, String identifier) async {
    if (identifier.contains('@')) {
      return db.query(
        'utilisateurs_systeme',
        where: 'LOWER(email) = ?',
        whereArgs: [identifier.toLowerCase()],
        limit: 1,
      );
    }
    return db.query(
      'utilisateurs_systeme',
      where: 'nom = ? OR id = ?',
      whereArgs: [identifier, identifier],
      limit: 1,
    );
  }

  Future<void> updatePasswordById(String userId, String newPassword) async {
    final db = await _sqlite.db;
    final passwordHash = sha256.convert(utf8.encode(newPassword)).toString();
    await db.update(
      'utilisateurs_systeme',
      {
        'password_hash': passwordHash,
        'must_change_password': 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updatePasswordByEmail(String email, String newPassword) async {
    final db = await _sqlite.db;
    final passwordHash = sha256.convert(utf8.encode(newPassword)).toString();
    await db.update(
      'utilisateurs_systeme',
      {
        'password_hash': passwordHash,
        'must_change_password': 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_name');
    await prefs.remove('current_user_email');
  }

  Future<Map<String, String>> getCurrentUserSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('current_user_name') ?? 'Utilisateur';
    final email = prefs.getString('current_user_email') ?? '';
    return {'name': name, 'email': email};
  }
}

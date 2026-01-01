import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:convert';

class SQLiteService {
  static final SQLiteService _instance = SQLiteService._internal();
  factory SQLiteService() => _instance;
  SQLiteService._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    await init();
    return _db!;
  }

  Future<void> init({String? dbPath, bool useInMemory = false}) async {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      sqfliteFfiInit();
    }

    final pathToOpen = await _resolvePath(dbPath: dbPath, useInMemory: useInMemory);
    final dbFactory = (Platform.isMacOS || Platform.isLinux || Platform.isWindows)
        ? databaseFactoryFfi
        : databaseFactory;

    _db = await dbFactory.openDatabase(
      pathToOpen,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await _createSchema(db);
        },
        onOpen: (db) async {
          await _ensureSchema(db);
          await _ensureDefaultAdmin(db);
        },
      ),
    );
  }

  static Future<SQLiteService> inMemory() async {
    final service = SQLiteService._internal();
    await service.init(useInMemory: true);
    return service;
  }

  Future<String> _resolvePath({String? dbPath, required bool useInMemory}) async {
    if (useInMemory) return ':memory:';
    if (dbPath != null) return dbPath;
    final documents = await getApplicationDocumentsDirectory();
    return p.join(documents.path, 'sirhpro.db');
  }

  Future<void> _createSchema(Database db) async {
    for (final table in _schema.keys) {
      final columns = _schema[table]!;
      final sql = 'CREATE TABLE $table (${columns.entries.map((e) => '${e.key} ${e.value}').join(', ')})';
      await db.execute(sql);
    }
  }

  Future<void> _ensureSchema(Database db) async {
    for (final table in _schema.keys) {
      final exists = await _tableExists(db, table);
      if (!exists) {
        final columns = _schema[table]!;
        final sql = 'CREATE TABLE $table (${columns.entries.map((e) => '${e.key} ${e.value}').join(', ')})';
        await db.execute(sql);
        continue;
      }

      final columns = _schema[table]!;
      for (final entry in columns.entries) {
        final hasColumn = await _columnExists(db, table, entry.key);
        if (!hasColumn) {
          await db.execute('ALTER TABLE $table ADD COLUMN ${entry.key} ${entry.value}');
        }
      }
    }
  }

  Future<bool> _tableExists(Database db, String table) async {
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [table],
    );
    return rows.isNotEmpty;
  }

  Future<bool> _columnExists(Database db, String table, String column) async {
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    return rows.any((row) => row['name'] == column);
  }

  Future<void> _ensureDefaultAdmin(Database db) async {
    final rows = await db.query('utilisateurs_systeme', limit: 1);
    if (rows.isNotEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final passwordHash = sha256.convert(utf8.encode('admin')).toString();
    await db.insert('utilisateurs_systeme', {
      'id': 'admin-001',
      'nom': 'Administrateur',
      'email': 'admin@gmail.com',
      'role': 'Administrateur RH',
      'statut': 'Actif',
      'password_hash': passwordHash,
      'is_active': 1,
      'must_change_password': 1,
      'last_login': null,
      'created_at': now,
      'updated_at': now,
    });
  }
}

final Map<String, Map<String, String>> _schema = {
  'employes': {
    'id': 'TEXT PRIMARY KEY',
    'matricule': 'TEXT',
    'nom_complet': 'TEXT',
    'departement_id': 'TEXT',
    'poste_id': 'TEXT',
    'statut_contrat': 'TEXT',
    'date_embauche': 'INTEGER',
    'telephone': 'TEXT',
    'email': 'TEXT',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'departements': {
    'id': 'TEXT PRIMARY KEY',
    'nom': 'TEXT',
    'manager_id': 'TEXT',
    'effectif': 'INTEGER',
    'budget_masse_salariale': 'REAL',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'postes': {
    'id': 'TEXT PRIMARY KEY',
    'intitule': 'TEXT',
    'description': 'TEXT',
    'departement_id': 'TEXT',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'contrats': {
    'id': 'TEXT PRIMARY KEY',
    'employe_id': 'TEXT',
    'type': 'TEXT',
    'date_debut': 'INTEGER',
    'date_fin': 'INTEGER',
    'statut': 'TEXT',
    'salaire_base': 'REAL',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'presences': {
    'id': 'TEXT PRIMARY KEY',
    'employe_id': 'TEXT',
    'date': 'INTEGER',
    'heure_arrivee': 'TEXT',
    'heure_depart': 'TEXT',
    'statut': 'TEXT',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'conges_absences': {
    'id': 'TEXT PRIMARY KEY',
    'employe_id': 'TEXT',
    'type': 'TEXT',
    'date_debut': 'INTEGER',
    'date_fin': 'INTEGER',
    'statut': 'TEXT',
    'motif': 'TEXT',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'formations': {
    'id': 'TEXT PRIMARY KEY',
    'titre': 'TEXT',
    'categorie': 'TEXT',
    'date_debut': 'INTEGER',
    'date_fin': 'INTEGER',
    'budget': 'REAL',
    'statut': 'TEXT',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'evaluations_performance': {
    'id': 'TEXT PRIMARY KEY',
    'employe_id': 'TEXT',
    'periode': 'TEXT',
    'statut': 'TEXT',
    'note_globale': 'REAL',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'competences': {
    'id': 'TEXT PRIMARY KEY',
    'employe_id': 'TEXT',
    'libelle': 'TEXT',
    'niveau': 'TEXT',
    'certification': 'TEXT',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'recrutements': {
    'id': 'TEXT PRIMARY KEY',
    'poste_id': 'TEXT',
    'candidat_nom': 'TEXT',
    'statut': 'TEXT',
    'source': 'TEXT',
    'score': 'INTEGER',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'paie_salaires': {
    'id': 'TEXT PRIMARY KEY',
    'employe_id': 'TEXT',
    'periode': 'TEXT',
    'brut': 'REAL',
    'net': 'REAL',
    'statut': 'TEXT',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'avantages_sociaux': {
    'id': 'TEXT PRIMARY KEY',
    'employe_id': 'TEXT',
    'type': 'TEXT',
    'valeur': 'REAL',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'sanctions_avertissements': {
    'id': 'TEXT PRIMARY KEY',
    'employe_id': 'TEXT',
    'type': 'TEXT',
    'date': 'INTEGER',
    'statut': 'TEXT',
    'motif': 'TEXT',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'notes_frais': {
    'id': 'TEXT PRIMARY KEY',
    'employe_id': 'TEXT',
    'categorie': 'TEXT',
    'montant': 'REAL',
    'statut': 'TEXT',
    'date': 'INTEGER',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'equipements_materiel': {
    'id': 'TEXT PRIMARY KEY',
    'employe_id': 'TEXT',
    'type': 'TEXT',
    'reference': 'TEXT',
    'statut': 'TEXT',
    'date_attribution': 'INTEGER',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'documents_employes': {
    'id': 'TEXT PRIMARY KEY',
    'employe_id': 'TEXT',
    'type': 'TEXT',
    'fichier': 'TEXT',
    'date': 'INTEGER',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'organigramme': {
    'id': 'TEXT PRIMARY KEY',
    'parent_id': 'TEXT',
    'label': 'TEXT',
    'type': 'TEXT',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'plannings_horaires': {
    'id': 'TEXT PRIMARY KEY',
    'employe_id': 'TEXT',
    'jour': 'TEXT',
    'heure_debut': 'TEXT',
    'heure_fin': 'TEXT',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'incidents_accidents': {
    'id': 'TEXT PRIMARY KEY',
    'employe_id': 'TEXT',
    'type': 'TEXT',
    'date': 'INTEGER',
    'statut': 'TEXT',
    'description': 'TEXT',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'entretiens_individuels': {
    'id': 'TEXT PRIMARY KEY',
    'employe_id': 'TEXT',
    'date': 'INTEGER',
    'statut': 'TEXT',
    'notes': 'TEXT',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'mobilite_interne': {
    'id': 'TEXT PRIMARY KEY',
    'employe_id': 'TEXT',
    'type': 'TEXT',
    'date': 'INTEGER',
    'statut': 'TEXT',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'reporting_rh': {
    'id': 'TEXT PRIMARY KEY',
    'type': 'TEXT',
    'periode': 'TEXT',
    'fichier': 'TEXT',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'parametres_entreprise': {
    'id': 'TEXT PRIMARY KEY',
    'raison_sociale': 'TEXT',
    'siret': 'TEXT',
    'convention_collective': 'TEXT',
    'adresse': 'TEXT',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'utilisateurs_systeme': {
    'id': 'TEXT PRIMARY KEY',
    'nom': 'TEXT',
    'email': 'TEXT',
    'role': 'TEXT',
    'statut': 'TEXT',
    'telephone': 'TEXT',
    'departement': 'TEXT',
    'password_hash': 'TEXT',
    'is_active': 'INTEGER DEFAULT 1',
    'must_change_password': 'INTEGER DEFAULT 0',
    'last_login': 'INTEGER',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
};

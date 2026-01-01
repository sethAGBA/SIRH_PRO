import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:convert';

class SQLiteService {
  static const int _schemaVersion = 16;
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
        version: _schemaVersion,
        onCreate: (db, version) async {
          await _createSchema(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          await _migrateSchema(db, oldVersion, newVersion);
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

  Future<void> _migrateSchema(Database db, int oldVersion, int newVersion) async {
    for (var version = oldVersion + 1; version <= newVersion; version++) {
      if (version == 2) {
        await _migrateToV2(db);
      }
      if (version == 3) {
        await _migrateToV3(db);
      }
      if (version == 4) {
        await _migrateToV4(db);
      }
      if (version == 5) {
        await _migrateToV5(db);
      }
      if (version == 6) {
        await _migrateToV6(db);
      }
      if (version == 7) {
        await _migrateToV7(db);
      }
      if (version == 8) {
        await _migrateToV8(db);
      }
      if (version == 9) {
        await _migrateToV9(db);
      }
      if (version == 10) {
        await _migrateToV10(db);
      }
      if (version == 11) {
        await _migrateToV11(db);
      }
      if (version == 12) {
        await _migrateToV12(db);
      }
      if (version == 13) {
        await _migrateToV13(db);
      }
      if (version == 14) {
        await _migrateToV14(db);
      }
      if (version == 15) {
        await _migrateToV15(db);
      }
      if (version == 16) {
        await _migrateToV16(db);
      }
    }
  }

  Future<void> _migrateToV2(Database db) async {
    final table = 'employes';
    final columns = _schema[table]!;
    final exists = await _tableExists(db, table);
    if (!exists) {
      final sql = 'CREATE TABLE $table (${columns.entries.map((e) => '${e.key} ${e.value}').join(', ')})';
      await db.execute(sql);
      return;
    }
    for (final entry in columns.entries) {
      await _addColumnIfMissing(db, table, entry.key, entry.value);
    }
  }

  Future<void> _migrateToV3(Database db) async {
    final table = 'departements';
    final columns = _schema[table]!;
    final exists = await _tableExists(db, table);
    if (!exists) {
      final sql = 'CREATE TABLE $table (${columns.entries.map((e) => '${e.key} ${e.value}').join(', ')})';
      await db.execute(sql);
      return;
    }
    for (final entry in columns.entries) {
      await _addColumnIfMissing(db, table, entry.key, entry.value);
    }
  }

  Future<void> _migrateToV4(Database db) async {
    final table = 'departements';
    final columns = _schema[table]!;
    final exists = await _tableExists(db, table);
    if (!exists) {
      final sql = 'CREATE TABLE $table (${columns.entries.map((e) => '${e.key} ${e.value}').join(', ')})';
      await db.execute(sql);
      return;
    }
    for (final entry in columns.entries) {
      await _addColumnIfMissing(db, table, entry.key, entry.value);
    }
  }

  Future<void> _migrateToV5(Database db) async {
    final table = 'departements';
    final columns = _schema[table]!;
    final exists = await _tableExists(db, table);
    if (!exists) {
      final sql = 'CREATE TABLE $table (${columns.entries.map((e) => '${e.key} ${e.value}').join(', ')})';
      await db.execute(sql);
      return;
    }
    for (final entry in columns.entries) {
      await _addColumnIfMissing(db, table, entry.key, entry.value);
    }
  }

  Future<void> _migrateToV6(Database db) async {
    final table = 'departements';
    final columns = _schema[table]!;
    final exists = await _tableExists(db, table);
    if (!exists) {
      final sql = 'CREATE TABLE $table (${columns.entries.map((e) => '${e.key} ${e.value}').join(', ')})';
      await db.execute(sql);
      return;
    }
    for (final entry in columns.entries) {
      await _addColumnIfMissing(db, table, entry.key, entry.value);
    }
  }

  Future<void> _migrateToV7(Database db) async {
    final table = 'departements';
    final columns = _schema[table]!;
    final exists = await _tableExists(db, table);
    if (!exists) {
      final sql = 'CREATE TABLE $table (${columns.entries.map((e) => '${e.key} ${e.value}').join(', ')})';
      await db.execute(sql);
      return;
    }
    for (final entry in columns.entries) {
      await _addColumnIfMissing(db, table, entry.key, entry.value);
    }
  }

  Future<void> _migrateToV8(Database db) async {
    final table = 'postes';
    final columns = _schema[table]!;
    final exists = await _tableExists(db, table);
    if (!exists) {
      final sql = 'CREATE TABLE $table (${columns.entries.map((e) => '${e.key} ${e.value}').join(', ')})';
      await db.execute(sql);
      return;
    }
    for (final entry in columns.entries) {
      await _addColumnIfMissing(db, table, entry.key, entry.value);
    }
  }

  Future<void> _migrateToV9(Database db) async {
    final deptRows = await db.query('departements', columns: ['id', 'nom']);
    final posteRows = await db.query('postes', columns: ['id', 'intitule']);
    final deptByName = <String, String>{};
    for (final row in deptRows) {
      final name = row['nom'] as String?;
      final id = row['id'] as String?;
      if (name != null && id != null && name.isNotEmpty) {
        deptByName[name] = id;
      }
    }
    final posteByName = <String, String>{};
    for (final row in posteRows) {
      final name = row['intitule'] as String?;
      final id = row['id'] as String?;
      if (name != null && id != null && name.isNotEmpty) {
        posteByName[name] = id;
      }
    }

    final employees = await db.query('employes', columns: ['id', 'departement_id', 'poste_id']);
    for (final row in employees) {
      final id = row['id'] as String?;
      if (id == null || id.isEmpty) continue;
      final currentDept = row['departement_id'] as String?;
      final currentPoste = row['poste_id'] as String?;
      final update = <String, Object?>{};
      if (currentDept != null && deptByName.containsKey(currentDept)) {
        update['departement_id'] = deptByName[currentDept];
      }
      if (currentPoste != null && posteByName.containsKey(currentPoste)) {
        update['poste_id'] = posteByName[currentPoste];
      }
      if (update.isNotEmpty) {
        await db.update('employes', update, where: 'id = ?', whereArgs: [id]);
      }
    }
  }

  Future<void> _migrateToV10(Database db) async {
    final table = 'presences';
    final columns = _schema[table]!;
    final exists = await _tableExists(db, table);
    if (!exists) {
      final sql = 'CREATE TABLE $table (${columns.entries.map((e) => '${e.key} ${e.value}').join(', ')})';
      await db.execute(sql);
      return;
    }
    for (final entry in columns.entries) {
      await _addColumnIfMissing(db, table, entry.key, entry.value);
    }
  }

  Future<void> _migrateToV11(Database db) async {
    final table = 'conges_absences';
    final columns = _schema[table]!;
    final exists = await _tableExists(db, table);
    if (!exists) {
      final sql = 'CREATE TABLE $table (${columns.entries.map((e) => '${e.key} ${e.value}').join(', ')})';
      await db.execute(sql);
      return;
    }
    for (final entry in columns.entries) {
      await _addColumnIfMissing(db, table, entry.key, entry.value);
    }
  }

  Future<void> _migrateToV12(Database db) async {
    final table = 'conges_absences';
    final columns = _schema[table]!;
    final exists = await _tableExists(db, table);
    if (!exists) {
      final sql = 'CREATE TABLE $table (${columns.entries.map((e) => '${e.key} ${e.value}').join(', ')})';
      await db.execute(sql);
      return;
    }
    for (final entry in columns.entries) {
      await _addColumnIfMissing(db, table, entry.key, entry.value);
    }
  }

  Future<void> _migrateToV13(Database db) async {
    final table = 'recrutements';
    final columns = _schema[table]!;
    final exists = await _tableExists(db, table);
    if (!exists) {
      final sql = 'CREATE TABLE $table (${columns.entries.map((e) => '${e.key} ${e.value}').join(', ')})';
      await db.execute(sql);
      return;
    }
    for (final entry in columns.entries) {
      await _addColumnIfMissing(db, table, entry.key, entry.value);
    }
  }

  Future<void> _migrateToV14(Database db) async {
    final table = 'postes';
    final columns = _schema[table]!;
    final exists = await _tableExists(db, table);
    if (!exists) {
      final sql = 'CREATE TABLE $table (${columns.entries.map((e) => '${e.key} ${e.value}').join(', ')})';
      await db.execute(sql);
      return;
    }
    for (final entry in columns.entries) {
      await _addColumnIfMissing(db, table, entry.key, entry.value);
    }
  }

  Future<void> _migrateToV15(Database db) async {
    final table = 'recrutements';
    final columns = _schema[table]!;
    final exists = await _tableExists(db, table);
    if (!exists) {
      final sql = 'CREATE TABLE $table (${columns.entries.map((e) => '${e.key} ${e.value}').join(', ')})';
      await db.execute(sql);
      return;
    }
    for (final entry in columns.entries) {
      await _addColumnIfMissing(db, table, entry.key, entry.value);
    }
  }

  Future<void> _migrateToV16(Database db) async {
    const tables = ['formations', 'entretiens_individuels'];
    for (final table in tables) {
      final columns = _schema[table]!;
      final exists = await _tableExists(db, table);
      if (!exists) {
        final sql = 'CREATE TABLE $table (${columns.entries.map((e) => '${e.key} ${e.value}').join(', ')})';
        await db.execute(sql);
        continue;
      }
      for (final entry in columns.entries) {
        await _addColumnIfMissing(db, table, entry.key, entry.value);
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

  Future<void> _addColumnIfMissing(Database db, String table, String column, String type) async {
    final hasColumn = await _columnExists(db, table, column);
    if (!hasColumn) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    }
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
    'contract_type': 'TEXT',
    'statut_contrat': 'TEXT',
    'statut_employe': 'TEXT',
    'tenure': 'TEXT',
    'date_embauche': 'INTEGER',
    'telephone': 'TEXT',
    'email': 'TEXT',
    'skills': 'TEXT',
    'date_naissance': 'TEXT',
    'lieu_naissance': 'TEXT',
    'nationalite': 'TEXT',
    'etat_civil_detaille': 'TEXT',
    'nir': 'TEXT',
    'situation_familiale': 'TEXT',
    'adresse': 'TEXT',
    'contact_urgence': 'TEXT',
    'cni': 'TEXT',
    'passeport': 'TEXT',
    'permis': 'TEXT',
    'titre_sejour': 'TEXT',
    'rib': 'TEXT',
    'bic': 'TEXT',
    'salaire_verse': 'TEXT',
    'poste_actuel': 'TEXT',
    'poste_precedent': 'TEXT',
    'derniere_promotion': 'TEXT',
    'augmentation': 'TEXT',
    'objectifs': 'TEXT',
    'evaluation': 'TEXT',
    'contract_start_date': 'TEXT',
    'contract_end_date': 'TEXT',
    'periode_essai_duree': 'TEXT',
    'periode_essai_fin': 'TEXT',
    'temps_travail_type': 'TEXT',
    'temps_partiel_pourcentage': 'TEXT',
    'classification': 'TEXT',
    'coefficient': 'TEXT',
    'convention_collective': 'TEXT',
    'statut_cadre': 'TEXT',
    'avenants': 'TEXT',
    'charte_informatique': 'TEXT',
    'confidentialite': 'TEXT',
    'clauses_signees': 'TEXT',
    'carte_vitale': 'TEXT',
    'justificatif_domicile': 'TEXT',
    'diplomes_certifies': 'TEXT',
    'habilitations': 'TEXT',
    'diplome': 'TEXT',
    'certification': 'TEXT',
    'formations_suivies': 'TEXT',
    'formations_planifiees': 'TEXT',
    'competences_tech': 'TEXT',
    'competences_comport': 'TEXT',
    'langues': 'TEXT',
    'conges_restants': 'TEXT',
    'rtt_restants': 'TEXT',
    'absences_justifiees': 'TEXT',
    'retards': 'TEXT',
    'teletravail': 'TEXT',
    'dernier_pointage': 'TEXT',
    'planning_contractuel': 'TEXT',
    'quota_heures': 'TEXT',
    'solde_conges_calcule': 'TEXT',
    'rtt_periode': 'TEXT',
    'salaire_base': 'TEXT',
    'prime_performance': 'TEXT',
    'mutuelle': 'TEXT',
    'ticket_restaurant': 'TEXT',
    'dernier_bulletin': 'TEXT',
    'historique_bulletins': 'TEXT',
    'regime_fiscal': 'TEXT',
    'taux_pas': 'TEXT',
    'mode_paiement': 'TEXT',
    'variables_recurrence': 'TEXT',
    'pc_portable': 'TEXT',
    'telephone_pro': 'TEXT',
    'badge_acces': 'TEXT',
    'licence': 'TEXT',
    'manager': 'TEXT',
    'entite_legale': 'TEXT',
    'site_affectation': 'TEXT',
    'centre_cout': 'TEXT',
    'consentement_rgpd': 'TEXT',
    'habilitations_systemes': 'TEXT',
    'historique_modifications': 'TEXT',
    'visites_medicales': 'TEXT',
    'aptitude_medicale': 'TEXT',
    'restrictions_poste': 'TEXT',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'departements': {
    'id': 'TEXT PRIMARY KEY',
    'nom': 'TEXT',
    'manager_id': 'TEXT',
    'manager_nom': 'TEXT',
    'effectif': 'INTEGER',
    'budget_masse_salariale': 'REAL',
    'budget_affiche': 'TEXT',
    'pole': 'TEXT',
    'taille': 'TEXT',
    'localisation': 'TEXT',
    'code': 'TEXT',
    'description': 'TEXT',
    'email': 'TEXT',
    'telephone': 'TEXT',
    'extension': 'TEXT',
    'adresse': 'TEXT',
    'parent_departement': 'TEXT',
    'parent_departement_id': 'TEXT',
    'parent_departement_nom': 'TEXT',
    'date_creation': 'TEXT',
    'notes': 'TEXT',
    'responsables': 'TEXT',
    'cadres_count': 'TEXT',
    'techniciens_count': 'TEXT',
    'support_count': 'TEXT',
    'variation_annuelle': 'TEXT',
    'taux_absenteisme': 'TEXT',
    'productivite_moyenne': 'TEXT',
    'satisfaction_equipe': 'TEXT',
    'turnover_departement': 'TEXT',
    'budget_vs_realise': 'TEXT',
    'salaires_totaux': 'TEXT',
    'primes_variables': 'TEXT',
    'charges_sociales': 'TEXT',
    'cout_moyen_employe': 'TEXT',
    'objectif_principal': 'TEXT',
    'indicateur_objectif': 'TEXT',
    'projet_en_cours': 'TEXT',
    'ressources_necessaires': 'TEXT',
    'statut': 'TEXT',
    'deleted_at': 'INTEGER',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'postes': {
    'id': 'TEXT PRIMARY KEY',
    'code': 'TEXT',
    'intitule': 'TEXT',
    'description': 'TEXT',
    'departement_id': 'TEXT',
    'departement_nom': 'TEXT',
    'niveau': 'TEXT',
    'type_contrat': 'TEXT',
    'localisation': 'TEXT',
    'salaire_range': 'TEXT',
    'missions': 'TEXT',
    'responsabilites': 'TEXT',
    'liens_hierarchiques': 'TEXT',
    'formation': 'TEXT',
    'experience': 'TEXT',
    'competences_tech': 'TEXT',
    'competences_comport': 'TEXT',
    'langues': 'TEXT',
    'duree_cdd': 'TEXT',
    'avantages': 'TEXT',
    'date_prise_poste': 'TEXT',
    'sites_emploi': 'TEXT',
    'reseaux_sociaux': 'TEXT',
    'cooptation_interne': 'TEXT',
    'cabinets': 'TEXT',
    'statut': 'TEXT',
    'deleted_at': 'INTEGER',
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
    'employe_nom': 'TEXT',
    'date': 'INTEGER',
    'heure_arrivee': 'TEXT',
    'heure_depart': 'TEXT',
    'statut': 'TEXT',
    'type': 'TEXT',
    'source': 'TEXT',
    'lieu': 'TEXT',
    'justification': 'TEXT',
    'statut_validation': 'TEXT',
    'validateur': 'TEXT',
    'commentaire': 'TEXT',
    'created_at': 'INTEGER',
    'updated_at': 'INTEGER',
  },
  'conges_absences': {
    'id': 'TEXT PRIMARY KEY',
    'employe_id': 'TEXT',
    'employe_nom': 'TEXT',
    'type': 'TEXT',
    'date_debut': 'INTEGER',
    'date_fin': 'INTEGER',
    'statut': 'TEXT',
    'motif': 'TEXT',
    'justificatif': 'TEXT',
    'nb_jours': 'REAL',
    'date_reprise': 'INTEGER',
    'interim': 'TEXT',
    'contact': 'TEXT',
    'commentaire': 'TEXT',
    'decision_motif': 'TEXT',
    'historique': 'TEXT',
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
    'lieu': 'TEXT',
    'participants': 'INTEGER',
    'description': 'TEXT',
    'formateur': 'TEXT',
    'mode': 'TEXT',
    'objectifs': 'TEXT',
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
    'poste_nom': 'TEXT',
    'candidat_nom': 'TEXT',
    'candidat_email': 'TEXT',
    'candidat_telephone': 'TEXT',
    'localisation': 'TEXT',
    'experience': 'TEXT',
    'salaire_souhaite': 'TEXT',
    'disponibilite': 'TEXT',
    'entretien_date': 'INTEGER',
    'entretien_lieu': 'TEXT',
    'statut': 'TEXT',
    'stage': 'TEXT',
    'type_contrat': 'TEXT',
    'source': 'TEXT',
    'score': 'INTEGER',
    'commentaire': 'TEXT',
    'cv_url': 'TEXT',
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
    'employe_nom': 'TEXT',
    'poste': 'TEXT',
    'manager': 'TEXT',
    'date': 'INTEGER',
    'statut': 'TEXT',
    'type': 'TEXT',
    'lieu': 'TEXT',
    'objectifs': 'TEXT',
    'notes': 'TEXT',
    'actions': 'TEXT',
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

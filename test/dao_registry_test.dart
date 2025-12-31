import 'package:flutter_test/flutter_test.dart';

import 'package:sirhpro/core/database/dao/dao_registry.dart';
import 'package:sirhpro/core/database/sqlite_service.dart';

void main() {
  late DaoRegistry daos;

  setUpAll(() async {
    final sqlite = await SQLiteService.inMemory();
    daos = DaoRegistry(sqlite: sqlite);
  });

  test('DaoRegistry with in-memory SQLite works', () async {
    await daos.employes.insert({
      'id': 'emp-001',
      'matricule': 'RH-001',
      'nom_complet': 'Test Employe',
      'departement_id': 'dept-001',
      'poste_id': 'poste-001',
      'statut_contrat': 'CDI',
      'date_embauche': DateTime.now().millisecondsSinceEpoch,
      'telephone': '90000000',
      'email': 'test@example.com',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });

    final row = await daos.employes.getById('emp-001');
    expect(row, isNotNull);
    expect(row!['matricule'], equals('RH-001'));
  });

  test('Departements and contrats CRUD work in memory', () async {
    await daos.departements.insert({
      'id': 'dept-001',
      'nom': 'RH',
      'manager_id': 'emp-001',
      'effectif': 12,
      'budget_masse_salariale': 1500000,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });

    final dept = await daos.departements.getById('dept-001');
    expect(dept, isNotNull);
    expect(dept!['nom'], equals('RH'));

    await daos.contrats.insert({
      'id': 'ctr-001',
      'employe_id': 'emp-001',
      'type': 'CDI',
      'date_debut': DateTime.now().millisecondsSinceEpoch,
      'date_fin': null,
      'statut': 'Actif',
      'salaire_base': 450000,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });

    final contrat = await daos.contrats.getById('ctr-001');
    expect(contrat, isNotNull);
    expect(contrat!['statut'], equals('Actif'));
  });
}

import 'package:sirhpro/core/database/sqlite_service.dart';

Future<void> main() async {
  final sqlite = SQLiteService();
  final db = await sqlite.db;

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
  var updatedCount = 0;
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
      updatedCount += 1;
    }
  }

  // ignore: avoid_print
  print('Migration terminee. Employes mis a jour: $updatedCount');
}

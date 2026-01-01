import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/dao/dao_registry.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/operation_notice.dart';
import '../../../core/widgets/section_header.dart';
import '../../../shared/models/departement.dart';
import '../../../shared/models/org_node.dart';
import 'department_form_screen.dart';
import 'department_detail_screen.dart';

class DepartementsScreen extends StatefulWidget {
  const DepartementsScreen({super.key});

  @override
  State<DepartementsScreen> createState() => _DepartementsScreenState();
}

class _DepartementsScreenState extends State<DepartementsScreen> {
  final List<Departement> _departements = [];
  bool _loading = true;
  List<String> _poleOptions = [];
  List<String> _sizeOptions = [];
  List<String> _locationOptions = [];

  String _filterPole = 'Tous';
  String _filterSize = 'Tous';
  String _filterLocation = 'Tous';
  String _filterStatus = 'Actif';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    setState(() => _loading = true);
    final rows = await DaoRegistry.instance.departements.list(orderBy: 'nom ASC');
    final departments = rows.map(_departmentFromRow).toList();
    if (!mounted) return;
    setState(() {
      _departements
        ..clear()
        ..addAll(departments);
      _refreshFilterOptions();
      _loading = false;
    });
  }

  void _refreshFilterOptions() {
    _poleOptions = _departements.map((d) => d.pole).where((v) => v.trim().isNotEmpty).toSet().toList()
      ..sort();
    _sizeOptions = _departements.map((d) => d.size).where((v) => v.trim().isNotEmpty).toSet().toList()
      ..sort();
    _locationOptions = _departements.map((d) => d.location).where((v) => v.trim().isNotEmpty).toSet().toList()
      ..sort();

    if (_filterPole != 'Tous' && !_poleOptions.contains(_filterPole)) {
      _filterPole = 'Tous';
    }
    if (_filterSize != 'Tous' && !_sizeOptions.contains(_filterSize)) {
      _filterSize = 'Tous';
    }
    if (_filterLocation != 'Tous' && !_locationOptions.contains(_filterLocation)) {
      _filterLocation = 'Tous';
    }
  }

  Departement _departmentFromRow(Map<String, dynamic> row) {
    final budgetDisplay = (row['budget_affiche'] as String?)?.trim() ?? '';
    final budgetValue = row['budget_masse_salariale'];
    return Departement(
      id: (row['id'] as String?) ?? '',
      name: (row['nom'] as String?) ?? '',
      manager: (row['manager_nom'] as String?) ?? '',
      managerId: (row['manager_id'] as String?) ?? '',
      headcount: (row['effectif'] as int?) ?? 0,
      budget: budgetDisplay.isNotEmpty ? budgetDisplay : _formatBudgetValue(budgetValue),
      pole: (row['pole'] as String?) ?? '',
      size: (row['taille'] as String?) ?? '',
      location: (row['localisation'] as String?) ?? '',
      code: (row['code'] as String?) ?? '',
      description: (row['description'] as String?) ?? '',
      email: (row['email'] as String?) ?? '',
      phone: (row['telephone'] as String?) ?? '',
      extension: (row['extension'] as String?) ?? '',
      adresse: (row['adresse'] as String?) ?? '',
      parentDepartement: (row['parent_departement_nom'] as String?) ??
          (row['parent_departement'] as String?) ??
          '',
      parentDepartementId: (row['parent_departement_id'] as String?) ?? '',
      dateCreation: (row['date_creation'] as String?) ?? '',
      notes: (row['notes'] as String?) ?? '',
      responsables: (row['responsables'] as String?) ?? '',
      cadresCount: (row['cadres_count'] as String?) ?? '',
      techniciensCount: (row['techniciens_count'] as String?) ?? '',
      supportCount: (row['support_count'] as String?) ?? '',
      variationAnnuelle: (row['variation_annuelle'] as String?) ?? '',
      tauxAbsenteisme: (row['taux_absenteisme'] as String?) ?? '',
      productiviteMoyenne: (row['productivite_moyenne'] as String?) ?? '',
      satisfactionEquipe: (row['satisfaction_equipe'] as String?) ?? '',
      turnoverDepartement: (row['turnover_departement'] as String?) ?? '',
      budgetVsRealise: (row['budget_vs_realise'] as String?) ?? '',
      salairesTotaux: (row['salaires_totaux'] as String?) ?? '',
      primesVariables: (row['primes_variables'] as String?) ?? '',
      chargesSociales: (row['charges_sociales'] as String?) ?? '',
      coutMoyenEmploye: (row['cout_moyen_employe'] as String?) ?? '',
      objectifPrincipal: (row['objectif_principal'] as String?) ?? '',
      indicateurObjectif: (row['indicateur_objectif'] as String?) ?? '',
      projetEnCours: (row['projet_en_cours'] as String?) ?? '',
      ressourcesNecessaires: (row['ressources_necessaires'] as String?) ?? '',
      status: (row['statut'] as String?) ?? 'Actif',
      deletedAt: row['deleted_at'] as int?,
    );
  }

  Map<String, dynamic> _departmentToRow(Departement departement, {required bool forInsert}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final parsedBudget = _parseBudgetValue(departement.budget);
    final data = <String, dynamic>{
      'nom': departement.name,
      'manager_id': departement.managerId,
      'manager_nom': departement.manager,
      'effectif': departement.headcount,
      'budget_masse_salariale': parsedBudget,
      'budget_affiche': departement.budget,
      'pole': departement.pole,
      'taille': departement.size,
      'localisation': departement.location,
      'code': departement.code,
      'description': departement.description,
      'email': departement.email,
      'telephone': departement.phone,
      'extension': departement.extension,
      'adresse': departement.adresse,
      'parent_departement': departement.parentDepartement,
      'parent_departement_id': departement.parentDepartementId,
      'parent_departement_nom': departement.parentDepartement,
      'date_creation': departement.dateCreation,
      'notes': departement.notes,
      'responsables': departement.responsables,
      'cadres_count': departement.cadresCount,
      'techniciens_count': departement.techniciensCount,
      'support_count': departement.supportCount,
      'variation_annuelle': departement.variationAnnuelle,
      'taux_absenteisme': departement.tauxAbsenteisme,
      'productivite_moyenne': departement.productiviteMoyenne,
      'satisfaction_equipe': departement.satisfactionEquipe,
      'turnover_departement': departement.turnoverDepartement,
      'budget_vs_realise': departement.budgetVsRealise,
      'salaires_totaux': departement.salairesTotaux,
      'primes_variables': departement.primesVariables,
      'charges_sociales': departement.chargesSociales,
      'cout_moyen_employe': departement.coutMoyenEmploye,
      'objectif_principal': departement.objectifPrincipal,
      'indicateur_objectif': departement.indicateurObjectif,
      'projet_en_cours': departement.projetEnCours,
      'ressources_necessaires': departement.ressourcesNecessaires,
      'statut': departement.status,
      'deleted_at': departement.deletedAt,
      'updated_at': now,
    };

    if (forInsert) {
      data['id'] = departement.id;
      data['created_at'] = now;
    }

    return data;
  }

  double? _parseBudgetValue(String input) {
    final normalized = input.replaceAll(RegExp(r'[^0-9.,]'), '').replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  String _formatBudgetValue(Object? value) {
    if (value == null) return '';
    if (value is num) return value.toString();
    return value.toString();
  }

  List<Departement> get _filteredDepartments {
    return _departements.where((dep) {
      final matchPole = _filterPole == 'Tous' || dep.pole == _filterPole;
      final matchSize = _filterSize == 'Tous' || dep.size == _filterSize;
      final matchLocation = _filterLocation == 'Tous' || dep.location == _filterLocation;
      final status = dep.deletedAt != null ? 'Archive' : dep.status;
      final matchStatus = _filterStatus == 'Tous' || status == _filterStatus;
      final matchSearch =
          _searchQuery.isEmpty || dep.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchPole && matchSize && matchLocation && matchStatus && matchSearch;
    }).toList();
  }

  void _openDepartment(Departement departement) {
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: DepartmentDetailScreen(departement: departement),
      ),
    );
  }

  void _showCreateDepartment() {
    _openDepartmentForm();
  }

  void _showAssignManager(Departement departement) {
    final managerCtrl = TextEditingController(text: departement.managerId);
    final managerNameCtrl = TextEditingController(text: departement.manager);
    final futureOptions = DaoRegistry.instance.employes.list(orderBy: 'nom_complet ASC');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Affecter manager'),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: futureOptions,
          builder: (context, snapshot) {
            final rows = snapshot.data ?? [];
            final options = rows
                .map(
                  (row) => _ManagerOption(
                    id: (row['id'] as String?) ?? '',
                    label: (row['nom_complet'] as String?) ?? '',
                  ),
                )
                .where((opt) => opt.id.isNotEmpty && opt.label.trim().isNotEmpty)
                .toList()
              ..sort((a, b) => a.label.compareTo(b.label));

            if (options.isEmpty) {
              return TextField(
                controller: managerNameCtrl,
                decoration: const InputDecoration(labelText: 'Manager'),
              );
            }

            final normalized = options.any((opt) => opt.id == managerCtrl.text) || managerCtrl.text.isEmpty
                ? options
                : [_ManagerOption(id: managerCtrl.text, label: managerCtrl.text), ...options];
            final value = managerCtrl.text.isEmpty ? normalized.first.id : managerCtrl.text;
            if (managerCtrl.text.isEmpty) {
              managerCtrl.text = value;
            }
            final selected = normalized.firstWhere((opt) => opt.id == managerCtrl.text, orElse: () => normalized.first);
            managerNameCtrl.text = selected.label;

            return DropdownButtonFormField<String>(
              value: value,
              decoration: const InputDecoration(labelText: 'Manager'),
              items: normalized
                  .map(
                    (opt) => DropdownMenuItem(
                      value: opt.id,
                      child: Text(opt.label),
                    ),
                  )
                  .toList(),
              onChanged: (selectedId) {
                managerCtrl.text = selectedId ?? '';
                final match = normalized.firstWhere(
                  (opt) => opt.id == managerCtrl.text,
                  orElse: () => _ManagerOption(id: '', label: ''),
                );
                managerNameCtrl.text = match.label;
              },
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final updated = Departement(
                id: departement.id,
                name: departement.name,
                manager: managerNameCtrl.text.trim(),
                managerId: managerCtrl.text.trim(),
                headcount: departement.headcount,
                budget: departement.budget,
                pole: departement.pole,
                size: departement.size,
                location: departement.location,
                code: departement.code,
                description: departement.description,
                email: departement.email,
                phone: departement.phone,
                extension: departement.extension,
                adresse: departement.adresse,
                parentDepartement: departement.parentDepartement,
                parentDepartementId: departement.parentDepartementId,
                dateCreation: departement.dateCreation,
                notes: departement.notes,
                responsables: departement.responsables,
                cadresCount: departement.cadresCount,
                techniciensCount: departement.techniciensCount,
                supportCount: departement.supportCount,
                variationAnnuelle: departement.variationAnnuelle,
                tauxAbsenteisme: departement.tauxAbsenteisme,
                productiviteMoyenne: departement.productiviteMoyenne,
                satisfactionEquipe: departement.satisfactionEquipe,
                turnoverDepartement: departement.turnoverDepartement,
                budgetVsRealise: departement.budgetVsRealise,
                salairesTotaux: departement.salairesTotaux,
                primesVariables: departement.primesVariables,
                chargesSociales: departement.chargesSociales,
                coutMoyenEmploye: departement.coutMoyenEmploye,
                objectifPrincipal: departement.objectifPrincipal,
                indicateurObjectif: departement.indicateurObjectif,
                projetEnCours: departement.projetEnCours,
                ressourcesNecessaires: departement.ressourcesNecessaires,
                status: departement.status,
                deletedAt: departement.deletedAt,
              );
              DaoRegistry.instance.departements
                  .update(departement.id, _departmentToRow(updated, forInsert: false))
                  .then((_) => _loadDepartments())
                  .then((_) {
                showOperationNotice(context, message: 'Manager mis a jour.', success: true);
                Navigator.of(context).pop();
              });
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    ).then((_) {
      managerCtrl.dispose();
      managerNameCtrl.dispose();
    });
  }

  void _showEditStructure(Departement departement) {
    _openDepartmentForm(departement: departement);
  }

  Future<void> _confirmDeleteDepartment(Departement departement) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer departement'),
        content: Text('Supprimer ${departement.name} ? Cette action est reversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    final updated = Departement(
      id: departement.id,
      name: departement.name,
      manager: departement.manager,
      managerId: departement.managerId,
      headcount: departement.headcount,
      budget: departement.budget,
      pole: departement.pole,
      size: departement.size,
      location: departement.location,
      code: departement.code,
      description: departement.description,
      email: departement.email,
      phone: departement.phone,
      extension: departement.extension,
      adresse: departement.adresse,
      parentDepartement: departement.parentDepartement,
      parentDepartementId: departement.parentDepartementId,
      dateCreation: departement.dateCreation,
      notes: departement.notes,
      responsables: departement.responsables,
      cadresCount: departement.cadresCount,
      techniciensCount: departement.techniciensCount,
      supportCount: departement.supportCount,
      variationAnnuelle: departement.variationAnnuelle,
      tauxAbsenteisme: departement.tauxAbsenteisme,
      productiviteMoyenne: departement.productiviteMoyenne,
      satisfactionEquipe: departement.satisfactionEquipe,
      turnoverDepartement: departement.turnoverDepartement,
      budgetVsRealise: departement.budgetVsRealise,
      salairesTotaux: departement.salairesTotaux,
      primesVariables: departement.primesVariables,
      chargesSociales: departement.chargesSociales,
      coutMoyenEmploye: departement.coutMoyenEmploye,
      objectifPrincipal: departement.objectifPrincipal,
      indicateurObjectif: departement.indicateurObjectif,
      projetEnCours: departement.projetEnCours,
      ressourcesNecessaires: departement.ressourcesNecessaires,
      status: 'Archive',
      deletedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await DaoRegistry.instance.departements.update(
      departement.id,
      _departmentToRow(updated, forInsert: false),
    );
    await _loadDepartments();
    showOperationNotice(context, message: 'Departement archive.', success: true);
  }

  Future<void> _restoreDepartment(Departement departement) async {
    final updated = Departement(
      id: departement.id,
      name: departement.name,
      manager: departement.manager,
      managerId: departement.managerId,
      headcount: departement.headcount,
      budget: departement.budget,
      pole: departement.pole,
      size: departement.size,
      location: departement.location,
      code: departement.code,
      description: departement.description,
      email: departement.email,
      phone: departement.phone,
      extension: departement.extension,
      adresse: departement.adresse,
      parentDepartement: departement.parentDepartement,
      parentDepartementId: departement.parentDepartementId,
      dateCreation: departement.dateCreation,
      notes: departement.notes,
      responsables: departement.responsables,
      cadresCount: departement.cadresCount,
      techniciensCount: departement.techniciensCount,
      supportCount: departement.supportCount,
      variationAnnuelle: departement.variationAnnuelle,
      tauxAbsenteisme: departement.tauxAbsenteisme,
      productiviteMoyenne: departement.productiviteMoyenne,
      satisfactionEquipe: departement.satisfactionEquipe,
      turnoverDepartement: departement.turnoverDepartement,
      budgetVsRealise: departement.budgetVsRealise,
      salairesTotaux: departement.salairesTotaux,
      primesVariables: departement.primesVariables,
      chargesSociales: departement.chargesSociales,
      coutMoyenEmploye: departement.coutMoyenEmploye,
      objectifPrincipal: departement.objectifPrincipal,
      indicateurObjectif: departement.indicateurObjectif,
      projetEnCours: departement.projetEnCours,
      ressourcesNecessaires: departement.ressourcesNecessaires,
      status: 'Actif',
      deletedAt: null,
    );
    await DaoRegistry.instance.departements.update(
      departement.id,
      _departmentToRow(updated, forInsert: false),
    );
    await _loadDepartments();
    showOperationNotice(context, message: 'Departement restaure.', success: true);
  }

  Future<void> _openDepartmentForm({Departement? departement}) async {
    final created = await showDialog<Departement>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: DepartmentFormScreen(departement: departement),
      ),
    );

    if (created == null) return;
    final exists = _departements.any((d) => d.id == created.id);
    if (exists) {
      await DaoRegistry.instance.departements.update(created.id, _departmentToRow(created, forInsert: false));
      showOperationNotice(context, message: 'Departement mis a jour.', success: true);
    } else {
      await DaoRegistry.instance.departements.insert(_departmentToRow(created, forInsert: true));
      if (created.status == 'Brouillon') {
        showOperationNotice(context, message: 'Departement cree en brouillon (masque par defaut).', success: true);
      } else {
        showOperationNotice(context, message: 'Departement cree.', success: true);
      }
    }
    await _loadDepartments();
  }

  @override
  Widget build(BuildContext context) {
    final mutedText = appTextMuted(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Recherche departement...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value.trim()),
                      ),
                    ),
                    _FilterDropdown(
                      label: 'Pole',
                      value: _filterPole,
                      items: ['Tous', ..._poleOptions],
                      onChanged: (value) => setState(() => _filterPole = value),
                    ),
                    _FilterDropdown(
                      label: 'Taille',
                      value: _filterSize,
                      items: ['Tous', ..._sizeOptions],
                      onChanged: (value) => setState(() => _filterSize = value),
                    ),
                    _FilterDropdown(
                      label: 'Localisation',
                      value: _filterLocation,
                      items: ['Tous', ..._locationOptions],
                      onChanged: (value) => setState(() => _filterLocation = value),
                    ),
                    _FilterDropdown(
                      label: 'Statut',
                      value: _filterStatus,
                      items: const ['Tous', 'Actif', 'Brouillon', 'Archive'],
                      onChanged: (value) => setState(() => _filterStatus = value),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredDepartments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Aucun departement. Utilisez "Creer departement" pour commencer.',
                  style: TextStyle(color: mutedText),
                ),
              ),
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _filteredDepartments
                  .map(
                    (dep) => _DepartmentCard(
                      departement: dep,
                      onOpen: () => _openDepartment(dep),
                      onEditStructure: () => _showEditStructure(dep),
                      onAssignManager: () => _showAssignManager(dep),
                      onDelete: () => _confirmDeleteDepartment(dep),
                      onRestore: () => _restoreDepartment(dep),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 24),
          AppCard(
            child: SizedBox(
              height: 320,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Organigramme',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: appTextPrimary(context),
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('Export PDF'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.image_outlined),
                        label: const Text('Export PNG'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.open_with),
                        label: const Text('Edition drag & drop'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _OrgChartCanvas(
                      mutedText: mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final actionButton = ElevatedButton.icon(
      onPressed: _showCreateDepartment,
      icon: const Icon(Icons.add),
      label: const Text('Creer departement'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: SectionHeader(
                  title: 'Organisation',
                  subtitle: 'Suivi des departements et effectifs.',
                ),
              ),
              const SizedBox(width: 16),
              actionButton,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Organisation',
              subtitle: 'Suivi des departements et effectifs.',
            ),
            const SizedBox(height: 12),
            actionButton,
          ],
        );
      },
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  const _DepartmentCard({
    required this.departement,
    required this.onOpen,
    required this.onEditStructure,
    required this.onAssignManager,
    required this.onDelete,
    required this.onRestore,
  });

  final Departement departement;
  final VoidCallback onOpen;
  final VoidCallback onEditStructure;
  final VoidCallback onAssignManager;
  final VoidCallback onDelete;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final primaryText = appTextPrimary(context);
    final mutedText = appTextMuted(context);
    final badgeLabel = departement.deletedAt != null
        ? 'Archive'
        : (departement.status == 'Brouillon' ? 'Brouillon' : '');

    return AppCard(
      child: InkWell(
        onTap: onOpen,
        child: SizedBox(
          width: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      departement.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                    ),
                  ),
                  if (badgeLabel.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeLabel == 'Archive' ? Colors.redAccent.withOpacity(0.12) : Colors.orangeAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badgeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: badgeLabel == 'Archive' ? Colors.redAccent : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEditStructure();
                      if (value == 'manager') onAssignManager();
                      if (value == 'delete') onDelete();
                      if (value == 'restore') onRestore();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Modifier structure')),
                      const PopupMenuItem(value: 'manager', child: Text('Affecter manager')),
                      if (departement.deletedAt != null)
                        const PopupMenuItem(value: 'restore', child: Text('Restaurer'))
                      else
                        const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Manager: ${departement.manager}',
                style: TextStyle(fontSize: 12, color: mutedText),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.people, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${departement.headcount} employes',
                    style: TextStyle(fontSize: 12, color: primaryText),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.payments, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    departement.budget,
                    style: TextStyle(fontSize: 12, color: primaryText),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${departement.pole} - ${departement.location}',
                style: TextStyle(fontSize: 12, color: mutedText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: (value) => onChanged(value ?? 'Tous'),
      ),
    );
  }
}

class _ManagerOption {
  const _ManagerOption({required this.id, required this.label});

  final String id;
  final String label;
}

class _OrgChartCanvas extends StatefulWidget {
  const _OrgChartCanvas({required this.mutedText});

  final Color mutedText;

  @override
  State<_OrgChartCanvas> createState() => _OrgChartCanvasState();
}

class _OrgChartCanvasState extends State<_OrgChartCanvas> {
  final List<OrgNode> _nodes = [
    OrgNode(id: 'n1', label: 'Direction RH', position: const Offset(40, 24)),
    OrgNode(id: 'n2', label: 'Recrutement', position: const Offset(260, 24), parentId: 'n1'),
    OrgNode(id: 'n3', label: 'Formation', position: const Offset(480, 24), parentId: 'n1'),
    OrgNode(id: 'n4', label: 'Paie', position: const Offset(260, 140), parentId: 'n1'),
  ];

  String? _linkSourceId;

  void _startLink(String nodeId) {
    setState(() => _linkSourceId = nodeId);
  }

  void _finishLink(String nodeId) {
    if (_linkSourceId == null || _linkSourceId == nodeId) return;
    setState(() {
      final targetIndex = _nodes.indexWhere((n) => n.id == nodeId);
      if (targetIndex != -1) {
        _nodes[targetIndex] = _nodes[targetIndex].copyWith(parentId: _linkSourceId);
      }
      _linkSourceId = null;
    });
  }

  void _cancelLink() {
    setState(() => _linkSourceId = null);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _cancelLink,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: appBorderColor(context)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _OrgLinesPainter(nodes: _nodes),
                ),
                ..._nodes.map(
                  (node) => Positioned(
                    left: node.position.dx,
                    top: node.position.dy,
                    child: _OrgNodeCard(
                      node: node,
                      isLinkSource: _linkSourceId == node.id,
                      onDrag: (delta) {
                        setState(() {
                          final index = _nodes.indexWhere((n) => n.id == node.id);
                          if (index == -1) return;
                          final next = node.position + delta;
                          _nodes[index] = node.copyWith(
                            position: Offset(
                              next.dx.clamp(0, constraints.maxWidth - 160),
                              next.dy.clamp(0, constraints.maxHeight - 64),
                            ),
                          );
                        });
                      },
                      onLinkTap: () {
                        if (_linkSourceId == null) {
                          _startLink(node.id);
                        } else {
                          _finishLink(node.id);
                        }
                      },
                    ),
                  ),
                ),
                if (_nodes.isEmpty)
                  Center(
                    child: Text(
                      'Aucun noeud. Ajoutez un departement.',
                      style: TextStyle(color: widget.mutedText),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrgNodeCard extends StatelessWidget {
  const _OrgNodeCard({
    required this.node,
    required this.isLinkSource,
    required this.onDrag,
    required this.onLinkTap,
  });

  final OrgNode node;
  final bool isLinkSource;
  final ValueChanged<Offset> onDrag;
  final VoidCallback onLinkTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) => onDrag(details.delta),
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isLinkSource ? AppColors.primary.withOpacity(0.12) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLinkSource ? AppColors.primary : appBorderColor(context),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.account_tree, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                node.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: appTextPrimary(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: onLinkTap,
              child: Icon(
                Icons.link,
                size: 16,
                color: isLinkSource ? AppColors.primary : appTextMuted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrgLinesPainter extends CustomPainter {
  _OrgLinesPainter({required this.nodes});

  final List<OrgNode> nodes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.4)
      ..strokeWidth = 1.5;

    for (final node in nodes) {
      if (node.parentId == null) continue;
      final parent = nodes.firstWhere(
        (n) => n.id == node.parentId,
        orElse: () => node,
      );
      if (parent.id == node.id) continue;
      final start = Offset(parent.position.dx + 80, parent.position.dy + 64);
      final end = Offset(node.position.dx + 80, node.position.dy);
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrgLinesPainter oldDelegate) {
    return oldDelegate.nodes != nodes;
  }
}

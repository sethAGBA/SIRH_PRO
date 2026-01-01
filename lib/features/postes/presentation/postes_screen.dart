import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/dao/dao_registry.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/operation_notice.dart';
import '../../../core/widgets/section_header.dart';
import '../../../shared/models/poste.dart';
import 'poste_detail_screen.dart';
import 'postes_form_screen.dart';

class PostesScreen extends StatefulWidget {
  const PostesScreen({super.key});

  @override
  State<PostesScreen> createState() => _PostesScreenState();
}

class _PostesScreenState extends State<PostesScreen> {
  final List<Poste> _postes = [];
  List<DepartmentOption> _departmentOptions = [];
  Map<String, String> _departmentLabelsById = {};
  String _filterDepartment = '';
  String _filterStatus = 'Actif';
  String _searchQuery = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDependencies();
  }

  Future<void> _loadDependencies() async {
    await _loadDepartmentOptions();
    await _loadPostes();
  }

  Future<void> _loadDepartmentOptions() async {
    final departmentRows = await DaoRegistry.instance.departements.list(orderBy: 'nom ASC');
    final options = departmentRows
        .map(
          (row) => DepartmentOption(
            id: (row['id'] as String?) ?? '',
            label: (row['nom'] as String?) ?? '',
          ),
        )
        .where((opt) => opt.id.isNotEmpty && opt.label.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => a.label.compareTo(b.label));

    if (!mounted) return;
    setState(() {
      _departmentOptions = options;
      _departmentLabelsById = {for (final opt in options) opt.id: opt.label};
      if (_filterDepartment.isNotEmpty && !_departmentLabelsById.containsKey(_filterDepartment)) {
        _filterDepartment = '';
      }
    });
  }

  Future<void> _loadPostes() async {
    setState(() => _loading = true);
    final rows = await DaoRegistry.instance.postes.list(orderBy: 'created_at DESC');
    final postes = rows.map(_posteFromRow).toList();
    if (!mounted) return;
    setState(() {
      _postes
        ..clear()
        ..addAll(postes);
      _loading = false;
    });
  }

  Poste _posteFromRow(Map<String, dynamic> row) {
    final departmentId = (row['departement_id'] as String?) ?? '';
    final departmentName =
        (row['departement_nom'] as String?) ?? (_departmentLabelsById[departmentId] ?? '');
    return Poste(
      id: (row['id'] as String?) ?? '',
      code: (row['code'] as String?) ?? '',
      title: (row['intitule'] as String?) ?? '',
      description: (row['description'] as String?) ?? '',
      departmentId: departmentId,
      departmentName: departmentName,
      level: (row['niveau'] as String?) ?? '',
      typeContrat: (row['type_contrat'] as String?) ?? '',
      localisation: (row['localisation'] as String?) ?? '',
      salaireRange: (row['salaire_range'] as String?) ?? '',
      missions: (row['missions'] as String?) ?? '',
      responsabilites: (row['responsabilites'] as String?) ?? '',
      liensHierarchiques: (row['liens_hierarchiques'] as String?) ?? '',
      formation: (row['formation'] as String?) ?? '',
      experience: (row['experience'] as String?) ?? '',
      competencesTech: (row['competences_tech'] as String?) ?? '',
      competencesComport: (row['competences_comport'] as String?) ?? '',
      langues: (row['langues'] as String?) ?? '',
      dureeCdd: (row['duree_cdd'] as String?) ?? '',
      avantages: (row['avantages'] as String?) ?? '',
      datePrisePoste: (row['date_prise_poste'] as String?) ?? '',
      sitesEmploi: (row['sites_emploi'] as String?) ?? '',
      reseauxSociaux: (row['reseaux_sociaux'] as String?) ?? '',
      cooptationInterne: (row['cooptation_interne'] as String?) ?? '',
      cabinets: (row['cabinets'] as String?) ?? '',
      status: (row['statut'] as String?) ?? 'Actif',
      deletedAt: row['deleted_at'] as int?,
    );
  }

  Map<String, dynamic> _posteToRow(Poste poste, {required bool forInsert}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final data = <String, dynamic>{
      'code': poste.code,
      'intitule': poste.title,
      'description': poste.description,
      'departement_id': poste.departmentId,
      'departement_nom': poste.departmentName,
      'niveau': poste.level,
      'type_contrat': poste.typeContrat,
      'localisation': poste.localisation,
      'salaire_range': poste.salaireRange,
      'missions': poste.missions,
      'responsabilites': poste.responsabilites,
      'liens_hierarchiques': poste.liensHierarchiques,
      'formation': poste.formation,
      'experience': poste.experience,
      'competences_tech': poste.competencesTech,
      'competences_comport': poste.competencesComport,
      'langues': poste.langues,
      'duree_cdd': poste.dureeCdd,
      'avantages': poste.avantages,
      'date_prise_poste': poste.datePrisePoste,
      'sites_emploi': poste.sitesEmploi,
      'reseaux_sociaux': poste.reseauxSociaux,
      'cooptation_interne': poste.cooptationInterne,
      'cabinets': poste.cabinets,
      'statut': poste.status,
      'deleted_at': poste.deletedAt,
      'updated_at': now,
    };
    if (forInsert) {
      data['id'] = poste.id;
      data['created_at'] = now;
    }
    return data;
  }

  List<Poste> get _filteredPostes {
    return _postes.where((poste) {
      final matchDept = _filterDepartment.isEmpty || poste.departmentId == _filterDepartment;
      final status = poste.deletedAt != null ? 'Archive' : poste.status;
      final matchStatus = _filterStatus == 'Tous' || status == _filterStatus;
      final matchSearch = _searchQuery.isEmpty ||
          poste.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          poste.code.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchDept && matchStatus && matchSearch;
    }).toList();
  }

  Future<void> _openForm({Poste? poste}) async {
    final saved = await showDialog<Poste>(
      context: context,
      builder: (_) => Dialog.fullscreen(
                  child: PostesFormScreen(
                    poste: poste,
                    departmentOptions: _departmentOptions,
                  ),
      ),
    );
    if (saved == null) return;
    final exists = _postes.any((p) => p.id == saved.id);
    if (exists) {
      await DaoRegistry.instance.postes.update(saved.id, _posteToRow(saved, forInsert: false));
      showOperationNotice(context, message: 'Poste mis a jour.', success: true);
    } else {
      await DaoRegistry.instance.postes.insert(_posteToRow(saved, forInsert: true));
      showOperationNotice(context, message: 'Poste cree.', success: true);
    }
    await _loadPostes();
  }

  Future<void> _openDetail(Poste poste) async {
    await showDialog<void>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: PosteDetailScreen(
          poste: poste,
          departmentOptions: _departmentOptions,
        ),
      ),
    );
    await _loadPostes();
  }

  Future<void> _confirmDelete(Poste poste) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer poste'),
        content: Text('Supprimer ${poste.title} ? Cette action est reversible.'),
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
    final updated = Poste(
      id: poste.id,
      code: poste.code,
      title: poste.title,
      description: poste.description,
      departmentId: poste.departmentId,
      departmentName: poste.departmentName,
      level: poste.level,
      status: 'Archive',
      deletedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await DaoRegistry.instance.postes.update(poste.id, _posteToRow(updated, forInsert: false));
    await _loadPostes();
    showOperationNotice(context, message: 'Poste archive.', success: true);
  }

  Future<void> _restore(Poste poste) async {
    final updated = Poste(
      id: poste.id,
      code: poste.code,
      title: poste.title,
      description: poste.description,
      departmentId: poste.departmentId,
      departmentName: poste.departmentName,
      level: poste.level,
      status: 'Actif',
      deletedAt: null,
    );
    await DaoRegistry.instance.postes.update(poste.id, _posteToRow(updated, forInsert: false));
    await _loadPostes();
    showOperationNotice(context, message: 'Poste restaure.', success: true);
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
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Recherche poste...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value.trim()),
                  ),
                ),
                _FilterOptionDropdown(
                  label: 'Departement',
                  value: _filterDepartment,
                  options: _departmentOptions,
                  onChanged: (value) => setState(() => _filterDepartment = value),
                ),
                _FilterDropdown(
                  label: 'Statut',
                  value: _filterStatus,
                  items: const ['Tous', 'Actif', 'Brouillon', 'Archive'],
                  onChanged: (value) => setState(() => _filterStatus = value),
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
          else if (_filteredPostes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Aucun poste. Utilisez "Creer poste" pour commencer.',
                  style: TextStyle(color: mutedText),
                ),
              ),
            )
          else
            DataTable(
              columns: const [
                DataColumn(label: Text('Code')),
                DataColumn(label: Text('Intitule')),
                DataColumn(label: Text('Departement')),
                DataColumn(label: Text('Niveau')),
                DataColumn(label: Text('Statut')),
                DataColumn(label: Text('Actions')),
              ],
              rows: _filteredPostes
                  .map(
                    (poste) => DataRow(
                      onSelectChanged: (_) => _openDetail(poste),
                      cells: [
                        DataCell(Text(poste.code.isEmpty ? '-' : poste.code)),
                        DataCell(Text(poste.title)),
                        DataCell(Text(_departmentLabelsById[poste.departmentId] ?? poste.departmentName)),
                        DataCell(Text(poste.level.isEmpty ? '-' : poste.level)),
                        DataCell(Text(poste.deletedAt != null ? 'Archive' : poste.status)),
                        DataCell(
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') _openForm(poste: poste);
                              if (value == 'delete') _confirmDelete(poste);
                              if (value == 'restore') _restore(poste);
                              if (value == 'detail') _openDetail(poste);
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'detail', child: Text('Voir fiche')),
                              const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                              if (poste.deletedAt != null)
                                const PopupMenuItem(value: 'restore', child: Text('Restaurer'))
                              else
                                const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final actionButton = ElevatedButton.icon(
      onPressed: () => _openForm(),
      icon: const Icon(Icons.add),
      label: const Text('Creer poste'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
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
                  title: 'Postes',
                  subtitle: 'Creation, modification et affectation des postes.',
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
              title: 'Postes',
              subtitle: 'Creation, modification et affectation des postes.',
            ),
            const SizedBox(height: 12),
            actionButton,
          ],
        );
      },
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
      width: 190,
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
        onChanged: (value) => onChanged(value ?? items.first),
      ),
    );
  }
}

class _FilterOptionDropdown extends StatelessWidget {
  const _FilterOptionDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<DepartmentOption> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final entries = [
      const DepartmentOption(id: '', label: 'Tous'),
      ...options,
    ];
    return SizedBox(
      width: 190,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: entries
            .map(
              (option) => DropdownMenuItem(
                value: option.id,
                child: Text(option.label),
              ),
            )
            .toList(),
        onChanged: (value) => onChanged(value ?? ''),
      ),
    );
  }
}

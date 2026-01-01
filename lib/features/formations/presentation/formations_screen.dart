import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/dao/dao_registry.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/operation_notice.dart';
import '../../../core/widgets/section_header.dart';
import '../../../shared/models/entretien_individuel.dart';
import '../../../shared/models/formation_session.dart';

class FormationsScreen extends StatefulWidget {
  const FormationsScreen({super.key});

  @override
  State<FormationsScreen> createState() => _FormationsScreenState();
}

class _FormationsScreenState extends State<FormationsScreen> {
  final List<FormationSession> _sessions = [];
  final List<EntretienIndividuel> _entretiens = [];
  final List<_IdLabelOption> _employeeOptions = [];
  final List<_IdLabelOption> _posteOptions = [];

  bool _loadingSessions = false;
  bool _loadingEntretiens = false;
  int _sessionPage = 0;
  final int _sessionPageSize = 8;
  int _sessionTotal = 0;
  int _entretienPage = 0;
  final int _entretienPageSize = 8;
  int _entretienTotal = 0;

  String _searchSession = '';
  String _filterCategory = 'Toutes';
  String _filterSessionStatus = 'Tous';
  String _sessionSort = 'Date desc';

  String _searchEntretien = '';
  String _filterEntretienStatus = 'Tous';
  String _filterEntretienType = 'Tous';
  String _entretienSort = 'Date desc';

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _loadPostes();
    _loadSessions();
    _loadEntretiens();
  }

  Future<void> _loadEmployees() async {
    final rows = await DaoRegistry.instance.employes.list(orderBy: 'nom_complet ASC');
    final options = rows
        .map(
          (row) => _IdLabelOption(
            id: (row['id'] as String?) ?? '',
            label: (row['nom_complet'] as String?) ?? '',
          ),
        )
        .where((opt) => opt.id.isNotEmpty && opt.label.isNotEmpty)
        .toList();
    if (!mounted) return;
    setState(() => _employeeOptions
      ..clear()
      ..addAll(options));
  }

  Future<void> _loadPostes() async {
    final rows = await DaoRegistry.instance.postes.list(orderBy: 'intitule ASC');
    final options = rows
        .where((row) => row['deleted_at'] == null)
        .map(
          (row) => _IdLabelOption(
            id: (row['id'] as String?) ?? '',
            label: (row['intitule'] as String?) ?? '',
          ),
        )
        .where((opt) => opt.id.isNotEmpty && opt.label.isNotEmpty)
        .toList();
    if (!mounted) return;
    setState(() => _posteOptions
      ..clear()
      ..addAll(options));
  }

  Future<void> _loadSessions({bool resetPage = false}) async {
    if (resetPage) _sessionPage = 0;
    setState(() => _loadingSessions = true);
    final category = _filterCategory == 'Toutes' ? null : _filterCategory;
    final status = _filterSessionStatus == 'Tous' ? null : _filterSessionStatus;
    final rows = await DaoRegistry.instance.formations.search(
      query: _searchSession,
      category: category,
      status: status,
      orderBy: _sessionOrderBy(),
      limit: _sessionPageSize,
      offset: _sessionPage * _sessionPageSize,
    );
    final total = await DaoRegistry.instance.formations.count(
      query: _searchSession,
      category: category,
      status: status,
    );
    if (!mounted) return;
    setState(() {
      _sessions
        ..clear()
        ..addAll(rows.map(_sessionFromRow));
      _sessionTotal = total;
      _loadingSessions = false;
    });
  }

  Future<void> _loadEntretiens({bool resetPage = false}) async {
    if (resetPage) _entretienPage = 0;
    setState(() => _loadingEntretiens = true);
    final status = _filterEntretienStatus == 'Tous' ? null : _filterEntretienStatus;
    final type = _filterEntretienType == 'Tous' ? null : _filterEntretienType;
    final rows = await DaoRegistry.instance.entretiens.search(
      query: _searchEntretien,
      status: status,
      type: type,
      orderBy: _entretienOrderBy(),
      limit: _entretienPageSize,
      offset: _entretienPage * _entretienPageSize,
    );
    final total = await DaoRegistry.instance.entretiens.count(
      query: _searchEntretien,
      status: status,
      type: type,
    );
    if (!mounted) return;
    setState(() {
      _entretiens
        ..clear()
        ..addAll(rows.map(_entretienFromRow));
      _entretienTotal = total;
      _loadingEntretiens = false;
    });
  }

  String _sessionOrderBy() {
    switch (_sessionSort) {
      case 'Date asc':
        return 'date_debut ASC';
      case 'Statut':
        return 'statut ASC';
      case 'Categorie':
        return 'categorie ASC';
      case 'Titre':
        return 'titre ASC';
      case 'Date desc':
      default:
        return 'date_debut DESC';
    }
  }

  String _entretienOrderBy() {
    switch (_entretienSort) {
      case 'Date asc':
        return 'date ASC';
      case 'Statut':
        return 'statut ASC';
      case 'Type':
        return 'type ASC';
      case 'Employe':
        return 'employe_nom ASC';
      case 'Date desc':
      default:
        return 'date DESC';
    }
  }

  Future<void> _exportSessionsCsv() async {
    final category = _filterCategory == 'Toutes' ? null : _filterCategory;
    final status = _filterSessionStatus == 'Tous' ? null : _filterSessionStatus;
    final rows = await DaoRegistry.instance.formations.search(
      query: _searchSession,
      category: category,
      status: status,
      orderBy: _sessionOrderBy(),
    );
    final sessions = rows.map(_sessionFromRow).toList();
    final headers = [
      'Titre',
      'Categorie',
      'Date debut',
      'Date fin',
      'Lieu',
      'Participants',
      'Budget',
      'Statut',
      'Formateur',
      'Mode',
      'Objectifs',
      'Description',
    ];
    final lines = <String>[
      headers.map(_escapeCsv).join(','),
      ...sessions.map(
        (session) => [
          session.title,
          session.category,
          _formatDate(session.startDate),
          _formatDate(session.endDate),
          session.location,
          session.participants.toString(),
          session.budget.toStringAsFixed(0),
          session.status,
          session.trainer,
          session.mode,
          session.objectifs,
          session.description,
        ].map(_escapeCsv).join(','),
      ),
    ];
    await _showCsvDialog('Export sessions', lines.join('\n'));
  }

  Future<void> _exportEntretiensCsv() async {
    final status = _filterEntretienStatus == 'Tous' ? null : _filterEntretienStatus;
    final type = _filterEntretienType == 'Tous' ? null : _filterEntretienType;
    final rows = await DaoRegistry.instance.entretiens.search(
      query: _searchEntretien,
      status: status,
      type: type,
      orderBy: _entretienOrderBy(),
    );
    final entretiens = rows.map(_entretienFromRow).toList();
    final headers = [
      'Employe',
      'Poste',
      'Manager',
      'Date',
      'Lieu',
      'Type',
      'Statut',
      'Objectifs',
      'Notes',
      'Actions',
    ];
    final lines = <String>[
      headers.map(_escapeCsv).join(','),
      ...entretiens.map(
        (entretien) => [
          entretien.employeNom,
          entretien.poste,
          entretien.manager,
          _formatDate(entretien.date),
          entretien.lieu,
          entretien.type,
          entretien.status,
          entretien.objectifs,
          entretien.notes,
          entretien.actions,
        ].map(_escapeCsv).join(','),
      ),
    ];
    await _showCsvDialog('Export entretiens', lines.join('\n'));
  }

  Future<void> _showCsvDialog(String title, String csv) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 520,
          child: SelectableText(csv),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: csv));
              if (!context.mounted) return;
              Navigator.of(context).pop();
              showOperationNotice(context, message: 'CSV copie.', success: true);
            },
            child: const Text('Copier'),
          ),
        ],
      ),
    );
  }

  FormationSession _sessionFromRow(Map<String, dynamic> row) {
    final startMillis = row['date_debut'] as int?;
    final endMillis = row['date_fin'] as int?;
    final budget = row['budget'];
    final participants = row['participants'];
    return FormationSession(
      id: (row['id'] as String?) ?? '',
      title: (row['titre'] as String?) ?? '',
      category: (row['categorie'] as String?) ?? '',
      startDate: startMillis == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(startMillis),
      endDate: endMillis == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(endMillis),
      budget: budget is num ? budget.toDouble() : 0,
      status: (row['statut'] as String?) ?? '',
      location: (row['lieu'] as String?) ?? '',
      participants: participants is int ? participants : int.tryParse('${participants ?? 0}') ?? 0,
      description: (row['description'] as String?) ?? '',
      trainer: (row['formateur'] as String?) ?? '',
      mode: (row['mode'] as String?) ?? '',
      objectifs: (row['objectifs'] as String?) ?? '',
    );
  }

  Map<String, dynamic> _sessionToRow(FormationSession session, {required bool forInsert}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return {
      'id': session.id,
      'titre': session.title,
      'categorie': session.category,
      'date_debut': session.startDate.millisecondsSinceEpoch,
      'date_fin': session.endDate.millisecondsSinceEpoch,
      'budget': session.budget,
      'statut': session.status,
      'lieu': session.location,
      'participants': session.participants,
      'description': session.description,
      'formateur': session.trainer,
      'mode': session.mode,
      'objectifs': session.objectifs,
      'updated_at': now,
      if (forInsert) 'created_at': now,
    };
  }

  EntretienIndividuel _entretienFromRow(Map<String, dynamic> row) {
    final dateMillis = row['date'] as int?;
    return EntretienIndividuel(
      id: (row['id'] as String?) ?? '',
      employeId: (row['employe_id'] as String?) ?? '',
      employeNom: (row['employe_nom'] as String?) ?? '',
      poste: (row['poste'] as String?) ?? '',
      manager: (row['manager'] as String?) ?? '',
      date: dateMillis == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(dateMillis),
      status: (row['statut'] as String?) ?? '',
      type: (row['type'] as String?) ?? '',
      lieu: (row['lieu'] as String?) ?? '',
      objectifs: (row['objectifs'] as String?) ?? '',
      notes: (row['notes'] as String?) ?? '',
      actions: (row['actions'] as String?) ?? '',
    );
  }

  Map<String, dynamic> _entretienToRow(EntretienIndividuel entretien, {required bool forInsert}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return {
      'id': entretien.id,
      'employe_id': entretien.employeId,
      'employe_nom': entretien.employeNom,
      'poste': entretien.poste,
      'manager': entretien.manager,
      'date': entretien.date.millisecondsSinceEpoch,
      'statut': entretien.status,
      'type': entretien.type,
      'lieu': entretien.lieu,
      'objectifs': entretien.objectifs,
      'notes': entretien.notes,
      'actions': entretien.actions,
      'updated_at': now,
      if (forInsert) 'created_at': now,
    };
  }

  Future<void> _openSessionForm({FormationSession? session}) async {
    final updated = await showDialog<FormationSession>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _SessionFormDialog(session: session),
      ),
    );
    if (updated == null) return;

    final exists = _sessions.any((item) => item.id == updated.id);
    if (exists) {
      await DaoRegistry.instance.formations.update(updated.id, _sessionToRow(updated, forInsert: false));
      showOperationNotice(context, message: 'Session mise a jour.', success: true);
    } else {
      await DaoRegistry.instance.formations.insert(_sessionToRow(updated, forInsert: true));
      showOperationNotice(context, message: 'Session ajoutee.', success: true);
    }
    await _loadSessions(resetPage: true);
  }

  void _openSessionDetail(FormationSession session) {
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _SessionDetailScreen(session: session),
      ),
    );
  }

  Future<void> _openEntretienForm({EntretienIndividuel? entretien}) async {
    final updated = await showDialog<EntretienIndividuel>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _EntretienFormDialog(
          entretien: entretien,
          employeeOptions: _employeeOptions,
          posteOptions: _posteOptions,
          managerOptions: _employeeOptions,
        ),
      ),
    );
    if (updated == null) return;

    final exists = _entretiens.any((item) => item.id == updated.id);
    if (exists) {
      await DaoRegistry.instance.entretiens.update(updated.id, _entretienToRow(updated, forInsert: false));
      showOperationNotice(context, message: 'Entretien mis a jour.', success: true);
    } else {
      await DaoRegistry.instance.entretiens.insert(_entretienToRow(updated, forInsert: true));
      showOperationNotice(context, message: 'Entretien ajoute.', success: true);
    }
    await _loadEntretiens(resetPage: true);
  }

  void _openEntretienDetail(EntretienIndividuel entretien) {
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _EntretienDetailScreen(entretien: entretien),
      ),
    );
  }

  Future<void> _deleteSession(FormationSession session) async {
    await DaoRegistry.instance.formations.delete(session.id);
    await _loadSessions(resetPage: true);
    showOperationNotice(context, message: 'Session supprimee.', success: true);
  }

  Future<void> _deleteEntretien(EntretienIndividuel entretien) async {
    await DaoRegistry.instance.entretiens.delete(entretien.id);
    await _loadEntretiens(resetPage: true);
    showOperationNotice(context, message: 'Entretien supprime.', success: true);
  }

  @override
  Widget build(BuildContext context) {
    final categories = _sessions.map((session) => session.category).where((c) => c.isNotEmpty).toSet().toList();
    return DefaultTabController(
      length: 4,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Formations & developpement',
              subtitle: 'Plan annuel, catalogue, sessions et entretiens.',
            ),
            const SizedBox(height: 16),
            AppCard(
              child: TabBar(
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: appTextMuted(context),
                tabs: const [
                  Tab(text: 'Plan annuel'),
                  Tab(text: 'Catalogue'),
                  Tab(text: 'Sessions'),
                  Tab(text: 'Entretiens'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 720,
              child: TabBarView(
                children: [
                  _PlanAnnuelTab(sessions: _sessions),
                  _CatalogueTab(categories: categories, sessions: _sessions),
                    _SessionsTab(
                    loading: _loadingSessions,
                    sessions: _sessions,
                    filterCategory: _filterCategory,
                    filterStatus: _filterSessionStatus,
                    page: _sessionPage,
                    pageSize: _sessionPageSize,
                    total: _sessionTotal,
                    sortValue: _sessionSort,
                    onSearch: (value) {
                      _searchSession = value;
                      _loadSessions(resetPage: true);
                    },
                    onCategoryChanged: (value) {
                      _filterCategory = value;
                      _loadSessions(resetPage: true);
                    },
                    onStatusChanged: (value) {
                      _filterSessionStatus = value;
                      _loadSessions(resetPage: true);
                    },
                    onSortChanged: (value) {
                      _sessionSort = value;
                      _loadSessions(resetPage: true);
                    },
                    onCreate: () => _openSessionForm(),
                    onEdit: (session) => _openSessionForm(session: session),
                    onOpen: _openSessionDetail,
                    onDelete: _deleteSession,
                    onExport: _exportSessionsCsv,
                    onPrev: () {
                      if (_sessionPage == 0) return;
                      setState(() => _sessionPage -= 1);
                      _loadSessions();
                    },
                    onNext: () {
                      final canNext = (_sessionPage + 1) * _sessionPageSize < _sessionTotal;
                      if (!canNext) return;
                      setState(() => _sessionPage += 1);
                      _loadSessions();
                    },
                  ),
                  _EntretiensTab(
                    loading: _loadingEntretiens,
                    entretiens: _entretiens,
                    filterStatus: _filterEntretienStatus,
                    filterType: _filterEntretienType,
                    page: _entretienPage,
                    pageSize: _entretienPageSize,
                    total: _entretienTotal,
                    sortValue: _entretienSort,
                    onSearch: (value) {
                      _searchEntretien = value;
                      _loadEntretiens(resetPage: true);
                    },
                    onStatusChanged: (value) {
                      _filterEntretienStatus = value;
                      _loadEntretiens(resetPage: true);
                    },
                    onTypeChanged: (value) {
                      _filterEntretienType = value;
                      _loadEntretiens(resetPage: true);
                    },
                    onSortChanged: (value) {
                      _entretienSort = value;
                      _loadEntretiens(resetPage: true);
                    },
                    onCreate: () => _openEntretienForm(),
                    onEdit: (entretien) => _openEntretienForm(entretien: entretien),
                    onOpen: _openEntretienDetail,
                    onDelete: _deleteEntretien,
                    onExport: _exportEntretiensCsv,
                    onPrev: () {
                      if (_entretienPage == 0) return;
                      setState(() => _entretienPage -= 1);
                      _loadEntretiens();
                    },
                    onNext: () {
                      final canNext = (_entretienPage + 1) * _entretienPageSize < _entretienTotal;
                      if (!canNext) return;
                      setState(() => _entretienPage += 1);
                      _loadEntretiens();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanAnnuelTab extends StatelessWidget {
  const _PlanAnnuelTab({required this.sessions});

  final List<FormationSession> sessions;

  @override
  Widget build(BuildContext context) {
    final totalBudget = sessions.fold<double>(0, (sum, s) => sum + s.budget);
    final categories = sessions.map((s) => s.category).where((c) => c.isNotEmpty).toSet();
    final completed = sessions.where((s) => s.status == 'Terminee').length;
    final total = sessions.length;
    final rate = total == 0 ? 0 : (completed / total * 100).round();

    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _MetricCard(title: 'Budget global', value: _formatBudget(totalBudget), subtitle: 'Plan annuel'),
              _MetricCard(title: 'Categories', value: '${categories.length}', subtitle: 'Catalogue'),
              _MetricCard(title: 'Sessions', value: '$total', subtitle: 'Planifiees'),
              _MetricCard(title: 'Taux de realisation', value: '$rate%', subtitle: 'Terminees'),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calendrier sessions prevues', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                if (sessions.isEmpty)
                  Text('Aucune session planifiee.', style: TextStyle(color: appTextMuted(context)))
                else
                  ...sessions.map(
                    (session) => _InfoRow(
                      label: '${session.title} • ${session.category}',
                      value: '${_formatDate(session.startDate)} • ${session.location}',
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calendrier mensuel', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                _MonthlyCalendar(sessions: sessions),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogueTab extends StatelessWidget {
  const _CatalogueTab({required this.categories, required this.sessions});

  final List<String> categories;
  final List<FormationSession> sessions;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Center(
        child: Text('Aucun catalogue disponible.', style: TextStyle(color: appTextMuted(context))),
      );
    }
    return SingleChildScrollView(
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: categories
            .map(
              (category) => _CatalogueCard(
                title: category,
                items: sessions.where((s) => s.category == category).map((s) => s.title).toList(),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SessionsTab extends StatelessWidget {
  const _SessionsTab({
    required this.loading,
    required this.sessions,
    required this.filterCategory,
    required this.filterStatus,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.sortValue,
    required this.onSearch,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onSortChanged,
    required this.onCreate,
    required this.onEdit,
    required this.onOpen,
    required this.onDelete,
    required this.onExport,
    required this.onPrev,
    required this.onNext,
  });

  final bool loading;
  final List<FormationSession> sessions;
  final String filterCategory;
  final String filterStatus;
  final int page;
  final int pageSize;
  final int total;
  final String sortValue;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onCreate;
  final ValueChanged<FormationSession> onEdit;
  final ValueChanged<FormationSession> onOpen;
  final ValueChanged<FormationSession> onDelete;
  final VoidCallback onExport;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final categories = sessions.map((s) => s.category).where((c) => c.isNotEmpty).toSet().toList();
    return SingleChildScrollView(
      child: Column(
        children: [
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
                      hintText: 'Recherche session...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: onSearch,
                  ),
                ),
                _FilterDropdown(
                  label: 'Categorie',
                  value: filterCategory,
                  items: ['Toutes', ...categories],
                  onChanged: onCategoryChanged,
                ),
                _FilterDropdown(
                  label: 'Statut',
                  value: filterStatus,
                  items: const ['Tous', 'Inscription ouverte', 'Convocations envoyees', 'En cours', 'Terminee'],
                  onChanged: onStatusChanged,
                ),
                _FilterDropdown(
                  label: 'Tri',
                  value: sortValue,
                  items: const ['Date desc', 'Date asc', 'Statut', 'Categorie', 'Titre'],
                  onChanged: onSortChanged,
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: onExport,
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Exporter CSV'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add),
                  label: const Text('Nouvelle session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (sessions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text('Aucune session disponible.', style: TextStyle(color: appTextMuted(context))),
            )
          else
            ...sessions.map(
              (session) => _SessionCard(
                session: session,
                onEdit: () => onEdit(session),
                onOpen: () => onOpen(session),
                onDelete: () => onDelete(session),
              ),
            ),
          const SizedBox(height: 12),
          _PaginationBar(
            page: page,
            pageSize: pageSize,
            total: total,
            onPrev: onPrev,
            onNext: onNext,
          ),
        ],
      ),
    );
  }
}

class _EntretiensTab extends StatelessWidget {
  const _EntretiensTab({
    required this.loading,
    required this.entretiens,
    required this.filterStatus,
    required this.filterType,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.sortValue,
    required this.onSearch,
    required this.onStatusChanged,
    required this.onTypeChanged,
    required this.onSortChanged,
    required this.onCreate,
    required this.onEdit,
    required this.onOpen,
    required this.onDelete,
    required this.onExport,
    required this.onPrev,
    required this.onNext,
  });

  final bool loading;
  final List<EntretienIndividuel> entretiens;
  final String filterStatus;
  final String filterType;
  final int page;
  final int pageSize;
  final int total;
  final String sortValue;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onCreate;
  final ValueChanged<EntretienIndividuel> onEdit;
  final ValueChanged<EntretienIndividuel> onOpen;
  final ValueChanged<EntretienIndividuel> onDelete;
  final VoidCallback onExport;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
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
                      hintText: 'Recherche entretien...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: onSearch,
                  ),
                ),
                _FilterDropdown(
                  label: 'Type',
                  value: filterType,
                  items: const ['Tous', 'Annuel', 'Professionnel', 'Integration'],
                  onChanged: onTypeChanged,
                ),
                _FilterDropdown(
                  label: 'Statut',
                  value: filterStatus,
                  items: const ['Tous', 'A planifier', 'Confirme', 'En cours', 'Termine'],
                  onChanged: onStatusChanged,
                ),
                _FilterDropdown(
                  label: 'Tri',
                  value: sortValue,
                  items: const ['Date desc', 'Date asc', 'Statut', 'Type', 'Employe'],
                  onChanged: onSortChanged,
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: onExport,
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Exporter CSV'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add),
                  label: const Text('Nouvel entretien'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (entretiens.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text('Aucun entretien planifie.', style: TextStyle(color: appTextMuted(context))),
            )
          else
            ...entretiens.map(
              (entretien) => _EntretienCard(
                entretien: entretien,
                onEdit: () => onEdit(entretien),
                onOpen: () => onOpen(entretien),
                onDelete: () => onDelete(entretien),
              ),
            ),
          const SizedBox(height: 12),
          _PaginationBar(
            page: page,
            pageSize: pageSize,
            total: total,
            onPrev: onPrev,
            onNext: onNext,
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.onEdit,
    required this.onOpen,
    required this.onDelete,
  });

  final FormationSession session;
  final VoidCallback onEdit;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  session.title,
                  style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context)),
                ),
              ),
              _StatusPill(label: session.status),
            ],
          ),
          const SizedBox(height: 6),
          Text('${session.category} • ${_formatDate(session.startDate)}', style: TextStyle(color: appTextMuted(context))),
          const SizedBox(height: 6),
          Text('Lieu: ${_display(session.location)}', style: TextStyle(color: appTextMuted(context), fontSize: 12)),
          Text('Participants: ${session.participants}', style: TextStyle(color: appTextMuted(context), fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              TextButton(onPressed: onEdit, child: const Text('Inscrire employes')),
              TextButton(onPressed: onEdit, child: const Text('Convocations auto')),
              TextButton(onPressed: onEdit, child: const Text('Emargement')),
              TextButton(onPressed: onEdit, child: const Text('Eval a chaud')),
              TextButton(onPressed: onEdit, child: const Text('Eval a froid')),
              TextButton(onPressed: onEdit, child: const Text('Attestations')),
              TextButton(onPressed: onOpen, child: const Text('Voir details')),
              TextButton(onPressed: onEdit, child: const Text('Modifier')),
              TextButton(onPressed: onDelete, child: const Text('Supprimer')),
            ],
          ),
        ],
      ),
    );
  }
}

class _EntretienCard extends StatelessWidget {
  const _EntretienCard({
    required this.entretien,
    required this.onEdit,
    required this.onOpen,
    required this.onDelete,
  });

  final EntretienIndividuel entretien;
  final VoidCallback onEdit;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entretien.employeNom,
                  style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context)),
                ),
              ),
              _StatusPill(label: entretien.status),
            ],
          ),
          const SizedBox(height: 6),
          Text('${entretien.poste} • ${_formatDate(entretien.date)}', style: TextStyle(color: appTextMuted(context))),
          const SizedBox(height: 6),
          Text('Manager: ${_display(entretien.manager)}', style: TextStyle(color: appTextMuted(context), fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              TextButton(onPressed: onEdit, child: const Text('Planifier entretien')),
              TextButton(onPressed: onOpen, child: const Text('Grille entretien')),
              TextButton(onPressed: onOpen, child: const Text('Bilan competences')),
              TextButton(onPressed: onOpen, child: const Text('Besoins formation')),
              TextButton(onPressed: onOpen, child: const Text('Objectifs N+1')),
              TextButton(onPressed: onOpen, child: const Text('Suivi plan')),
              TextButton(onPressed: onEdit, child: const Text('Modifier')),
              TextButton(onPressed: onOpen, child: const Text('Details')),
              TextButton(onPressed: onDelete, child: const Text('Supprimer')),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionFormDialog extends StatefulWidget {
  const _SessionFormDialog({this.session});

  final FormationSession? session;

  @override
  State<_SessionFormDialog> createState() => _SessionFormDialogState();
}

class _SessionFormDialogState extends State<_SessionFormDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _startCtrl;
  late final TextEditingController _endCtrl;
  late final TextEditingController _budgetCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _participantsCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _trainerCtrl;
  late final TextEditingController _modeCtrl;
  late final TextEditingController _objectifsCtrl;
  String _status = 'Inscription ouverte';
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.session?.title ?? '');
    _categoryCtrl = TextEditingController(text: widget.session?.category ?? '');
    _startCtrl = TextEditingController(text: widget.session == null ? '' : _formatDate(widget.session!.startDate));
    _endCtrl = TextEditingController(text: widget.session == null ? '' : _formatDate(widget.session!.endDate));
    _budgetCtrl = TextEditingController(text: widget.session?.budget.toString() ?? '');
    _locationCtrl = TextEditingController(text: widget.session?.location ?? '');
    _participantsCtrl = TextEditingController(text: widget.session?.participants.toString() ?? '');
    _descriptionCtrl = TextEditingController(text: widget.session?.description ?? '');
    _trainerCtrl = TextEditingController(text: widget.session?.trainer ?? '');
    _modeCtrl = TextEditingController(text: widget.session?.mode ?? '');
    _objectifsCtrl = TextEditingController(text: widget.session?.objectifs ?? '');
    _status = widget.session?.status ?? 'Inscription ouverte';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _budgetCtrl.dispose();
    _locationCtrl.dispose();
    _participantsCtrl.dispose();
    _descriptionCtrl.dispose();
    _trainerCtrl.dispose();
    _modeCtrl.dispose();
    _objectifsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final initial = DateTime.tryParse(controller.text.trim()) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    controller.text = _formatDate(picked);
  }

  bool _validate() {
    if (_titleCtrl.text.trim().isEmpty) {
      _error = 'Titre requis.';
      return false;
    }
    if (_categoryCtrl.text.trim().isEmpty) {
      _error = 'Categorie requise.';
      return false;
    }
    if (DateTime.tryParse(_startCtrl.text.trim()) == null) {
      _error = 'Date debut invalide.';
      return false;
    }
    if (DateTime.tryParse(_endCtrl.text.trim()) == null) {
      _error = 'Date fin invalide.';
      return false;
    }
    return true;
  }

  void _save() {
    setState(() => _error = null);
    if (!_validate()) {
      setState(() {});
      return;
    }

    final start = DateTime.parse(_startCtrl.text.trim());
    final end = DateTime.parse(_endCtrl.text.trim());
    final budget = double.tryParse(_budgetCtrl.text.trim()) ?? 0;
    final participants = int.tryParse(_participantsCtrl.text.trim()) ?? 0;
    final id = widget.session?.id ?? 'formation-${DateTime.now().millisecondsSinceEpoch}';

    final session = FormationSession(
      id: id,
      title: _titleCtrl.text.trim(),
      category: _categoryCtrl.text.trim(),
      startDate: start,
      endDate: end,
      budget: budget,
      status: _status,
      location: _locationCtrl.text.trim(),
      participants: participants,
      description: _descriptionCtrl.text.trim(),
      trainer: _trainerCtrl.text.trim(),
      mode: _modeCtrl.text.trim(),
      objectifs: _objectifsCtrl.text.trim(),
    );
    Navigator.of(context).pop(session);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.session != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier session' : 'Nouvelle session'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ),
            AppCard(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _FormField(controller: _titleCtrl, label: 'Titre *'),
                  _FormField(controller: _categoryCtrl, label: 'Categorie *'),
                  _FormField(
                    controller: _startCtrl,
                    label: 'Date debut *',
                    readOnly: true,
                    onTap: () => _pickDate(_startCtrl),
                    suffixIcon: const Icon(Icons.date_range),
                  ),
                  _FormField(
                    controller: _endCtrl,
                    label: 'Date fin *',
                    readOnly: true,
                    onTap: () => _pickDate(_endCtrl),
                    suffixIcon: const Icon(Icons.date_range),
                  ),
                  _FormField(controller: _locationCtrl, label: 'Lieu'),
                  _FormField(controller: _participantsCtrl, label: 'Participants'),
                  _FormField(controller: _budgetCtrl, label: 'Budget'),
                  _FormDropdown(
                    label: 'Statut',
                    value: _status,
                    items: const ['Inscription ouverte', 'Convocations envoyees', 'En cours', 'Terminee'],
                    onChanged: (value) => setState(() => _status = value),
                  ),
                  _FormField(controller: _trainerCtrl, label: 'Formateur'),
                  _FormField(controller: _modeCtrl, label: 'Mode'),
                  _FormField(controller: _descriptionCtrl, label: 'Description', maxLines: 3),
                  _FormField(controller: _objectifsCtrl, label: 'Objectifs', maxLines: 3),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(isEditing ? 'Mettre a jour' : 'Enregistrer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionDetailScreen extends StatelessWidget {
  const _SessionDetailScreen({required this.session});

  final FormationSession session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(session.title),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: session.title,
              subtitle: session.category,
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'Categorie', value: _display(session.category)),
                  _InfoRow(label: 'Periode', value: '${_formatDate(session.startDate)} - ${_formatDate(session.endDate)}'),
                  _InfoRow(label: 'Lieu', value: _display(session.location)),
                  _InfoRow(label: 'Participants', value: '${session.participants}'),
                  _InfoRow(label: 'Budget', value: _formatBudget(session.budget)),
                  _InfoRow(label: 'Statut', value: _display(session.status)),
                  _InfoRow(label: 'Formateur', value: _display(session.trainer)),
                  _InfoRow(label: 'Mode', value: _display(session.mode)),
                  _InfoRow(label: 'Objectifs', value: _display(session.objectifs)),
                  _InfoRow(label: 'Description', value: _display(session.description)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntretienFormDialog extends StatefulWidget {
  const _EntretienFormDialog({
    required this.employeeOptions,
    required this.posteOptions,
    required this.managerOptions,
    this.entretien,
  });

  final List<_IdLabelOption> employeeOptions;
  final List<_IdLabelOption> posteOptions;
  final List<_IdLabelOption> managerOptions;
  final EntretienIndividuel? entretien;

  @override
  State<_EntretienFormDialog> createState() => _EntretienFormDialogState();
}

class _EntretienFormDialogState extends State<_EntretienFormDialog> {
  late final TextEditingController _employeeCtrl;
  late final TextEditingController _posteCtrl;
  late final TextEditingController _managerCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _lieuCtrl;
  late final TextEditingController _objectifsCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _actionsCtrl;

  String _selectedEmployeeId = '';
  String _status = 'A planifier';
  String _type = 'Annuel';
  String? _error;

  @override
  void initState() {
    super.initState();
    _employeeCtrl = TextEditingController(text: widget.entretien?.employeNom ?? '');
    _posteCtrl = TextEditingController(text: widget.entretien?.poste ?? '');
    _managerCtrl = TextEditingController(text: widget.entretien?.manager ?? '');
    _dateCtrl = TextEditingController(
      text: widget.entretien == null ? '' : _formatDate(widget.entretien!.date),
    );
    _lieuCtrl = TextEditingController(text: widget.entretien?.lieu ?? '');
    _objectifsCtrl = TextEditingController(text: widget.entretien?.objectifs ?? '');
    _notesCtrl = TextEditingController(text: widget.entretien?.notes ?? '');
    _actionsCtrl = TextEditingController(text: widget.entretien?.actions ?? '');

    _selectedEmployeeId = widget.entretien?.employeId ?? '';
    _status = widget.entretien?.status ?? 'A planifier';
    _type = widget.entretien?.type ?? 'Annuel';
  }

  @override
  void dispose() {
    _employeeCtrl.dispose();
    _posteCtrl.dispose();
    _managerCtrl.dispose();
    _dateCtrl.dispose();
    _lieuCtrl.dispose();
    _objectifsCtrl.dispose();
    _notesCtrl.dispose();
    _actionsCtrl.dispose();
    super.dispose();
  }

  String _resolveEmployeeId(String label) {
    final match = widget.employeeOptions.firstWhere(
      (opt) => opt.label.toLowerCase() == label.toLowerCase(),
      orElse: () => const _IdLabelOption(id: '', label: ''),
    );
    return match.id;
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final initial = DateTime.tryParse(controller.text.trim()) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    controller.text = _formatDate(picked);
  }

  bool _validate() {
    if (_employeeCtrl.text.trim().isEmpty) {
      _error = 'Employe requis.';
      return false;
    }
    if (DateTime.tryParse(_dateCtrl.text.trim()) == null) {
      _error = 'Date invalide.';
      return false;
    }
    if (_selectedEmployeeId.isEmpty) {
      _selectedEmployeeId = _resolveEmployeeId(_employeeCtrl.text.trim());
    }
    if (_selectedEmployeeId.isEmpty) {
      _error = 'Selectionnez un employe existant.';
      return false;
    }
    return true;
  }

  void _save() {
    setState(() => _error = null);
    if (!_validate()) {
      setState(() {});
      return;
    }

    final date = DateTime.parse(_dateCtrl.text.trim());
    final id = widget.entretien?.id ?? 'entretien-${DateTime.now().millisecondsSinceEpoch}';

    final entretien = EntretienIndividuel(
      id: id,
      employeId: _selectedEmployeeId,
      employeNom: _employeeCtrl.text.trim(),
      poste: _posteCtrl.text.trim(),
      manager: _managerCtrl.text.trim(),
      date: date,
      status: _status,
      type: _type,
      lieu: _lieuCtrl.text.trim(),
      objectifs: _objectifsCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      actions: _actionsCtrl.text.trim(),
    );
    Navigator.of(context).pop(entretien);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entretien != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier entretien' : 'Nouvel entretien'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ),
            AppCard(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _EmployeeAutocomplete(
                    controller: _employeeCtrl,
                    label: 'Employe *',
                    options: widget.employeeOptions,
                    onSelected: (id) => _selectedEmployeeId = id,
                    onInputChanged: () => _selectedEmployeeId = '',
                  ),
                  _EmployeeAutocomplete(
                    controller: _posteCtrl,
                    label: 'Poste',
                    options: widget.posteOptions,
                    onSelected: (_) {},
                    onInputChanged: () {},
                  ),
                  _EmployeeAutocomplete(
                    controller: _managerCtrl,
                    label: 'Manager',
                    options: widget.managerOptions,
                    onSelected: (_) {},
                    onInputChanged: () {},
                  ),
                  _FormField(
                    controller: _dateCtrl,
                    label: 'Date *',
                    readOnly: true,
                    onTap: () => _pickDate(_dateCtrl),
                    suffixIcon: const Icon(Icons.date_range),
                  ),
                  _FormField(controller: _lieuCtrl, label: 'Lieu'),
                  _FormDropdown(
                    label: 'Type',
                    value: _type,
                    items: const ['Annuel', 'Professionnel', 'Integration'],
                    onChanged: (value) => setState(() => _type = value),
                  ),
                  _FormDropdown(
                    label: 'Statut',
                    value: _status,
                    items: const ['A planifier', 'Confirme', 'En cours', 'Termine'],
                    onChanged: (value) => setState(() => _status = value),
                  ),
                  _FormField(controller: _objectifsCtrl, label: 'Objectifs', maxLines: 3),
                  _FormField(controller: _notesCtrl, label: 'Notes', maxLines: 3),
                  _FormField(controller: _actionsCtrl, label: 'Actions', maxLines: 3),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(isEditing ? 'Mettre a jour' : 'Enregistrer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntretienDetailScreen extends StatelessWidget {
  const _EntretienDetailScreen({required this.entretien});

  final EntretienIndividuel entretien;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entretien.employeNom),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: entretien.employeNom,
              subtitle: entretien.poste.isEmpty ? 'Poste a definir' : entretien.poste,
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'Poste', value: _display(entretien.poste)),
                  _InfoRow(label: 'Manager', value: _display(entretien.manager)),
                  _InfoRow(label: 'Date', value: _formatDate(entretien.date)),
                  _InfoRow(label: 'Lieu', value: _display(entretien.lieu)),
                  _InfoRow(label: 'Type', value: _display(entretien.type)),
                  _InfoRow(label: 'Statut', value: _display(entretien.status)),
                  _InfoRow(label: 'Objectifs', value: _display(entretien.objectifs)),
                  _InfoRow(label: 'Notes', value: _display(entretien.notes)),
                  _InfoRow(label: 'Actions', value: _display(entretien.actions)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyCalendar extends StatelessWidget {
  const _MonthlyCalendar({required this.sessions});

  final List<FormationSession> sessions;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final sessionsByDay = <int, List<FormationSession>>{};
    for (final session in sessions) {
      if (session.startDate.month == now.month && session.startDate.year == now.year) {
        sessionsByDay.putIfAbsent(session.startDate.day, () => []).add(session);
      }
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: daysInMonth,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        final day = index + 1;
        final hasSession = sessionsByDay.containsKey(day);
        return Container(
          decoration: BoxDecoration(
            color: hasSession ? AppColors.primary.withOpacity(0.12) : AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: appBorderColor(context)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$day', style: TextStyle(color: appTextPrimary(context))),
                if (hasSession)
                  Text(
                    '${sessionsByDay[day]!.length} session',
                    style: TextStyle(color: appTextMuted(context), fontSize: 10),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CatalogueCard extends StatelessWidget {
  const _CatalogueCard({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: SizedBox(
        width: 260,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
            const SizedBox(height: 8),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: AppColors.success),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(color: appTextMuted(context), fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.subtitle});

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: appTextMuted(context))),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: appTextPrimary(context)),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: appTextMuted(context), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label.isEmpty ? 'A definir' : label, style: const TextStyle(fontSize: 10, color: AppColors.primary)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: appTextMuted(context)))),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, suffixIcon: suffixIcon),
      ),
    );
  }
}

class _FormDropdown extends StatelessWidget {
  const _FormDropdown({
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
      width: 240,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            )
            .toList(),
        onChanged: (value) => onChanged(value ?? items.first),
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
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            )
            .toList(),
        onChanged: (value) => onChanged(value ?? items.first),
      ),
    );
  }
}

class _EmployeeAutocomplete extends StatefulWidget {
  const _EmployeeAutocomplete({
    required this.controller,
    required this.label,
    required this.options,
    required this.onSelected,
    required this.onInputChanged,
  });

  final TextEditingController controller;
  final String label;
  final List<_IdLabelOption> options;
  final ValueChanged<String> onSelected;
  final VoidCallback onInputChanged;

  @override
  State<_EmployeeAutocomplete> createState() => _EmployeeAutocompleteState();
}

class _EmployeeAutocompleteState extends State<_EmployeeAutocomplete> {
  TextEditingController? _internalController;

  void _handleTextChanged() {
    if (_internalController == null) return;
    widget.controller.text = _internalController!.text;
    widget.onInputChanged();
  }

  @override
  void dispose() {
    _internalController?.removeListener(_handleTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.options.isEmpty) {
      return _FormField(controller: widget.controller, label: widget.label);
    }
    return SizedBox(
      width: 240,
      child: Autocomplete<_IdLabelOption>(
        optionsBuilder: (TextEditingValue text) {
          final query = text.text.trim().toLowerCase();
          if (query.isEmpty) return widget.options;
          return widget.options.where((opt) => opt.label.toLowerCase().contains(query));
        },
        displayStringForOption: (option) => option.label,
        onSelected: (option) {
          widget.controller.text = option.label;
          widget.onSelected(option.id);
        },
        fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
          if (_internalController != textController) {
            _internalController?.removeListener(_handleTextChanged);
            _internalController = textController;
            _internalController!.text = widget.controller.text;
            _internalController!.selection = TextSelection.fromPosition(
              TextPosition(offset: _internalController!.text.length),
            );
            _internalController!.addListener(_handleTextChanged);
          }
          return TextField(
            controller: textController,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: widget.label,
              suffixIcon: const Icon(Icons.search),
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              child: SizedBox(
                width: 240,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return ListTile(
                      title: Text(
                        option.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _IdLabelOption {
  const _IdLabelOption({required this.id, required this.label});

  final String id;
  final String label;
}

String _formatDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _escapeCsv(String value) {
  final escaped = value.replaceAll('"', '""');
  final needsQuotes = escaped.contains(',') || escaped.contains('\n') || escaped.contains('\r') || escaped.contains('"');
  return needsQuotes ? '"$escaped"' : escaped;
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  final int page;
  final int pageSize;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    final start = page * pageSize + 1;
    var end = (page + 1) * pageSize;
    if (end > total) end = total;
    final canPrev = page > 0;
    final canNext = end < total;

    return Row(
      children: [
        Text('$start-$end sur $total', style: TextStyle(color: appTextMuted(context))),
        const Spacer(),
        TextButton(onPressed: canPrev ? onPrev : null, child: const Text('Precedent')),
        const SizedBox(width: 8),
        TextButton(onPressed: canNext ? onNext : null, child: const Text('Suivant')),
      ],
    );
  }
}

String _formatBudget(double value) {
  if (value == 0) return 'FCFA 0';
  if (value >= 1000000) {
    return 'FCFA ${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return 'FCFA ${(value / 1000).toStringAsFixed(1)}k';
  }
  return 'FCFA ${value.toStringAsFixed(0)}';
}

String _display(String value) {
  return value.isEmpty ? 'A definir' : value;
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/dao/dao_registry.dart';
import '../../../core/utils/time_calculator.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/operation_notice.dart';
import '../../../core/widgets/section_header.dart';
import '../../../shared/models/presence.dart';

class PresencesScreen extends StatefulWidget {
  const PresencesScreen({super.key});

  @override
  State<PresencesScreen> createState() => _PresencesScreenState();
}

class _PresencesScreenState extends State<PresencesScreen> {
  final List<Presence> _presences = [];
  final List<_IdLabelOption> _employeeOptions = [];
  final TextEditingController _startDateCtrl = TextEditingController();
  final TextEditingController _endDateCtrl = TextEditingController();

  bool _loading = false;
  int _page = 0;
  final int _pageSize = 10;
  int _totalPresences = 0;

  String _searchQuery = '';
  String _filterEmployeeId = '';
  String _filterStatus = 'Tous';
  String _filterType = 'Tous';
  String _filterSource = 'Tous';
  String _filterValidation = 'Tous';

  _PresenceMetrics _metrics = const _PresenceMetrics.empty();
  List<_AnomalyItemData> _anomalies = const [];
  Map<int, String> _calendarStatuses = const {};
  List<int> _weeklyPresence = const [];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    super.dispose();
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
    await _loadPresences(resetPage: true);
    await _loadMetrics();
  }

  Future<void> _loadPresences({bool resetPage = false}) async {
    if (resetPage) _page = 0;
    setState(() => _loading = true);

    final start = _parseDate(_startDateCtrl.text.trim(), endOfDay: false);
    final end = _parseDate(_endDateCtrl.text.trim(), endOfDay: true);

    final rows = await DaoRegistry.instance.presences.search(
      query: _searchQuery,
      employeeId: _filterEmployeeId,
      status: _filterStatus == 'Tous' ? null : _filterStatus,
      type: _filterType == 'Tous' ? null : _filterType,
      source: _filterSource == 'Tous' ? null : _filterSource,
      validationStatus: _filterValidation == 'Tous' ? null : _filterValidation,
      startDate: start,
      endDate: end,
      limit: _pageSize,
      offset: _page * _pageSize,
      orderBy: 'date DESC',
    );

    final total = await DaoRegistry.instance.presences.count(
      query: _searchQuery,
      employeeId: _filterEmployeeId,
      status: _filterStatus == 'Tous' ? null : _filterStatus,
      type: _filterType == 'Tous' ? null : _filterType,
      source: _filterSource == 'Tous' ? null : _filterSource,
      validationStatus: _filterValidation == 'Tous' ? null : _filterValidation,
      startDate: start,
      endDate: end,
    );

    if (!mounted) return;
    setState(() {
      _presences
        ..clear()
        ..addAll(rows.map(_presenceFromRow).map(_normalizePresenceName));
      _totalPresences = total;
      _loading = false;
    });
  }

  Future<void> _loadMetrics() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);

    final rows = await DaoRegistry.instance.presences.search(
      startDate: start.millisecondsSinceEpoch,
      endDate: end.millisecondsSinceEpoch,
      orderBy: 'date ASC',
    );
    final presences = rows.map(_presenceFromRow).toList();

    final stats = _computeMetrics(presences.map(_normalizePresenceName).toList());
    if (!mounted) return;
    setState(() {
      _metrics = stats.metrics;
      _anomalies = stats.anomalies;
      _calendarStatuses = stats.calendarStatuses;
      _weeklyPresence = stats.weeklyPresence;
    });
  }

  Presence _normalizePresenceName(Presence presence) {
    if (presence.employeName.isNotEmpty || presence.employeId.isEmpty) {
      return presence;
    }
    final match = _employeeOptions.firstWhere(
      (opt) => opt.id == presence.employeId,
      orElse: () => const _IdLabelOption(id: '', label: ''),
    );
    if (match.label.isEmpty) return presence;
    return Presence(
      id: presence.id,
      employeId: presence.employeId,
      employeName: match.label,
      date: presence.date,
      heureArrivee: presence.heureArrivee,
      heureDepart: presence.heureDepart,
      status: presence.status,
      type: presence.type,
      source: presence.source,
      lieu: presence.lieu,
      justification: presence.justification,
      validationStatus: presence.validationStatus,
      validator: presence.validator,
      commentaire: presence.commentaire,
    );
  }

  Presence _presenceFromRow(Map<String, dynamic> row) {
    final dateMillis = row['date'] as int?;
    return Presence(
      id: (row['id'] as String?) ?? '',
      employeId: (row['employe_id'] as String?) ?? '',
      employeName: (row['employe_nom'] as String?) ?? '',
      date: dateMillis == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(dateMillis),
      heureArrivee: (row['heure_arrivee'] as String?) ?? '',
      heureDepart: (row['heure_depart'] as String?) ?? '',
      status: (row['statut'] as String?) ?? '',
      type: (row['type'] as String?) ?? '',
      source: (row['source'] as String?) ?? '',
      lieu: (row['lieu'] as String?) ?? '',
      justification: (row['justification'] as String?) ?? '',
      validationStatus: (row['statut_validation'] as String?) ?? '',
      validator: (row['validateur'] as String?) ?? '',
      commentaire: (row['commentaire'] as String?) ?? '',
    );
  }

  Map<String, dynamic> _presenceToRow(Presence presence, {required bool forInsert}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return {
      'id': presence.id,
      'employe_id': presence.employeId,
      'employe_nom': presence.employeName,
      'date': presence.date.millisecondsSinceEpoch,
      'heure_arrivee': presence.heureArrivee,
      'heure_depart': presence.heureDepart,
      'statut': presence.status,
      'type': presence.type,
      'source': presence.source,
      'lieu': presence.lieu,
      'justification': presence.justification,
      'statut_validation': presence.validationStatus,
      'validateur': presence.validator,
      'commentaire': presence.commentaire,
      'updated_at': now,
      if (forInsert) 'created_at': now,
    };
  }

  Future<void> _openPresenceForm({
    Presence? presence,
    String? presetType,
    String? presetStatus,
    String? presetSource,
  }) async {
    final updated = await showDialog<Presence>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _PresenceFormScreen(
          presence: presence,
          employeeOptions: _employeeOptions,
          presetType: presetType,
          presetStatus: presetStatus,
          presetSource: presetSource,
        ),
      ),
    );

    if (updated == null) return;

    final exists = _presences.any((item) => item.id == updated.id);
    if (exists) {
      await DaoRegistry.instance.presences.update(updated.id, _presenceToRow(updated, forInsert: false));
      showOperationNotice(context, message: 'Presence mise a jour.', success: true);
    } else {
      await DaoRegistry.instance.presences.insert(_presenceToRow(updated, forInsert: true));
      showOperationNotice(context, message: 'Presence enregistree.', success: true);
    }
    await _loadPresences(resetPage: true);
    await _loadMetrics();
  }

  Future<void> _confirmDeletePresence(Presence presence) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer presence'),
        content: Text('Supprimer le pointage de ${presence.employeName} ?'),
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
    await DaoRegistry.instance.presences.delete(presence.id);
    await _loadPresences(resetPage: true);
    await _loadMetrics();
    showOperationNotice(context, message: 'Presence supprimee.', success: true);
  }

  void _openPresenceDetail(Presence presence) {
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _PresenceDetailScreen(
          presence: presence,
          onEdit: () => _openPresenceForm(presence: presence),
          onDelete: () => _confirmDeletePresence(presence),
        ),
      ),
    );
  }

  int? _parseDate(String input, {required bool endOfDay}) {
    if (input.isEmpty) return null;
    final date = DateTime.tryParse(input);
    if (date == null) return null;
    if (!endOfDay) {
      return DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    }
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999).millisecondsSinceEpoch;
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Tableau de bord'),
              Tab(text: 'Pointage employe'),
              Tab(text: 'Gestion horaires'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _DashboardTab(
                  metrics: _metrics,
                  anomalies: _anomalies,
                  calendarStatuses: _calendarStatuses,
                  weeklyPresence: _weeklyPresence,
                ),
                _PointageTab(
                  loading: _loading,
                  presences: _presences,
                  totalPresences: _totalPresences,
                  page: _page,
                  pageSize: _pageSize,
                  employeeOptions: _employeeOptions,
                  searchQuery: _searchQuery,
                  filterEmployeeId: _filterEmployeeId,
                  filterStatus: _filterStatus,
                  filterType: _filterType,
                  filterSource: _filterSource,
                  filterValidation: _filterValidation,
                  startDateCtrl: _startDateCtrl,
                  endDateCtrl: _endDateCtrl,
                  onSearchChanged: (value) {
                    _searchQuery = value;
                    _loadPresences(resetPage: true);
                  },
                  onEmployeeChanged: (value) {
                    _filterEmployeeId = value;
                    _loadPresences(resetPage: true);
                  },
                  onStatusChanged: (value) {
                    _filterStatus = value;
                    _loadPresences(resetPage: true);
                  },
                  onTypeChanged: (value) {
                    _filterType = value;
                    _loadPresences(resetPage: true);
                  },
                  onSourceChanged: (value) {
                    _filterSource = value;
                    _loadPresences(resetPage: true);
                  },
                  onValidationChanged: (value) {
                    _filterValidation = value;
                    _loadPresences(resetPage: true);
                  },
                  onDateApply: () => _loadPresences(resetPage: true),
                  onManual: () => _openPresenceForm(
                    presetType: 'Pointage',
                    presetStatus: 'Present',
                    presetSource: 'Manuel',
                  ),
                  onTeletravail: () => _openPresenceForm(
                    presetType: 'Teletravail',
                    presetStatus: 'Teletravail',
                    presetSource: 'Declaration',
                  ),
                  onAjustement: () => _openPresenceForm(
                    presetType: 'Ajustement',
                    presetStatus: 'Present',
                    presetSource: 'RH',
                  ),
                  onCreate: () => _openPresenceForm(),
                  onOpenDetail: _openPresenceDetail,
                  onEdit: (presence) => _openPresenceForm(presence: presence),
                  onDelete: _confirmDeletePresence,
                  onPrevPage: () {
                    if (_page == 0) return;
                    setState(() => _page -= 1);
                    _loadPresences();
                  },
                  onNextPage: () {
                    final canNext = (_page + 1) * _pageSize < _totalPresences;
                    if (!canNext) return;
                    setState(() => _page += 1);
                    _loadPresences();
                  },
                  formatDate: _formatDate,
                ),
                _HorairesTab(metrics: _metrics),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.metrics,
    required this.anomalies,
    required this.calendarStatuses,
    required this.weeklyPresence,
  });

  final _PresenceMetrics metrics;
  final List<_AnomalyItemData> anomalies;
  final Map<int, String> calendarStatuses;
  final List<int> weeklyPresence;

  @override
  Widget build(BuildContext context) {
    final presenceRate = metrics.total == 0 ? 0 : (metrics.presentCount / metrics.total * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Tableau de bord pointages',
            subtitle: 'Suivi journalier et statistiques mensuelles.',
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vue journaliere',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: appTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 12),
                _DailyStatusRow(metrics: metrics),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Calendrier mensuel',
            subtitle: 'Visualisation par employe et par jour.',
          ),
          const SizedBox(height: 12),
          _MonthlyCalendar(statuses: calendarStatuses),
          const SizedBox(height: 24),
          const SectionHeader(
            title: 'Statistiques',
            subtitle: 'Taux de presence, retards, heures supplementaires.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _PresenceStat(title: 'Taux de presence', value: '$presenceRate%'),
              _PresenceStat(title: 'Heures supplementaires', value: '${metrics.overtimeHours.toStringAsFixed(1)}h'),
              _PresenceStat(title: 'Retards', value: '${metrics.retardsCount}'),
              _PresenceStat(title: 'Absences non justifiees', value: '${metrics.absencesNonJustifiees}'),
            ],
          ),
          const SizedBox(height: 24),
          AppCard(
            child: SizedBox(
              height: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tendance hebdomadaire',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: appTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _PresenceChart(values: weeklyPresence)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: SizedBox(
              height: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anomalies',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: appTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: anomalies.isEmpty
                        ? Center(
                            child: Text(
                              'Aucune anomalie detectee.',
                              style: TextStyle(color: appTextMuted(context)),
                            ),
                          )
                        : ListView(
                            children: anomalies
                                .map(
                                  (item) => _AnomalyItem(
                                    title: item.title,
                                    subtitle: item.subtitle,
                                  ),
                                )
                                .toList(),
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
}

class _PointageTab extends StatelessWidget {
  const _PointageTab({
    required this.loading,
    required this.presences,
    required this.totalPresences,
    required this.page,
    required this.pageSize,
    required this.employeeOptions,
    required this.searchQuery,
    required this.filterEmployeeId,
    required this.filterStatus,
    required this.filterType,
    required this.filterSource,
    required this.filterValidation,
    required this.startDateCtrl,
    required this.endDateCtrl,
    required this.onSearchChanged,
    required this.onEmployeeChanged,
    required this.onStatusChanged,
    required this.onTypeChanged,
    required this.onSourceChanged,
    required this.onValidationChanged,
    required this.onDateApply,
    required this.onManual,
    required this.onTeletravail,
    required this.onAjustement,
    required this.onCreate,
    required this.onOpenDetail,
    required this.onEdit,
    required this.onDelete,
    required this.onPrevPage,
    required this.onNextPage,
    required this.formatDate,
  });

  final bool loading;
  final List<Presence> presences;
  final int totalPresences;
  final int page;
  final int pageSize;
  final List<_IdLabelOption> employeeOptions;
  final String searchQuery;
  final String filterEmployeeId;
  final String filterStatus;
  final String filterType;
  final String filterSource;
  final String filterValidation;
  final TextEditingController startDateCtrl;
  final TextEditingController endDateCtrl;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onEmployeeChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onSourceChanged;
  final ValueChanged<String> onValidationChanged;
  final VoidCallback onDateApply;
  final VoidCallback onManual;
  final VoidCallback onTeletravail;
  final VoidCallback onAjustement;
  final VoidCallback onCreate;
  final ValueChanged<Presence> onOpenDetail;
  final ValueChanged<Presence> onEdit;
  final ValueChanged<Presence> onDelete;
  final VoidCallback onPrevPage;
  final VoidCallback onNextPage;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
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
                          hintText: 'Recherche employe...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: onSearchChanged,
                      ),
                    ),
                    _EmployeeDropdown(
                      label: 'Employe',
                      value: filterEmployeeId,
                      options: employeeOptions,
                      onChanged: onEmployeeChanged,
                    ),
                    _FilterDropdown(
                      label: 'Statut',
                      value: filterStatus,
                      items: const ['Tous', 'Present', 'Absent', 'Retard', 'Teletravail', 'Conge', 'Mission'],
                      onChanged: onStatusChanged,
                    ),
                    _FilterDropdown(
                      label: 'Type',
                      value: filterType,
                      items: const ['Tous', 'Pointage', 'Teletravail', 'Absence', 'Ajustement', 'Mission'],
                      onChanged: onTypeChanged,
                    ),
                    _FilterDropdown(
                      label: 'Source',
                      value: filterSource,
                      items: const ['Tous', 'Badge', 'Manuel', 'Mobile', 'RH', 'Declaration'],
                      onChanged: onSourceChanged,
                    ),
                    _FilterDropdown(
                      label: 'Validation',
                      value: filterValidation,
                      items: const ['Tous', 'En attente', 'Valide', 'Rejete'],
                      onChanged: onValidationChanged,
                    ),
                    SizedBox(
                      width: 160,
                      child: TextField(
                        controller: startDateCtrl,
                        decoration: const InputDecoration(labelText: 'Du (YYYY-MM-DD)'),
                        onSubmitted: (_) => onDateApply(),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: TextField(
                        controller: endDateCtrl,
                        decoration: const InputDecoration(labelText: 'Au (YYYY-MM-DD)'),
                        onSubmitted: (_) => onDateApply(),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onDateApply,
                      icon: const Icon(Icons.filter_alt_outlined),
                      label: const Text('Appliquer'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onManual,
                      icon: const Icon(Icons.edit_calendar),
                      label: const Text('Pointage manuel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onTeletravail,
                      icon: const Icon(Icons.home_work_outlined),
                      label: const Text('Declaration teletravail'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onAjustement,
                      icon: const Icon(Icons.tune),
                      label: const Text('Ajustement horaire'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onCreate,
                      icon: const Icon(Icons.add),
                      label: const Text('Nouvelle presence'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTable(context),
                const SizedBox(height: 12),
                _PaginationBar(
                  page: page,
                  pageSize: pageSize,
                  total: totalPresences,
                  onPrev: onPrevPage,
                  onNext: onNextPage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const SectionHeader(
      title: 'Pointage employe',
      subtitle: 'Badgeage, teletravail, ajustements horaires.',
    );
  }

  Widget _buildTable(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (presences.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Aucune presence. Utilisez "Nouvelle presence" pour commencer.',
            style: TextStyle(color: appTextMuted(context)),
          ),
        ),
      );
    }

    return DataTable(
      columns: const [
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Employe')),
        DataColumn(label: Text('Statut')),
        DataColumn(label: Text('Type')),
        DataColumn(label: Text('Heure')),
        DataColumn(label: Text('Validation')),
        DataColumn(label: Text('Actions')),
      ],
      rows: presences
          .map(
            (presence) => DataRow(
              cells: [
                DataCell(Text(formatDate(presence.date))),
                DataCell(
                  SizedBox(
                    width: 160,
                    child: Text(
                      presence.employeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ),
                DataCell(Text(presence.status)),
                DataCell(Text(presence.type)),
                DataCell(Text(_formatHourRange(presence.heureArrivee, presence.heureDepart))),
                DataCell(Text(presence.validationStatus.isEmpty ? 'En attente' : presence.validationStatus)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Voir details',
                        icon: const Icon(Icons.visibility_outlined),
                        onPressed: () => onOpenDetail(presence),
                      ),
                      IconButton(
                        tooltip: 'Modifier',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => onEdit(presence),
                      ),
                      IconButton(
                        tooltip: 'Supprimer',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onDelete(presence),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _HorairesTab extends StatelessWidget {
  const _HorairesTab({required this.metrics});

  final _PresenceMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final contractHours = metrics.totalWorkDays * 8.0;
    final breakdown = computeOvertimeBreakdown(
      totalHours: metrics.totalWorkedHours,
      contractHours: contractHours,
      overtime25Cap: 8,
      rttRate: 0,
    );
    final presenceRate = metrics.total == 0 ? 0 : (metrics.presentCount / metrics.total * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Gestion des horaires',
            subtitle: 'Horaires contractuels, planning et compteurs temps.',
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _InfoRow(label: 'Type contrat', value: 'A definir'),
                _InfoRow(label: 'Horaires standards', value: 'A definir'),
                _InfoRow(label: 'Repos hebdomadaire', value: 'A definir'),
                _InfoRow(label: 'Modulation temps', value: 'A definir'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _InfoRow(label: 'Equipes', value: 'A definir'),
                _InfoRow(label: 'Astreintes', value: 'A definir'),
                _InfoRow(label: 'Teletravail autorise', value: 'A definir'),
                _InfoRow(label: 'Planning variable', value: 'A definir'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Heures travaillees', value: '${metrics.totalWorkedHours.toStringAsFixed(1)}h'),
                _InfoRow(label: 'Heures supplementaires', value: '${metrics.overtimeHours.toStringAsFixed(1)}h'),
                const _InfoRow(label: 'Recuperations acquises', value: 'A definir'),
                const _InfoRow(label: 'RTT disponibles', value: 'A definir'),
                const _InfoRow(label: 'Compte epargne temps', value: 'A definir'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calcul automatique heures',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: appTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                _InfoRow(label: 'Heures normales', value: '${breakdown.normalHours.toStringAsFixed(1)}h'),
                _InfoRow(label: 'HS majorees 25%', value: '${breakdown.overtime25.toStringAsFixed(1)}h'),
                _InfoRow(label: 'HS majorees 50%', value: '${breakdown.overtime50.toStringAsFixed(1)}h'),
                _InfoRow(label: 'RTT acquis', value: '${breakdown.rttAccrued.toStringAsFixed(1)}h'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Taux presence mensuel', value: '$presenceRate%'),
                _InfoRow(label: 'Retards cumules', value: '${metrics.retardsCount}'),
                _InfoRow(label: 'Absences non justifiees', value: '${metrics.absencesNonJustifiees}'),
                const _InfoRow(label: 'Regularite horaires', value: 'A definir'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyStatusRow extends StatelessWidget {
  const _DailyStatusRow({required this.metrics});

  final _PresenceMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        _StatusChip(label: 'Presents', value: '${metrics.presentCount}'),
        _StatusChip(label: 'Absents', value: '${metrics.absentsCount}'),
        _StatusChip(label: 'Retards', value: '${metrics.retardsCount}'),
        _StatusChip(label: 'Teletravail', value: '${metrics.teletravailCount}'),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: appTextPrimary(context), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MonthlyCalendar extends StatelessWidget {
  const _MonthlyCalendar({required this.statuses});

  final Map<int, String> statuses;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_monthLabel(now.month)} ${now.year}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: appTextPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
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
              final status = statuses[day] ?? '';
              final statusColor = _statusColor(status);
              return Container(
                decoration: BoxDecoration(
                  color: statusColor == null ? AppColors.card : statusColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColor ?? appBorderColor(context),
                  ),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: statusColor == null ? appTextPrimary(context) : statusColor,
                      fontWeight: statusColor == null ? FontWeight.w500 : FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PresenceStat extends StatelessWidget {
  const _PresenceStat({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, color: appTextMuted(context)),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: appTextPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnomalyItem extends StatelessWidget {
  const _AnomalyItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.alert,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: appTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: appTextMuted(context)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

class _PresenceChart extends StatelessWidget {
  const _PresenceChart({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final normalized = values.length >= 7 ? values : [...values, ...List.filled(7 - values.length, 0)];
    final spots = <FlSpot>[];
    for (var i = 0; i < 7; i++) {
      spots.add(FlSpot(i.toDouble(), normalized[i].toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: AppColors.primary,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: const LinearGradient(
                colors: [Color(0x4422D3EE), Color(0x0019A7E0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            spots: spots,
          ),
        ],
      ),
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
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: appTextMuted(context)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: appTextPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresenceFormScreen extends StatefulWidget {
  const _PresenceFormScreen({
    this.presence,
    required this.employeeOptions,
    this.presetType,
    this.presetStatus,
    this.presetSource,
  });

  final Presence? presence;
  final List<_IdLabelOption> employeeOptions;
  final String? presetType;
  final String? presetStatus;
  final String? presetSource;

  @override
  State<_PresenceFormScreen> createState() => _PresenceFormScreenState();
}

class _PresenceFormScreenState extends State<_PresenceFormScreen> {
  late final TextEditingController _employeeCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _arrivalCtrl;
  late final TextEditingController _departureCtrl;
  late final TextEditingController _justificationCtrl;
  late final TextEditingController _lieuCtrl;
  late final TextEditingController _validatorCtrl;
  late final TextEditingController _commentCtrl;
  String _selectedEmployeeId = '';

  String _status = 'Present';
  String _type = 'Pointage';
  String _source = 'Badge';
  String _validationStatus = 'En attente';
  String? _error;

  @override
  void initState() {
    super.initState();
    _employeeCtrl = TextEditingController(text: widget.presence?.employeName ?? '');
    _dateCtrl = TextEditingController(text: widget.presence != null ? _formatDate(widget.presence!.date) : '');
    _arrivalCtrl = TextEditingController(text: widget.presence?.heureArrivee ?? '');
    _departureCtrl = TextEditingController(text: widget.presence?.heureDepart ?? '');
    _justificationCtrl = TextEditingController(text: widget.presence?.justification ?? '');
    _lieuCtrl = TextEditingController(text: widget.presence?.lieu ?? '');
    _validatorCtrl = TextEditingController(text: widget.presence?.validator ?? '');
    _commentCtrl = TextEditingController(text: widget.presence?.commentaire ?? '');
    _selectedEmployeeId = widget.presence?.employeId ?? '';

    _status = widget.presence?.status ?? widget.presetStatus ?? 'Present';
    _type = widget.presence?.type ?? widget.presetType ?? 'Pointage';
    _source = widget.presence?.source ?? widget.presetSource ?? 'Badge';
    _validationStatus = widget.presence?.validationStatus.isNotEmpty == true
        ? widget.presence!.validationStatus
        : 'En attente';
  }

  @override
  void dispose() {
    _employeeCtrl.dispose();
    _dateCtrl.dispose();
    _arrivalCtrl.dispose();
    _departureCtrl.dispose();
    _justificationCtrl.dispose();
    _lieuCtrl.dispose();
    _validatorCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  String _resolveEmployeeName(String id) {
    final match = widget.employeeOptions.firstWhere(
      (opt) => opt.id == id,
      orElse: () => const _IdLabelOption(id: '', label: ''),
    );
    return match.label.isEmpty ? id : match.label;
  }

  String _resolveEmployeeId(String label) {
    final match = widget.employeeOptions.firstWhere(
      (opt) => opt.label.toLowerCase() == label.toLowerCase(),
      orElse: () => const _IdLabelOption(id: '', label: ''),
    );
    return match.id;
  }

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(_dateCtrl.text.trim()) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    _dateCtrl.text = _formatDate(picked);
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
    );
    if (picked == null) return;
    final hour = picked.hour.toString().padLeft(2, '0');
    final minute = picked.minute.toString().padLeft(2, '0');
    controller.text = '$hour:$minute';
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  bool _validate() {
    final employee = _employeeCtrl.text.trim();
    final date = DateTime.tryParse(_dateCtrl.text.trim());
    if (employee.isEmpty) {
      _error = 'Employe requis.';
      return false;
    }
    if (date == null) {
      _error = 'Date invalide.';
      return false;
    }
    if (_selectedEmployeeId.isEmpty) {
      _selectedEmployeeId = _resolveEmployeeId(employee);
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
    final id = widget.presence?.id ?? 'presence-${DateTime.now().millisecondsSinceEpoch}';
    final presence = Presence(
      id: id,
      employeId: _selectedEmployeeId,
      employeName: _resolveEmployeeName(_selectedEmployeeId),
      date: date,
      heureArrivee: _arrivalCtrl.text.trim(),
      heureDepart: _departureCtrl.text.trim(),
      status: _status,
      type: _type,
      source: _source,
      lieu: _lieuCtrl.text.trim(),
      justification: _justificationCtrl.text.trim(),
      validationStatus: _validationStatus,
      validator: _validatorCtrl.text.trim(),
      commentaire: _commentCtrl.text.trim(),
    );
    Navigator.of(context).pop(presence);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.presence != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier presence' : 'Nouvelle presence'),
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
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
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
                  _FormField(
                    controller: _dateCtrl,
                    label: 'Date *',
                    readOnly: true,
                    onTap: _pickDate,
                    suffixIcon: const Icon(Icons.date_range),
                  ),
                  _FormField(
                    controller: _arrivalCtrl,
                    label: 'Heure arrivee',
                    readOnly: true,
                    onTap: () => _pickTime(_arrivalCtrl),
                    suffixIcon: const Icon(Icons.schedule),
                  ),
                  _FormField(
                    controller: _departureCtrl,
                    label: 'Heure depart',
                    readOnly: true,
                    onTap: () => _pickTime(_departureCtrl),
                    suffixIcon: const Icon(Icons.schedule),
                  ),
                  _FormDropdown(
                    label: 'Statut *',
                    value: _status,
                    items: const ['Present', 'Absent', 'Retard', 'Teletravail', 'Conge', 'Mission'],
                    onChanged: (value) => setState(() => _status = value),
                  ),
                  _FormDropdown(
                    label: 'Type *',
                    value: _type,
                    items: const ['Pointage', 'Teletravail', 'Absence', 'Ajustement', 'Mission'],
                    onChanged: (value) => setState(() => _type = value),
                  ),
                  _FormDropdown(
                    label: 'Source *',
                    value: _source,
                    items: const ['Badge', 'Manuel', 'Mobile', 'RH', 'Declaration'],
                    onChanged: (value) => setState(() => _source = value),
                  ),
                  _FormField(controller: _lieuCtrl, label: 'Lieu'),
                  _FormDropdown(
                    label: 'Validation',
                    value: _validationStatus,
                    items: const ['En attente', 'Valide', 'Rejete'],
                    onChanged: (value) => setState(() => _validationStatus = value),
                  ),
                  _FormField(controller: _validatorCtrl, label: 'Validateur'),
                  _FormField(controller: _justificationCtrl, label: 'Justification'),
                  _FormField(controller: _commentCtrl, label: 'Commentaire'),
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

class _PresenceDetailScreen extends StatelessWidget {
  const _PresenceDetailScreen({
    required this.presence,
    required this.onEdit,
    required this.onDelete,
  });

  final Presence presence;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail presence'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
              onEdit();
            },
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Close icon replaces delete here per detail pattern.
            },
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
              title: presence.employeName.isEmpty ? 'Presence' : presence.employeName,
              subtitle: 'Pointage du ${_formatDate(presence.date)}',
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'Employe', value: presence.employeName),
                  _InfoRow(label: 'Date', value: _formatDate(presence.date)),
                  _InfoRow(label: 'Statut', value: _display(presence.status)),
                  _InfoRow(label: 'Type', value: _display(presence.type)),
                  _InfoRow(label: 'Source', value: _display(presence.source)),
                  _InfoRow(label: 'Heure arrivee', value: _display(presence.heureArrivee)),
                  _InfoRow(label: 'Heure depart', value: _display(presence.heureDepart)),
                  _InfoRow(label: 'Lieu', value: _display(presence.lieu)),
                  _InfoRow(label: 'Justification', value: _display(presence.justification)),
                  _InfoRow(label: 'Validation', value: _display(presence.validationStatus)),
                  _InfoRow(label: 'Validateur', value: _display(presence.validator)),
                  _InfoRow(label: 'Commentaire', value: _display(presence.commentaire)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _display(String value) {
    return value.isEmpty ? 'A definir' : value;
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(labelText: label, suffixIcon: suffixIcon),
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
      width: 170,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label, filled: true),
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

class _EmployeeDropdown extends StatelessWidget {
  const _EmployeeDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<_IdLabelOption> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final entries = [const _IdLabelOption(id: '', label: 'Tous'), ...options];
    return SizedBox(
      width: 190,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label, filled: true),
        items: entries
            .map(
              (option) => DropdownMenuItem(
                value: option.id,
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            )
            .toList(),
        onChanged: (selected) => onChanged(selected ?? ''),
      ),
    );
  }
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

class _IdLabelOption {
  const _IdLabelOption({required this.id, required this.label});

  final String id;
  final String label;
}

class _PresenceMetrics {
  const _PresenceMetrics({
    required this.total,
    required this.presentCount,
    required this.absentsCount,
    required this.retardsCount,
    required this.teletravailCount,
    required this.overtimeHours,
    required this.absencesNonJustifiees,
    required this.totalWorkedHours,
    required this.totalWorkDays,
  });

  const _PresenceMetrics.empty()
      : total = 0,
        presentCount = 0,
        absentsCount = 0,
        retardsCount = 0,
        teletravailCount = 0,
        overtimeHours = 0,
        absencesNonJustifiees = 0,
        totalWorkedHours = 0,
        totalWorkDays = 0;

  final int total;
  final int presentCount;
  final int absentsCount;
  final int retardsCount;
  final int teletravailCount;
  final double overtimeHours;
  final int absencesNonJustifiees;
  final double totalWorkedHours;
  final int totalWorkDays;
}

class _AnomalyItemData {
  const _AnomalyItemData({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

class _MetricsResult {
  const _MetricsResult({
    required this.metrics,
    required this.anomalies,
    required this.calendarStatuses,
    required this.weeklyPresence,
  });

  final _PresenceMetrics metrics;
  final List<_AnomalyItemData> anomalies;
  final Map<int, String> calendarStatuses;
  final List<int> weeklyPresence;
}

_MetricsResult _computeMetrics(List<Presence> presences) {
  int present = 0;
  int absent = 0;
  int retard = 0;
  int teletravail = 0;
  int absencesNonJustifiees = 0;
  double overtimeHours = 0;
  double totalWorkedMinutes = 0;
  final workedDays = <String>{};

  final anomalies = <_AnomalyItemData>[];
  final calendarStatuses = <int, String>{};

  for (final presence in presences) {
    final status = presence.status;
    if (status == 'Present') {
      present += 1;
    } else if (status == 'Absent') {
      absent += 1;
      if (presence.justification.isEmpty) {
        absencesNonJustifiees += 1;
        anomalies.add(
          _AnomalyItemData(
            title: 'Absence non justifiee',
            subtitle: '${presence.employeName} - ${_formatDate(presence.date)}',
          ),
        );
      }
    } else if (status == 'Retard') {
      retard += 1;
      anomalies.add(
        _AnomalyItemData(
          title: 'Retard',
          subtitle: '${presence.employeName} - ${_formatDate(presence.date)}',
        ),
      );
    } else if (status == 'Teletravail') {
      teletravail += 1;
    }

    final day = presence.date.day;
    if (status.isNotEmpty && !calendarStatuses.containsKey(day)) {
      calendarStatuses[day] = status;
    }

    final minutes = _computeWorkedMinutes(presence.heureArrivee, presence.heureDepart);
    if (minutes != null && minutes > 8 * 60) {
      overtimeHours += (minutes - 480) / 60.0;
    }
    if (minutes != null) {
      totalWorkedMinutes += minutes;
    }
    if (status == 'Present' || status == 'Retard' || status == 'Teletravail' || status == 'Mission') {
      workedDays.add(_formatDate(presence.date));
    }
  }

  final weeklyPresence = _buildWeeklyPresence(presences);

  return _MetricsResult(
    metrics: _PresenceMetrics(
      total: presences.length,
      presentCount: present,
      absentsCount: absent,
      retardsCount: retard,
      teletravailCount: teletravail,
      overtimeHours: overtimeHours,
      absencesNonJustifiees: absencesNonJustifiees,
      totalWorkedHours: totalWorkedMinutes / 60.0,
      totalWorkDays: workedDays.length,
    ),
    anomalies: anomalies.take(6).toList(),
    calendarStatuses: calendarStatuses,
    weeklyPresence: weeklyPresence,
  );
}

List<int> _buildWeeklyPresence(List<Presence> presences) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
  final counts = List<int>.filled(7, 0);

  for (final presence in presences) {
    final date = DateTime(presence.date.year, presence.date.month, presence.date.day);
    final diff = date.difference(start).inDays;
    if (diff >= 0 && diff < 7 && presence.status == 'Present') {
      counts[diff] += 1;
    }
  }
  return counts;
}

int? _computeWorkedMinutes(String start, String end) {
  if (start.isEmpty || end.isEmpty) return null;
  final startParts = start.split(':');
  final endParts = end.split(':');
  if (startParts.length < 2 || endParts.length < 2) return null;
  final startHour = int.tryParse(startParts[0]);
  final startMin = int.tryParse(startParts[1]);
  final endHour = int.tryParse(endParts[0]);
  final endMin = int.tryParse(endParts[1]);
  if (startHour == null || startMin == null || endHour == null || endMin == null) return null;
  final startTotal = startHour * 60 + startMin;
  final endTotal = endHour * 60 + endMin;
  if (endTotal < startTotal) return null;
  return endTotal - startTotal;
}

String _formatDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _formatHourRange(String start, String end) {
  if (start.isEmpty && end.isEmpty) return '';
  if (start.isEmpty) return end;
  if (end.isEmpty) return start;
  return '$start - $end';
}

Color? _statusColor(String status) {
  switch (status) {
    case 'Present':
      return AppColors.success;
    case 'Absent':
      return AppColors.alert;
    case 'Retard':
      return Colors.orangeAccent;
    case 'Teletravail':
      return AppColors.primary;
    case 'Conge':
      return Colors.purpleAccent;
    case 'Mission':
      return Colors.teal;
  }
  return null;
}

String _monthLabel(int month) {
  const months = [
    'Janvier',
    'Fevrier',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Aout',
    'Septembre',
    'Octobre',
    'Novembre',
    'Decembre',
  ];
  if (month < 1 || month > 12) return '';
  return months[month - 1];
}

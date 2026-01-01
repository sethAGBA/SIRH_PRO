import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/dao/dao_registry.dart';
import '../../../core/security/auth_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/operation_notice.dart';
import '../../../core/widgets/section_header.dart';
import '../../../shared/models/conge_absence.dart';

class CongesAbsencesScreen extends StatefulWidget {
  const CongesAbsencesScreen({super.key});

  @override
  State<CongesAbsencesScreen> createState() => _CongesAbsencesScreenState();
}

class _CongesAbsencesScreenState extends State<CongesAbsencesScreen> {
  final List<CongeAbsence> _requests = [];
  final List<_IdLabelOption> _employeeOptions = [];
  final TextEditingController _startDateCtrl = TextEditingController();
  final TextEditingController _endDateCtrl = TextEditingController();

  bool _loading = false;
  int _page = 0;
  final int _pageSize = 10;
  int _totalRequests = 0;

  String _searchQuery = '';
  String _filterEmployeeId = '';
  String _filterStatus = 'Tous';
  String _filterType = 'Tous';

  List<_BalanceRow> _balanceRows = const [];
  Map<int, String> _calendarStatuses = const {};

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _loadBalances();
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
    await _loadRequests(resetPage: true);
    await _loadCalendar();
  }

  Future<void> _loadRequests({bool resetPage = false}) async {
    if (resetPage) _page = 0;
    setState(() => _loading = true);

    final start = _parseDate(_startDateCtrl.text.trim(), endOfDay: false);
    final end = _parseDate(_endDateCtrl.text.trim(), endOfDay: true);

    final rows = await DaoRegistry.instance.conges.search(
      query: _searchQuery,
      employeeId: _filterEmployeeId,
      status: _filterStatus == 'Tous' ? null : _filterStatus,
      type: _filterType == 'Tous' ? null : _filterType,
      startDate: start,
      endDate: end,
      limit: _pageSize,
      offset: _page * _pageSize,
      orderBy: 'date_debut DESC',
    );

    final total = await DaoRegistry.instance.conges.count(
      query: _searchQuery,
      employeeId: _filterEmployeeId,
      status: _filterStatus == 'Tous' ? null : _filterStatus,
      type: _filterType == 'Tous' ? null : _filterType,
      startDate: start,
      endDate: end,
    );

    if (!mounted) return;
    setState(() {
      _requests
        ..clear()
        ..addAll(rows.map(_congeFromRow).map(_normalizeEmployeeName));
      _totalRequests = total;
      _loading = false;
    });
  }

  Future<void> _loadCalendar() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);

    final rows = await DaoRegistry.instance.conges.search(
      startDate: start.millisecondsSinceEpoch,
      endDate: end.millisecondsSinceEpoch,
    );
    final items = rows.map(_congeFromRow).map(_normalizeEmployeeName).toList();

    final statusMap = <int, String>{};
    for (final item in items) {
      final day = item.startDate.day;
      if (!statusMap.containsKey(day)) {
        statusMap[day] = item.status;
      }
    }

    if (!mounted) return;
    setState(() => _calendarStatuses = statusMap);
  }

  Future<void> _loadBalances() async {
    final rows = await DaoRegistry.instance.employes.list(orderBy: 'nom_complet ASC');
    final balances = rows
        .map(
          (row) => _BalanceRow(
            name: (row['nom_complet'] as String?) ?? '',
            congesRestants: (row['conges_restants'] as String?) ?? '',
            rttRestants: (row['rtt_restants'] as String?) ?? '',
            absencesJustifiees: (row['absences_justifiees'] as String?) ?? '',
          ),
        )
        .where((row) => row.name.isNotEmpty)
        .toList();
    if (!mounted) return;
    setState(() => _balanceRows = balances);
  }

  CongeAbsence _congeFromRow(Map<String, dynamic> row) {
    final startMillis = row['date_debut'] as int?;
    final endMillis = row['date_fin'] as int?;
    final repriseMillis = row['date_reprise'] as int?;
    final nbJours = row['nb_jours'];
    return CongeAbsence(
      id: (row['id'] as String?) ?? '',
      employeId: (row['employe_id'] as String?) ?? '',
      employeName: (row['employe_nom'] as String?) ?? '',
      type: (row['type'] as String?) ?? '',
      startDate: startMillis == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(startMillis),
      endDate: endMillis == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(endMillis),
      status: (row['statut'] as String?) ?? '',
      motif: (row['motif'] as String?) ?? '',
      justificatif: (row['justificatif'] as String?) ?? '',
      nbJours: nbJours is num ? nbJours.toDouble() : 0,
      dateReprise: repriseMillis == null ? null : DateTime.fromMillisecondsSinceEpoch(repriseMillis),
      interim: (row['interim'] as String?) ?? '',
      contact: (row['contact'] as String?) ?? '',
      commentaire: (row['commentaire'] as String?) ?? '',
      decisionMotif: (row['decision_motif'] as String?) ?? '',
      history: _decodeHistory((row['historique'] as String?) ?? ''),
    );
  }

  Map<String, dynamic> _congeToRow(CongeAbsence conge, {required bool forInsert}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return {
      'id': conge.id,
      'employe_id': conge.employeId,
      'employe_nom': conge.employeName,
      'type': conge.type,
      'date_debut': conge.startDate.millisecondsSinceEpoch,
      'date_fin': conge.endDate.millisecondsSinceEpoch,
      'statut': conge.status,
      'motif': conge.motif,
      'justificatif': conge.justificatif,
      'nb_jours': conge.nbJours,
      'date_reprise': conge.dateReprise?.millisecondsSinceEpoch,
      'interim': conge.interim,
      'contact': conge.contact,
      'commentaire': conge.commentaire,
      'decision_motif': conge.decisionMotif,
      'historique': jsonEncode(conge.history.map((entry) => entry.toJson()).toList()),
      'updated_at': now,
      if (forInsert) 'created_at': now,
    };
  }

  CongeAbsence _normalizeEmployeeName(CongeAbsence conge) {
    if (conge.employeName.isNotEmpty || conge.employeId.isEmpty) return conge;
    final match = _employeeOptions.firstWhere(
      (opt) => opt.id == conge.employeId,
      orElse: () => const _IdLabelOption(id: '', label: ''),
    );
    if (match.label.isEmpty) return conge;
    return CongeAbsence(
      id: conge.id,
      employeId: conge.employeId,
      employeName: match.label,
      type: conge.type,
      startDate: conge.startDate,
      endDate: conge.endDate,
      status: conge.status,
      motif: conge.motif,
      justificatif: conge.justificatif,
      nbJours: conge.nbJours,
      dateReprise: conge.dateReprise,
      interim: conge.interim,
      contact: conge.contact,
      commentaire: conge.commentaire,
      decisionMotif: conge.decisionMotif,
      history: conge.history,
    );
  }

  Future<void> _openForm({CongeAbsence? conge}) async {
    final updated = await showDialog<CongeAbsence>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _CongeFormScreen(
          conge: conge,
          employeeOptions: _employeeOptions,
        ),
      ),
    );

    if (updated == null) return;
    final exists = _requests.any((item) => item.id == updated.id);
    if (exists) {
      await DaoRegistry.instance.conges.update(updated.id, _congeToRow(updated, forInsert: false));
      showOperationNotice(context, message: 'Demande mise a jour.', success: true);
    } else {
      await DaoRegistry.instance.conges.insert(_congeToRow(updated, forInsert: true));
      showOperationNotice(context, message: 'Demande enregistree.', success: true);
    }
    await _loadRequests(resetPage: true);
    await _loadCalendar();
    await _loadBalances();
  }

  void _openDetail(CongeAbsence conge) {
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _CongeDetailScreen(
          conge: conge,
          onEdit: () => _openForm(conge: conge),
        ),
      ),
    );
  }

  void _openHistory(CongeAbsence conge) {
    final entries = _buildHistoryEntries(conge);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Historique validations'),
        content: SizedBox(
          width: 420,
          child: entries.isEmpty
              ? const Text('Aucun historique disponible.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: entries.length,
                  itemBuilder: (context, index) => _HistoryTimelineItem(
                    entry: entries[index],
                    isLast: index == entries.length - 1,
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(CongeAbsence conge, String status, {String decisionMotif = ''}) async {
    final currentUser = await AuthService().getCurrentUserSummary();
    final validatorName = currentUser['name'] ?? 'Utilisateur';
    final updated = CongeAbsence(
      id: conge.id,
      employeId: conge.employeId,
      employeName: conge.employeName,
      type: conge.type,
      startDate: conge.startDate,
      endDate: conge.endDate,
      status: status,
      motif: conge.motif,
      justificatif: conge.justificatif,
      nbJours: conge.nbJours,
      dateReprise: conge.dateReprise,
      interim: conge.interim,
      contact: conge.contact,
      commentaire: conge.commentaire,
      decisionMotif: decisionMotif.isEmpty ? conge.decisionMotif : decisionMotif,
      history: _appendHistory(
        conge.history,
        status,
        decisionMotif: decisionMotif,
        validatorName: validatorName,
      ),
    );
    await DaoRegistry.instance.conges.update(updated.id, _congeToRow(updated, forInsert: false));
    await _loadRequests(resetPage: true);
    await _loadCalendar();
    await _loadBalances();
    showOperationNotice(context, message: status == 'Refusee' ? 'Demande refusee.' : 'Demande mise a jour.', success: status != 'Refusee');
  }

  Future<void> _confirmDelete(CongeAbsence conge) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la demande'),
        content: Text('Supprimer la demande de ${conge.employeName} ?'),
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
    await DaoRegistry.instance.conges.delete(conge.id);
    await _loadRequests(resetPage: true);
    await _loadCalendar();
    await _loadBalances();
    showOperationNotice(context, message: 'Demande supprimee.', success: true);
  }

  Future<void> _refuse(CongeAbsence conge) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refuser la demande'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Motif du refus'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (reason == null) return;
    await _updateStatus(conge, 'Refusee', decisionMotif: reason);
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Demandes'),
              Tab(text: 'Calendrier'),
              Tab(text: 'Soldes'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _RequestsTab(
                  loading: _loading,
                  requests: _requests,
                  totalRequests: _totalRequests,
                  page: _page,
                  pageSize: _pageSize,
                  employeeOptions: _employeeOptions,
                  filterEmployeeId: _filterEmployeeId,
                  filterStatus: _filterStatus,
                  filterType: _filterType,
                  startDateCtrl: _startDateCtrl,
                  endDateCtrl: _endDateCtrl,
                  onSearchChanged: (value) {
                    _searchQuery = value;
                    _loadRequests(resetPage: true);
                  },
                  onEmployeeChanged: (value) {
                    _filterEmployeeId = value;
                    _loadRequests(resetPage: true);
                  },
                  onStatusChanged: (value) {
                    _filterStatus = value;
                    _loadRequests(resetPage: true);
                  },
                  onTypeChanged: (value) {
                    _filterType = value;
                    _loadRequests(resetPage: true);
                  },
                  onDateApply: () => _loadRequests(resetPage: true),
                  onNewRequest: () => _openForm(),
                  onOpenDetail: _openDetail,
                  onHistory: _openHistory,
                  onValidateN1: (conge) => _updateStatus(conge, 'En attente RH'),
                  onValidateRh: (conge) => _updateStatus(conge, 'Validee'),
                  onRefuse: _refuse,
                  onDelete: _confirmDelete,
                  onPrevPage: () {
                    if (_page == 0) return;
                    setState(() => _page -= 1);
                    _loadRequests();
                  },
                  onNextPage: () {
                    final canNext = (_page + 1) * _pageSize < _totalRequests;
                    if (!canNext) return;
                    setState(() => _page += 1);
                    _loadRequests();
                  },
                ),
                _CalendarTab(statuses: _calendarStatuses),
                _BalancesTab(rows: _balanceRows),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestsTab extends StatelessWidget {
  const _RequestsTab({
    required this.loading,
    required this.requests,
    required this.totalRequests,
    required this.page,
    required this.pageSize,
    required this.employeeOptions,
    required this.filterEmployeeId,
    required this.filterStatus,
    required this.filterType,
    required this.startDateCtrl,
    required this.endDateCtrl,
    required this.onSearchChanged,
    required this.onEmployeeChanged,
    required this.onStatusChanged,
    required this.onTypeChanged,
    required this.onDateApply,
    required this.onNewRequest,
    required this.onOpenDetail,
    required this.onHistory,
    required this.onValidateN1,
    required this.onValidateRh,
    required this.onRefuse,
    required this.onDelete,
    required this.onPrevPage,
    required this.onNextPage,
  });

  final bool loading;
  final List<CongeAbsence> requests;
  final int totalRequests;
  final int page;
  final int pageSize;
  final List<_IdLabelOption> employeeOptions;
  final String filterEmployeeId;
  final String filterStatus;
  final String filterType;
  final TextEditingController startDateCtrl;
  final TextEditingController endDateCtrl;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onEmployeeChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onDateApply;
  final VoidCallback onNewRequest;
  final ValueChanged<CongeAbsence> onOpenDetail;
  final ValueChanged<CongeAbsence> onHistory;
  final ValueChanged<CongeAbsence> onValidateN1;
  final ValueChanged<CongeAbsence> onValidateRh;
  final ValueChanged<CongeAbsence> onRefuse;
  final ValueChanged<CongeAbsence> onDelete;
  final VoidCallback onPrevPage;
  final VoidCallback onNextPage;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Tableau des demandes',
            subtitle: 'Workflow validation N+1 -> RH -> confirmation.',
          ),
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
                      label: 'Type',
                      value: filterType,
                      items: const [
                        'Tous',
                        'CP',
                        'RTT',
                        'Maladie',
                        'Sans solde',
                        'Maternite',
                        'Paternite',
                        'Autorisation',
                        'Mission',
                      ],
                      onChanged: onTypeChanged,
                    ),
                    _FilterDropdown(
                      label: 'Statut',
                      value: filterStatus,
                      items: const [
                        'Tous',
                        'En attente N+1',
                        'En attente RH',
                        'Validee',
                        'Refusee',
                        'Annulee',
                      ],
                      onChanged: onStatusChanged,
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
                    ElevatedButton.icon(
                      onPressed: onNewRequest,
                      icon: const Icon(Icons.add),
                      label: const Text('Nouvelle demande'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTable(context),
                const SizedBox(height: 12),
                _PaginationBar(
                  page: page,
                  pageSize: pageSize,
                  total: totalRequests,
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

  Widget _buildTable(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (requests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Aucune demande. Utilisez "Nouvelle demande" pour commencer.',
            style: TextStyle(color: appTextMuted(context)),
          ),
        ),
      );
    }

    return DataTable(
      columns: const [
        DataColumn(label: Text('Employe')),
        DataColumn(label: Text('Type')),
        DataColumn(label: Text('Periode')),
        DataColumn(label: Text('Jours')),
        DataColumn(label: Text('Statut')),
        DataColumn(label: Text('Actions')),
      ],
      rows: requests
          .map(
            (request) => DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 160,
                    child: Text(
                      request.employeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(Text(request.type)),
                DataCell(Text('${_formatDate(request.startDate)} - ${_formatDate(request.endDate)}')),
                DataCell(Text(request.nbJours.toStringAsFixed(1))),
                DataCell(Text(request.status)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Voir details',
                        icon: const Icon(Icons.visibility_outlined),
                        onPressed: () => onOpenDetail(request),
                      ),
                      IconButton(
                        tooltip: 'Historique',
                        icon: const Icon(Icons.timeline_outlined),
                        onPressed: () => onHistory(request),
                      ),
                      IconButton(
                        tooltip: 'Valider N+1',
                        icon: const Icon(Icons.verified_outlined),
                        onPressed: request.status == 'En attente N+1' ? () => onValidateN1(request) : null,
                      ),
                      IconButton(
                        tooltip: 'Valider RH',
                        icon: const Icon(Icons.verified_user_outlined),
                        onPressed: request.status == 'En attente RH' ? () => onValidateRh(request) : null,
                      ),
                      IconButton(
                        tooltip: 'Refuser',
                        icon: const Icon(Icons.block_outlined),
                        onPressed: request.status == 'Refusee' ? null : () => onRefuse(request),
                      ),
                      IconButton(
                        tooltip: 'Supprimer',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onDelete(request),
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

class _CalendarTab extends StatelessWidget {
  const _CalendarTab({required this.statuses});

  final Map<int, String> statuses;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Calendrier des absences',
            subtitle: 'Vue mensuelle des conges et absences.',
          ),
          const SizedBox(height: 12),
          AppCard(
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
                        border: Border.all(color: statusColor ?? appBorderColor(context)),
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            color: statusColor ?? appTextPrimary(context),
                            fontWeight: statusColor == null ? FontWeight.w500 : FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalancesTab extends StatelessWidget {
  const _BalancesTab({required this.rows});

  final List<_BalanceRow> rows;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Soldes conges',
            subtitle: 'Compteurs conges et absences par employe.',
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows.isEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Aucun solde disponible.',
                            style: TextStyle(color: appTextMuted(context)),
                          ),
                        ),
                      ),
                    ]
                  : [
                      DataTable(
                        columns: const [
                          DataColumn(label: Text('Employe')),
                          DataColumn(label: Text('Conges restants')),
                          DataColumn(label: Text('RTT restants')),
                          DataColumn(label: Text('Absences justifiees')),
                        ],
                        rows: rows
                            .map(
                              (row) => DataRow(
                                cells: [
                                  DataCell(
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        row.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(row.congesRestants.isEmpty ? '0' : row.congesRestants)),
                                  DataCell(Text(row.rttRestants.isEmpty ? '0' : row.rttRestants)),
                                  DataCell(Text(row.absencesJustifiees.isEmpty ? '0' : row.absencesJustifiees)),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CongeFormScreen extends StatefulWidget {
  const _CongeFormScreen({
    required this.employeeOptions,
    this.conge,
  });

  final List<_IdLabelOption> employeeOptions;
  final CongeAbsence? conge;

  @override
  State<_CongeFormScreen> createState() => _CongeFormScreenState();
}

class _CongeFormScreenState extends State<_CongeFormScreen> {
  late final TextEditingController _employeeCtrl;
  late final TextEditingController _startCtrl;
  late final TextEditingController _endCtrl;
  late final TextEditingController _repriseCtrl;
  late final TextEditingController _motifCtrl;
  late final TextEditingController _justificatifCtrl;
  late final TextEditingController _interimCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _commentCtrl;

  String _selectedEmployeeId = '';
  String _type = 'CP';
  String _status = 'En attente N+1';
  String? _error;

  @override
  void initState() {
    super.initState();
    _employeeCtrl = TextEditingController(text: widget.conge?.employeName ?? '');
    _startCtrl = TextEditingController(text: widget.conge != null ? _formatDate(widget.conge!.startDate) : '');
    _endCtrl = TextEditingController(text: widget.conge != null ? _formatDate(widget.conge!.endDate) : '');
    _repriseCtrl = TextEditingController(
      text: widget.conge?.dateReprise != null ? _formatDate(widget.conge!.dateReprise!) : '',
    );
    _motifCtrl = TextEditingController(text: widget.conge?.motif ?? '');
    _justificatifCtrl = TextEditingController(text: widget.conge?.justificatif ?? '');
    _interimCtrl = TextEditingController(text: widget.conge?.interim ?? '');
    _contactCtrl = TextEditingController(text: widget.conge?.contact ?? '');
    _commentCtrl = TextEditingController(text: widget.conge?.commentaire ?? '');
    _selectedEmployeeId = widget.conge?.employeId ?? '';
    _type = widget.conge?.type ?? 'CP';
    _status = widget.conge?.status ?? 'En attente N+1';
  }

  @override
  void dispose() {
    _employeeCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _repriseCtrl.dispose();
    _motifCtrl.dispose();
    _justificatifCtrl.dispose();
    _interimCtrl.dispose();
    _contactCtrl.dispose();
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
    final start = DateTime.tryParse(_startCtrl.text.trim());
    final end = DateTime.tryParse(_endCtrl.text.trim());
    if (start == null || end == null) {
      _error = 'Periode invalide.';
      return false;
    }
    if (end.isBefore(start)) {
      _error = 'Date de fin avant la date de debut.';
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

  Future<void> _save() async {
    setState(() => _error = null);
    if (!_validate()) {
      setState(() {});
      return;
    }

    final currentUser = await AuthService().getCurrentUserSummary();
    final creatorName = currentUser['name'] ?? 'Utilisateur';
    final start = DateTime.parse(_startCtrl.text.trim());
    final end = DateTime.parse(_endCtrl.text.trim());
    final reprise = _repriseCtrl.text.trim().isEmpty ? null : DateTime.tryParse(_repriseCtrl.text.trim());
    final days = end.difference(start).inDays + 1;

    final id = widget.conge?.id ?? 'conge-${DateTime.now().millisecondsSinceEpoch}';
    final conge = CongeAbsence(
      id: id,
      employeId: _selectedEmployeeId,
      employeName: _resolveEmployeeName(_selectedEmployeeId),
      type: _type,
      startDate: start,
      endDate: end,
      status: _status,
      motif: _motifCtrl.text.trim(),
      justificatif: _justificatifCtrl.text.trim(),
      nbJours: days.toDouble(),
      dateReprise: reprise,
      interim: _interimCtrl.text.trim(),
      contact: _contactCtrl.text.trim(),
      commentaire: _commentCtrl.text.trim(),
      decisionMotif: widget.conge?.decisionMotif ?? '',
      history: _buildInitialHistory(widget.conge?.history, creatorName),
    );
    Navigator.of(context).pop(conge);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.conge != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier demande' : 'Nouvelle demande'),
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
                  _FormField(
                    controller: _repriseCtrl,
                    label: 'Date reprise',
                    readOnly: true,
                    onTap: () => _pickDate(_repriseCtrl),
                    suffixIcon: const Icon(Icons.date_range),
                  ),
                  _FormDropdown(
                    label: 'Type *',
                    value: _type,
                    items: const [
                      'CP',
                      'RTT',
                      'Maladie',
                      'Sans solde',
                      'Maternite',
                      'Paternite',
                      'Autorisation',
                      'Mission',
                    ],
                    onChanged: (value) => setState(() => _type = value),
                  ),
                  _FormDropdown(
                    label: 'Statut *',
                    value: _status,
                    items: const [
                      'En attente N+1',
                      'En attente RH',
                      'Validee',
                      'Refusee',
                      'Annulee',
                    ],
                    onChanged: (value) => setState(() => _status = value),
                  ),
                  _FormField(controller: _motifCtrl, label: 'Motif'),
                  _FormField(controller: _justificatifCtrl, label: 'Justificatif'),
                  _FormField(controller: _interimCtrl, label: 'Interim'),
                  _FormField(controller: _contactCtrl, label: 'Contact'),
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

class _CongeDetailScreen extends StatelessWidget {
  const _CongeDetailScreen({
    required this.conge,
    required this.onEdit,
  });

  final CongeAbsence conge;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail conge'),
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
              title: conge.employeName.isEmpty ? 'Conge' : conge.employeName,
              subtitle: '${_formatDate(conge.startDate)} - ${_formatDate(conge.endDate)}',
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'Employe', value: conge.employeName),
                  _InfoRow(label: 'Type', value: _display(conge.type)),
                  _InfoRow(label: 'Statut', value: _display(conge.status)),
                  _InfoRow(label: 'Periode', value: '${_formatDate(conge.startDate)} - ${_formatDate(conge.endDate)}'),
                  _InfoRow(label: 'Nombre de jours', value: conge.nbJours.toStringAsFixed(1)),
                  _InfoRow(label: 'Date reprise', value: conge.dateReprise == null ? 'A definir' : _formatDate(conge.dateReprise!)),
                  _InfoRow(label: 'Motif', value: _display(conge.motif)),
                  _InfoRow(label: 'Justificatif', value: _display(conge.justificatif)),
                  _InfoRow(label: 'Interim', value: _display(conge.interim)),
                  _InfoRow(label: 'Contact', value: _display(conge.contact)),
                  _InfoRow(label: 'Commentaire', value: _display(conge.commentaire)),
                  _InfoRow(label: 'Decision', value: _display(conge.decisionMotif)),
                ],
              ),
            ),
          ],
        ),
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

class _IdLabelOption {
  const _IdLabelOption({required this.id, required this.label});

  final String id;
  final String label;
}

class _BalanceRow {
  const _BalanceRow({
    required this.name,
    required this.congesRestants,
    required this.rttRestants,
    required this.absencesJustifiees,
  });

  final String name;
  final String congesRestants;
  final String rttRestants;
  final String absencesJustifiees;
}

class _HistoryTimelineItem extends StatelessWidget {
  const _HistoryTimelineItem({required this.entry, required this.isLast});

  final CongeHistoryEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 28,
                  color: AppColors.primary.withOpacity(0.3),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: appTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.subtitle,
                  style: TextStyle(color: appTextMuted(context)),
                ),
                if (entry.validator.isNotEmpty)
                  Text(
                    'Par ${entry.validator}',
                    style: TextStyle(color: appTextMuted(context), fontSize: 12),
                  ),
                const SizedBox(height: 2),
                Text(
                  _formatDateTime(entry.timestamp),
                  style: TextStyle(color: appTextMuted(context), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

List<CongeHistoryEntry> _buildHistoryEntries(CongeAbsence conge) {
  if (conge.history.isNotEmpty) {
    return conge.history;
  }
  final now = DateTime.now().millisecondsSinceEpoch;
  final entries = <CongeHistoryEntry>[
    CongeHistoryEntry(
      title: 'Demande creee',
      subtitle: 'Le ${_formatDate(conge.startDate)}',
      timestamp: now,
      validator: '',
    ),
  ];

  if (conge.status == 'En attente RH' || conge.status == 'Validee' || conge.status == 'Refusee') {
    entries.add(
      CongeHistoryEntry(
        title: 'Validee N+1',
        subtitle: 'En attente RH',
        timestamp: now,
        validator: '',
      ),
    );
  }

  if (conge.status == 'Validee') {
    entries.add(
      CongeHistoryEntry(
        title: 'Validee RH',
        subtitle: 'Decision finale',
        timestamp: now,
        validator: '',
      ),
    );
  }

  if (conge.status == 'Refusee') {
    final reason = conge.decisionMotif.isEmpty ? 'Motif non renseigne' : conge.decisionMotif;
    entries.add(
      CongeHistoryEntry(
        title: 'Refusee RH',
        subtitle: reason,
        timestamp: now,
        validator: '',
      ),
    );
  }

  if (conge.status == 'Annulee') {
    entries.add(
      CongeHistoryEntry(
        title: 'Annulee',
        subtitle: 'Demande annulee par le collaborateur',
        timestamp: now,
        validator: '',
      ),
    );
  }

  return entries;
}

String _display(String value) {
  return value.isEmpty ? 'A definir' : value;
}

List<CongeHistoryEntry> _decodeHistory(String raw) {
  if (raw.trim().isEmpty) return [];
  try {
    final list = jsonDecode(raw);
    if (list is! List) return [];
    return list
        .map(
          (item) => item is Map<String, dynamic>
              ? CongeHistoryEntry.fromJson(item)
              : CongeHistoryEntry.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  } catch (_) {
    return [];
  }
}

List<CongeHistoryEntry> _appendHistory(
  List<CongeHistoryEntry> existing,
  String status, {
  String decisionMotif = '',
  String validatorName = '',
}) {
  final entries = List<CongeHistoryEntry>.from(existing);
  final now = DateTime.now().millisecondsSinceEpoch;
  if (entries.isEmpty) {
    entries.add(
      CongeHistoryEntry(
        title: 'Demande creee',
        subtitle: 'Creation',
        timestamp: now,
        validator: validatorName,
      ),
    );
  }
  var title = 'Mise a jour';
  var subtitle = status;

  if (status == 'En attente RH') {
    title = 'Validee N+1';
    subtitle = 'En attente RH';
  } else if (status == 'Validee') {
    title = 'Validee RH';
    subtitle = 'Decision finale';
  } else if (status == 'Refusee') {
    title = 'Refusee RH';
    subtitle = decisionMotif.isEmpty ? 'Motif non renseigne' : decisionMotif;
  } else if (status == 'Annulee') {
    title = 'Annulee';
    subtitle = 'Demande annulee par le collaborateur';
  }

  entries.add(
    CongeHistoryEntry(
      title: title,
      subtitle: subtitle,
      timestamp: now,
      validator: validatorName,
    ),
  );
  return entries;
}

List<CongeHistoryEntry> _buildInitialHistory(List<CongeHistoryEntry>? existing, String creatorName) {
  if (existing != null && existing.isNotEmpty) return existing;
  return [
    CongeHistoryEntry(
      title: 'Demande creee',
      subtitle: 'Creation',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      validator: creatorName,
    ),
  ];
}

String _formatDateTime(int timestamp) {
  if (timestamp == 0) return 'Date inconnue';
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final datePart = _formatDate(date);
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$datePart $hour:$minute';
}

Color? _statusColor(String status) {
  switch (status) {
    case 'Validee':
      return AppColors.success;
    case 'Refusee':
      return AppColors.alert;
    case 'En attente N+1':
    case 'En attente RH':
      return Colors.orangeAccent;
    case 'Annulee':
      return Colors.grey;
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

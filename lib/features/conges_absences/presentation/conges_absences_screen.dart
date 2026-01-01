import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/operation_notice.dart';
import '../../../core/widgets/section_header.dart';

class CongesAbsencesScreen extends StatefulWidget {
  const CongesAbsencesScreen({super.key});

  @override
  State<CongesAbsencesScreen> createState() => _CongesAbsencesScreenState();
}

class _CongesAbsencesScreenState extends State<CongesAbsencesScreen> {
  final List<_LeaveRequest> _requests = [
    _LeaveRequest(
      id: 'req-1',
      employee: 'Amina Diallo',
      type: 'CP',
      period: '12-16 avr',
      status: 'En attente N+1',
      history: ['Demande creee'],
    ),
    _LeaveRequest(
      id: 'req-2',
      employee: 'Yann Leclerc',
      type: 'RTT',
      period: '03 mai',
      status: 'Validee',
      history: ['Demande creee', 'Validee N+1', 'Validee RH', 'Confirmee'],
    ),
    _LeaveRequest(
      id: 'req-3',
      employee: 'Samuel Mensah',
      type: 'Sans solde',
      period: '22-24 mai',
      status: 'Refusee',
      history: ['Demande creee', 'Refusee N+1: planning charge'],
    ),
  ];

  void _openNewRequest() {
    showDialog(
      context: context,
      builder: (_) => const _LeaveRequestDialog(),
    );
  }

  void _validateN1(_LeaveRequest request) {
    _updateRequest(
      request,
      status: 'En attente RH',
      historyEntry: 'Validee N+1',
    );
  }

  void _validateRh(_LeaveRequest request) {
    _updateRequest(
      request,
      status: 'Validee',
      historyEntry: 'Validee RH',
    );
  }

  void _refuseRequest(_LeaveRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refuser la demande'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Motif de refus'),
          onChanged: (value) => _pendingRefusalReason = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = _pendingRefusalReason.trim();
              _pendingRefusalReason = '';
              Navigator.of(context).pop();
              _updateRequest(
                request,
                status: 'Refusee',
                historyEntry: reason.isEmpty ? 'Refusee RH' : 'Refusee RH: $reason',
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showHistory(_LeaveRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Historique decisions'),
        content: SizedBox(
          width: 420,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: request.history.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (context, index) => Text(request.history[index]),
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

  String _pendingRefusalReason = '';

  void _updateRequest(_LeaveRequest request, {required String status, required String historyEntry}) {
    setState(() {
      final index = _requests.indexWhere((r) => r.id == request.id);
      if (index == -1) return;
      final updatedHistory = List<String>.from(_requests[index].history)..add(historyEntry);
      _requests[index] = _requests[index].copyWith(
        status: status,
        history: updatedHistory,
      );
    });
    final successMessage = status == 'Refusee' ? 'Demande refusee.' : 'Demande mise a jour.';
    showOperationNotice(context, message: successMessage, success: status != 'Refusee');
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
                  onNewRequest: _openNewRequest,
                  requests: _requests,
                  onValidateN1: _validateN1,
                  onValidateRh: _validateRh,
                  onRefuse: _refuseRequest,
                  onHistory: _showHistory,
                ),
                const _CalendarTab(),
                const _BalancesTab(),
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
    required this.onNewRequest,
    required this.requests,
    required this.onValidateN1,
    required this.onValidateRh,
    required this.onRefuse,
    required this.onHistory,
  });

  final VoidCallback onNewRequest;
  final List<_LeaveRequest> requests;
  final ValueChanged<_LeaveRequest> onValidateN1;
  final ValueChanged<_LeaveRequest> onValidateRh;
  final ValueChanged<_LeaveRequest> onRefuse;
  final ValueChanged<_LeaveRequest> onHistory;

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
                    _FilterDropdown(
                      label: 'Statut',
                      value: 'En attente',
                      items: const ['En attente', 'Validees', 'Refusees'],
                    ),
                    _FilterDropdown(
                      label: 'Type',
                      value: 'Tous',
                      items: const ['Tous', 'CP', 'RTT', 'Sans solde', 'Evt familial'],
                    ),
                    SizedBox(
                      width: 180,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Periode (YYYY-MM)',
                          prefixIcon: Icon(Icons.date_range),
                        ),
                      ),
                    ),
                    const Spacer(),
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
                DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.05)
                        : const Color(0xFFF8FAFC),
                  ),
                  columns: const [
                    DataColumn(label: Text('Employe')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Periode')),
                    DataColumn(label: Text('Workflow')),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: requests
                      .map(
                        (row) => DataRow(
                          cells: [
                            DataCell(Text(row.employee)),
                            DataCell(Text(row.type)),
                            DataCell(Text(row.period)),
                            DataCell(Text(row.workflowLabel)),
                            DataCell(_StatusBadge(status: row.status)),
                            DataCell(
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'n1') onValidateN1(row);
                                  if (value == 'rh') onValidateRh(row);
                                  if (value == 'refuse') onRefuse(row);
                                  if (value == 'history') onHistory(row);
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(value: 'n1', child: Text('Valider N+1')),
                                  PopupMenuItem(value: 'rh', child: Text('Valider RH')),
                                  PopupMenuItem(value: 'refuse', child: Text('Refuser')),
                                  PopupMenuItem(value: 'history', child: Text('Historique')),
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
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alertes',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: appTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                const _AlertItem(
                  title: 'Chevauchement detecte',
                  subtitle: '2 demandes sur la meme periode (Finance)',
                ),
                const _AlertItem(
                  title: 'Effectif minimum non respecte',
                  subtitle: 'Equipe Marketing - seuil 70%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarTab extends StatelessWidget {
  const _CalendarTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Calendrier des absences',
            subtitle: 'Vue globale des absences prevues.',
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Avril 2024',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: appTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 30,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 10,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final highlight = day == 12 || day == 13 || day == 14;
                    return Container(
                      decoration: BoxDecoration(
                        color: highlight ? AppColors.primary.withOpacity(0.15) : AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: appBorderColor(context)),
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: TextStyle(color: appTextPrimary(context)),
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
  const _BalancesTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Gestion des soldes',
            subtitle: 'Compteurs conges et absences par employe.',
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _InfoRow(label: 'CP acquis annee N', value: '24 jours'),
                _InfoRow(label: 'Report annee N-1', value: '5 jours'),
                _InfoRow(label: 'Pris a date', value: '8 jours'),
                _InfoRow(label: 'Poses en attente', value: '3 jours'),
                _InfoRow(label: 'Solde disponible', value: '18 jours'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _InfoRow(label: 'RTT droits annuels', value: '10 jours'),
                _InfoRow(label: 'RTT acquis', value: '6 jours'),
                _InfoRow(label: 'RTT consommes', value: '3 jours'),
                _InfoRow(label: 'RTT restants', value: '3 jours'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _InfoRow(label: 'Arrets ordinaires', value: '2 jours'),
                _InfoRow(label: 'Arrets longue duree', value: '0'),
                _InfoRow(label: 'Accidents travail', value: '1'),
                _InfoRow(label: 'Maladies pro', value: '0'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _InfoRow(label: 'Maternite/Paternite', value: '0'),
                _InfoRow(label: 'Evenements familiaux', value: '1'),
                _InfoRow(label: 'Formation pro', value: '0'),
                _InfoRow(label: 'Conge sabbatique', value: '0'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaveRequestDialog extends StatefulWidget {
  const _LeaveRequestDialog();

  @override
  State<_LeaveRequestDialog> createState() => _LeaveRequestDialogState();
}

class _LeaveRequestDialogState extends State<_LeaveRequestDialog> {
  String _type = 'CP';
  final TextEditingController _startCtrl = TextEditingController();
  final TextEditingController _endCtrl = TextEditingController();
  final TextEditingController _reasonCtrl = TextEditingController();
  final TextEditingController _justifCtrl = TextEditingController();
  String _solde = '18 jours';

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    _reasonCtrl.dispose();
    _justifCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Demande de conge'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _type,
              items: const [
                DropdownMenuItem(value: 'CP', child: Text('CP')),
                DropdownMenuItem(value: 'RTT', child: Text('RTT')),
                DropdownMenuItem(value: 'Sans solde', child: Text('Sans solde')),
                DropdownMenuItem(value: 'Evenement familial', child: Text('Evenement familial')),
              ],
              onChanged: (value) {
                setState(() {
                  _type = value ?? 'CP';
                  _solde = _type == 'RTT' ? '3 jours' : '18 jours';
                });
              },
              decoration: const InputDecoration(labelText: 'Type de conge'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _startCtrl,
              decoration: const InputDecoration(labelText: 'Date debut (YYYY-MM-DD)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _endCtrl,
              decoration: const InputDecoration(labelText: 'Date fin (YYYY-MM-DD)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonCtrl,
              decoration: const InputDecoration(labelText: 'Motif / commentaire'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _justifCtrl,
              decoration: const InputDecoration(labelText: 'Piece justificative (optionnel)'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Solde restant: $_solde'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Suggestion dates: selon planning equipe',
                style: TextStyle(color: appTextMuted(context)),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Regle anciennete: OK',
                style: TextStyle(color: appTextMuted(context)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_startCtrl.text.trim().isEmpty || _endCtrl.text.trim().isEmpty) {
              showOperationNotice(context, message: 'Champs obligatoires manquants.', success: false);
              return;
            }
            showOperationNotice(context, message: 'Demande envoyee.', success: true);
            Navigator.of(context).pop();
          },
          child: const Text('Soumettre'),
        ),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
  });

  final String label;
  final String value;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        isExpanded: true,
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: (_) {},
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  Color _color() {
    switch (status) {
      case 'Validee':
        return AppColors.success;
      case 'Refusee':
        return AppColors.danger;
      default:
        return AppColors.alert;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  const _AlertItem({required this.title, required this.subtitle});

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
        ],
      ),
    );
  }
}

class _LeaveRequest {
  const _LeaveRequest({
    required this.id,
    required this.employee,
    required this.type,
    required this.period,
    required this.status,
    required this.history,
  });

  final String id;
  final String employee;
  final String type;
  final String period;
  final String status;
  final List<String> history;

  String get workflowLabel {
    if (status == 'En attente N+1') return 'N+1 -> RH -> confirmation';
    if (status == 'En attente RH') return 'RH -> confirmation';
    if (status == 'Validee') return 'Confirmee';
    if (status == 'Refusee') return 'Refusee';
    return 'N+1 -> RH -> confirmation';
  }

  _LeaveRequest copyWith({
    String? status,
    List<String>? history,
  }) {
    return _LeaveRequest(
      id: id,
      employee: employee,
      type: type,
      period: period,
      status: status ?? this.status,
      history: history ?? this.history,
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

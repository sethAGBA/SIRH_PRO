import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';

class DisciplineSanctionsScreen extends StatefulWidget {
  const DisciplineSanctionsScreen({super.key});

  @override
  State<DisciplineSanctionsScreen> createState() => _DisciplineSanctionsScreenState();
}

class _DisciplineSanctionsScreenState extends State<DisciplineSanctionsScreen> {
  final List<_DisciplineCase> _cases = const [
    _DisciplineCase(
      employee: 'Awa Komla',
      employeeId: 'EMP-0021',
      role: 'Analyste RH',
      date: '2024-05-02 09:30',
      location: 'Bureau RH',
      incident: 'Retard repete',
      status: 'En cours',
      sanction: 'Avertissement',
      procedure: 'Convocation envoyee',
      decisionStatus: 'Brouillon',
    ),
    _DisciplineCase(
      employee: 'Noel Mensah',
      employeeId: 'EMP-0044',
      role: 'Dev Flutter',
      date: '2024-04-20 14:10',
      location: 'Open space',
      incident: 'Non-respect procedure',
      status: 'A cloturer',
      sanction: 'Mise a pied',
      procedure: 'Entretien termine',
      decisionStatus: 'Notifie',
    ),
  ];

  void _openCaseDetail(_DisciplineCase item) {
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(child: _DisciplineDetailDialog(caseItem: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Discipline & sanctions',
              subtitle: 'Registre disciplinaire et procedures legales.',
            ),
            const SizedBox(height: 16),
            AppCard(
              child: TabBar(
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: appTextMuted(context),
                tabs: const [
                  Tab(text: 'Registre'),
                  Tab(text: 'Tracabilite'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 740,
              child: TabBarView(
                children: [
                  _RegistreTab(cases: _cases, onOpen: _openCaseDetail),
                  const _TraceTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegistreTab extends StatelessWidget {
  const _RegistreTab({required this.cases, required this.onOpen});

  final List<_DisciplineCase> cases;
  final ValueChanged<_DisciplineCase> onOpen;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _MetricCard(title: 'Dossiers ouverts', value: '4', subtitle: 'En cours'),
              _MetricCard(title: 'Sanctions graves', value: '1', subtitle: 'Mois en cours'),
              _MetricCard(title: 'Mises a pied', value: '2', subtitle: 'Annee'),
              _MetricCard(title: 'Avertissements', value: '6', subtitle: 'Annee'),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Registre disciplinaire', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.05)
                        : const Color(0xFFF8FAFC),
                  ),
                  columns: const [
                    DataColumn(label: Text('Employe')),
                    DataColumn(label: Text('Incident')),
                    DataColumn(label: Text('Sanction')),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Decision')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: cases
                      .map(
                        (item) => DataRow(
                          cells: [
                            DataCell(Text(item.employee)),
                            DataCell(Text(item.incident)),
                            DataCell(Text(item.sanction)),
                            DataCell(_StatusChip(status: item.status)),
                            DataCell(_DecisionChip(status: item.decisionStatus)),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(onPressed: () => onOpen(item), icon: const Icon(Icons.visibility_outlined)),
                                  IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
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
        ],
      ),
    );
  }
}

class _TraceTab extends StatelessWidget {
  const _TraceTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tracabilite legale', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Delais legaux respectes', value: '100%'),
                const _InfoRow(label: 'Archivage securise', value: 'Actif'),
                const _InfoRow(label: 'Consultation IRP', value: 'Si necessaire'),
                const _InfoRow(label: 'Historique actions', value: 'Journal complet'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Historique actions correctives', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Avertissement', value: 'EMP-0021 - 2024-05-02'),
                const _InfoRow(label: 'Mise a pied', value: 'EMP-0044 - 2024-04-22'),
                const _InfoRow(label: 'Blame', value: 'EMP-0018 - 2024-03-15'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DisciplineDetailDialog extends StatelessWidget {
  const _DisciplineDetailDialog({required this.caseItem});

  final _DisciplineCase caseItem;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dossier disciplinaire - ${caseItem.employee}'),
          automaticallyImplyLeading: false,
          actions: [
            _DecisionActions(status: caseItem.decisionStatus),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Incident'),
              Tab(text: 'Employe'),
              Tab(text: 'Procedure'),
              Tab(text: 'Decision'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DetailSection(
              title: 'Description incident',
              items: [
                _InfoRow(label: 'Date et heure', value: caseItem.date),
                _InfoRow(label: 'Lieu', value: caseItem.location),
                _InfoRow(label: 'Nature des faits', value: caseItem.incident),
                _InfoRow(label: 'Temoins', value: '2 personnes'),
                _InfoRow(label: 'Pieces a l appui', value: 'Rapport, emails'),
                _InfoRow(
                  label: 'Statut dossier',
                  value: caseItem.status,
                  valueColor: _disciplineStatusColor(caseItem.status),
                ),
              ],
            ),
            _DetailSection(
              title: 'Employe concerne',
              items: [
                _InfoRow(label: 'Identite', value: '${caseItem.employee} (${caseItem.employeeId})'),
                _InfoRow(label: 'Poste', value: caseItem.role),
                _InfoRow(label: 'Anciennete', value: '3 ans'),
                _InfoRow(label: 'Antecedents', value: 'Aucun'),
                _InfoRow(label: 'Circonstances', value: 'Charge projet elevee'),
              ],
            ),
            _DetailSection(
              title: 'Procedure',
              items: [
                _InfoRow(label: 'Convocation entretien', value: 'Envoyee'),
                _InfoRow(label: 'Date entretien', value: '2024-05-05 10:00'),
                _InfoRow(label: 'Presence representant', value: 'Oui'),
                _InfoRow(label: 'Explications employe', value: 'Retards justifies'),
                _InfoRow(label: 'Delai reflexion', value: '48h'),
              ],
            ),
            _DetailSection(
              title: 'Decision',
              items: [
                _InfoRow(label: 'Type sanction', value: caseItem.sanction),
                _InfoRow(label: 'Motifs', value: caseItem.incident),
                _InfoRow(label: 'Notification ecrite', value: 'Preparee'),
                _InfoRow(label: 'Voies recours', value: 'IRP / Legal'),
                _InfoRow(label: 'Archivage legal', value: 'Planifie'),
                _InfoRow(label: 'Statut decision', value: caseItem.decisionStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.items});

  final String title;
  final List<_InfoRow> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
            const SizedBox(height: 12),
            ...items,
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
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: appTextMuted(context), fontSize: 12)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: appTextPrimary(context))),
            const SizedBox(height: 6),
            Text(subtitle, style: TextStyle(color: appTextMuted(context), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _disciplineStatusColor(status);
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

class _DecisionChip extends StatelessWidget {
  const _DecisionChip({required this.status});

  final String status;

  Color _statusColor() {
    switch (status) {
      case 'Brouillon':
        return AppColors.alert;
      case 'Valide':
        return AppColors.primary;
      case 'Notifie':
        return AppColors.success;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

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
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor ?? appTextPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _disciplineStatusColor(String status) {
  switch (status) {
    case 'En cours':
      return AppColors.alert;
    case 'A cloturer':
      return AppColors.primary;
    case 'Cloture':
      return AppColors.success;
    default:
      return AppColors.textMuted;
  }
}

class _DecisionActions extends StatelessWidget {
  const _DecisionActions({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'Brouillon':
        return Row(
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Valider'),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Demander infos'),
            ),
          ],
        );
      case 'Valide':
        return Row(
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.print, size: 18),
              label: const Text('Notifier'),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.archive_outlined, size: 18),
              label: const Text('Archiver'),
            ),
          ],
        );
      case 'Notifie':
        return Row(
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.archive_outlined, size: 18),
              label: const Text('Archiver'),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _DisciplineCase {
  const _DisciplineCase({
    required this.employee,
    required this.employeeId,
    required this.role,
    required this.date,
    required this.location,
    required this.incident,
    required this.status,
    required this.sanction,
    required this.procedure,
    required this.decisionStatus,
  });

  final String employee;
  final String employeeId;
  final String role;
  final String date;
  final String location;
  final String incident;
  final String status;
  final String sanction;
  final String procedure;
  final String decisionStatus;
}

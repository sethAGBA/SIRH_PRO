import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';

class SanteTravailScreen extends StatefulWidget {
  const SanteTravailScreen({super.key});

  @override
  State<SanteTravailScreen> createState() => _SanteTravailScreenState();
}

class _SanteTravailScreenState extends State<SanteTravailScreen> {
  final List<_AccidentCase> _cases = const [
    _AccidentCase(
      employee: 'Awa Komla',
      date: '2024-05-05',
      type: 'AT',
      status: 'Declare',
      resume: 'Chute escaliers',
      workStop: '3 jours',
    ),
    _AccidentCase(
      employee: 'Noel Mensah',
      date: '2024-04-22',
      type: 'MP',
      status: 'Suivi',
      resume: 'TMS poignet',
      workStop: '7 jours',
    ),
  ];

  final List<_MedicalVisit> _visits = const [
    _MedicalVisit(employee: 'Laura B.', type: 'Embauche', date: '2024-05-12', status: 'Planifiee'),
    _MedicalVisit(employee: 'Samuel Mensah', type: 'Periodique', date: '2024-05-18', status: 'A planifier'),
    _MedicalVisit(employee: 'Koffi S.', type: 'Reprise', date: '2024-05-20', status: 'Planifiee'),
  ];

  void _openAccidentDetail(_AccidentCase item) {
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(child: _AccidentDetailDialog(caseItem: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Accidents & medecine du travail',
              subtitle: 'AT/MP, suivi medical et prevention.',
            ),
            const SizedBox(height: 16),
            AppCard(
              child: TabBar(
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: appTextMuted(context),
                tabs: const [
                  Tab(text: 'Accidents'),
                  Tab(text: 'Suivi medical'),
                  Tab(text: 'Prevention'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 740,
              child: TabBarView(
                children: [
                  _AccidentsTab(cases: _cases, onOpen: _openAccidentDetail),
                  _MedicalTab(visits: _visits),
                  const _PreventionTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccidentsTab extends StatelessWidget {
  const _AccidentsTab({required this.cases, required this.onOpen});

  final List<_AccidentCase> cases;
  final ValueChanged<_AccidentCase> onOpen;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _MetricCard(title: 'AT/MP declares', value: '2', subtitle: 'Mois en cours'),
              _MetricCard(title: 'Reprises prevues', value: '1', subtitle: '7 jours'),
              _MetricCard(title: 'Jours perdus', value: '10', subtitle: 'Mois en cours'),
              _MetricCard(title: 'Analyse causes', value: '2', subtitle: 'En cours'),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Declarations AT/MP', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () => onOpen(_AccidentCase.empty()),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Nouvelle declaration'),
                  ),
                ),
                const SizedBox(height: 12),
                DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.05)
                        : const Color(0xFFF8FAFC),
                  ),
                  columns: const [
                    DataColumn(label: Text('Employe')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: cases
                      .map(
                        (item) => DataRow(
                          cells: [
                            DataCell(Text(item.employee)),
                            DataCell(Text(item.type)),
                            DataCell(Text(item.date)),
                            DataCell(_StatusChip(status: item.status)),
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
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Suivi arrets de travail', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Awa Komla', value: 'Arret 3 jours'),
                const _InfoRow(label: 'Noel Mensah', value: 'Arret 7 jours'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicalTab extends StatelessWidget {
  const _MedicalTab({required this.visits});

  final List<_MedicalVisit> visits;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _MetricCard(title: 'Visites embauche', value: '2', subtitle: 'Mois'),
              _MetricCard(title: 'Visites periodiques', value: '6', subtitle: 'A planifier'),
              _MetricCard(title: 'Visites reprise', value: '1', subtitle: 'Prevues'),
              _MetricCard(title: 'Rappels vaccins', value: '5', subtitle: 'Actifs'),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dossier sante', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Visites medicales', value: 'Embauche, periodique, reprise'),
                const _InfoRow(label: 'Vaccinations', value: 'Obligatoires + recommandees'),
                const _InfoRow(label: 'Aptitude au poste', value: 'Avis medecin, restrictions'),
                const _InfoRow(label: 'Statistiques sante', value: 'AT, MP, jours perdus'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Visites medicales', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                ...visits.map(
                  (visit) => _InfoRow(
                    label: '${visit.employee} • ${visit.type}',
                    value: '${visit.date} • ${visit.status}',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreventionTab extends StatelessWidget {
  const _PreventionTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Prevention des risques', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Document unique (DUER)', value: 'A jour'),
                const _InfoRow(label: 'Formation securite', value: 'Obligatoire'),
                const _InfoRow(label: 'EPI fournis', value: 'Renouveles trimestriel'),
                const _InfoRow(label: 'Visites poste', value: 'Planifiees'),
                const _InfoRow(label: 'Registres reglementaires', value: 'Conformes'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Statistiques sante', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Taux accidents', value: '1.2%'),
                const _InfoRow(label: 'Maladies professionnelles', value: '0.4%'),
                const _InfoRow(label: 'Journees perdues', value: '10'),
                const _InfoRow(label: 'Actions prevention', value: '3 en cours'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccidentDetailDialog extends StatelessWidget {
  const _AccidentDetailDialog({required this.caseItem});

  final _AccidentCase caseItem;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dossier AT/MP - ${caseItem.employee}'),
          automaticallyImplyLeading: false,
          actions: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Declarer CPAM'),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Cloturer'),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Declaration'),
              Tab(text: 'Suivi arret'),
              Tab(text: 'Analyse'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AccidentFormSection(caseItem: caseItem),
            _DetailSection(
              title: 'Suivi arret de travail',
              items: [
                _InfoRow(label: 'Duree arret', value: caseItem.workStop),
                _InfoRow(label: 'Reprise prevue', value: '2024-05-10'),
                _InfoRow(label: 'Visite reprise', value: 'Planifiee'),
                _InfoRow(label: 'Amenagements', value: 'Poste adapte'),
              ],
            ),
            const _DetailSection(
              title: 'Analyse causes & prevention',
              items: [
                _InfoRow(label: 'Cause principale', value: 'Sol glissant'),
                _InfoRow(label: 'Mesures correctives', value: 'Signalisation'),
                _InfoRow(label: 'EPI fournis', value: 'Chaussures'),
                _InfoRow(label: 'Actions prevention', value: 'Formation securite'),
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

class _AccidentFormSection extends StatefulWidget {
  const _AccidentFormSection({required this.caseItem});

  final _AccidentCase caseItem;

  @override
  State<_AccidentFormSection> createState() => _AccidentFormSectionState();
}

class _AccidentFormSectionState extends State<_AccidentFormSection> {
  late final TextEditingController _employeeController;
  late final TextEditingController _dateController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _piecesController;
  late String _type;
  late String _status;

  @override
  void initState() {
    super.initState();
    _employeeController = TextEditingController(text: widget.caseItem.employee);
    _dateController = TextEditingController(text: widget.caseItem.date);
    _locationController = TextEditingController(text: 'Site principal');
    _descriptionController = TextEditingController(text: widget.caseItem.resume);
    _piecesController = TextEditingController(text: 'Rapport, certificat');
    _type = widget.caseItem.type;
    _status = widget.caseItem.status;
  }

  @override
  void dispose() {
    _employeeController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _piecesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Declaration AT/MP', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _FormField(label: 'Employe', controller: _employeeController),
                _FormField(label: 'Date', controller: _dateController),
                _FormField(label: 'Lieu', controller: _locationController),
                _FormDropdown(
                  label: 'Type',
                  value: _type,
                  items: const ['AT', 'MP'],
                  onChanged: (value) => setState(() => _type = value),
                ),
                _FormDropdown(
                  label: 'Statut',
                  value: _status,
                  items: const ['Declare', 'Suivi', 'Cloture'],
                  onChanged: (value) => setState(() => _status = value),
                ),
                _FormField(label: 'Pieces jointes', controller: _piecesController),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description', hintText: 'Nature des faits'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(onPressed: () {}, child: const Text('Scanner justificatifs')),
                OutlinedButton(onPressed: () {}, child: const Text('Enregistrer')),
                OutlinedButton(onPressed: () {}, child: const Text('Declarer CPAM')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
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
        onChanged: (value) => onChanged(value ?? items.first),
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

  Color _statusColor() {
    switch (status) {
      case 'Declare':
        return AppColors.primary;
      case 'Suivi':
        return AppColors.alert;
      case 'Cloture':
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
          Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context)))),
        ],
      ),
    );
  }
}

class _AccidentCase {
  const _AccidentCase({
    required this.employee,
    required this.date,
    required this.type,
    required this.status,
    required this.resume,
    required this.workStop,
  });

  factory _AccidentCase.empty() {
    return const _AccidentCase(
      employee: '',
      date: '',
      type: 'AT',
      status: 'Declare',
      resume: '',
      workStop: '',
    );
  }

  final String employee;
  final String date;
  final String type;
  final String status;
  final String resume;
  final String workStop;
}

class _MedicalVisit {
  const _MedicalVisit({
    required this.employee,
    required this.type,
    required this.date,
    required this.status,
  });

  final String employee;
  final String type;
  final String date;
  final String status;
}

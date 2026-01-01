import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/operation_notice.dart';
import '../../../core/widgets/section_header.dart';

class ReportingScreen extends StatefulWidget {
  const ReportingScreen({super.key});

  @override
  State<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends State<ReportingScreen> {
  final List<_ReportTemplate> _templates = const [
    _ReportTemplate(title: 'Effectifs', format: 'PDF', schedule: 'Mensuel'),
    _ReportTemplate(title: 'Absenteisme', format: 'Excel', schedule: 'Hebdo'),
    _ReportTemplate(title: 'Paie', format: 'CSV', schedule: 'Mensuel'),
    _ReportTemplate(title: 'Formation', format: 'PDF', schedule: 'Trimestriel'),
  ];

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
              title: 'Reporting & statistiques RH',
              subtitle: 'Tableau de bord direction et rapports.',
            ),
            const SizedBox(height: 16),
            AppCard(
              child: TabBar(
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: appTextMuted(context),
                tabs: const [
                  Tab(text: 'Dashboard'),
                  Tab(text: 'Rapports reglementaires'),
                  Tab(text: 'Rapports personnalisables'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 780,
              child: TabBarView(
                children: [
                  const _DashboardTab(),
                  const _ReglementairesTab(),
                  _CustomReportsTab(templates: _templates),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _FilterDropdown(
                  label: 'Periode',
                  value: 'Jan - Dec 2024',
                  items: const ['Jan - Dec 2024', 'Jan - Jun 2024', 'Q1 2024', 'Q2 2024'],
                  onChanged: (_) {},
                ),
                _FilterDropdown(
                  label: 'Departement',
                  value: 'Tous',
                  items: const ['Tous', 'RH', 'Finance', 'IT', 'Operations'],
                  onChanged: (_) {},
                ),
                _FilterDropdown(
                  label: 'Site',
                  value: 'Lome',
                  items: const ['Lome', 'Kara', 'Atakpame'],
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _MetricCard(title: 'Effectif total', value: '247', subtitle: 'ETP'),
              _MetricCard(title: 'CDI / CDD / Stage', value: '180 / 52 / 15', subtitle: 'Repartition'),
              _MetricCard(title: 'Anciennete moyenne', value: '4.2 ans', subtitle: 'Moyenne'),
              _MetricCard(title: 'Ratio H/F', value: '56% / 44%', subtitle: 'H/F'),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _MetricCard(title: 'Taux absenteisme', value: '3.2%', subtitle: 'Mensuel'),
              _MetricCard(title: 'Turn-over', value: '8.5%', subtitle: 'Annuel'),
              _MetricCard(title: 'Mobilite interne', value: '12', subtitle: 'Mouvements'),
              _MetricCard(title: 'Accidents travail', value: '2', subtitle: 'Mois'),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _MetricCard(title: 'Heures formation', value: '18h', subtitle: 'Par employe'),
              _MetricCard(title: 'Budget formation', value: 'FCFA 6.2M', subtitle: 'Consomme'),
              _MetricCard(title: 'Acces formation', value: '72%', subtitle: 'Taux'),
              _MetricCard(title: 'Competences critiques', value: '5', subtitle: 'A couvrir'),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _MetricCard(title: 'Masse salariale', value: 'FCFA 1.9M', subtitle: 'Mensuel'),
              _MetricCard(title: 'Salaire moyen/median', value: '520k / 480k', subtitle: 'FCFA'),
              _MetricCard(title: 'Ecarts H/F', value: '4%', subtitle: 'Egalite'),
              _MetricCard(title: 'Primes distribuees', value: 'FCFA 120k', subtitle: 'Mensuel'),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tendances & previsions', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _TrendRow(label: 'Evolution effectifs 12 mois', value: '+6%'),
                const _TrendRow(label: 'Departes retraite', value: '3 d ici 12 mois'),
                const _TrendRow(label: 'Besoins recrutement', value: '8 postes'),
                const _TrendRow(label: 'Risques sociaux', value: 'Absenteisme IT'),
                const SizedBox(height: 12),
                const SizedBox(height: 220, child: _TrendChart()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReglementairesTab extends StatelessWidget {
  const _ReglementairesTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rapports reglementaires', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _ReportRow(title: 'Bilan social annuel', format: 'PDF'),
                const _ReportRow(title: 'Index egalite professionnelle', format: 'Excel'),
                const _ReportRow(title: 'Rapport formation professionnelle', format: 'PDF'),
                const _ReportRow(title: 'BDES', format: 'PDF'),
                const _ReportRow(title: 'Registres obligatoires', format: 'CSV'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Exports', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(onPressed: () {}, child: const Text('Exporter PDF')),
                    OutlinedButton(
                      onPressed: () => showOperationNotice(context, message: 'Export PDF lance.', success: true),
                      child: const Text('Exporter PDF'),
                    ),
                    OutlinedButton(
                      onPressed: () => showOperationNotice(context, message: 'Export Excel lance.', success: true),
                      child: const Text('Exporter Excel'),
                    ),
                    OutlinedButton(
                      onPressed: () => showOperationNotice(context, message: 'Export CSV lance.', success: true),
                      child: const Text('Exporter CSV'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomReportsTab extends StatelessWidget {
  const _CustomReportsTab({required this.templates});

  final List<_ReportTemplate> templates;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Generateur de rapports', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: const [
                    _FilterDropdown(
                      label: 'Periode',
                      value: 'Jan - Dec 2024',
                      items: ['Jan - Dec 2024', 'Jan - Jun 2024', 'Q1 2024', 'Q2 2024'],
                      onChanged: _noop,
                    ),
                    _FilterDropdown(
                      label: 'Departement',
                      value: 'Tous',
                      items: ['Tous', 'RH', 'Finance', 'IT', 'Operations'],
                      onChanged: _noop,
                    ),
                    _FilterDropdown(
                      label: 'Indicateurs',
                      value: 'Effectifs, Paie',
                      items: ['Effectifs, Paie', 'Absenteisme', 'Formation', 'Paie'],
                      onChanged: _noop,
                    ),
                    _FilterDropdown(
                      label: 'Format',
                      value: 'PDF',
                      items: ['PDF', 'Excel', 'CSV'],
                      onChanged: _noop,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => showOperationNotice(context, message: 'Previsualisation ouverte.', success: true),
                      child: const Text('Previsualiser'),
                    ),
                    OutlinedButton(
                      onPressed: () => showOperationNotice(context, message: 'Template enregistre.', success: true),
                      child: const Text('Enregistrer template'),
                    ),
                    OutlinedButton(
                      onPressed: () => showOperationNotice(context, message: 'Envoi planifie.', success: true),
                      child: const Text('Planifier envoi'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Templates', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                ...templates.map(
                  (template) => _TemplateRow(template: template),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _noop(String _) {}

class _TrendChart extends StatelessWidget {
  const _TrendChart();

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 200),
              FlSpot(1, 210),
              FlSpot(2, 215),
              FlSpot(3, 222),
              FlSpot(4, 230),
              FlSpot(5, 238),
              FlSpot(6, 242),
              FlSpot(7, 246),
              FlSpot(8, 247),
            ],
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
        ],
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

class _ReportRow extends StatelessWidget {
  const _ReportRow({required this.title, required this.format});

  final String title;
  final String format;

  @override
  Widget build(BuildContext context) {
    final muted = appTextMuted(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context)))),
          Text(format, style: TextStyle(color: muted)),
        ],
      ),
    );
  }
}

class _FilterBox extends StatelessWidget {
  const _FilterBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: TextField(
        decoration: InputDecoration(labelText: label, hintText: value),
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
      width: 220,
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

class _TemplateRow extends StatelessWidget {
  const _TemplateRow({required this.template});

  final _ReportTemplate template;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(template.title, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context)))),
          Text(template.schedule, style: TextStyle(color: appTextMuted(context))),
          const SizedBox(width: 12),
          Text(template.format, style: TextStyle(color: appTextMuted(context))),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => showOperationNotice(context, message: 'Rapport genere.', success: true),
            child: const Text('Executer'),
          ),
        ],
      ),
    );
  }
}

class _TrendRow extends StatelessWidget {
  const _TrendRow({required this.label, required this.value});

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

class _ReportTemplate {
  const _ReportTemplate({required this.title, required this.format, required this.schedule});

  final String title;
  final String format;
  final String schedule;
}

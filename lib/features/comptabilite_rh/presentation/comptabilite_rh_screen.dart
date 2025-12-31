import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';

class ComptabiliteRhScreen extends StatefulWidget {
  const ComptabiliteRhScreen({super.key});

  @override
  State<ComptabiliteRhScreen> createState() => _ComptabiliteRhScreenState();
}

class _ComptabiliteRhScreenState extends State<ComptabiliteRhScreen> {
  final List<_BudgetLine> _budgetLines = const [
    _BudgetLine(label: 'RH', budget: 1200000, actual: 980000),
    _BudgetLine(label: 'IT', budget: 900000, actual: 860000),
    _BudgetLine(label: 'Finance', budget: 700000, actual: 640000),
    _BudgetLine(label: 'Operations', budget: 1600000, actual: 1420000),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Comptabilite RH',
              subtitle: 'Masse salariale, provisions, ratios et DSN.',
            ),
            const SizedBox(height: 16),
            AppCard(
              child: TabBar(
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: appTextMuted(context),
                tabs: const [
                  Tab(text: 'Masse salariale'),
                  Tab(text: 'Provisions'),
                  Tab(text: 'Ratios'),
                  Tab(text: 'Declarations'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 740,
              child: TabBarView(
                children: [
                  _MasseSalarialeTab(lines: _budgetLines),
                  const _ProvisionsTab(),
                  const _RatiosTab(),
                  const _DeclarationsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MasseSalarialeTab extends StatelessWidget {
  const _MasseSalarialeTab({required this.lines});

  final List<_BudgetLine> lines;

  @override
  Widget build(BuildContext context) {
    final totalBudget = lines.fold<int>(0, (sum, item) => sum + item.budget);
    final totalActual = lines.fold<int>(0, (sum, item) => sum + item.actual);
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _MetricCard(title: 'Budget previsionnel', value: _fmtAmount(totalBudget), subtitle: 'Annuel'),
              _MetricCard(title: 'Realise YTD', value: _fmtAmount(totalActual), subtitle: 'Cumul'),
              _MetricCard(title: 'Ecart', value: _fmtAmount(totalBudget - totalActual), subtitle: 'Budget vs realise'),
              const _MetricCard(title: 'Cout total employeur', value: 'FCFA 1.9M', subtitle: 'Brut + charges'),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Repartition par departement', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                ...lines.map((line) => _BudgetRow(line: line)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: SizedBox(
              height: 240,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Budget vs realise', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                  const SizedBox(height: 12),
                  Expanded(child: _BudgetChart(lines: lines)),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      _LegendDot(color: AppColors.primary, label: 'Realise'),
                      SizedBox(width: 12),
                      _LegendDot(color: Color(0xFF7DD3FC), label: 'Budget'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Evolution mensuelle', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Janvier', value: 'FCFA 420k'),
                const _InfoRow(label: 'Fevrier', value: 'FCFA 460k'),
                const _InfoRow(label: 'Mars', value: 'FCFA 480k'),
                const _InfoRow(label: 'Avril', value: 'FCFA 520k'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Projections embauches/departs', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Embauches prevues', value: '6 (Q2)'),
                const _InfoRow(label: 'Departs retraite', value: '2 (Q3)'),
                const _InfoRow(label: 'Impact budget', value: '+FCFA 120k'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProvisionsTab extends StatelessWidget {
  const _ProvisionsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Charges de personnel', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Salaires bruts', value: 'FCFA 1.2M'),
                const _InfoRow(label: 'Charges sociales', value: 'FCFA 240k'),
                const _InfoRow(label: 'Primes et bonus', value: 'FCFA 80k'),
                const _InfoRow(label: 'Avantages sociaux', value: 'FCFA 60k'),
                const _InfoRow(label: 'Formations', value: 'FCFA 40k'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Provisions', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Conges payes non pris', value: 'FCFA 110k'),
                const _InfoRow(label: 'CET', value: 'FCFA 60k'),
                const _InfoRow(label: 'Primes variables', value: 'FCFA 40k'),
                const _InfoRow(label: 'Indemnites depart retraite', value: 'FCFA 90k'),
                const _InfoRow(label: 'Litiges prud homaux', value: 'FCFA 20k'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Budget vs realise', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'RH', value: 'Ecart +FCFA 120k'),
                const _InfoRow(label: 'IT', value: 'Ecart -FCFA 40k'),
                const _InfoRow(label: 'Finance', value: 'Ecart -FCFA 20k'),
                const _InfoRow(label: 'Operations', value: 'Ecart +FCFA 60k'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatiosTab extends StatelessWidget {
  const _RatiosTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ratios financiers', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Masse salariale / CA', value: '18%'),
                const _InfoRow(label: 'Cout moyen employe', value: 'FCFA 480k'),
                const _InfoRow(label: 'Productivite par tete', value: 'FCFA 3.2M'),
                const _InfoRow(label: 'ROI formations', value: '1.4x'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeclarationsTab extends StatelessWidget {
  const _DeclarationsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Declarations sociales', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'DSN mensuelle', value: 'Automatisee'),
                const _InfoRow(label: 'Declarations trimestrielles', value: 'Planifiees'),
                const _InfoRow(label: 'Declarations annuelles', value: 'DADS'),
                const _InfoRow(label: 'Taxe apprentissage', value: 'Echeance Juin'),
                const _InfoRow(label: 'Participation formation', value: 'Echeance Dec'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({required this.line});

  final _BudgetLine line;

  @override
  Widget build(BuildContext context) {
    final diff = line.budget - line.actual;
    final status = diff >= 0 ? 'Sous budget' : 'Depassement';
    final color = diff >= 0 ? AppColors.success : AppColors.alert;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(line.label, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
          const SizedBox(height: 6),
          Text('Budget ${_fmtAmount(line.budget)} • Realise ${_fmtAmount(line.actual)}',
              style: TextStyle(color: appTextMuted(context))),
          const SizedBox(height: 6),
          Text('$status ${_fmtAmount(diff.abs())}', style: TextStyle(color: color, fontSize: 12)),
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

class _BudgetChart extends StatelessWidget {
  const _BudgetChart({required this.lines});

  final List<_BudgetLine> lines;

  String _formatTooltipAmount(double value) {
    final amount = (value * 100000).round();
    return _fmtAmount(amount);
  }

  @override
  Widget build(BuildContext context) {
    final muted = appTextMuted(context);
    final tooltipBg = Theme.of(context).brightness == Brightness.dark ? AppColors.sidebarTop : Colors.white;
    final tooltipText = Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary;
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                return Text(
                  'FCFA ${(value / 10).toStringAsFixed(1)}M',
                  style: TextStyle(color: muted, fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= lines.length) {
                  return const SizedBox.shrink();
                }
                final label = lines[index].label;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(label, style: TextStyle(color: muted, fontSize: 10)),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => tooltipBg,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = lines[groupIndex].label;
              final series = rodIndex == 0 ? 'Budget' : 'Realise';
              return BarTooltipItem(
                '$label\n$series: ${_formatTooltipAmount(rod.toY)}',
                TextStyle(color: tooltipText, fontSize: 12),
              );
            },
          ),
        ),
        barGroups: [
          for (var i = 0; i < lines.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: lines[i].budget / 100000,
                  width: 14,
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.primary.withOpacity(0.6),
                ),
                BarChartRodData(
                  toY: lines[i].actual / 100000,
                  width: 14,
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.primary,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: appTextMuted(context), fontSize: 12)),
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
          Expanded(child: Text(label, style: TextStyle(color: appTextMuted(context)))),
          Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context)))),
        ],
      ),
    );
  }
}

class _BudgetLine {
  const _BudgetLine({required this.label, required this.budget, required this.actual});

  final String label;
  final int budget;
  final int actual;
}

String _fmtAmount(int value) {
  return 'FCFA ${value.toString().replaceAllMapped(RegExp(r'\\B(?=(\\d{3})+(?!\\d))'), (match) => ' ')}';
}

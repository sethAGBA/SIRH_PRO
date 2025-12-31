import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/time_calculator.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';

class PresencesScreen extends StatefulWidget {
  const PresencesScreen({super.key});

  @override
  State<PresencesScreen> createState() => _PresencesScreenState();
}

class _PresencesScreenState extends State<PresencesScreen> {
  void _openPointageManual() {
    showDialog(
      context: context,
      builder: (_) => const _PointageManualDialog(),
    );
  }

  void _openTeletravailDialog() {
    showDialog(
      context: context,
      builder: (_) => const _TeletravailDialog(),
    );
  }

  void _openAjustementDialog() {
    showDialog(
      context: context,
      builder: (_) => const _AjustementDialog(),
    );
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
                _DashboardTab(),
                _PointageTab(
                  onManual: _openPointageManual,
                  onTeletravail: _openTeletravailDialog,
                  onAjustement: _openAjustementDialog,
                ),
                const _HorairesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                const _DailyStatusRow(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Calendrier mensuel',
            subtitle: 'Visualisation par employe et par jour.',
          ),
          const SizedBox(height: 12),
          const _MonthlyCalendar(),
          const SizedBox(height: 24),
          const SectionHeader(
            title: 'Statistiques',
            subtitle: 'Taux de presence, retards, heures supplementaires.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _PresenceStat(title: 'Taux de presence', value: '96%'),
              _PresenceStat(title: 'Heures supplementaires', value: '42h'),
              _PresenceStat(title: 'Retards', value: '6'),
              _PresenceStat(title: 'Absences non justifiees', value: '3'),
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
                  const Expanded(child: _PresenceChart()),
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
                    child: ListView(
                      children: const [
                        _AnomalyItem(
                          title: 'Pointage manquant',
                          subtitle: 'EMP-0044 - Finance',
                        ),
                        _AnomalyItem(
                          title: 'Horaire incoherent',
                          subtitle: 'EMP-0078 - IT',
                        ),
                        _AnomalyItem(
                          title: 'Retard recurrent',
                          subtitle: 'EMP-0021 - Marketing',
                        ),
                      ],
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
    required this.onManual,
    required this.onTeletravail,
    required this.onAjustement,
  });

  final VoidCallback onManual;
  final VoidCallback onTeletravail;
  final VoidCallback onAjustement;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Pointage employe',
            subtitle: 'Badgeage, teletravail, ajustements horaires.',
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Systeme de badgeage',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: appTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan carte / QR code'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onManual,
                      icon: const Icon(Icons.edit_calendar),
                      label: const Text('Pointage manuel'),
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
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Export releves',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: appTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Export heures mensuel'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Exporter CSV'),
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

class _HorairesTab extends StatelessWidget {
  const _HorairesTab();

  @override
  Widget build(BuildContext context) {
    final breakdown = computeOvertimeBreakdown(
      totalHours: 46,
      contractHours: 39,
      overtime25Cap: 8,
      rttRate: 0,
    );

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
                _InfoRow(label: 'Type contrat', value: '39h - Forfait jour'),
                _InfoRow(label: 'Horaires standards', value: '08:00 - 17:00'),
                _InfoRow(label: 'Repos hebdomadaire', value: 'Samedi / Dimanche'),
                _InfoRow(label: 'Modulation temps', value: 'Active'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _InfoRow(label: 'Equipes', value: 'Matin / Apres-midi'),
                _InfoRow(label: 'Astreintes', value: '2 par mois'),
                _InfoRow(label: 'Teletravail autorise', value: '2 jours/semaine'),
                _InfoRow(label: 'Planning variable', value: 'Active'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _InfoRow(label: 'Heures travaillees', value: '142h'),
                _InfoRow(label: 'Heures supplementaires', value: '12h'),
                _InfoRow(label: 'Recuperations acquises', value: '5h'),
                _InfoRow(label: 'RTT disponibles', value: '3'),
                _InfoRow(label: 'Compte epargne temps', value: '8h'),
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
              children: const [
                _InfoRow(label: 'Taux presence mensuel', value: '95%'),
                _InfoRow(label: 'Retards cumules', value: '3'),
                _InfoRow(label: 'Absences non justifiees', value: '1'),
                _InfoRow(label: 'Regularite horaires', value: 'Stable'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyStatusRow extends StatelessWidget {
  const _DailyStatusRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: const [
        _StatusChip(label: 'Presents', value: '232'),
        _StatusChip(label: 'Absents', value: '15'),
        _StatusChip(label: 'Retards', value: '6'),
        _StatusChip(label: 'Teletravail', value: '22'),
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
  const _MonthlyCalendar();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mars 2024',
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
              return Container(
                decoration: BoxDecoration(
                  color: day % 6 == 0 ? AppColors.alert.withOpacity(0.15) : AppColors.card,
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
  const _PresenceChart();

  @override
  Widget build(BuildContext context) {
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
            spots: const [
              FlSpot(0, 210),
              FlSpot(1, 218),
              FlSpot(2, 225),
              FlSpot(3, 232),
              FlSpot(4, 228),
              FlSpot(5, 236),
              FlSpot(6, 232),
            ],
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

class _PointageManualDialog extends StatelessWidget {
  const _PointageManualDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pointage manuel'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          TextField(decoration: InputDecoration(labelText: 'Employe')),
          SizedBox(height: 8),
          TextField(decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)')),
          SizedBox(height: 8),
          TextField(decoration: InputDecoration(labelText: 'Heure')),
          SizedBox(height: 8),
          TextField(decoration: InputDecoration(labelText: 'Justification')),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class _TeletravailDialog extends StatelessWidget {
  const _TeletravailDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Declaration teletravail'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          TextField(decoration: InputDecoration(labelText: 'Employe')),
          SizedBox(height: 8),
          TextField(decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)')),
          SizedBox(height: 8),
          TextField(decoration: InputDecoration(labelText: 'Motif')),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class _AjustementDialog extends StatelessWidget {
  const _AjustementDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajustement horaire'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          TextField(decoration: InputDecoration(labelText: 'Employe')),
          SizedBox(height: 8),
          TextField(decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)')),
          SizedBox(height: 8),
          TextField(decoration: InputDecoration(labelText: 'Nouvel horaire')),
          SizedBox(height: 8),
          TextField(decoration: InputDecoration(labelText: 'Justification')),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

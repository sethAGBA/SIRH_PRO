import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const DashboardScreen({super.key, required this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Chiffres cles du jour'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: const [
                _KpiCard(
                  title: 'Patients hospitalises',
                  value: '142',
                  subtitle: '+6 vs hier',
                  icon: Icons.people_alt_rounded,
                  color: Color(0xFF3B82F6),
                ),
                _KpiCard(
                  title: 'Consultations',
                  value: '87',
                  subtitle: '25 en attente',
                  icon: Icons.event_available_rounded,
                  color: Color(0xFF10B981),
                ),
                _KpiCard(
                  title: 'Urgences',
                  value: '12',
                  subtitle: '3 critiques',
                  icon: Icons.warning_amber_rounded,
                  color: Color(0xFFEF4444),
                ),
                _KpiCard(
                  title: 'Disponibilite lits',
                  value: '23/180',
                  subtitle: 'Occupation 78%',
                  icon: Icons.bed_rounded,
                  color: Color(0xFF8B5CF6),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _buildSectionTitle('Graphiques & activite'),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _ChartCard(
                      title: 'Admissions sur 30 jours',
                      subtitle: 'Tendance stable',
                      width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                    ),
                    _ChartCard(
                      title: 'Occupation par service',
                      subtitle: 'Medecine interne en tension',
                      width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
            _buildSectionTitle('Alertes & performance'),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _InfoCard(
                      title: 'Alertes critiques',
                      width: isWide ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
                      child: const _AlertList(),
                    ),
                    _InfoCard(
                      title: 'Indicateurs de performance',
                      width: isWide ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
                      child: const _PerformanceList(),
                    ),
                    _InfoCard(
                      title: 'Agenda du jour',
                      width: isWide ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
                      child: const _AgendaList(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Aujourd\'hui',
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7)),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double width;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6))),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: _ChartPlaceholder(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MetricChip(label: 'Moyenne 32/j', color: const Color(0xFF0EA5A4)),
              _MetricChip(label: 'Pic 48', color: const Color(0xFF3B82F6)),
              _MetricChip(label: 'Min 18', color: const Color(0xFF22C55E)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bars = [24, 40, 32, 46, 28, 36, 50, 38, 44, 30, 42, 36];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: bars
          .map(
            (value) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: value.toDouble() + 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5A4), Color(0xFF14B8A6)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MetricChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final double width;
  final Widget child;

  const _InfoCard({required this.title, required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _AlertList extends StatelessWidget {
  const _AlertList();

  @override
  Widget build(BuildContext context) {
    final alerts = [
      '3 patients en etat critique',
      'Stock antibiotiques faible',
      'IRM en maintenance (salle 2)',
      'Infirmiers manquants: service urgence',
    ];
    return Column(
      children: alerts
          .map(
            (alert) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(alert, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12)),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PerformanceList extends StatelessWidget {
  const _PerformanceList();

  @override
  Widget build(BuildContext context) {
    final items = [
      _PerformanceItem(label: 'Temps attente moyen', value: '28 min', color: Color(0xFF0EA5A4)),
      _PerformanceItem(label: 'Satisfaction patients', value: '87%', color: Color(0xFF22C55E)),
      _PerformanceItem(label: 'Ratio personnel/patients', value: '1/8', color: Color(0xFF3B82F6)),
      _PerformanceItem(label: 'Taux occupation', value: '78%', color: Color(0xFFF59E0B)),
    ];
    return Column(children: items);
  }
}

class _PerformanceItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PerformanceItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}

class _AgendaList extends StatelessWidget {
  const _AgendaList();

  @override
  Widget build(BuildContext context) {
    final items = [
      _AgendaItem(time: '09:00', title: 'Appendicectomie', location: 'Salle 2'),
      _AgendaItem(time: '11:30', title: 'Tournee Medecine interne', location: 'Etage 2'),
      _AgendaItem(time: '14:30', title: 'Cesarrienne', location: 'Salle 1'),
      _AgendaItem(time: '16:00', title: 'Reunion staff', location: 'Salle de conference'),
    ];
    return Column(children: items);
  }
}

class _AgendaItem extends StatelessWidget {
  final String time;
  final String title;
  final String location;

  const _AgendaItem({required this.time, required this.title, required this.location});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(time, style: const TextStyle(color: Color(0xFF0EA5A4), fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(location, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

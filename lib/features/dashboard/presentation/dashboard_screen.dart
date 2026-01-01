import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/security/auth_service.dart';
import '../../auth/presentation/login_screen.dart';
import '../../conges_absences/presentation/conges_absences_screen.dart';
import '../../comptabilite_rh/presentation/comptabilite_rh_screen.dart';
import '../../departements/presentation/departements_screen.dart';
import '../../employes/presentation/employes_screen.dart';
import '../../evaluations/presentation/evaluations_screen.dart';
import '../../formations/presentation/formations_screen.dart';
import '../../notes_frais/presentation/notes_frais_screen.dart';
import '../../paie_remuneration/presentation/paie_remuneration_screen.dart';
import '../../presences/presentation/presences_screen.dart';
import '../../parametres/presentation/parametres_screen.dart';
import '../../postes/presentation/postes_screen.dart';
import '../../recrutements/presentation/recrutements_screen.dart';
import '../../reporting/presentation/reporting_screen.dart';
import '../../sante_travail/presentation/sante_travail_screen.dart';
import '../../discipline_sanctions/presentation/discipline_sanctions_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String? _userName;
  String? _userEmail;

  late final List<AppSidebarItem> _items = [
    const AppSidebarItem(label: 'Tableau de bord', icon: Icons.dashboard),
    const AppSidebarItem(label: 'Employes', icon: Icons.people),
    const AppSidebarItem(label: 'Departements', icon: Icons.apartment),
    const AppSidebarItem(label: 'Postes', icon: Icons.badge_outlined),
    const AppSidebarItem(label: 'Presences', icon: Icons.schedule),
    const AppSidebarItem(label: 'Conges & absences', icon: Icons.beach_access),
    const AppSidebarItem(label: 'Recrutements', icon: Icons.work_outline),
    const AppSidebarItem(label: 'Formations', icon: Icons.school),
    const AppSidebarItem(label: 'Evaluations', icon: Icons.fact_check_outlined),
    const AppSidebarItem(label: 'Paie & remuneration', icon: Icons.payments),
    const AppSidebarItem(label: 'Notes de frais', icon: Icons.receipt_long),
    const AppSidebarItem(label: 'Discipline & sanctions', icon: Icons.gavel),
    const AppSidebarItem(label: 'Sante travail', icon: Icons.health_and_safety),
    const AppSidebarItem(label: 'Comptabilite RH', icon: Icons.account_balance),
    const AppSidebarItem(label: 'Reporting RH', icon: Icons.insights),
    const AppSidebarItem(label: 'Parametres', icon: Icons.settings),
  ];

  late final List<Widget> _screens = const [
    _DashboardHome(),
    EmployesScreen(),
    DepartementsScreen(),
    PostesScreen(),
    PresencesScreen(),
    CongesAbsencesScreen(),
    RecrutementsScreen(),
    FormationsScreen(),
    EvaluationsScreen(),
    PaieRemunerationScreen(),
    NotesFraisScreen(),
    DisciplineSanctionsScreen(),
    SanteTravailScreen(),
    ComptabiliteRhScreen(),
    ReportingScreen(),
    ParametresScreen(),
  ];

  void _onSelect(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserSummary();
  }

  Future<void> _loadUserSummary() async {
    final summary = await AuthService().getCurrentUserSummary();
    if (!mounted) return;
    setState(() {
      _userName = summary['name'];
      _userEmail = summary['email'];
    });
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Deconnexion'),
              content: const Text('Voulez-vous vraiment vous deconnecter ?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                  child: const Text('Confirmer'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirm) return;

    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _items[_selectedIndex].label;

    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            items: _items,
            selectedIndex: _selectedIndex,
            onSelect: _onSelect,
            onLogout: _handleLogout,
            userName: _userName,
            userEmail: _userEmail,
          ),
          Expanded(
            child: Column(
              children: [
                _TopBar(title: title),
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: _screens[_selectedIndex],
                  ),
                ),
                const _BottomStatusBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.sidebarBottom,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher employe, departement, poste...',
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.black.withOpacity(0.25),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          _StatPill(
            icon: Icons.groups,
            label: 'Effectif present: 232',
          ),
          const SizedBox(width: 12),
          _NotificationButton(
            hasNotifications: true,
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Indicateurs clefs',
            subtitle: 'Etat du jour et tendances recentes.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _KpiCard(
                title: 'Effectif present',
                value: '232',
                delta: '+4 vs hier',
                icon: Icons.groups,
              ),
              _KpiCard(
                title: 'Absents',
                value: '15',
                delta: '-2 vs hier',
                icon: Icons.event_busy,
              ),
              _KpiCard(
                title: 'En formation',
                value: '8',
                delta: '+1 cette semaine',
                icon: Icons.school,
              ),
              _KpiCard(
                title: 'Teletravail',
                value: '22',
                delta: 'Stable',
                icon: Icons.home_work,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            title: 'Analytique RH',
            subtitle: 'Suivi des tendances et alertes critiques.',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 980;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: isWide ? 2 : 0,
                    child: Column(
                      children: const [
                        _MiniChartCard(
                          title: 'Evolution des effectifs (12 mois)',
                          metric: '+6.2%',
                        ),
                        SizedBox(height: 16),
                        _MiniChartCard(
                          title: 'Taux d absenteisme',
                          metric: '3.4%',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),
                  Expanded(
                    flex: isWide ? 1 : 0,
                    child: const _AlertList(),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            title: 'Agenda RH',
            subtitle: 'Entretiens, recrutements et formations planifies.',
          ),
          const SizedBox(height: 16),
          const _AgendaList(),
        ],
      ),
    );
  }
}

class _BottomStatusBar extends StatelessWidget {
  const _BottomStatusBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.sidebarTop,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTight = constraints.maxWidth < 720;
          if (isTight) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.circle, color: AppColors.success, size: 10),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Synchronisation OK - Derniere mise a jour: 2 min',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.notifications_active_outlined, color: Colors.white.withOpacity(0.8), size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '3 alertes RH en attente',
                        style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.circle, color: AppColors.success, size: 10),
                  const SizedBox(width: 8),
                  Text(
                    'Synchronisation OK - Derniere mise a jour: 2 min',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.notifications_active_outlined, color: Colors.white.withOpacity(0.8), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '3 alertes RH en attente',
                    style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.delta,
    required this.icon,
  });

  final String title;
  final String value;
  final String delta;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 220,
        child: _KpiCardBody(
          title: title,
          value: value,
          delta: delta,
          icon: icon,
        ),
      ),
    );
  }
}

class _KpiCardBody extends StatelessWidget {
  const _KpiCardBody({
    required this.title,
    required this.value,
    required this.delta,
    required this.icon,
  });

  final String title;
  final String value;
  final String delta;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final primaryText = appTextPrimary(context);
    final mutedText = appTextMuted(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryDark, size: 18),
            ),
            const Spacer(),
            const Icon(Icons.more_horiz, color: Color(0xFF94A3B8)),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: mutedText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          delta,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MiniChartCard extends StatelessWidget {
  const _MiniChartCard({required this.title, required this.metric});

  final String title;
  final String metric;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _MiniChartBody(title: title, metric: metric),
      ),
    );
  }
}

class _MiniChartBody extends StatelessWidget {
  const _MiniChartBody({required this.title, required this.metric});

  final String title;
  final String metric;

  @override
  Widget build(BuildContext context) {
    final primaryText = appTextPrimary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 140, child: _LineChart()),
        const SizedBox(height: 12),
        Text(
          metric,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart();

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
                colors: [Color(0x5522D3EE), Color(0x0019A7E0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            spots: const [
              FlSpot(0, 3),
              FlSpot(1, 3.4),
              FlSpot(2, 4.2),
              FlSpot(3, 3.8),
              FlSpot(4, 4.7),
              FlSpot(5, 5.2),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertList extends StatelessWidget {
  const _AlertList();

  @override
  Widget build(BuildContext context) {
    final primaryText = appTextPrimary(context);

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alertes critiques',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 12),
            const _AlertItem(
              title: 'Fin periode d essai',
              subtitle: '3 contrats a confirmer cette semaine',
            ),
            const _AlertItem(
              title: 'Documents expirants',
              subtitle: '5 attestations a renouveler',
            ),
            const _AlertItem(
              title: 'Formations obligatoires',
              subtitle: '2 equipes en retard',
            ),
          ],
        ),
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
    final primaryText = appTextPrimary(context);
    final mutedText = appTextMuted(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
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
                    color: primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: mutedText,
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

class _AgendaList extends StatelessWidget {
  const _AgendaList();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            _AgendaItem(
              title: 'Entretien annuel - Marketing',
              time: '10:30',
              detail: 'Salle B - 6 participants',
            ),
            _AgendaItem(
              title: 'Session onboarding',
              time: '14:00',
              detail: 'Nouveaux arrivants - 4 employes',
            ),
            _AgendaItem(
              title: 'Recrutement - Analyste RH',
              time: '16:00',
              detail: 'Entretien final - Direction',
            ),
          ],
        ),
      ),
    );
  }
}

class _AgendaItem extends StatelessWidget {
  const _AgendaItem({
    required this.title,
    required this.time,
    required this.detail,
  });

  final String title;
  final String time;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final primaryText = appTextPrimary(context);
    final mutedText = appTextMuted(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                time,
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 12,
                    color: mutedText,
                  ),
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

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.hasNotifications});

  final bool hasNotifications;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
          ),
          if (hasNotifications)
            const Positioned(
              top: 8,
              right: 8,
              child: SizedBox(
                width: 8,
                height: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

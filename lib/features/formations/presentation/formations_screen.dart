import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';

class FormationsScreen extends StatefulWidget {
  const FormationsScreen({super.key});

  @override
  State<FormationsScreen> createState() => _FormationsScreenState();
}

class _FormationsScreenState extends State<FormationsScreen> {
  final List<_TrainingSession> _sessions = const [
    _TrainingSession(
      title: 'Leadership',
      category: 'Developpement personnel',
      date: '2024-04-12',
      location: 'Salle 3',
      attendees: 18,
      status: 'Inscription ouverte',
    ),
    _TrainingSession(
      title: 'Securite IT',
      category: 'Obligatoire',
      date: '2024-04-20',
      location: 'Visio',
      attendees: 24,
      status: 'Convocations envoyees',
    ),
    _TrainingSession(
      title: 'Excel avance',
      category: 'Metier',
      date: '2024-05-02',
      location: 'Salle 2',
      attendees: 14,
      status: 'Emargement ouvert',
    ),
  ];

  final List<_Interview> _interviews = const [
    _Interview(
      employee: 'Awa Komla',
      role: 'Analyste RH',
      date: '2024-04-18',
      manager: 'S. Mensah',
      status: 'A planifier',
    ),
    _Interview(
      employee: 'Noel Mensah',
      role: 'Dev Flutter',
      date: '2024-04-22',
      manager: 'K. Amouzou',
      status: 'Confirme',
    ),
    _Interview(
      employee: 'Laura B.',
      role: 'Comptable',
      date: '2024-05-03',
      manager: 'D. Sena',
      status: 'En cours',
    ),
  ];

  void _openSessionDetail(_TrainingSession session) {
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(child: _SessionDetailDialog(session: session)),
    );
  }

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
              title: 'Formations & developpement',
              subtitle: 'Plan annuel, catalogue, sessions et entretiens.',
            ),
            const SizedBox(height: 16),
            AppCard(
              child: TabBar(
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: appTextMuted(context),
                tabs: const [
                  Tab(text: 'Plan annuel'),
                  Tab(text: 'Catalogue'),
                  Tab(text: 'Sessions'),
                  Tab(text: 'Entretiens'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 720,
              child: TabBarView(
                children: [
                  _PlanAnnuelTab(sessions: _sessions),
                  const _CatalogueTab(),
                  _SessionsTab(sessions: _sessions, onOpenSession: _openSessionDetail),
                  _EntretiensTab(interviews: _interviews),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanAnnuelTab extends StatelessWidget {
  const _PlanAnnuelTab({required this.sessions});

  final List<_TrainingSession> sessions;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _MetricCard(title: 'Budget global', value: 'FCFA 48M', subtitle: 'Plan annuel'),
              _MetricCard(title: 'Budget par dept.', value: 'FCFA 8.5M', subtitle: 'Moyenne'),
              _MetricCard(title: 'Formations obligatoires', value: '12', subtitle: 'Reglementaires'),
              _MetricCard(title: 'Taux de realisation', value: '63%', subtitle: 'vs objectifs'),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calendrier sessions prevues', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                ...sessions.map(
                  (session) => _InfoRow(
                    label: '${session.title} • ${session.category}',
                    value: '${session.date} • ${session.location}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calendrier mensuel', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                _MonthlyCalendar(sessions: sessions),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Objectifs par categorie', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _ProgressRow(label: 'Obligatoires', value: 0.72, detail: '9/12 realisees'),
                const _ProgressRow(label: 'Metier', value: 0.55, detail: '11/20 realisees'),
                const _ProgressRow(label: 'Developpement', value: 0.48, detail: '6/12 realisees'),
                const _ProgressRow(label: 'Langues', value: 0.38, detail: '3/8 realisees'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogueTab extends StatelessWidget {
  const _CatalogueTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: const [
          _CatalogueCard(
            title: 'Formations obligatoires',
            items: [
              'Securite et prevention',
              'Habilitations techniques',
              'Conformite reglementaire',
              'Formations metier legales',
            ],
          ),
          _CatalogueCard(
            title: 'Formations metier',
            items: [
              'Techniques professionnelles',
              'Logiciels et outils',
              'Processus internes',
              'Nouveaux produits/services',
            ],
          ),
          _CatalogueCard(
            title: 'Developpement personnel',
            items: [
              'Management et leadership',
              'Communication',
              'Gestion du temps',
              'Efficacite professionnelle',
            ],
          ),
          _CatalogueCard(
            title: 'Langues',
            items: [
              'Anglais professionnel',
              'Autres langues',
              'Niveaux debutant a expert',
              'Certifications (TOEIC, etc.)',
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionsTab extends StatelessWidget {
  const _SessionsTab({required this.sessions, required this.onOpenSession});

  final List<_TrainingSession> sessions;
  final ValueChanged<_TrainingSession> onOpenSession;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final session = sessions[index];
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(session.title, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
              const SizedBox(height: 6),
              Text('${session.category} • ${session.date} • ${session.location}', style: TextStyle(color: appTextMuted(context))),
              const SizedBox(height: 6),
              Text('Participants: ${session.attendees}', style: TextStyle(color: appTextMuted(context), fontSize: 12)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(onPressed: () {}, child: const Text('Inscrire employes')),
                  OutlinedButton(onPressed: () {}, child: const Text('Convocations auto')),
                  OutlinedButton(onPressed: () {}, child: const Text('Emargement')),
                  OutlinedButton(onPressed: () {}, child: const Text('Eval a chaud')),
                  OutlinedButton(onPressed: () {}, child: const Text('Eval a froid')),
                  OutlinedButton(onPressed: () {}, child: const Text('Attestations')),
                  OutlinedButton(onPressed: () => onOpenSession(session), child: const Text('Voir details')),
                ],
              ),
              const SizedBox(height: 8),
              Text('Statut: ${session.status}', style: TextStyle(color: appTextMuted(context), fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}

class _EntretiensTab extends StatelessWidget {
  const _EntretiensTab({required this.interviews});

  final List<_Interview> interviews;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: interviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final interview = interviews[index];
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(interview.employee, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
              const SizedBox(height: 6),
              Text('${interview.role} • Manager ${interview.manager}', style: TextStyle(color: appTextMuted(context))),
              const SizedBox(height: 6),
              Text('Date: ${interview.date} • Statut: ${interview.status}', style: TextStyle(color: appTextMuted(context), fontSize: 12)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(onPressed: () {}, child: const Text('Planifier entretien')),
                  OutlinedButton(onPressed: () {}, child: const Text('Grille entretien')),
                  OutlinedButton(onPressed: () {}, child: const Text('Bilan competences')),
                  OutlinedButton(onPressed: () {}, child: const Text('Besoins formation')),
                  OutlinedButton(onPressed: () {}, child: const Text('Objectifs N+1')),
                  OutlinedButton(onPressed: () {}, child: const Text('Suivi plan')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: SizedBox(
        width: 240,
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

class _CatalogueCard extends StatelessWidget {
  const _CatalogueCard({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: SizedBox(
        width: 280,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
            const SizedBox(height: 10),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item, style: TextStyle(color: appTextMuted(context)))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.label, required this.value, required this.detail});

  final String label;
  final double value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: AppColors.primary.withOpacity(0.08),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(detail, style: TextStyle(color: appTextMuted(context), fontSize: 12)),
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
          Expanded(child: Text(label, style: TextStyle(color: appTextMuted(context)))),
          Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context)))),
        ],
      ),
    );
  }
}

class _MonthlyCalendar extends StatelessWidget {
  const _MonthlyCalendar({required this.sessions});

  final List<_TrainingSession> sessions;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;
    final firstOfMonth = DateTime(currentYear, currentMonth, 1);
    final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
    final firstWeekday = firstOfMonth.weekday; // 1 = Monday
    final totalCells = ((daysInMonth + firstWeekday - 1) / 7).ceil() * 7;

    final sessionsByDay = <int, List<_TrainingSession>>{};
    for (final session in sessions) {
      final date = DateTime.tryParse(session.date);
      if (date != null && date.year == currentYear && date.month == currentMonth) {
        sessionsByDay.putIfAbsent(date.day, () => []).add(session);
      }
    }

    const headers = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const monthNames = [
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
    final monthLabel = '${monthNames[currentMonth - 1]} $currentYear';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(monthLabel, style: TextStyle(color: appTextMuted(context))),
        const SizedBox(height: 8),
        Row(
          children: headers
              .map(
                (label) => Expanded(
                  child: Center(
                    child: Text(label, style: TextStyle(color: appTextMuted(context), fontSize: 11)),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 280,
          child: Scrollbar(
            thumbVisibility: true,
            child: GridView.builder(
              itemCount: totalCells,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final dayNumber = index - (firstWeekday - 1) + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox.shrink();
                }
                final hasSession = sessionsByDay.containsKey(dayNumber);
                final sessionCount = sessionsByDay[dayNumber]?.length ?? 0;
                return Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: hasSession ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: appBorderColor(context).withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: hasSession ? AppColors.primary : appTextPrimary(context),
                          fontSize: 12,
                        ),
                      ),
                      if (hasSession) ...[
                        const SizedBox(height: 4),
                        Text(
                          '$sessionCount session',
                          style: TextStyle(color: appTextMuted(context), fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SessionDetailDialog extends StatelessWidget {
  const _SessionDetailDialog({required this.session});

  final _TrainingSession session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Session - ${session.title}'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.group_add_outlined, size: 18),
            label: const Text('Inscrire'),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.mail_outline, size: 18),
            label: const Text('Convocations'),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.verified_outlined, size: 18),
            label: const Text('Attestations'),
          ),
          const SizedBox(width: 8),
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
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fiche session', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Intitule', value: session.title),
                  _InfoRow(label: 'Categorie', value: session.category),
                  _InfoRow(label: 'Date', value: session.date),
                  _InfoRow(label: 'Lieu', value: session.location),
                  _InfoRow(label: 'Participants', value: '${session.attendees}'),
                  _InfoRow(label: 'Statut', value: session.status),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gestion session', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(onPressed: () {}, child: const Text('Emargement electronique')),
                      OutlinedButton(onPressed: () {}, child: const Text('Eval a chaud')),
                      OutlinedButton(onPressed: () {}, child: const Text('Eval a froid')),
                      OutlinedButton(onPressed: () {}, child: const Text('Mise a jour competences')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingSession {
  const _TrainingSession({
    required this.title,
    required this.category,
    required this.date,
    required this.location,
    required this.attendees,
    required this.status,
  });

  final String title;
  final String category;
  final String date;
  final String location;
  final int attendees;
  final String status;
}

class _Interview {
  const _Interview({
    required this.employee,
    required this.role,
    required this.date,
    required this.manager,
    required this.status,
  });

  final String employee;
  final String role;
  final String date;
  final String manager;
  final String status;
}

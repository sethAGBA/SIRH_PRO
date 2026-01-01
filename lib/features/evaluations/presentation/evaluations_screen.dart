import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/operation_notice.dart';
import '../../../core/widgets/section_header.dart';

class EvaluationsScreen extends StatefulWidget {
  const EvaluationsScreen({super.key});

  @override
  State<EvaluationsScreen> createState() => _EvaluationsScreenState();
}

class _EvaluationsScreenState extends State<EvaluationsScreen> {
  final List<_Campaign> _campaigns = [
    _Campaign(
      name: 'Campagne annuelle 2024',
      period: 'Jan - Dec 2024',
      completion: 0.72,
      status: 'En cours',
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 12, 31),
    ),
    _Campaign(
      name: 'Campagne semestrielle',
      period: 'Jan - Jun 2024',
      completion: 0.6,
      status: 'Relances actives',
      startDate: DateTime(2024, 1, 15),
      endDate: DateTime(2024, 6, 30),
    ),
    _Campaign(
      name: 'Campagne IT',
      period: 'Mar - Apr 2024',
      completion: 0.84,
      status: 'Consolidation',
      startDate: DateTime(2024, 3, 10),
      endDate: DateTime(2024, 4, 25),
    ),
  ];

  final List<_EvaluationDossier> _dossiers = const [
    _EvaluationDossier(
      employee: 'Awa Komla',
      role: 'Analyste RH',
      manager: 'S. Mensah',
      status: 'En cours',
      realizationRate: '78%',
      strengths: 'Leadership, rigueur',
      improvements: 'Reporting',
      objectivesNext: 'Refonte processus onboarding',
      trainingNeeds: 'Gestion de projet',
      compensation: 'Prime performance',
    ),
    _EvaluationDossier(
      employee: 'Noel Mensah',
      role: 'Dev Flutter',
      manager: 'K. Amouzou',
      status: 'Planifie',
      realizationRate: '81%',
      strengths: 'Qualite code, autonomie',
      improvements: 'Communication',
      objectivesNext: 'Livrer module paie',
      trainingNeeds: 'Architecture DDD',
      compensation: 'Augmentation a evaluer',
    ),
    _EvaluationDossier(
      employee: 'Laura B.',
      role: 'Comptable',
      manager: 'D. Sena',
      status: 'Termine',
      realizationRate: '88%',
      strengths: 'Precision, delais',
      improvements: 'Automatisation',
      objectivesNext: 'Optimiser cloture mensuelle',
      trainingNeeds: 'Excel avance',
      compensation: 'Prime proposee',
    ),
  ];

  final List<_Objective> _objectives = const [
    _Objective(
      title: 'Reduire absentéisme',
      owner: 'RH',
      progress: 0.55,
      indicator: 'Taux < 4%',
      status: 'En cours',
    ),
    _Objective(
      title: 'Digitaliser onboarding',
      owner: 'RH + IT',
      progress: 0.35,
      indicator: '100% parcours en ligne',
      status: 'Planifie',
    ),
    _Objective(
      title: 'Former managers',
      owner: 'Formation',
      progress: 0.72,
      indicator: '80% managers certifies',
      status: 'En cours',
    ),
  ];

  void _openDossier(_EvaluationDossier dossier) {
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(child: _DossierDialog(dossier: dossier)),
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
              title: 'Evaluations & performance',
              subtitle: 'Campagnes, entretiens, objectifs et talents.',
            ),
            const SizedBox(height: 16),
            AppCard(
              child: TabBar(
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: appTextMuted(context),
                tabs: const [
                  Tab(text: 'Campagnes'),
                  Tab(text: 'Entretiens'),
                  Tab(text: 'Objectifs'),
                  Tab(text: '9-Box & talents'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 740,
              child: TabBarView(
                children: [
                  _CampaignsTab(campaigns: _campaigns),
                  _EntretiensTab(dossiers: _dossiers, onOpen: _openDossier),
                  _ObjectifsTab(objectives: _objectives),
                  const _NineBoxTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignsTab extends StatelessWidget {
  const _CampaignsTab({required this.campaigns});

  final List<_Campaign> campaigns;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _FilterDropdown(
                  label: 'Departement',
                  value: 'Tous',
                  items: const ['Tous', 'RH', 'Finance', 'IT', 'Operations'],
                  onChanged: (_) {},
                ),
                _FilterDropdown(
                  label: 'Manager',
                  value: 'Tous',
                  items: const ['Tous', 'S. Mensah', 'K. Amouzou', 'D. Sena'],
                  onChanged: (_) {},
                ),
                _FilterDropdown(
                  label: 'Statut',
                  value: 'Tous',
                  items: const ['Tous', 'En cours', 'Relances actives', 'Consolidation', 'Termine'],
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
              _MetricCard(title: 'Calendrier', value: 'Jan-Dec', subtitle: 'Evaluations annuelles'),
              _MetricCard(title: 'Relances managers', value: '36', subtitle: 'Automatiques'),
              _MetricCard(title: 'Taux realise', value: '72%', subtitle: 'Avancement global'),
              _MetricCard(title: 'Consolidation', value: '3', subtitle: 'Campagnes en analyse'),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calendrier des campagnes', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                _CampaignCalendar(campaigns: campaigns),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Suivi campagnes', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                ...campaigns.map((campaign) => _CampaignRow(campaign: campaign)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Analyse performance globale', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Top performance', value: '18% effectif'),
                const _InfoRow(label: 'Performance stable', value: '68% effectif'),
                const _InfoRow(label: 'Sous performance', value: '14% effectif'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EntretiensTab extends StatelessWidget {
  const _EntretiensTab({required this.dossiers, required this.onOpen});

  final List<_EvaluationDossier> dossiers;
  final ValueChanged<_EvaluationDossier> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: dossiers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final dossier = dossiers[index];
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dossier.employee, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
              const SizedBox(height: 6),
              Text('${dossier.role} • Manager ${dossier.manager}', style: TextStyle(color: appTextMuted(context))),
              const SizedBox(height: 6),
              Text('Statut: ${dossier.status} • Taux: ${dossier.realizationRate}',
                  style: TextStyle(color: appTextMuted(context), fontSize: 12)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(onPressed: () => onOpen(dossier), child: const Text('Ouvrir dossier')),
                  OutlinedButton(onPressed: () {}, child: const Text('Planifier entretien')),
                  OutlinedButton(onPressed: () {}, child: const Text('Relancer manager')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ObjectifsTab extends StatelessWidget {
  const _ObjectifsTab({required this.objectives});

  final List<_Objective> objectives;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: objectives.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final objective = objectives[index];
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(objective.title, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
              const SizedBox(height: 6),
              Text('Owner: ${objective.owner} • ${objective.indicator}', style: TextStyle(color: appTextMuted(context))),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: objective.progress,
                minHeight: 6,
                backgroundColor: AppColors.primary.withOpacity(0.08),
                color: AppColors.primary,
              ),
              const SizedBox(height: 6),
              Text('Statut: ${objective.status}', style: TextStyle(color: appTextMuted(context), fontSize: 12)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(onPressed: () {}, child: const Text('Assigner')),
                  OutlinedButton(onPressed: () {}, child: const Text('Ajuster')),
                  OutlinedButton(onPressed: () {}, child: const Text('Suivi temps reel')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NineBoxTab extends StatelessWidget {
  const _NineBoxTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Matrice performance / potentiel', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                _NineBoxGrid(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hauts potentiels', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Vivier leadership', value: '12 profils'),
                const _InfoRow(label: 'Plans de succession', value: '6 postes critiques'),
                const _InfoRow(label: 'Mobilites en cours', value: '4 dossiers'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DossierDialog extends StatelessWidget {
  const _DossierDialog({required this.dossier});

  final _EvaluationDossier dossier;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Entretien - ${dossier.employee}'),
          automaticallyImplyLeading: false,
          actions: [
            TextButton.icon(
              onPressed: () => showOperationNotice(context, message: 'Evaluation validee.', success: true),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Valider'),
            ),
            TextButton.icon(
              onPressed: () => showOperationNotice(context, message: 'Impression lancee.', success: true),
              icon: const Icon(Icons.print, size: 18),
              label: const Text('Imprimer'),
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
              Tab(text: 'Bilan'),
              Tab(text: 'Competences'),
              Tab(text: 'Objectifs N+1'),
              Tab(text: 'Developpement'),
              Tab(text: 'Remuneration'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DossierSection(
              title: 'Bilan annee ecoulee',
              items: [
                _InfoRow(label: 'Objectifs fixes', value: dossier.objectivesPast),
                _InfoRow(label: 'Taux realisation', value: dossier.realizationRate),
                _InfoRow(label: 'Realisations marquantes', value: dossier.achievements),
                _InfoRow(label: 'Difficultes', value: dossier.difficulties),
                _InfoRow(label: 'Competences mobilisees', value: dossier.skills),
              ],
            ),
            _DossierSection(
              title: 'Evaluation competences',
              items: [
                _InfoRow(label: 'Techniques', value: dossier.techSkills),
                _InfoRow(label: 'Manageriales', value: dossier.mgrSkills),
                _InfoRow(label: 'Savoir-etre', value: dossier.softSkills),
                _InfoRow(label: 'Points forts', value: dossier.strengths),
                _InfoRow(label: 'Axes amelioration', value: dossier.improvements),
              ],
            ),
            _DossierSection(
              title: 'Objectifs N+1',
              items: [
                _InfoRow(label: 'Objectifs quantitatifs', value: dossier.objectivesNext),
                _InfoRow(label: 'Objectifs qualitatifs', value: dossier.objectivesQuali),
                _InfoRow(label: 'Projets assignes', value: dossier.projects),
                _InfoRow(label: 'Indicateurs mesure', value: dossier.indicators),
                _InfoRow(label: 'Moyens necessaires', value: dossier.resources),
              ],
            ),
            _DossierSection(
              title: 'Developpement',
              items: [
                _InfoRow(label: 'Besoins formation', value: dossier.trainingNeeds),
                _InfoRow(label: 'Competences a acquerir', value: dossier.skillsToAcquire),
                _InfoRow(label: 'Perspectives evolution', value: dossier.evolution),
                _InfoRow(label: 'Mobilite souhaitee', value: dossier.mobility),
                _InfoRow(label: 'Accompagnement', value: dossier.support),
              ],
            ),
            _DossierSection(
              title: 'Remuneration',
              items: [
                _InfoRow(label: 'Discussion augmentation', value: dossier.raiseDiscussion),
                _InfoRow(label: 'Primes performance', value: dossier.performanceBonus),
                _InfoRow(label: 'Avantages', value: dossier.perks),
                _InfoRow(label: 'Decision', value: dossier.compensation),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DossierSection extends StatelessWidget {
  const _DossierSection({required this.title, required this.items});

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

class _NineBoxGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final labels = [
      'Fort potentiel',
      'Potentiel eleve',
      'Potentiel moyen',
      'Performance forte',
      'Performance stable',
      'Performance faible',
      'A developper',
      'Sous surveillance',
      'Risque depart',
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: labels.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(labels[index], style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context), fontSize: 12)),
              const Spacer(),
              Text('${(index + 1) * 2} profils', style: TextStyle(color: appTextMuted(context), fontSize: 11)),
            ],
          ),
        );
      },
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

class _CampaignRow extends StatelessWidget {
  const _CampaignRow({required this.campaign});

  final _Campaign campaign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(campaign.name, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
          const SizedBox(height: 6),
          Text('${campaign.period} • ${campaign.status}', style: TextStyle(color: appTextMuted(context))),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: campaign.completion,
            minHeight: 6,
            backgroundColor: AppColors.primary.withOpacity(0.08),
            color: AppColors.primary,
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
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context)),
            ),
          ),
        ],
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
      width: 180,
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
        onChanged: (value) => onChanged(value ?? 'Tous'),
      ),
    );
  }
}

class _CampaignCalendar extends StatelessWidget {
  const _CampaignCalendar({required this.campaigns});

  final List<_Campaign> campaigns;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentYear = now.year;
    final firstOfMonth = DateTime(currentYear, now.month, 1);
    final daysInMonth = DateTime(currentYear, now.month + 1, 0).day;
    final firstWeekday = firstOfMonth.weekday;
    final totalCells = ((daysInMonth + firstWeekday - 1) / 7).ceil() * 7;

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
    final monthLabel = '${monthNames[now.month - 1]} $currentYear';

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
                final dayDate = DateTime(currentYear, now.month, dayNumber);
                final activeCampaigns = campaigns
                    .where((campaign) =>
                        !dayDate.isBefore(campaign.startDate) && !dayDate.isAfter(campaign.endDate))
                    .toList();
                final highlight = activeCampaigns.isNotEmpty;
                return Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: highlight ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
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
                          color: highlight ? AppColors.primary : appTextPrimary(context),
                          fontSize: 12,
                        ),
                      ),
                  if (highlight) ...[
                    const SizedBox(height: 4),
                    Text(
                      activeCampaigns.length == 1 ? 'Campagne' : '${activeCampaigns.length} campagnes',
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

class _Campaign {
  const _Campaign({
    required this.name,
    required this.period,
    required this.completion,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  final String name;
  final String period;
  final double completion;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
}

class _EvaluationDossier {
  const _EvaluationDossier({
    required this.employee,
    required this.role,
    required this.manager,
    required this.status,
    required this.realizationRate,
    required this.strengths,
    required this.improvements,
    required this.objectivesNext,
    required this.trainingNeeds,
    required this.compensation,
    this.objectivesPast = 'Objectifs SMART 2023',
    this.achievements = 'Projets finalises, KPI depasses',
    this.difficulties = 'Charge elevee Q3',
    this.skills = 'Organisation, reporting',
    this.techSkills = 'Paie, droit social',
    this.mgrSkills = 'Coordination',
    this.softSkills = 'Communication',
    this.objectivesQuali = 'Satisfaction interne',
    this.projects = 'Pilotage campagne RH',
    this.indicators = 'OKR trimestriels',
    this.resources = 'Budget formation',
    this.skillsToAcquire = 'Leadership',
    this.evolution = 'Responsable RH',
    this.mobility = 'Ouverte',
    this.support = 'Mentoring',
    this.raiseDiscussion = 'A discuter',
    this.performanceBonus = 'Prime 10%',
    this.perks = 'Mutuelle, prime',
  });

  final String employee;
  final String role;
  final String manager;
  final String status;
  final String realizationRate;
  final String strengths;
  final String improvements;
  final String objectivesNext;
  final String trainingNeeds;
  final String compensation;
  final String objectivesPast;
  final String achievements;
  final String difficulties;
  final String skills;
  final String techSkills;
  final String mgrSkills;
  final String softSkills;
  final String objectivesQuali;
  final String projects;
  final String indicators;
  final String resources;
  final String skillsToAcquire;
  final String evolution;
  final String mobility;
  final String support;
  final String raiseDiscussion;
  final String performanceBonus;
  final String perks;
}

class _Objective {
  const _Objective({
    required this.title,
    required this.owner,
    required this.progress,
    required this.indicator,
    required this.status,
  });

  final String title;
  final String owner;
  final double progress;
  final String indicator;
  final String status;
}

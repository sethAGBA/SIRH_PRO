import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';

class RecrutementsScreen extends StatefulWidget {
  const RecrutementsScreen({super.key});

  @override
  State<RecrutementsScreen> createState() => _RecrutementsScreenState();
}

class _RecrutementsScreenState extends State<RecrutementsScreen> {
  String _filterPoste = 'Tous';
  String _filterSource = 'Tous';
  String _filterStatus = 'Tous';

  final List<_Candidate> _candidates = [
    _Candidate(
      name: 'Awa Komla',
      job: 'Analyste RH',
      source: 'LinkedIn',
      stage: _Stage.cv,
      status: 'Nouveau',
      score: 78,
    ),
    _Candidate(
      name: 'Noel Mensah',
      job: 'Dev Flutter',
      source: 'Cooptation',
      stage: _Stage.preselection,
      status: 'Qualifie',
      score: 86,
    ),
    _Candidate(
      name: 'Koffi S.',
      job: 'Dev Flutter',
      source: 'Site emploi',
      stage: _Stage.entretien,
      status: 'Entretien planifie',
      score: 90,
    ),
    _Candidate(
      name: 'Laura B.',
      job: 'Comptable',
      source: 'Cabinet',
      stage: _Stage.offre,
      status: 'Offre envoyee',
      score: 88,
    ),
    _Candidate(
      name: 'Jean P.',
      job: 'Analyste RH',
      source: 'LinkedIn',
      stage: _Stage.embauche,
      status: 'Embauche',
      score: 92,
    ),
  ];

  final List<_JobOpening> _jobs = const [
    _JobOpening(
      title: 'Analyste RH',
      department: 'RH',
      type: 'CDI',
      location: 'Lome',
      salaryRange: 'FCFA 400k - 600k',
    ),
    _JobOpening(
      title: 'Dev Flutter',
      department: 'IT',
      type: 'CDI',
      location: 'Kara',
      salaryRange: 'FCFA 500k - 800k',
    ),
    _JobOpening(
      title: 'Comptable',
      department: 'Finance',
      type: 'CDD',
      location: 'Lome',
      salaryRange: 'FCFA 350k - 500k',
    ),
  ];

  void _openJobDetail(_JobOpening job) {
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(child: _JobDetailDialog(job: job)),
    );
  }

  void _openCandidateDetail(_Candidate candidate) {
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(child: _CandidateDetailDialog(candidate: candidate)),
    );
  }

  List<_Candidate> _filteredByStage(_Stage stage) {
    return _candidates.where((c) {
      final matchPoste = _filterPoste == 'Tous' || c.job == _filterPoste;
      final matchSource = _filterSource == 'Tous' || c.source == _filterSource;
      final matchStatus = _filterStatus == 'Tous' || c.status == _filterStatus;
      return c.stage == stage && matchPoste && matchSource && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Recrutements',
            subtitle: 'Pipeline candidatures et postes ouverts.',
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _FilterDropdown(
                  label: 'Poste',
                  value: _filterPoste,
                  items: const ['Tous', 'Analyste RH', 'Dev Flutter', 'Comptable'],
                  onChanged: (value) => setState(() => _filterPoste = value),
                ),
                _FilterDropdown(
                  label: 'Source',
                  value: _filterSource,
                  items: const ['Tous', 'LinkedIn', 'Site emploi', 'Cooptation', 'Cabinet'],
                  onChanged: (value) => setState(() => _filterSource = value),
                ),
                _FilterDropdown(
                  label: 'Statut',
                  value: _filterStatus,
                  items: const ['Tous', 'Nouveau', 'Qualifie', 'Entretien planifie', 'Offre envoyee', 'Embauche'],
                  onChanged: (value) => setState(() => _filterStatus = value),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Importer CV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Pipeline candidatures',
            subtitle: 'CV recus -> Preselection -> Entretien -> Offre -> Embauche.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _KanbanColumn(
                title: 'CV recus',
                candidates: _filteredByStage(_Stage.cv),
                onOpenCandidate: _openCandidateDetail,
              ),
              _KanbanColumn(
                title: 'Preselection',
                candidates: _filteredByStage(_Stage.preselection),
                onOpenCandidate: _openCandidateDetail,
              ),
              _KanbanColumn(
                title: 'Entretien',
                candidates: _filteredByStage(_Stage.entretien),
                onOpenCandidate: _openCandidateDetail,
              ),
              _KanbanColumn(
                title: 'Offre',
                candidates: _filteredByStage(_Stage.offre),
                onOpenCandidate: _openCandidateDetail,
              ),
              _KanbanColumn(
                title: 'Embauche',
                candidates: _filteredByStage(_Stage.embauche),
                onOpenCandidate: _openCandidateDetail,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            title: 'Postes a pourvoir',
            subtitle: 'Fiches de poste et diffusion.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _jobs
                .map(
                  (job) => _JobCard(
                    job: job,
                    onOpen: () => _openJobDetail(job),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            title: 'Onboarding nouveaux arrivants',
            subtitle: 'Checklist integration et suivi periode d essai.',
          ),
          const SizedBox(height: 12),
          const _OnboardingChecklist(),
        ],
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({
    required this.title,
    required this.candidates,
    required this.onOpenCandidate,
  });

  final String title;
  final List<_Candidate> candidates;
  final ValueChanged<_Candidate> onOpenCandidate;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context)),
            ),
            const SizedBox(height: 8),
            ...candidates.map((c) => _CandidateCard(candidate: c, onOpen: () => onOpenCandidate(c))),
            if (candidates.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('Aucun candidat', style: TextStyle(color: appTextMuted(context))),
              ),
          ],
        ),
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({required this.candidate, required this.onOpen});

  final _Candidate candidate;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            candidate.name,
            style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context)),
          ),
          const SizedBox(height: 4),
          Text(candidate.job, style: TextStyle(color: appTextMuted(context), fontSize: 12)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(candidate.source, style: TextStyle(color: appTextMuted(context), fontSize: 11)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  candidate.status,
                  style: const TextStyle(fontSize: 10, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('Score', style: TextStyle(color: appTextMuted(context), fontSize: 11)),
              const SizedBox(width: 6),
              Expanded(
                child: LinearProgressIndicator(
                  value: candidate.score / 100,
                  minHeight: 6,
                  backgroundColor: AppColors.primary.withOpacity(0.08),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text('${candidate.score}%', style: TextStyle(color: appTextMuted(context), fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('Planifier'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Email'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Archiver'),
              ),
              TextButton(
                onPressed: onOpen,
                child: const Text('Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job, required this.onOpen});

  final _JobOpening job;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: SizedBox(
        width: 260,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context)),
            ),
            const SizedBox(height: 6),
            Text('${job.department} - ${job.location}', style: TextStyle(color: appTextMuted(context))),
            const SizedBox(height: 6),
            Text('Contrat: ${job.type}', style: TextStyle(color: appTextMuted(context), fontSize: 12)),
            const SizedBox(height: 6),
            Text(job.salaryRange, style: TextStyle(color: appTextPrimary(context), fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(onPressed: onOpen, child: const Text('Voir fiche')),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JobDetailDialog extends StatelessWidget {
  const _JobDetailDialog({required this.job});

  final _JobOpening job;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(job.title),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Description'),
              Tab(text: 'Profil'),
              Tab(text: 'Conditions'),
              Tab(text: 'Diffusion'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _JobSection(
              title: 'Description',
              items: [
                _JobField(label: 'Intitule poste', value: job.title),
                _JobField(label: 'Departement', value: job.department),
                const _JobField(label: 'Missions principales', value: 'Pilotage des activites RH'),
                const _JobField(label: 'Responsabilites', value: 'Reporting, coordination'),
                const _JobField(label: 'Liens hierarchiques', value: 'DRH'),
              ],
            ),
            const _JobSection(
              title: 'Profil recherche',
              items: [
                _JobField(label: 'Formation', value: 'Bac+4 RH'),
                _JobField(label: 'Experience', value: '3 ans minimum'),
                _JobField(label: 'Competences techniques', value: 'Paie, droit social'),
                _JobField(label: 'Competences comportementales', value: 'Communication'),
                _JobField(label: 'Langues', value: 'Francais, Anglais'),
              ],
            ),
            _JobSection(
              title: 'Conditions',
              items: [
                _JobField(label: 'Type contrat', value: job.type),
                const _JobField(label: 'Duree si CDD', value: '6 mois'),
                _JobField(label: 'Fourchette salariale', value: job.salaryRange),
                const _JobField(label: 'Avantages', value: 'Mutuelle, prime'),
                const _JobField(label: 'Date prise de poste', value: '2024-05-01'),
              ],
            ),
            const _JobSection(
              title: 'Diffusion',
              items: [
                _JobField(label: 'Sites emploi', value: 'LinkedIn, Emploi.tg'),
                _JobField(label: 'Reseaux sociaux', value: 'Facebook, X'),
                _JobField(label: 'Cooptation interne', value: 'Active'),
                _JobField(label: 'Cabinets', value: 'RH Partners'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CandidateDetailDialog extends StatelessWidget {
  const _CandidateDetailDialog({required this.candidate});

  final _Candidate candidate;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Candidature - ${candidate.name}'),
          automaticallyImplyLeading: false,
          actions: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.event_available, size: 18),
              label: const Text('Planifier entretien'),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.mail_outline, size: 18),
              label: const Text('Envoyer email'),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.description_outlined, size: 18),
              label: const Text('Generer offre'),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Profil'),
              Tab(text: 'Historique'),
              Tab(text: 'Entretien'),
              Tab(text: 'Offre'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _CandidateSection(
              title: 'Profil candidat',
              items: [
                _JobField(label: 'Nom', value: candidate.name),
                _JobField(label: 'Poste cible', value: candidate.job),
                _JobField(label: 'Source', value: candidate.source),
                _JobField(label: 'Statut', value: candidate.status),
                _JobField(label: 'Score automatique', value: '${candidate.score}%'),
                const _JobField(label: 'Experience', value: '3 ans'),
                const _JobField(label: 'Competences', value: 'Paie, reporting, RGPD'),
                const _JobField(label: 'Disponibilite', value: 'Sous 2 semaines'),
              ],
            ),
            const _CandidateSection(
              title: 'Historique des echanges',
              items: [
                _JobField(label: 'Dernier contact', value: '2024-05-14'),
                _JobField(label: 'Emails envoyes', value: 'Convocation entretien'),
                _JobField(label: 'Notes recruteur', value: 'Profil pertinent'),
                _JobField(label: 'Documents', value: 'CV, Lettre motivation'),
              ],
            ),
            const _CandidateSection(
              title: 'Planification entretien',
              items: [
                _JobField(label: 'Type entretien', value: 'RH + Manager'),
                _JobField(label: 'Date proposee', value: '2024-05-21 10:00'),
                _JobField(label: 'Lieu', value: 'Salle 2 / Visio'),
                _JobField(label: 'Grille evaluation', value: 'Standard RH v1'),
                _JobField(label: 'Commentaires', value: 'Preparer test technique'),
              ],
            ),
            const _CandidateSection(
              title: 'Offre d embauche',
              items: [
                _JobField(label: 'Etat', value: 'A preparer'),
                _JobField(label: 'Fourchette salariale', value: 'FCFA 450k - 650k'),
                _JobField(label: 'Avantages', value: 'Mutuelle, prime'),
                _JobField(label: 'Date envoi', value: 'A definir'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JobSection extends StatelessWidget {
  const _JobSection({required this.title, required this.items});

  final String title;
  final List<_JobField> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context)),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => _InfoRow(label: item.label, value: item.value)),
          ],
        ),
      ),
    );
  }
}

class _CandidateSection extends StatelessWidget {
  const _CandidateSection({required this.title, required this.items});

  final String title;
  final List<_JobField> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context)),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => _InfoRow(label: item.label, value: item.value)),
          ],
        ),
      ),
    );
  }
}

class _JobField {
  const _JobField({required this.label, required this.value});

  final String label;
  final String value;
}

class _OnboardingChecklist extends StatelessWidget {
  const _OnboardingChecklist();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _ChecklistItem(label: 'Badge et acces', value: 'En cours'),
          _ChecklistItem(label: 'Materiel attribue', value: 'OK'),
          _ChecklistItem(label: 'Formation initiale', value: 'Planifiee'),
          _ChecklistItem(label: 'Presentation equipe', value: 'OK'),
          _ChecklistItem(label: 'Suivi periode essai', value: 'A venir'),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: appTextPrimary(context)))),
          Text(value, style: TextStyle(color: appTextMuted(context))),
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

class _Candidate {
  const _Candidate({
    required this.name,
    required this.job,
    required this.source,
    required this.stage,
    required this.status,
    required this.score,
  });

  final String name;
  final String job;
  final String source;
  final _Stage stage;
  final String status;
  final int score;
}

class _JobOpening {
  const _JobOpening({
    required this.title,
    required this.department,
    required this.type,
    required this.location,
    required this.salaryRange,
  });

  final String title;
  final String department;
  final String type;
  final String location;
  final String salaryRange;
}

enum _Stage {
  cv,
  preselection,
  entretien,
  offre,
  embauche,
}

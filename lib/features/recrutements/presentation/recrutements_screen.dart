import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/dao/dao_registry.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/operation_notice.dart';
import '../../../core/widgets/section_header.dart';
import '../../../shared/models/poste.dart';
import '../../../shared/models/recrutement.dart';
import '../../postes/presentation/poste_detail_screen.dart';
import '../../postes/presentation/postes_form_screen.dart';

class RecrutementsScreen extends StatefulWidget {
  const RecrutementsScreen({super.key});

  @override
  State<RecrutementsScreen> createState() => _RecrutementsScreenState();
}

class _RecrutementsScreenState extends State<RecrutementsScreen> {
  final List<Recrutement> _candidates = [];
  final List<Recrutement> _tableCandidates = [];
  final List<Poste> _jobOpenings = [];
  final List<_IdLabelOption> _posteOptions = [];
  final List<DepartmentOption> _departmentOptions = [];

  bool _loading = false;
  int _page = 0;
  final int _pageSize = 10;
  int _totalCandidates = 0;
  String _searchQuery = '';
  String _filterPosteId = '';
  String _filterSource = 'Tous';
  String _filterStatus = 'Tous';
  String _filterStage = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadPostes();
    _loadDepartements();
    _loadCandidates();
  }

  Future<void> _loadPostes() async {
    final rows = await DaoRegistry.instance.postes.list(orderBy: 'intitule ASC');
    final postes = rows.map(_posteFromRow).toList();
    if (!mounted) return;
    setState(() {
      _posteOptions
        ..clear()
        ..addAll(
          postes
              .map((poste) => _IdLabelOption(id: poste.id, label: poste.title))
              .where((opt) => opt.id.isNotEmpty && opt.label.isNotEmpty),
        );
      _jobOpenings
        ..clear()
        ..addAll(postes.where((poste) => poste.status == 'Actif' && poste.deletedAt == null));
    });
  }

  Future<void> _loadDepartements() async {
    final rows = await DaoRegistry.instance.departements.list(orderBy: 'nom ASC');
    final options = rows
        .map(
          (row) => DepartmentOption(
            id: (row['id'] as String?) ?? '',
            label: (row['nom'] as String?) ?? '',
          ),
        )
        .where((opt) => opt.id.isNotEmpty && opt.label.isNotEmpty)
        .toList();
    if (!mounted) return;
    setState(() {
      _departmentOptions
        ..clear()
        ..addAll(options);
    });
  }

  Future<void> _loadCandidates({bool resetPage = false}) async {
    if (resetPage) _page = 0;
    setState(() => _loading = true);

    final posteId = _filterPosteId.isEmpty ? null : _filterPosteId;
    final source = _filterSource == 'Tous' ? null : _filterSource;
    final status = _filterStatus == 'Tous' ? null : _filterStatus;
    final stage = _filterStage == 'Tous' ? null : _filterStage;

    final pipelineFuture = DaoRegistry.instance.recrutements.search(
      query: _searchQuery,
      posteId: posteId,
      source: source,
      status: status,
      stage: stage,
      orderBy: 'created_at DESC',
    );
    final tableFuture = DaoRegistry.instance.recrutements.search(
      query: _searchQuery,
      posteId: posteId,
      source: source,
      status: status,
      stage: stage,
      orderBy: 'created_at DESC',
      limit: _pageSize,
      offset: _page * _pageSize,
    );
    final countFuture = DaoRegistry.instance.recrutements.count(
      query: _searchQuery,
      posteId: posteId,
      source: source,
      status: status,
      stage: stage,
    );

    final results = await Future.wait([pipelineFuture, tableFuture, countFuture]);
    final pipelineRows = results[0] as List<Map<String, dynamic>>;
    final tableRows = results[1] as List<Map<String, dynamic>>;
    final total = results[2] as int;

    if (!mounted) return;
    setState(() {
      _candidates
        ..clear()
        ..addAll(pipelineRows.map(_recrutementFromRow));
      _tableCandidates
        ..clear()
        ..addAll(tableRows.map(_recrutementFromRow));
      _totalCandidates = total;
      _loading = false;
    });
  }

  Poste _posteFromRow(Map<String, dynamic> row) {
    return Poste(
      id: (row['id'] as String?) ?? '',
      title: (row['intitule'] as String?) ?? '',
      departmentId: (row['departement_id'] as String?) ?? '',
      departmentName: (row['departement_nom'] as String?) ?? '',
      level: (row['niveau'] as String?) ?? '',
      description: (row['description'] as String?) ?? '',
      code: (row['code'] as String?) ?? '',
      typeContrat: (row['type_contrat'] as String?) ?? '',
      localisation: (row['localisation'] as String?) ?? '',
      salaireRange: (row['salaire_range'] as String?) ?? '',
      missions: (row['missions'] as String?) ?? '',
      responsabilites: (row['responsabilites'] as String?) ?? '',
      liensHierarchiques: (row['liens_hierarchiques'] as String?) ?? '',
      formation: (row['formation'] as String?) ?? '',
      experience: (row['experience'] as String?) ?? '',
      competencesTech: (row['competences_tech'] as String?) ?? '',
      competencesComport: (row['competences_comport'] as String?) ?? '',
      langues: (row['langues'] as String?) ?? '',
      dureeCdd: (row['duree_cdd'] as String?) ?? '',
      avantages: (row['avantages'] as String?) ?? '',
      datePrisePoste: (row['date_prise_poste'] as String?) ?? '',
      sitesEmploi: (row['sites_emploi'] as String?) ?? '',
      reseauxSociaux: (row['reseaux_sociaux'] as String?) ?? '',
      cooptationInterne: (row['cooptation_interne'] as String?) ?? '',
      cabinets: (row['cabinets'] as String?) ?? '',
      status: (row['statut'] as String?) ?? 'Actif',
      deletedAt: row['deleted_at'] as int?,
    );
  }

  Recrutement _recrutementFromRow(Map<String, dynamic> row) {
    final entretienMillis = row['entretien_date'] as int?;
    final score = row['score'];
    return Recrutement(
      id: (row['id'] as String?) ?? '',
      candidatNom: (row['candidat_nom'] as String?) ?? '',
      posteId: (row['poste_id'] as String?) ?? '',
      posteNom: (row['poste_nom'] as String?) ?? '',
      status: (row['statut'] as String?) ?? '',
      stage: (row['stage'] as String?) ?? 'CV',
      source: (row['source'] as String?) ?? '',
      score: score is int ? score : int.tryParse('${score ?? 0}') ?? 0,
      typeContrat: (row['type_contrat'] as String?) ?? '',
      email: (row['candidat_email'] as String?) ?? '',
      telephone: (row['candidat_telephone'] as String?) ?? '',
      localisation: (row['localisation'] as String?) ?? '',
      experience: (row['experience'] as String?) ?? '',
      salaireSouhaite: (row['salaire_souhaite'] as String?) ?? '',
      disponibilite: (row['disponibilite'] as String?) ?? '',
      entretienDate:
          entretienMillis == null ? null : DateTime.fromMillisecondsSinceEpoch(entretienMillis),
      entretienLieu: (row['entretien_lieu'] as String?) ?? '',
      commentaire: (row['commentaire'] as String?) ?? '',
      cvUrl: (row['cv_url'] as String?) ?? '',
    );
  }

  Map<String, dynamic> _recrutementToRow(Recrutement candidate, {required bool forInsert}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return {
      'id': candidate.id,
      'poste_id': candidate.posteId,
      'poste_nom': candidate.posteNom,
      'candidat_nom': candidate.candidatNom,
      'candidat_email': candidate.email,
      'candidat_telephone': candidate.telephone,
      'localisation': candidate.localisation,
      'experience': candidate.experience,
      'salaire_souhaite': candidate.salaireSouhaite,
      'disponibilite': candidate.disponibilite,
      'entretien_date': candidate.entretienDate?.millisecondsSinceEpoch,
      'entretien_lieu': candidate.entretienLieu,
      'statut': candidate.status,
      'stage': candidate.stage,
      'type_contrat': candidate.typeContrat,
      'source': candidate.source,
      'score': candidate.score,
      'commentaire': candidate.commentaire,
      'cv_url': candidate.cvUrl,
      'updated_at': now,
      if (forInsert) 'created_at': now,
    };
  }

  Future<void> _openCandidateForm({Recrutement? candidate}) async {
    final updated = await showDialog<Recrutement>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _CandidateFormScreen(
          candidate: candidate,
          posteOptions: _posteOptions,
        ),
      ),
    );

    if (updated == null) return;
    final exists = _candidates.any((item) => item.id == updated.id);
    if (exists) {
      await DaoRegistry.instance.recrutements.update(updated.id, _recrutementToRow(updated, forInsert: false));
      showOperationNotice(context, message: 'Candidature mise a jour.', success: true);
    } else {
      await DaoRegistry.instance.recrutements.insert(_recrutementToRow(updated, forInsert: true));
      showOperationNotice(context, message: 'Candidature enregistree.', success: true);
    }
    await _loadCandidates(resetPage: true);
  }

  void _openCandidateDetail(Recrutement candidate) {
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _CandidateDetailScreen(
          candidate: candidate,
          onEdit: () => _openCandidateForm(candidate: candidate),
        ),
      ),
    );
  }

  Future<void> _updateCandidate(Recrutement candidate, String message) async {
    await DaoRegistry.instance.recrutements.update(
      candidate.id,
      _recrutementToRow(candidate, forInsert: false),
    );
    await _loadCandidates(resetPage: true);
    showOperationNotice(context, message: message, success: true);
  }

  Future<void> _planifierEntretien(Recrutement candidate) async {
    final initial = candidate.entretienDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (pickedTime == null) return;

    final entretienDate = DateTime(
      picked.year,
      picked.month,
      picked.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final lieu = await _askEntretienLieu(candidate.entretienLieu);
    if (lieu == null) return;

    final updated = Recrutement(
      id: candidate.id,
      candidatNom: candidate.candidatNom,
      posteId: candidate.posteId,
      posteNom: candidate.posteNom,
      status: 'Entretien planifie',
      stage: 'Entretien',
      source: candidate.source,
      score: candidate.score,
      typeContrat: candidate.typeContrat,
      email: candidate.email,
      telephone: candidate.telephone,
      localisation: candidate.localisation,
      experience: candidate.experience,
      salaireSouhaite: candidate.salaireSouhaite,
      disponibilite: candidate.disponibilite,
      entretienDate: entretienDate,
      entretienLieu: lieu,
      commentaire: candidate.commentaire,
      cvUrl: candidate.cvUrl,
    );
    await _updateCandidate(updated, 'Entretien planifie.');
  }

  Future<String?> _askEntretienLieu(String current) async {
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lieu entretien'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Lieu ou lien visio'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    return result;
  }

  Future<void> _envoyerEmail(Recrutement candidate) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Envoyer un email'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Note (optionnel)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
    if (note == null) return;

    final entry = note.isEmpty ? 'Email envoye' : 'Email envoye: $note';
    final updated = Recrutement(
      id: candidate.id,
      candidatNom: candidate.candidatNom,
      posteId: candidate.posteId,
      posteNom: candidate.posteNom,
      status: candidate.status,
      stage: candidate.stage,
      source: candidate.source,
      score: candidate.score,
      typeContrat: candidate.typeContrat,
      email: candidate.email,
      telephone: candidate.telephone,
      localisation: candidate.localisation,
      experience: candidate.experience,
      salaireSouhaite: candidate.salaireSouhaite,
      disponibilite: candidate.disponibilite,
      entretienDate: candidate.entretienDate,
      entretienLieu: candidate.entretienLieu,
      commentaire: _appendComment(candidate.commentaire, entry),
      cvUrl: candidate.cvUrl,
    );
    await _updateCandidate(updated, 'Email envoye.');
  }

  Future<void> _archiverCandidature(Recrutement candidate) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archiver candidature'),
        content: Text('Archiver la candidature de ${candidate.candidatNom} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Archiver'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final updated = Recrutement(
      id: candidate.id,
      candidatNom: candidate.candidatNom,
      posteId: candidate.posteId,
      posteNom: candidate.posteNom,
      status: 'Refuse',
      stage: candidate.stage,
      source: candidate.source,
      score: candidate.score,
      typeContrat: candidate.typeContrat,
      email: candidate.email,
      telephone: candidate.telephone,
      localisation: candidate.localisation,
      experience: candidate.experience,
      salaireSouhaite: candidate.salaireSouhaite,
      disponibilite: candidate.disponibilite,
      entretienDate: candidate.entretienDate,
      entretienLieu: candidate.entretienLieu,
      commentaire: _appendComment(candidate.commentaire, 'Candidature archivee'),
      cvUrl: candidate.cvUrl,
    );
    await _updateCandidate(updated, 'Candidature archivee.');
  }

  Future<void> _confirmDelete(Recrutement candidate) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer candidature'),
        content: Text('Supprimer la candidature de ${candidate.candidatNom} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await DaoRegistry.instance.recrutements.delete(candidate.id);
    await _loadCandidates(resetPage: true);
    showOperationNotice(context, message: 'Candidature supprimee.', success: true);
  }

  void _openJobDetail(Poste poste) {
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: PosteDetailScreen(
          poste: poste,
          departmentOptions: _departmentOptions,
        ),
      ),
    );
  }

  List<Recrutement> _stageCandidates(String stage) {
    return _candidates.where((candidate) => candidate.stage == stage).toList();
  }

  Widget _buildTable(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_tableCandidates.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Aucune candidature.',
            style: TextStyle(color: appTextMuted(context)),
          ),
        ),
      );
    }
    return DataTable(
      columns: const [
        DataColumn(label: Text('Candidat')),
        DataColumn(label: Text('Poste')),
        DataColumn(label: Text('Etape')),
        DataColumn(label: Text('Statut')),
        DataColumn(label: Text('Source')),
        DataColumn(label: Text('Score')),
        DataColumn(label: Text('Actions')),
      ],
      rows: _tableCandidates
          .map(
            (candidate) => DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 160,
                    child: Text(
                      candidate.candidatNom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 160,
                    child: Text(
                      candidate.posteNom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(Text(candidate.stage)),
                DataCell(Text(candidate.status)),
                DataCell(Text(candidate.source)),
                DataCell(Text('${candidate.score}%')),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Voir details',
                        icon: const Icon(Icons.visibility_outlined),
                        onPressed: () => _openCandidateDetail(candidate),
                      ),
                      IconButton(
                        tooltip: 'Modifier',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _openCandidateForm(candidate: candidate),
                      ),
                      IconButton(
                        tooltip: 'Supprimer',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(candidate),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _buildPagination() {
    if (_totalCandidates == 0) return const SizedBox.shrink();
    final start = _page * _pageSize + 1;
    var end = (_page + 1) * _pageSize;
    if (end > _totalCandidates) end = _totalCandidates;
    final canPrev = _page > 0;
    final canNext = end < _totalCandidates;

    return Row(
      children: [
        Text('$start-$end sur $_totalCandidates', style: TextStyle(color: appTextMuted(context))),
        const Spacer(),
        TextButton(onPressed: canPrev ? () {
          setState(() => _page -= 1);
          _loadCandidates();
        } : null, child: const Text('Precedent')),
        const SizedBox(width: 8),
        TextButton(onPressed: canNext ? () {
          setState(() => _page += 1);
          _loadCandidates();
        } : null, child: const Text('Suivant')),
      ],
    );
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
                SizedBox(
                  width: 220,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Recherche candidat...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      _searchQuery = value.trim();
                      _loadCandidates(resetPage: true);
                    },
                  ),
                ),
                _PosteDropdown(
                  label: 'Poste',
                  value: _filterPosteId,
                  options: _posteOptions,
                  onChanged: (value) {
                    _filterPosteId = value;
                    _loadCandidates(resetPage: true);
                  },
                ),
                _FilterDropdown(
                  label: 'Source',
                  value: _filterSource,
                  items: const ['Tous', 'LinkedIn', 'Site emploi', 'Cooptation', 'Cabinet', 'Autre'],
                  onChanged: (value) {
                    _filterSource = value;
                    _loadCandidates(resetPage: true);
                  },
                ),
                _FilterDropdown(
                  label: 'Statut',
                  value: _filterStatus,
                  items: const [
                    'Tous',
                    'Nouveau',
                    'Qualifie',
                    'Entretien planifie',
                    'Offre envoyee',
                    'Embauche',
                    'Refuse',
                  ],
                  onChanged: (value) {
                    _filterStatus = value;
                    _loadCandidates(resetPage: true);
                  },
                ),
                _FilterDropdown(
                  label: 'Etape',
                  value: _filterStage,
                  items: const ['Tous', 'CV', 'Preselection', 'Entretien', 'Offre', 'Embauche'],
                  onChanged: (value) {
                    _filterStage = value;
                    _loadCandidates(resetPage: true);
                  },
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => showOperationNotice(context, message: 'Import CV lance.', success: true),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Importer CV'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openCandidateForm(),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Nouvelle candidature'),
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
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _KanbanColumn(
                  title: 'CV recus',
                  candidates: _stageCandidates('CV'),
                  onOpenCandidate: _openCandidateDetail,
                  onEditCandidate: (candidate) => _openCandidateForm(candidate: candidate),
                  onDeleteCandidate: _confirmDelete,
                  onPlanifier: _planifierEntretien,
                  onEmail: _envoyerEmail,
                  onArchiver: _archiverCandidature,
                ),
                _KanbanColumn(
                  title: 'Preselection',
                  candidates: _stageCandidates('Preselection'),
                  onOpenCandidate: _openCandidateDetail,
                  onEditCandidate: (candidate) => _openCandidateForm(candidate: candidate),
                  onDeleteCandidate: _confirmDelete,
                  onPlanifier: _planifierEntretien,
                  onEmail: _envoyerEmail,
                  onArchiver: _archiverCandidature,
                ),
                _KanbanColumn(
                  title: 'Entretien',
                  candidates: _stageCandidates('Entretien'),
                  onOpenCandidate: _openCandidateDetail,
                  onEditCandidate: (candidate) => _openCandidateForm(candidate: candidate),
                  onDeleteCandidate: _confirmDelete,
                  onPlanifier: _planifierEntretien,
                  onEmail: _envoyerEmail,
                  onArchiver: _archiverCandidature,
                ),
                _KanbanColumn(
                  title: 'Offre',
                  candidates: _stageCandidates('Offre'),
                  onOpenCandidate: _openCandidateDetail,
                  onEditCandidate: (candidate) => _openCandidateForm(candidate: candidate),
                  onDeleteCandidate: _confirmDelete,
                  onPlanifier: _planifierEntretien,
                  onEmail: _envoyerEmail,
                  onArchiver: _archiverCandidature,
                ),
                _KanbanColumn(
                  title: 'Embauche',
                  candidates: _stageCandidates('Embauche'),
                  onOpenCandidate: _openCandidateDetail,
                  onEditCandidate: (candidate) => _openCandidateForm(candidate: candidate),
                  onDeleteCandidate: _confirmDelete,
                  onPlanifier: _planifierEntretien,
                  onEmail: _envoyerEmail,
                  onArchiver: _archiverCandidature,
                ),
              ],
            ),
          const SizedBox(height: 24),
          const SectionHeader(
            title: 'Toutes les candidatures',
            subtitle: 'Tableau global avec pagination.',
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTable(context),
                const SizedBox(height: 12),
                _buildPagination(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            title: 'Postes a pourvoir',
            subtitle: 'Fiches de poste et diffusion.',
          ),
          const SizedBox(height: 12),
          if (_jobOpenings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('Aucun poste actif.', style: TextStyle(color: appTextMuted(context))),
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _jobOpenings
                  .map(
                    (job) => _JobCard(
                      poste: job,
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
    required this.onEditCandidate,
    required this.onDeleteCandidate,
    required this.onPlanifier,
    required this.onEmail,
    required this.onArchiver,
  });

  final String title;
  final List<Recrutement> candidates;
  final ValueChanged<Recrutement> onOpenCandidate;
  final ValueChanged<Recrutement> onEditCandidate;
  final ValueChanged<Recrutement> onDeleteCandidate;
  final ValueChanged<Recrutement> onPlanifier;
  final ValueChanged<Recrutement> onEmail;
  final ValueChanged<Recrutement> onArchiver;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context)),
                  ),
                ),
                _StageBadge(value: '${candidates.length}'),
              ],
            ),
            const SizedBox(height: 8),
            ...candidates.map(
              (candidate) => _CandidateCard(
                candidate: candidate,
                onOpen: () => onOpenCandidate(candidate),
                onEdit: () => onEditCandidate(candidate),
                onDelete: () => onDeleteCandidate(candidate),
                onPlanifier: () => onPlanifier(candidate),
                onEmail: () => onEmail(candidate),
                onArchiver: () => onArchiver(candidate),
              ),
            ),
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
  const _CandidateCard({
    required this.candidate,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    required this.onPlanifier,
    required this.onEmail,
    required this.onArchiver,
  });

  final Recrutement candidate;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPlanifier;
  final VoidCallback onEmail;
  final VoidCallback onArchiver;

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
            candidate.candidatNom,
            style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context)),
          ),
          const SizedBox(height: 4),
          Text(candidate.posteNom, style: TextStyle(color: appTextMuted(context), fontSize: 12)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(candidate.source, style: TextStyle(color: appTextMuted(context), fontSize: 11)),
              ),
              _StatusBadge(label: candidate.status),
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
                onPressed: onPlanifier,
                child: const Text('Planifier'),
              ),
              TextButton(
                onPressed: onEmail,
                child: const Text('Email'),
              ),
              TextButton(
                onPressed: onArchiver,
                child: const Text('Archiver'),
              ),
              TextButton(
                onPressed: onOpen,
                child: const Text('Details'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Spacer(),
              IconButton(
                tooltip: 'Modifier',
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
              ),
              IconButton(
                tooltip: 'Supprimer',
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.poste, required this.onOpen});

  final Poste poste;
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
              poste.title,
              style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context)),
            ),
            const SizedBox(height: 6),
            Text(
              poste.departmentName.isEmpty ? 'Departement non renseigne' : poste.departmentName,
              style: TextStyle(color: appTextMuted(context)),
            ),
            const SizedBox(height: 6),
            Text(
              'Contrat: ${poste.typeContrat.isEmpty ? 'A definir' : poste.typeContrat}',
              style: TextStyle(color: appTextMuted(context), fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              poste.localisation.isEmpty ? 'Localisation a definir' : poste.localisation,
              style: TextStyle(color: appTextMuted(context), fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              poste.salaireRange.isEmpty ? 'Salaire a definir' : poste.salaireRange,
              style: TextStyle(color: appTextPrimary(context), fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(onPressed: onOpen, child: const Text('Voir fiche')),
                const Spacer(),
                IconButton(
                  onPressed: onOpen,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CandidateFormScreen extends StatefulWidget {
  const _CandidateFormScreen({required this.posteOptions, this.candidate});

  final List<_IdLabelOption> posteOptions;
  final Recrutement? candidate;

  @override
  State<_CandidateFormScreen> createState() => _CandidateFormScreenState();
}

class _CandidateFormScreenState extends State<_CandidateFormScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _experienceCtrl;
  late final TextEditingController _salaryCtrl;
  late final TextEditingController _availabilityCtrl;
  late final TextEditingController _interviewCtrl;
  late final TextEditingController _interviewLieuCtrl;
  late final TextEditingController _commentCtrl;
  late final TextEditingController _cvCtrl;
  late final TextEditingController _scoreCtrl;

  String _posteId = '';
  String _stage = 'CV';
  String _status = 'Nouveau';
  String _source = 'LinkedIn';
  String _typeContrat = 'CDI';
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.candidate?.candidatNom ?? '');
    _emailCtrl = TextEditingController(text: widget.candidate?.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.candidate?.telephone ?? '');
    _locationCtrl = TextEditingController(text: widget.candidate?.localisation ?? '');
    _experienceCtrl = TextEditingController(text: widget.candidate?.experience ?? '');
    _salaryCtrl = TextEditingController(text: widget.candidate?.salaireSouhaite ?? '');
    _availabilityCtrl = TextEditingController(text: widget.candidate?.disponibilite ?? '');
    _interviewCtrl = TextEditingController(
      text: widget.candidate?.entretienDate == null
          ? ''
          : _formatDateTime(widget.candidate!.entretienDate!),
    );
    _interviewLieuCtrl = TextEditingController(text: widget.candidate?.entretienLieu ?? '');
    _commentCtrl = TextEditingController(text: widget.candidate?.commentaire ?? '');
    _cvCtrl = TextEditingController(text: widget.candidate?.cvUrl ?? '');
    _scoreCtrl = TextEditingController(text: widget.candidate?.score.toString() ?? '');

    _posteId = widget.candidate?.posteId ?? '';
    _stage = widget.candidate?.stage ?? 'CV';
    _status = widget.candidate?.status ?? 'Nouveau';
    _source = widget.candidate?.source ?? 'LinkedIn';
    _typeContrat = widget.candidate?.typeContrat ?? 'CDI';
    if (_posteId.isEmpty && widget.posteOptions.isNotEmpty) {
      _posteId = widget.posteOptions.first.id;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _experienceCtrl.dispose();
    _salaryCtrl.dispose();
    _availabilityCtrl.dispose();
    _interviewCtrl.dispose();
    _interviewLieuCtrl.dispose();
    _commentCtrl.dispose();
    _cvCtrl.dispose();
    _scoreCtrl.dispose();
    super.dispose();
  }

  String _resolvePosteName(String id) {
    final match = widget.posteOptions.firstWhere(
      (opt) => opt.id == id,
      orElse: () => const _IdLabelOption(id: '', label: ''),
    );
    return match.label.isEmpty ? id : match.label;
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final initial = DateTime.tryParse(controller.text.trim()) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    controller.text = _formatDate(picked);
  }

  Future<void> _pickDateTime(TextEditingController controller) async {
    final initial = _parseDateTime(controller.text.trim()) ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;
    final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    controller.text = _formatDateTime(dateTime);
  }

  bool _validate() {
    if (_nameCtrl.text.trim().isEmpty) {
      _error = 'Nom candidat requis.';
      return false;
    }
    if (_posteId.isEmpty) {
      _error = 'Poste requis.';
      return false;
    }
    return true;
  }

  void _save() {
    setState(() => _error = null);
    if (!_validate()) {
      setState(() {});
      return;
    }

    final score = int.tryParse(_scoreCtrl.text.trim()) ?? 0;
    final interviewDate = _parseDateTime(_interviewCtrl.text.trim());
    final id = widget.candidate?.id ?? 'cand-${DateTime.now().millisecondsSinceEpoch}';

    final candidate = Recrutement(
      id: id,
      candidatNom: _nameCtrl.text.trim(),
      posteId: _posteId,
      posteNom: _resolvePosteName(_posteId),
      status: _status,
      stage: _stage,
      source: _source,
      score: score,
      typeContrat: _typeContrat,
      email: _emailCtrl.text.trim(),
      telephone: _phoneCtrl.text.trim(),
      localisation: _locationCtrl.text.trim(),
      experience: _experienceCtrl.text.trim(),
      salaireSouhaite: _salaryCtrl.text.trim(),
      disponibilite: _availabilityCtrl.text.trim(),
      entretienDate: interviewDate,
      entretienLieu: _interviewLieuCtrl.text.trim(),
      commentaire: _commentCtrl.text.trim(),
      cvUrl: _cvCtrl.text.trim(),
    );

    Navigator.of(context).pop(candidate);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.candidate != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier candidature' : 'Nouvelle candidature'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            AppCard(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _FormField(controller: _nameCtrl, label: 'Nom candidat *'),
                  _PosteSelectField(
                    label: 'Poste *',
                    value: _posteId,
                    options: widget.posteOptions,
                    onChanged: (value) => setState(() => _posteId = value),
                  ),
                  _FormDropdown(
                    label: 'Etape *',
                    value: _stage,
                    items: const ['CV', 'Preselection', 'Entretien', 'Offre', 'Embauche'],
                    onChanged: (value) => setState(() => _stage = value),
                  ),
                  _FormDropdown(
                    label: 'Statut *',
                    value: _status,
                    items: const [
                      'Nouveau',
                      'Qualifie',
                      'Entretien planifie',
                      'Offre envoyee',
                      'Embauche',
                      'Refuse',
                    ],
                    onChanged: (value) => setState(() => _status = value),
                  ),
                  _FormDropdown(
                    label: 'Source *',
                    value: _source,
                    items: const ['LinkedIn', 'Site emploi', 'Cooptation', 'Cabinet', 'Autre'],
                    onChanged: (value) => setState(() => _source = value),
                  ),
                  _FormDropdown(
                    label: 'Type contrat',
                    value: _typeContrat,
                    items: const ['CDI', 'CDD', 'Stage', 'Freelance'],
                    onChanged: (value) => setState(() => _typeContrat = value),
                  ),
                  _FormField(controller: _scoreCtrl, label: 'Score (0-100)'),
                  _FormField(controller: _emailCtrl, label: 'Email'),
                  _FormField(controller: _phoneCtrl, label: 'Telephone'),
                  _FormField(controller: _locationCtrl, label: 'Localisation'),
                  _FormField(controller: _experienceCtrl, label: 'Experience'),
                  _FormField(controller: _salaryCtrl, label: 'Salaire souhaite'),
                  _FormField(controller: _availabilityCtrl, label: 'Disponibilite'),
                  _FormField(
                    controller: _interviewCtrl,
                    label: 'Date entretien',
                    readOnly: true,
                    onTap: () => _pickDateTime(_interviewCtrl),
                    suffixIcon: const Icon(Icons.date_range),
                  ),
                  _FormField(controller: _interviewLieuCtrl, label: 'Lieu entretien'),
                  _FormField(controller: _cvCtrl, label: 'Lien CV'),
                  _FormField(controller: _commentCtrl, label: 'Commentaire'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(isEditing ? 'Mettre a jour' : 'Enregistrer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CandidateDetailScreen extends StatelessWidget {
  const _CandidateDetailScreen({required this.candidate, required this.onEdit});

  final Recrutement candidate;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Candidature - ${candidate.candidatNom}'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
              onEdit();
            },
            icon: const Icon(Icons.edit_outlined),
          ),
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
            SectionHeader(
              title: candidate.candidatNom,
              subtitle: candidate.posteNom.isEmpty ? 'Poste a definir' : candidate.posteNom,
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'Poste', value: _display(candidate.posteNom)),
                  _InfoRow(label: 'Etape', value: _display(candidate.stage)),
                  _InfoRow(label: 'Statut', value: _display(candidate.status)),
                  _InfoRow(label: 'Source', value: _display(candidate.source)),
                  _InfoRow(label: 'Type contrat', value: _display(candidate.typeContrat)),
                  _InfoRow(label: 'Score', value: '${candidate.score}%'),
                  _InfoRow(label: 'Email', value: _display(candidate.email)),
                  _InfoRow(label: 'Telephone', value: _display(candidate.telephone)),
                  _InfoRow(label: 'Localisation', value: _display(candidate.localisation)),
                  _InfoRow(label: 'Experience', value: _display(candidate.experience)),
                  _InfoRow(label: 'Salaire souhaite', value: _display(candidate.salaireSouhaite)),
                  _InfoRow(label: 'Disponibilite', value: _display(candidate.disponibilite)),
                  _InfoRow(
                    label: 'Date entretien',
                    value: candidate.entretienDate == null ? 'A definir' : _formatDateTime(candidate.entretienDate!),
                  ),
                  _InfoRow(label: 'Lieu entretien', value: _display(candidate.entretienLieu)),
                  _InfoRow(label: 'Lien CV', value: _display(candidate.cvUrl)),
                  _InfoRow(label: 'Commentaire', value: _display(candidate.commentaire)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(labelText: label, suffixIcon: suffixIcon),
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
      width: 240,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            )
            .toList(),
        onChanged: (value) => onChanged(value ?? items.first),
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
                child: Text(
                  item,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            )
            .toList(),
        onChanged: (value) => onChanged(value ?? 'Tous'),
      ),
    );
  }
}

class _PosteDropdown extends StatelessWidget {
  const _PosteDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<_IdLabelOption> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final entries = [const _IdLabelOption(id: '', label: 'Tous'), ...options];
    return SizedBox(
      width: 200,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: entries
            .map(
              (option) => DropdownMenuItem(
                value: option.id,
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            )
            .toList(),
        onChanged: (value) => onChanged(value ?? ''),
      ),
    );
  }
}

class _PosteSelectField extends StatelessWidget {
  const _PosteSelectField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<_IdLabelOption> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return _FormField(controller: TextEditingController(text: value), label: label);
    }
    final normalized = options.any((opt) => opt.id == value) || value.isEmpty
        ? options
        : [_IdLabelOption(id: value, label: value), ...options];
    final selected = value.isEmpty ? normalized.first.id : value;
    return SizedBox(
      width: 240,
      child: DropdownButtonFormField<String>(
        value: selected,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: normalized
            .map(
              (opt) => DropdownMenuItem(
                value: opt.id,
                child: Text(
                  opt.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            )
            .toList(),
        onChanged: (value) => onChanged(value ?? ''),
      ),
    );
  }
}

class _StageBadge extends StatelessWidget {
  const _StageBadge({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(value, style: const TextStyle(fontSize: 11, color: AppColors.primary)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label.isEmpty ? 'A definir' : label,
        style: const TextStyle(fontSize: 10, color: AppColors.primary),
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

class _IdLabelOption {
  const _IdLabelOption({required this.id, required this.label});

  final String id;
  final String label;
}

String _formatDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _formatDateTime(DateTime date) {
  final datePart = _formatDate(date);
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$datePart $hour:$minute';
}

DateTime? _parseDateTime(String input) {
  if (input.trim().isEmpty) return null;
  final normalized = input.trim();
  if (normalized.contains(' ')) {
    final parts = normalized.split(' ');
    if (parts.length >= 2) {
      final date = DateTime.tryParse(parts[0]);
      if (date == null) return null;
      final timeParts = parts[1].split(':');
      if (timeParts.length < 2) return date;
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;
      return DateTime(date.year, date.month, date.day, hour, minute);
    }
  }
  return DateTime.tryParse(normalized);
}

String _display(String value) {
  return value.isEmpty ? 'A definir' : value;
}

String _appendComment(String existing, String entry) {
  final stamp = _formatDate(DateTime.now());
  if (existing.trim().isEmpty) return '$stamp - $entry';
  return '$existing\n$stamp - $entry';
}

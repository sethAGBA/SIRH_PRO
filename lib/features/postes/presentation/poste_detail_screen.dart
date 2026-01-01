import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/dao/dao_registry.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../shared/models/poste.dart';
import 'postes_form_screen.dart';

class PosteDetailScreen extends StatefulWidget {
  const PosteDetailScreen({
    super.key,
    required this.poste,
    required this.departmentOptions,
  });

  final Poste poste;
  final List<DepartmentOption> departmentOptions;

  @override
  State<PosteDetailScreen> createState() => _PosteDetailScreenState();
}

class _PosteDetailScreenState extends State<PosteDetailScreen> {
  late Poste _poste;

  @override
  void initState() {
    super.initState();
    _poste = widget.poste;
  }

  Future<void> _editPoste() async {
    final updated = await showDialog<Poste>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: PostesFormScreen(
          poste: _poste,
          departmentOptions: widget.departmentOptions,
        ),
      ),
    );
    if (updated == null) return;
    await DaoRegistry.instance.postes.update(
      updated.id,
      _posteToRow(updated, forInsert: false),
    );
    if (!mounted) return;
    setState(() => _poste = updated);
  }

  Map<String, dynamic> _posteToRow(Poste poste, {required bool forInsert}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final data = <String, dynamic>{
      'code': poste.code,
      'intitule': poste.title,
      'description': poste.description,
      'departement_id': poste.departmentId,
      'departement_nom': poste.departmentName,
      'niveau': poste.level,
      'type_contrat': poste.typeContrat,
      'localisation': poste.localisation,
      'salaire_range': poste.salaireRange,
      'missions': poste.missions,
      'responsabilites': poste.responsabilites,
      'liens_hierarchiques': poste.liensHierarchiques,
      'formation': poste.formation,
      'experience': poste.experience,
      'competences_tech': poste.competencesTech,
      'competences_comport': poste.competencesComport,
      'langues': poste.langues,
      'duree_cdd': poste.dureeCdd,
      'avantages': poste.avantages,
      'date_prise_poste': poste.datePrisePoste,
      'sites_emploi': poste.sitesEmploi,
      'reseaux_sociaux': poste.reseauxSociaux,
      'cooptation_interne': poste.cooptationInterne,
      'cabinets': poste.cabinets,
      'statut': poste.status,
      'deleted_at': poste.deletedAt,
      'updated_at': now,
    };
    if (forInsert) {
      data['id'] = poste.id;
      data['created_at'] = now;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_poste.title),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _editPoste,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Modifier poste',
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
            const SectionHeader(
              title: 'Fiche poste',
              subtitle: 'Informations principales et rattachement.',
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Identite',
              rows: [
                _InfoRow(label: 'Code', value: _display(_poste.code)),
                _InfoRow(label: 'Intitule', value: _display(_poste.title)),
                _InfoRow(label: 'Niveau', value: _display(_poste.level)),
                _InfoRow(label: 'Statut', value: _display(_poste.deletedAt != null ? 'Archive' : _poste.status)),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Rattachement',
              rows: [
                _InfoRow(label: 'Departement', value: _display(_poste.departmentName)),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Description',
              rows: [
                _InfoRow(label: 'Description', value: _display(_poste.description)),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Missions',
              rows: [
                _InfoRow(label: 'Missions principales', value: _display(_poste.missions)),
                _InfoRow(label: 'Responsabilites', value: _display(_poste.responsabilites)),
                _InfoRow(label: 'Liens hierarchiques', value: _display(_poste.liensHierarchiques)),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Profil recherche',
              rows: [
                _InfoRow(label: 'Formation', value: _display(_poste.formation)),
                _InfoRow(label: 'Experience', value: _display(_poste.experience)),
                _InfoRow(label: 'Competences techniques', value: _display(_poste.competencesTech)),
                _InfoRow(label: 'Competences comportementales', value: _display(_poste.competencesComport)),
                _InfoRow(label: 'Langues', value: _display(_poste.langues)),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Conditions',
              rows: [
                _InfoRow(label: 'Type contrat', value: _display(_poste.typeContrat)),
                _InfoRow(label: 'Duree CDD', value: _display(_poste.dureeCdd)),
                _InfoRow(label: 'Fourchette salariale', value: _display(_poste.salaireRange)),
                _InfoRow(label: 'Avantages', value: _display(_poste.avantages)),
                _InfoRow(label: 'Date prise de poste', value: _display(_poste.datePrisePoste)),
                _InfoRow(label: 'Localisation', value: _display(_poste.localisation)),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Diffusion',
              rows: [
                _InfoRow(label: 'Sites emploi', value: _display(_poste.sitesEmploi)),
                _InfoRow(label: 'Reseaux sociaux', value: _display(_poste.reseauxSociaux)),
                _InfoRow(label: 'Cooptation interne', value: _display(_poste.cooptationInterne)),
                _InfoRow(label: 'Cabinets', value: _display(_poste.cabinets)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.rows});

  final String title;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: appTextPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          ...rows,
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

String _display(String value) {
  return value.isEmpty ? 'A definir' : value;
}

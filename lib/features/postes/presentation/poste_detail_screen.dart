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

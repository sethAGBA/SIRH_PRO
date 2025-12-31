import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../shared/models/departement.dart';

class DepartmentDetailScreen extends StatelessWidget {
  const DepartmentDetailScreen({super.key, required this.departement});

  final Departement departement;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(departement.name),
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
              Tab(text: 'Equipe & effectifs'),
              Tab(text: 'Performance'),
              Tab(text: 'Masse salariale'),
              Tab(text: 'Objectifs & projets'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _EquipeTab(departement: departement),
            _PerformanceTab(departement: departement),
            _MasseSalarialeTab(departement: departement),
            _ObjectifsTab(departement: departement),
          ],
        ),
      ),
    );
  }
}

class _EquipeTab extends StatelessWidget {
  const _EquipeTab({required this.departement});

  final Departement departement;

  @override
  Widget build(BuildContext context) {
    return _SectionedTab(
      title: 'Equipe & effectifs',
      subtitle: 'Liste des employes, managers et repartition des postes.',
      sections: [
        _SectionContent(
          title: 'Managers et responsables',
          rows: [
            _FieldRow(label: 'Manager', value: departement.manager),
            const _FieldRow(label: 'Responsables', value: 'A definir'),
          ],
        ),
        _SectionContent(
          title: 'Repartition par poste',
          rows: const [
            _FieldRow(label: 'Cadres', value: '8'),
            _FieldRow(label: 'Techniciens', value: '12'),
            _FieldRow(label: 'Support', value: '6'),
          ],
        ),
        _SectionContent(
          title: 'Evolution effectifs',
          rows: const [
            _FieldRow(label: 'Effectif actuel', value: '26'),
            _FieldRow(label: 'Variation annuelle', value: '+3'),
          ],
        ),
      ],
    );
  }
}

class _PerformanceTab extends StatelessWidget {
  const _PerformanceTab({required this.departement});

  final Departement departement;

  @override
  Widget build(BuildContext context) {
    return _SectionedTab(
      title: 'Indicateurs de performance',
      subtitle: 'Absenteisme, productivite, satisfaction, turn-over.',
      sections: const [
        _SectionContent(
          title: 'Indicateurs clefs',
          rows: [
            _FieldRow(label: 'Taux absenteisme', value: '3.1%'),
            _FieldRow(label: 'Productivite moyenne', value: '82%'),
            _FieldRow(label: 'Satisfaction equipe', value: '4.1/5'),
            _FieldRow(label: 'Turn-over departement', value: '6%'),
            _FieldRow(label: 'Budget vs realise', value: '92%'),
          ],
        ),
      ],
    );
  }
}

class _MasseSalarialeTab extends StatelessWidget {
  const _MasseSalarialeTab({required this.departement});

  final Departement departement;

  @override
  Widget build(BuildContext context) {
    return _SectionedTab(
      title: 'Masse salariale',
      subtitle: 'Budget, salaires, primes et charges.',
      sections: [
        _SectionContent(
          title: 'Budget et charges',
          rows: [
            _FieldRow(label: 'Budget alloue', value: departement.budget),
            const _FieldRow(label: 'Salaires totaux', value: 'FCFA 320M'),
            const _FieldRow(label: 'Primes et variables', value: 'FCFA 28M'),
            const _FieldRow(label: 'Charges sociales', value: 'FCFA 46M'),
            const _FieldRow(label: 'Cout moyen employe', value: 'FCFA 12M'),
          ],
        ),
      ],
    );
  }
}

class _ObjectifsTab extends StatelessWidget {
  const _ObjectifsTab({required this.departement});

  final Departement departement;

  @override
  Widget build(BuildContext context) {
    return _SectionedTab(
      title: 'Objectifs & projets',
      subtitle: 'Objectifs trimestriels et projets en cours.',
      sections: const [
        _SectionContent(
          title: 'Objectifs trimestriels',
          rows: [
            _FieldRow(label: 'Objectif principal', value: 'Renforcer la retention'),
            _FieldRow(label: 'Indicateur', value: 'Turn-over < 5%'),
          ],
        ),
        _SectionContent(
          title: 'Projets en cours',
          rows: [
            _FieldRow(label: 'Projet', value: 'Digitalisation RH'),
            _FieldRow(label: 'Ressources necessaires', value: '2 recrues'),
          ],
        ),
      ],
    );
  }
}

class _SectionedTab extends StatelessWidget {
  const _SectionedTab({
    required this.title,
    required this.subtitle,
    required this.sections,
  });

  final String title;
  final String subtitle;
  final List<_SectionContent> sections;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, subtitle: subtitle),
          const SizedBox(height: 16),
          ...sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _SectionCard(section: section),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final _SectionContent section;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: appTextPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          ...section.rows.map(
            (row) => _InfoRow(label: row.label, value: row.value),
          ),
        ],
      ),
    );
  }
}

class _SectionContent {
  const _SectionContent({required this.title, required this.rows});

  final String title;
  final List<_FieldRow> rows;
}

class _FieldRow {
  const _FieldRow({required this.label, required this.value});

  final String label;
  final String value;
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

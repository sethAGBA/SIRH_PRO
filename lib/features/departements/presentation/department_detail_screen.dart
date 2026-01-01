import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/dao/dao_registry.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../shared/models/employe.dart';
import '../../../shared/models/departement.dart';
import '../../employes/presentation/employee_detail_screen.dart';
import 'department_form_screen.dart';

class DepartmentDetailScreen extends StatefulWidget {
  const DepartmentDetailScreen({super.key, required this.departement});

  final Departement departement;

  @override
  State<DepartmentDetailScreen> createState() => _DepartmentDetailScreenState();
}

class _DepartmentDetailScreenState extends State<DepartmentDetailScreen> {
  late Departement _departement;

  @override
  void initState() {
    super.initState();
    _departement = widget.departement;
  }

  Map<String, dynamic> _departmentToRow(Departement departement, {required bool forInsert}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final parsedBudget = _parseBudgetValue(departement.budget);
    final data = <String, dynamic>{
      'nom': departement.name,
      'manager_id': departement.managerId,
      'manager_nom': departement.manager,
      'effectif': departement.headcount,
      'budget_masse_salariale': parsedBudget,
      'budget_affiche': departement.budget,
      'pole': departement.pole,
      'taille': departement.size,
      'localisation': departement.location,
      'code': departement.code,
      'description': departement.description,
      'email': departement.email,
      'telephone': departement.phone,
      'extension': departement.extension,
      'adresse': departement.adresse,
      'parent_departement': departement.parentDepartement,
      'parent_departement_id': departement.parentDepartementId,
      'parent_departement_nom': departement.parentDepartement,
      'date_creation': departement.dateCreation,
      'notes': departement.notes,
      'responsables': departement.responsables,
      'cadres_count': departement.cadresCount,
      'techniciens_count': departement.techniciensCount,
      'support_count': departement.supportCount,
      'variation_annuelle': departement.variationAnnuelle,
      'taux_absenteisme': departement.tauxAbsenteisme,
      'productivite_moyenne': departement.productiviteMoyenne,
      'satisfaction_equipe': departement.satisfactionEquipe,
      'turnover_departement': departement.turnoverDepartement,
      'budget_vs_realise': departement.budgetVsRealise,
      'salaires_totaux': departement.salairesTotaux,
      'primes_variables': departement.primesVariables,
      'charges_sociales': departement.chargesSociales,
      'cout_moyen_employe': departement.coutMoyenEmploye,
      'objectif_principal': departement.objectifPrincipal,
      'indicateur_objectif': departement.indicateurObjectif,
      'projet_en_cours': departement.projetEnCours,
      'ressources_necessaires': departement.ressourcesNecessaires,
      'statut': departement.status,
      'deleted_at': departement.deletedAt,
      'updated_at': now,
    };

    if (forInsert) {
      data['id'] = departement.id;
      data['created_at'] = now;
    }

    return data;
  }

  double? _parseBudgetValue(String input) {
    final normalized = input.replaceAll(RegExp(r'[^0-9.,]'), '').replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  Future<void> _editDepartment() async {
    final updated = await showDialog<Departement>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: DepartmentFormScreen(departement: _departement),
      ),
    );

    if (updated == null) return;
    await DaoRegistry.instance.departements.update(
      updated.id,
      _departmentToRow(updated, forInsert: false),
    );
    if (!mounted) return;
    setState(() => _departement = updated);
  }

  Future<void> _openManagerDetail() async {
    final managerId = _departement.managerId;
    if (managerId.isEmpty) {
      _showMessage('Aucun manager associe.');
      return;
    }
    final row = await DaoRegistry.instance.employes.getById(managerId);
    if (row == null) {
      _showMessage('Manager introuvable.');
      return;
    }
    final employe = _employeeFromRow(row);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: EmployeeDetailScreen(employe: employe),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Employe _employeeFromRow(Map<String, dynamic> row) {
    final hireMillis = row['date_embauche'] as int?;
    final hireDate = hireMillis == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(hireMillis);
    return Employe(
      id: (row['id'] as String?) ?? '',
      matricule: (row['matricule'] as String?) ?? '',
      fullName: (row['nom_complet'] as String?) ?? '',
      department: (row['departement_id'] as String?) ?? '',
      role: (row['poste_id'] as String?) ?? '',
      contractType: (row['contract_type'] as String?) ?? '',
      contractStatus: (row['statut_contrat'] as String?) ?? '',
      tenure: (row['tenure'] as String?) ?? '',
      phone: (row['telephone'] as String?) ?? '',
      email: (row['email'] as String?) ?? '',
      skills: _splitList(row['skills'] as String?),
      hireDate: hireDate,
      status: (row['statut_employe'] as String?) ?? '',
      dateNaissance: (row['date_naissance'] as String?) ?? '',
      lieuNaissance: (row['lieu_naissance'] as String?) ?? '',
      nationalite: (row['nationalite'] as String?) ?? '',
      etatCivilDetaille: (row['etat_civil_detaille'] as String?) ?? '',
      nir: (row['nir'] as String?) ?? '',
      situationFamiliale: (row['situation_familiale'] as String?) ?? '',
      adresse: (row['adresse'] as String?) ?? '',
      contactUrgence: (row['contact_urgence'] as String?) ?? '',
      cni: (row['cni'] as String?) ?? '',
      passeport: (row['passeport'] as String?) ?? '',
      permis: (row['permis'] as String?) ?? '',
      titreSejour: (row['titre_sejour'] as String?) ?? '',
      rib: (row['rib'] as String?) ?? '',
      bic: (row['bic'] as String?) ?? '',
      salaireVerse: (row['salaire_verse'] as String?) ?? '',
      posteActuel: (row['poste_actuel'] as String?) ?? '',
      postePrecedent: (row['poste_precedent'] as String?) ?? '',
      dernierePromotion: (row['derniere_promotion'] as String?) ?? '',
      augmentation: (row['augmentation'] as String?) ?? '',
      objectifs: (row['objectifs'] as String?) ?? '',
      evaluation: (row['evaluation'] as String?) ?? '',
      contractStartDate: (row['contract_start_date'] as String?) ?? '',
      contractEndDate: (row['contract_end_date'] as String?) ?? '',
      periodeEssaiDuree: (row['periode_essai_duree'] as String?) ?? '',
      periodeEssaiFin: (row['periode_essai_fin'] as String?) ?? '',
      tempsTravailType: (row['temps_travail_type'] as String?) ?? '',
      tempsPartielPourcentage: (row['temps_partiel_pourcentage'] as String?) ?? '',
      classification: (row['classification'] as String?) ?? '',
      coefficient: (row['coefficient'] as String?) ?? '',
      conventionCollective: (row['convention_collective'] as String?) ?? '',
      statutCadre: (row['statut_cadre'] as String?) ?? '',
      avenants: (row['avenants'] as String?) ?? '',
      charteInformatique: (row['charte_informatique'] as String?) ?? '',
      confidentialite: (row['confidentialite'] as String?) ?? '',
      clausesSignees: (row['clauses_signees'] as String?) ?? '',
      carteVitale: (row['carte_vitale'] as String?) ?? '',
      justificatifDomicile: (row['justificatif_domicile'] as String?) ?? '',
      diplomesCertifies: (row['diplomes_certifies'] as String?) ?? '',
      habilitations: (row['habilitations'] as String?) ?? '',
      diplome: (row['diplome'] as String?) ?? '',
      certification: (row['certification'] as String?) ?? '',
      formationsSuivies: _splitList(row['formations_suivies'] as String?),
      formationsPlanifiees: _splitList(row['formations_planifiees'] as String?),
      competencesTech: (row['competences_tech'] as String?) ?? '',
      competencesComport: (row['competences_comport'] as String?) ?? '',
      langues: (row['langues'] as String?) ?? '',
      congesRestants: (row['conges_restants'] as String?) ?? '',
      rttRestants: (row['rtt_restants'] as String?) ?? '',
      absencesJustifiees: (row['absences_justifiees'] as String?) ?? '',
      retards: (row['retards'] as String?) ?? '',
      teletravail: (row['teletravail'] as String?) ?? '',
      dernierPointage: (row['dernier_pointage'] as String?) ?? '',
      planningContractuel: (row['planning_contractuel'] as String?) ?? '',
      quotaHeures: (row['quota_heures'] as String?) ?? '',
      soldeCongesCalcule: (row['solde_conges_calcule'] as String?) ?? '',
      rttPeriode: (row['rtt_periode'] as String?) ?? '',
      salaireBase: (row['salaire_base'] as String?) ?? '',
      primePerformance: (row['prime_performance'] as String?) ?? '',
      mutuelle: (row['mutuelle'] as String?) ?? '',
      ticketRestaurant: (row['ticket_restaurant'] as String?) ?? '',
      dernierBulletin: (row['dernier_bulletin'] as String?) ?? '',
      historiqueBulletins: (row['historique_bulletins'] as String?) ?? '',
      regimeFiscal: (row['regime_fiscal'] as String?) ?? '',
      tauxPas: (row['taux_pas'] as String?) ?? '',
      modePaiement: (row['mode_paiement'] as String?) ?? '',
      variablesRecurrence: (row['variables_recurrence'] as String?) ?? '',
      pcPortable: (row['pc_portable'] as String?) ?? '',
      telephonePro: (row['telephone_pro'] as String?) ?? '',
      badgeAcces: (row['badge_acces'] as String?) ?? '',
      licence: (row['licence'] as String?) ?? '',
      manager: (row['manager'] as String?) ?? '',
      entiteLegale: (row['entite_legale'] as String?) ?? '',
      siteAffectation: (row['site_affectation'] as String?) ?? '',
      centreCout: (row['centre_cout'] as String?) ?? '',
      consentementRgpd: (row['consentement_rgpd'] as String?) ?? '',
      habilitationsSystemes: (row['habilitations_systemes'] as String?) ?? '',
      historiqueModifications: (row['historique_modifications'] as String?) ?? '',
      visitesMedicales: (row['visites_medicales'] as String?) ?? '',
      aptitudeMedicale: (row['aptitude_medicale'] as String?) ?? '',
      restrictionsPoste: (row['restrictions_poste'] as String?) ?? '',
    );
  }

  List<String> _splitList(String? value) {
    if (value == null || value.trim().isEmpty) return [];
    return value.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_departement.name),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: _editDepartment,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Modifier departement',
            ),
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
            _EquipeTab(
              departement: _departement,
              onManagerTap: _openManagerDetail,
            ),
            _PerformanceTab(departement: _departement),
            _MasseSalarialeTab(departement: _departement),
            _ObjectifsTab(departement: _departement),
          ],
        ),
      ),
    );
  }
}

class _EquipeTab extends StatelessWidget {
  const _EquipeTab({required this.departement, required this.onManagerTap});

  final Departement departement;
  final VoidCallback onManagerTap;

  @override
  Widget build(BuildContext context) {
    return _SectionedTab(
      title: 'Equipe & effectifs',
      subtitle: 'Liste des employes, managers et repartition des postes.',
      sections: [
        _SectionContent(
          title: 'Managers et responsables',
          rows: [
            _FieldRow(label: 'Code', value: _display(departement.code)),
            _FieldRow(label: 'Description', value: _display(departement.description)),
            _ClickableRow(
              label: 'Manager',
              value: _display(departement.manager),
              enabled: departement.managerId.isNotEmpty,
              onTap: onManagerTap,
            ),
            _FieldRow(label: 'Responsables', value: _display(departement.responsables)),
          ],
        ),
        _SectionContent(
          title: 'Contact & localisation',
          rows: [
            _FieldRow(label: 'Email', value: _display(departement.email)),
            _FieldRow(label: 'Telephone', value: _display(departement.phone)),
            _FieldRow(label: 'Extension', value: _display(departement.extension)),
            _FieldRow(label: 'Adresse', value: _display(departement.adresse)),
            _FieldRow(label: 'Departement parent', value: _display(departement.parentDepartement)),
            _FieldRow(label: 'Date creation', value: _display(departement.dateCreation)),
          ],
        ),
        _SectionContent(
          title: 'Repartition par poste',
          rows: [
            _FieldRow(label: 'Cadres', value: _display(departement.cadresCount)),
            _FieldRow(label: 'Techniciens', value: _display(departement.techniciensCount)),
            _FieldRow(label: 'Support', value: _display(departement.supportCount)),
          ],
        ),
        _SectionContent(
          title: 'Evolution effectifs',
          rows: [
            _FieldRow(label: 'Effectif actuel', value: _intDisplay(departement.headcount)),
            _FieldRow(label: 'Variation annuelle', value: _display(departement.variationAnnuelle)),
          ],
        ),
        _SectionContent(
          title: 'Notes',
          rows: [
            _FieldRow(label: 'Notes', value: _display(departement.notes)),
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
      sections: [
        _SectionContent(
          title: 'Indicateurs clefs',
          rows: [
            _FieldRow(label: 'Taux absenteisme', value: _display(departement.tauxAbsenteisme)),
            _FieldRow(label: 'Productivite moyenne', value: _display(departement.productiviteMoyenne)),
            _FieldRow(label: 'Satisfaction equipe', value: _display(departement.satisfactionEquipe)),
            _FieldRow(label: 'Turn-over departement', value: _display(departement.turnoverDepartement)),
            _FieldRow(label: 'Budget vs realise', value: _display(departement.budgetVsRealise)),
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
            _FieldRow(label: 'Budget alloue', value: _display(departement.budget)),
            _FieldRow(label: 'Salaires totaux', value: _display(departement.salairesTotaux)),
            _FieldRow(label: 'Primes et variables', value: _display(departement.primesVariables)),
            _FieldRow(label: 'Charges sociales', value: _display(departement.chargesSociales)),
            _FieldRow(label: 'Cout moyen employe', value: _display(departement.coutMoyenEmploye)),
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
      sections: [
        _SectionContent(
          title: 'Objectifs trimestriels',
          rows: [
            _FieldRow(label: 'Objectif principal', value: _display(departement.objectifPrincipal)),
            _FieldRow(label: 'Indicateur', value: _display(departement.indicateurObjectif)),
          ],
        ),
        _SectionContent(
          title: 'Projets en cours',
          rows: [
            _FieldRow(label: 'Projet', value: _display(departement.projetEnCours)),
            _FieldRow(label: 'Ressources necessaires', value: _display(departement.ressourcesNecessaires)),
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
          ...section.rows,
        ],
      ),
    );
  }
}

class _SectionContent {
  const _SectionContent({required this.title, required this.rows});

  final String title;
  final List<Widget> rows;
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _InfoRow(label: label, value: value);
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

class _ClickableRow extends StatelessWidget {
  const _ClickableRow({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final muted = appTextMuted(context);
    final primary = appTextPrimary(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: muted),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: enabled ? onTap : null,
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: enabled ? AppColors.primary : primary,
                  decoration: enabled ? TextDecoration.underline : TextDecoration.none,
                ),
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

String _intDisplay(int value) {
  return value == 0 ? 'A definir' : value.toString();
}

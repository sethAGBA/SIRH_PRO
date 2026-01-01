import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/dao/dao_registry.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/operation_notice.dart';
import '../../../core/widgets/section_header.dart';
import '../../../shared/models/employe.dart';
import 'employee_detail_screen.dart';

class EmployesScreen extends StatefulWidget {
  const EmployesScreen({super.key});

  @override
  State<EmployesScreen> createState() => _EmployesScreenState();
}

class _EmployesScreenState extends State<EmployesScreen> {
  final List<Employe> _employees = [];

  final Set<String> _selectedIds = {};
  bool _loading = true;
  List<_IdLabelOption> _departmentOptions = [];
  List<_IdLabelOption> _roleOptions = [];
  List<_IdLabelOption> _roleOptionsActive = [];
  Map<String, String> _departmentLabelsById = {};
  Map<String, String> _roleLabelsById = {};
  Map<String, String> _departmentIdsByLabel = {};
  Map<String, String> _roleIdsByLabel = {};
  int _page = 0;
  final int _pageSize = 20;
  int _totalEmployees = 0;

  String _filterDepartment = '';
  String _filterRole = '';
  String _filterContract = 'Tous';
  String _filterStatus = 'Tous';
  String _filterHireDate = '';

  String _searchName = '';
  String _searchMatricule = '';
  String _searchPhone = '';
  String _searchEmail = '';
  String _searchSkills = '';

  @override
  void initState() {
    super.initState();
    _loadFilterOptions();
    _loadEmployees();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFilterOptions();
  }

  Future<void> _loadFilterOptions() async {
    final departmentRows = await DaoRegistry.instance.departements.list(orderBy: 'nom ASC');
    final roleRows = await DaoRegistry.instance.postes.list(orderBy: 'intitule ASC');
    final departments = departmentRows
        .map(
          (row) => _IdLabelOption(
            id: (row['id'] as String?) ?? '',
            label: (row['nom'] as String?) ?? '',
          ),
        )
        .where((opt) => opt.id.isNotEmpty && opt.label.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => a.label.compareTo(b.label));
    final roles = roleRows
        .map(
          (row) => _IdLabelOption(
            id: (row['id'] as String?) ?? '',
            label: (row['intitule'] as String?) ?? '',
          ),
        )
        .where((opt) => opt.id.isNotEmpty && opt.label.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => a.label.compareTo(b.label));
    final activeRoles = roleRows
        .where((row) {
          final deleted = row['deleted_at'] as int?;
          final status = (row['statut'] as String?) ?? 'Actif';
          return deleted == null && status == 'Actif';
        })
        .map(
          (row) => _IdLabelOption(
            id: (row['id'] as String?) ?? '',
            label: (row['intitule'] as String?) ?? '',
          ),
        )
        .where((opt) => opt.id.isNotEmpty && opt.label.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => a.label.compareTo(b.label));

    if (!mounted) return;
    setState(() {
      _departmentOptions = departments;
      _roleOptions = roles;
      _roleOptionsActive = activeRoles;
      _departmentLabelsById = {for (final opt in departments) opt.id: opt.label};
      _roleLabelsById = {for (final opt in roles) opt.id: opt.label};
      _departmentIdsByLabel = {for (final opt in departments) opt.label: opt.id};
      _roleIdsByLabel = {for (final opt in roles) opt.label: opt.id};
      if (_filterDepartment.isNotEmpty && !_departmentLabelsById.containsKey(_filterDepartment)) {
        _filterDepartment = '';
      }
      if (_filterRole.isNotEmpty && !_roleLabelsById.containsKey(_filterRole)) {
        _filterRole = '';
      }
    });
  }

  Future<void> _loadEmployees({bool resetPage = false}) async {
    if (resetPage) _page = 0;
    setState(() => _loading = true);

    final range = _parseHireDateRange(_filterHireDate);
    final department = _filterDepartment.isEmpty ? null : _filterDepartment;
    final role = _filterRole.isEmpty ? null : _filterRole;
    final contractType = _filterContract == 'Tous' ? null : _filterContract;
    final status = _filterStatus == 'Tous' ? null : _filterStatus;

    final total = await DaoRegistry.instance.employes.count(
      department: department,
      role: role,
      contractType: contractType,
      status: status,
      hireDateStart: range?.start,
      hireDateEnd: range?.end,
      name: _searchName,
      matricule: _searchMatricule,
      phone: _searchPhone,
      email: _searchEmail,
      skills: _searchSkills,
    );

    if (!mounted) return;
    if (total == 0) {
      await _loadFilterOptions();
      setState(() {
        _employees.clear();
        _totalEmployees = 0;
        _selectedIds.clear();
        _loading = false;
      });
      return;
    }

    final maxPage = (total - 1) ~/ _pageSize;
    final effectivePage = _page > maxPage ? maxPage : _page;
    final offset = effectivePage * _pageSize;
    final rows = await DaoRegistry.instance.employes.search(
      department: department,
      role: role,
      contractType: contractType,
      status: status,
      hireDateStart: range?.start,
      hireDateEnd: range?.end,
      name: _searchName,
      matricule: _searchMatricule,
      phone: _searchPhone,
      email: _searchEmail,
      skills: _searchSkills,
      orderBy: 'created_at DESC',
      limit: _pageSize,
      offset: offset,
    );

    if (!mounted) return;
    final employees = rows.map(_employeeFromRow).toList();
    await _loadFilterOptions();
    final normalization = _normalizeEmployeeRefs(employees);
    if (normalization.updated.isNotEmpty) {
      for (final updated in normalization.updated) {
        await DaoRegistry.instance.employes.update(updated.id, _employeeToRow(updated, forInsert: false));
      }
    }
    setState(() {
      _page = effectivePage;
      _totalEmployees = total;
      _employees
        ..clear()
        ..addAll(normalization.employees);
      _selectedIds.clear();
      _loading = false;
    });
  }

  Employe _employeeFromRow(Map<String, dynamic> row) {
    final hireMillis = row['date_embauche'] as int?;
    final hireDate = hireMillis == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(hireMillis);
    return Employe(
      id: (row['id'] as String?) ?? '',
      matricule: _readString(row, 'matricule'),
      fullName: _readString(row, 'nom_complet'),
      department: _readString(row, 'departement_id'),
      role: _readString(row, 'poste_id'),
      contractType: _readString(row, 'contract_type'),
      contractStatus: _readString(row, 'statut_contrat'),
      tenure: _readString(row, 'tenure'),
      phone: _readString(row, 'telephone'),
      email: _readString(row, 'email'),
      skills: _splitList(row['skills'] as String?),
      hireDate: hireDate,
      status: _readString(row, 'statut_employe'),
      dateNaissance: _readString(row, 'date_naissance'),
      lieuNaissance: _readString(row, 'lieu_naissance'),
      nationalite: _readString(row, 'nationalite'),
      etatCivilDetaille: _readString(row, 'etat_civil_detaille'),
      nir: _readString(row, 'nir'),
      situationFamiliale: _readString(row, 'situation_familiale'),
      adresse: _readString(row, 'adresse'),
      contactUrgence: _readString(row, 'contact_urgence'),
      cni: _readString(row, 'cni'),
      passeport: _readString(row, 'passeport'),
      permis: _readString(row, 'permis'),
      titreSejour: _readString(row, 'titre_sejour'),
      rib: _readString(row, 'rib'),
      bic: _readString(row, 'bic'),
      salaireVerse: _readString(row, 'salaire_verse'),
      posteActuel: _readString(row, 'poste_actuel'),
      postePrecedent: _readString(row, 'poste_precedent'),
      dernierePromotion: _readString(row, 'derniere_promotion'),
      augmentation: _readString(row, 'augmentation'),
      objectifs: _readString(row, 'objectifs'),
      evaluation: _readString(row, 'evaluation'),
      contractStartDate: _readString(row, 'contract_start_date'),
      contractEndDate: _readString(row, 'contract_end_date'),
      periodeEssaiDuree: _readString(row, 'periode_essai_duree'),
      periodeEssaiFin: _readString(row, 'periode_essai_fin'),
      tempsTravailType: _readString(row, 'temps_travail_type'),
      tempsPartielPourcentage: _readString(row, 'temps_partiel_pourcentage'),
      classification: _readString(row, 'classification'),
      coefficient: _readString(row, 'coefficient'),
      conventionCollective: _readString(row, 'convention_collective'),
      statutCadre: _readString(row, 'statut_cadre'),
      avenants: _readString(row, 'avenants'),
      charteInformatique: _readString(row, 'charte_informatique'),
      confidentialite: _readString(row, 'confidentialite'),
      clausesSignees: _readString(row, 'clauses_signees'),
      carteVitale: _readString(row, 'carte_vitale'),
      justificatifDomicile: _readString(row, 'justificatif_domicile'),
      diplomesCertifies: _readString(row, 'diplomes_certifies'),
      habilitations: _readString(row, 'habilitations'),
      diplome: _readString(row, 'diplome'),
      certification: _readString(row, 'certification'),
      formationsSuivies: _splitList(row['formations_suivies'] as String?),
      formationsPlanifiees: _splitList(row['formations_planifiees'] as String?),
      competencesTech: _readString(row, 'competences_tech'),
      competencesComport: _readString(row, 'competences_comport'),
      langues: _readString(row, 'langues'),
      congesRestants: _readString(row, 'conges_restants'),
      rttRestants: _readString(row, 'rtt_restants'),
      absencesJustifiees: _readString(row, 'absences_justifiees'),
      retards: _readString(row, 'retards'),
      teletravail: _readString(row, 'teletravail'),
      dernierPointage: _readString(row, 'dernier_pointage'),
      planningContractuel: _readString(row, 'planning_contractuel'),
      quotaHeures: _readString(row, 'quota_heures'),
      soldeCongesCalcule: _readString(row, 'solde_conges_calcule'),
      rttPeriode: _readString(row, 'rtt_periode'),
      salaireBase: _readString(row, 'salaire_base'),
      primePerformance: _readString(row, 'prime_performance'),
      mutuelle: _readString(row, 'mutuelle'),
      ticketRestaurant: _readString(row, 'ticket_restaurant'),
      dernierBulletin: _readString(row, 'dernier_bulletin'),
      historiqueBulletins: _readString(row, 'historique_bulletins'),
      regimeFiscal: _readString(row, 'regime_fiscal'),
      tauxPas: _readString(row, 'taux_pas'),
      modePaiement: _readString(row, 'mode_paiement'),
      variablesRecurrence: _readString(row, 'variables_recurrence'),
      pcPortable: _readString(row, 'pc_portable'),
      telephonePro: _readString(row, 'telephone_pro'),
      badgeAcces: _readString(row, 'badge_acces'),
      licence: _readString(row, 'licence'),
      manager: _readString(row, 'manager'),
      entiteLegale: _readString(row, 'entite_legale'),
      siteAffectation: _readString(row, 'site_affectation'),
      centreCout: _readString(row, 'centre_cout'),
      consentementRgpd: _readString(row, 'consentement_rgpd'),
      habilitationsSystemes: _readString(row, 'habilitations_systemes'),
      historiqueModifications: _readString(row, 'historique_modifications'),
      visitesMedicales: _readString(row, 'visites_medicales'),
      aptitudeMedicale: _readString(row, 'aptitude_medicale'),
      restrictionsPoste: _readString(row, 'restrictions_poste'),
    );
  }

  Map<String, dynamic> _employeeToRow(Employe employe, {required bool forInsert}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final data = <String, dynamic>{
      'matricule': employe.matricule,
      'nom_complet': employe.fullName,
      'departement_id': employe.department,
      'poste_id': employe.role,
      'contract_type': employe.contractType,
      'statut_contrat': employe.contractStatus,
      'tenure': employe.tenure,
      'telephone': employe.phone,
      'email': employe.email,
      'skills': _joinList(employe.skills),
      'date_embauche': employe.hireDate.millisecondsSinceEpoch,
      'statut_employe': employe.status,
      'date_naissance': employe.dateNaissance,
      'lieu_naissance': employe.lieuNaissance,
      'nationalite': employe.nationalite,
      'etat_civil_detaille': employe.etatCivilDetaille,
      'nir': employe.nir,
      'situation_familiale': employe.situationFamiliale,
      'adresse': employe.adresse,
      'contact_urgence': employe.contactUrgence,
      'cni': employe.cni,
      'passeport': employe.passeport,
      'permis': employe.permis,
      'titre_sejour': employe.titreSejour,
      'rib': employe.rib,
      'bic': employe.bic,
      'salaire_verse': employe.salaireVerse,
      'poste_actuel': employe.posteActuel,
      'poste_precedent': employe.postePrecedent,
      'derniere_promotion': employe.dernierePromotion,
      'augmentation': employe.augmentation,
      'objectifs': employe.objectifs,
      'evaluation': employe.evaluation,
      'contract_start_date': employe.contractStartDate,
      'contract_end_date': employe.contractEndDate,
      'periode_essai_duree': employe.periodeEssaiDuree,
      'periode_essai_fin': employe.periodeEssaiFin,
      'temps_travail_type': employe.tempsTravailType,
      'temps_partiel_pourcentage': employe.tempsPartielPourcentage,
      'classification': employe.classification,
      'coefficient': employe.coefficient,
      'convention_collective': employe.conventionCollective,
      'statut_cadre': employe.statutCadre,
      'avenants': employe.avenants,
      'charte_informatique': employe.charteInformatique,
      'confidentialite': employe.confidentialite,
      'clauses_signees': employe.clausesSignees,
      'carte_vitale': employe.carteVitale,
      'justificatif_domicile': employe.justificatifDomicile,
      'diplomes_certifies': employe.diplomesCertifies,
      'habilitations': employe.habilitations,
      'diplome': employe.diplome,
      'certification': employe.certification,
      'formations_suivies': _joinList(employe.formationsSuivies),
      'formations_planifiees': _joinList(employe.formationsPlanifiees),
      'competences_tech': employe.competencesTech,
      'competences_comport': employe.competencesComport,
      'langues': employe.langues,
      'conges_restants': employe.congesRestants,
      'rtt_restants': employe.rttRestants,
      'absences_justifiees': employe.absencesJustifiees,
      'retards': employe.retards,
      'teletravail': employe.teletravail,
      'dernier_pointage': employe.dernierPointage,
      'planning_contractuel': employe.planningContractuel,
      'quota_heures': employe.quotaHeures,
      'solde_conges_calcule': employe.soldeCongesCalcule,
      'rtt_periode': employe.rttPeriode,
      'salaire_base': employe.salaireBase,
      'prime_performance': employe.primePerformance,
      'mutuelle': employe.mutuelle,
      'ticket_restaurant': employe.ticketRestaurant,
      'dernier_bulletin': employe.dernierBulletin,
      'historique_bulletins': employe.historiqueBulletins,
      'regime_fiscal': employe.regimeFiscal,
      'taux_pas': employe.tauxPas,
      'mode_paiement': employe.modePaiement,
      'variables_recurrence': employe.variablesRecurrence,
      'pc_portable': employe.pcPortable,
      'telephone_pro': employe.telephonePro,
      'badge_acces': employe.badgeAcces,
      'licence': employe.licence,
      'manager': employe.manager,
      'entite_legale': employe.entiteLegale,
      'site_affectation': employe.siteAffectation,
      'centre_cout': employe.centreCout,
      'consentement_rgpd': employe.consentementRgpd,
      'habilitations_systemes': employe.habilitationsSystemes,
      'historique_modifications': employe.historiqueModifications,
      'visites_medicales': employe.visitesMedicales,
      'aptitude_medicale': employe.aptitudeMedicale,
      'restrictions_poste': employe.restrictionsPoste,
      'updated_at': now,
    };

    if (forInsert) {
      data['id'] = employe.id;
      data['created_at'] = now;
    }

    return data;
  }

  String _readString(Map<String, dynamic> row, String key) {
    return (row[key] as String?) ?? '';
  }

  List<String> _splitList(String? value) {
    if (value == null || value.trim().isEmpty) return [];
    return value.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
  }

  String _joinList(List<String> values) {
    return values.map((value) => value.trim()).where((value) => value.isNotEmpty).join(', ');
  }

  _NormalizationResult _normalizeEmployeeRefs(List<Employe> employees) {
    if (_departmentLabelsById.isEmpty && _roleLabelsById.isEmpty) {
      return _NormalizationResult(employees, const []);
    }
    final updated = <Employe>[];
    final normalized = employees.map((emp) {
          final deptId = _departmentLabelsById.containsKey(emp.department)
              ? emp.department
              : (_departmentIdsByLabel[emp.department] ?? emp.department);
          final roleId = _roleLabelsById.containsKey(emp.role)
              ? emp.role
              : (_roleIdsByLabel[emp.role] ?? emp.role);
          if (emp.department == deptId && emp.role == roleId) {
            return emp;
          }
          final updatedEmployee = Employe(
            id: emp.id,
            matricule: emp.matricule,
            fullName: emp.fullName,
            department: deptId,
            role: roleId,
            contractType: emp.contractType,
            contractStatus: emp.contractStatus,
            tenure: emp.tenure,
            phone: emp.phone,
            email: emp.email,
            skills: emp.skills,
            hireDate: emp.hireDate,
            status: emp.status,
            dateNaissance: emp.dateNaissance,
            lieuNaissance: emp.lieuNaissance,
            nationalite: emp.nationalite,
            etatCivilDetaille: emp.etatCivilDetaille,
            nir: emp.nir,
            situationFamiliale: emp.situationFamiliale,
            adresse: emp.adresse,
            contactUrgence: emp.contactUrgence,
            cni: emp.cni,
            passeport: emp.passeport,
            permis: emp.permis,
            titreSejour: emp.titreSejour,
            rib: emp.rib,
            bic: emp.bic,
            salaireVerse: emp.salaireVerse,
            posteActuel: emp.posteActuel,
            postePrecedent: emp.postePrecedent,
            dernierePromotion: emp.dernierePromotion,
            augmentation: emp.augmentation,
            objectifs: emp.objectifs,
            evaluation: emp.evaluation,
            contractStartDate: emp.contractStartDate,
            contractEndDate: emp.contractEndDate,
            periodeEssaiDuree: emp.periodeEssaiDuree,
            periodeEssaiFin: emp.periodeEssaiFin,
            tempsTravailType: emp.tempsTravailType,
            tempsPartielPourcentage: emp.tempsPartielPourcentage,
            classification: emp.classification,
            coefficient: emp.coefficient,
            conventionCollective: emp.conventionCollective,
            statutCadre: emp.statutCadre,
            avenants: emp.avenants,
            charteInformatique: emp.charteInformatique,
            confidentialite: emp.confidentialite,
            clausesSignees: emp.clausesSignees,
            carteVitale: emp.carteVitale,
            justificatifDomicile: emp.justificatifDomicile,
            diplomesCertifies: emp.diplomesCertifies,
            habilitations: emp.habilitations,
            diplome: emp.diplome,
            certification: emp.certification,
            formationsSuivies: emp.formationsSuivies,
            formationsPlanifiees: emp.formationsPlanifiees,
            competencesTech: emp.competencesTech,
            competencesComport: emp.competencesComport,
            langues: emp.langues,
            congesRestants: emp.congesRestants,
            rttRestants: emp.rttRestants,
            absencesJustifiees: emp.absencesJustifiees,
            retards: emp.retards,
            teletravail: emp.teletravail,
            dernierPointage: emp.dernierPointage,
            planningContractuel: emp.planningContractuel,
            quotaHeures: emp.quotaHeures,
            soldeCongesCalcule: emp.soldeCongesCalcule,
            rttPeriode: emp.rttPeriode,
            salaireBase: emp.salaireBase,
            primePerformance: emp.primePerformance,
            mutuelle: emp.mutuelle,
            ticketRestaurant: emp.ticketRestaurant,
            dernierBulletin: emp.dernierBulletin,
            historiqueBulletins: emp.historiqueBulletins,
            regimeFiscal: emp.regimeFiscal,
            tauxPas: emp.tauxPas,
            modePaiement: emp.modePaiement,
            variablesRecurrence: emp.variablesRecurrence,
            pcPortable: emp.pcPortable,
            telephonePro: emp.telephonePro,
            badgeAcces: emp.badgeAcces,
            licence: emp.licence,
            manager: emp.manager,
            entiteLegale: emp.entiteLegale,
            siteAffectation: emp.siteAffectation,
            centreCout: emp.centreCout,
            consentementRgpd: emp.consentementRgpd,
            habilitationsSystemes: emp.habilitationsSystemes,
            historiqueModifications: emp.historiqueModifications,
            visitesMedicales: emp.visitesMedicales,
            aptitudeMedicale: emp.aptitudeMedicale,
            restrictionsPoste: emp.restrictionsPoste,
          );
          updated.add(updatedEmployee);
          return updatedEmployee;
        })
        .toList();
    return _NormalizationResult(normalized, updated);
  }

  String _departmentLabel(String id) {
    return _departmentLabelsById[id] ?? id;
  }

  String _roleLabel(String id) {
    return _roleLabelsById[id] ?? id;
  }

  List<_IdLabelOption> _roleOptionsForForm({String? currentId}) {
    if (currentId == null || currentId.isEmpty) return _roleOptionsActive;
    final exists = _roleOptionsActive.any((opt) => opt.id == currentId);
    if (exists) return _roleOptionsActive;
    final label = _roleLabelsById[currentId] ?? currentId;
    return [
      _IdLabelOption(id: currentId, label: label),
      ..._roleOptionsActive,
    ];
  }

  Employe _withDisplayLabels(Employe employe) {
    return Employe(
      id: employe.id,
      matricule: employe.matricule,
      fullName: employe.fullName,
      department: _departmentLabel(employe.department),
      role: _roleLabel(employe.role),
      contractType: employe.contractType,
      contractStatus: employe.contractStatus,
      tenure: employe.tenure,
      phone: employe.phone,
      email: employe.email,
      skills: employe.skills,
      hireDate: employe.hireDate,
      status: employe.status,
      dateNaissance: employe.dateNaissance,
      lieuNaissance: employe.lieuNaissance,
      nationalite: employe.nationalite,
      etatCivilDetaille: employe.etatCivilDetaille,
      nir: employe.nir,
      situationFamiliale: employe.situationFamiliale,
      adresse: employe.adresse,
      contactUrgence: employe.contactUrgence,
      cni: employe.cni,
      passeport: employe.passeport,
      permis: employe.permis,
      titreSejour: employe.titreSejour,
      rib: employe.rib,
      bic: employe.bic,
      salaireVerse: employe.salaireVerse,
      posteActuel: employe.posteActuel,
      postePrecedent: employe.postePrecedent,
      dernierePromotion: employe.dernierePromotion,
      augmentation: employe.augmentation,
      objectifs: employe.objectifs,
      evaluation: employe.evaluation,
      contractStartDate: employe.contractStartDate,
      contractEndDate: employe.contractEndDate,
      periodeEssaiDuree: employe.periodeEssaiDuree,
      periodeEssaiFin: employe.periodeEssaiFin,
      tempsTravailType: employe.tempsTravailType,
      tempsPartielPourcentage: employe.tempsPartielPourcentage,
      classification: employe.classification,
      coefficient: employe.coefficient,
      conventionCollective: employe.conventionCollective,
      statutCadre: employe.statutCadre,
      avenants: employe.avenants,
      charteInformatique: employe.charteInformatique,
      confidentialite: employe.confidentialite,
      clausesSignees: employe.clausesSignees,
      carteVitale: employe.carteVitale,
      justificatifDomicile: employe.justificatifDomicile,
      diplomesCertifies: employe.diplomesCertifies,
      habilitations: employe.habilitations,
      diplome: employe.diplome,
      certification: employe.certification,
      formationsSuivies: employe.formationsSuivies,
      formationsPlanifiees: employe.formationsPlanifiees,
      competencesTech: employe.competencesTech,
      competencesComport: employe.competencesComport,
      langues: employe.langues,
      congesRestants: employe.congesRestants,
      rttRestants: employe.rttRestants,
      absencesJustifiees: employe.absencesJustifiees,
      retards: employe.retards,
      teletravail: employe.teletravail,
      dernierPointage: employe.dernierPointage,
      planningContractuel: employe.planningContractuel,
      quotaHeures: employe.quotaHeures,
      soldeCongesCalcule: employe.soldeCongesCalcule,
      rttPeriode: employe.rttPeriode,
      salaireBase: employe.salaireBase,
      primePerformance: employe.primePerformance,
      mutuelle: employe.mutuelle,
      ticketRestaurant: employe.ticketRestaurant,
      dernierBulletin: employe.dernierBulletin,
      historiqueBulletins: employe.historiqueBulletins,
      regimeFiscal: employe.regimeFiscal,
      tauxPas: employe.tauxPas,
      modePaiement: employe.modePaiement,
      variablesRecurrence: employe.variablesRecurrence,
      pcPortable: employe.pcPortable,
      telephonePro: employe.telephonePro,
      badgeAcces: employe.badgeAcces,
      licence: employe.licence,
      manager: employe.manager,
      entiteLegale: employe.entiteLegale,
      siteAffectation: employe.siteAffectation,
      centreCout: employe.centreCout,
      consentementRgpd: employe.consentementRgpd,
      habilitationsSystemes: employe.habilitationsSystemes,
      historiqueModifications: employe.historiqueModifications,
      visitesMedicales: employe.visitesMedicales,
      aptitudeMedicale: employe.aptitudeMedicale,
      restrictionsPoste: employe.restrictionsPoste,
    );
  }

  _EpochRange? _parseHireDateRange(String value) {
    final trimmed = value.trim();
    if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(trimmed)) return null;
    final parts = trimmed.split('-');
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year == null || month == null || month < 1 || month > 12) return null;
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1).subtract(const Duration(milliseconds: 1));
    return _EpochRange(start.millisecondsSinceEpoch, end.millisecondsSinceEpoch);
  }

  void _toggleSelection(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _openDetail(Employe employe) {
    final displayed = _withDisplayLabels(employe);
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: EmployeeDetailScreen(employe: displayed),
      ),
    );
  }

  void _showNewEmployeeWizard() {
    showDialog<Employe>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _NewEmployeeWizardDialog(
          existing: _employees,
          departmentOptions: _departmentOptions,
          roleOptions: _roleOptionsActive,
        ),
      ),
    ).then((created) async {
      if (created == null) return;
      await DaoRegistry.instance.employes.insert(_employeeToRow(created, forInsert: true));
      await _loadEmployees(resetPage: true);
      showOperationNotice(context, message: 'Employe cree.', success: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterRow(context),
                const SizedBox(height: 12),
                _buildAdvancedSearch(context),
                const SizedBox(height: 12),
                _buildBulkActions(context),
                const SizedBox(height: 12),
                _buildTable(context),
                const SizedBox(height: 12),
                _buildPagination(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final actionButton = ElevatedButton.icon(
      onPressed: _showNewEmployeeWizard,
      icon: const Icon(Icons.person_add_alt_1),
      label: const Text('Nouvel employe'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: SectionHeader(
                  title: 'Registre du personnel',
                  subtitle: 'Vue globale des employes et statut contrat.',
                ),
              ),
              const SizedBox(width: 16),
              actionButton,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Registre du personnel',
              subtitle: 'Vue globale des employes et statut contrat.',
            ),
            const SizedBox(height: 12),
            actionButton,
          ],
        );
      },
    );
  }

  Future<void> _showEditEmployeeDialog(Employe employe) async {
    final roleOptions = _roleOptionsForForm(currentId: employe.role);
    final updated = await showDialog<Employe>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: _EditEmployeeDialog(
          employe: employe,
          existing: _employees,
          departmentOptions: _departmentOptions,
          roleOptions: roleOptions,
        ),
      ),
    );

    if (updated == null) return;
    await DaoRegistry.instance.employes.update(updated.id, _employeeToRow(updated, forInsert: false));
    await _loadEmployees();
    showOperationNotice(context, message: 'Employe mis a jour.', success: true);
  }

  Future<void> _confirmDeleteEmployee(Employe employe) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer employe'),
        content: Text('Supprimer ${employe.fullName} ? Cette action est definitive.'),
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
    await DaoRegistry.instance.employes.delete(employe.id);
    await _loadEmployees();
    showOperationNotice(context, message: 'Employe supprime.', success: true);
  }

  Widget _buildFilterRow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 980;
        final filters = [
          _FilterOptionDropdown(
            label: 'Departement',
            value: _filterDepartment,
            options: _departmentOptions,
            onChanged: (value) {
              setState(() => _filterDepartment = value);
              _loadEmployees(resetPage: true);
            },
          ),
          _FilterOptionDropdown(
            label: 'Poste',
            value: _filterRole,
            options: _roleOptions,
            onChanged: (value) {
              setState(() => _filterRole = value);
              _loadEmployees(resetPage: true);
            },
          ),
          _FilterDropdown(
            label: 'Contrat',
            value: _filterContract,
            items: const ['Tous', 'CDI', 'CDD', 'Stage'],
            onChanged: (value) {
              setState(() => _filterContract = value);
              _loadEmployees(resetPage: true);
            },
          ),
          _FilterDropdown(
            label: 'Statut',
            value: _filterStatus,
            items: const ['Tous', 'Actif', 'Suspendu', 'Parti'],
            onChanged: (value) {
              setState(() => _filterStatus = value);
              _loadEmployees(resetPage: true);
            },
          ),
          SizedBox(
            width: 180,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Date embauche (YYYY-MM)',
                prefixIcon: const Icon(Icons.date_range),
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF1F5F9),
              ),
              onChanged: (value) {
                setState(() => _filterHireDate = value.trim());
                _loadEmployees(resetPage: true);
              },
            ),
          ),
        ];

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: filters,
        );
      },
    );
  }

  Widget _buildAdvancedSearch(BuildContext context) {
    return ExpansionTile(
      title: Text(
        'Recherche avancee',
        style: TextStyle(color: appTextPrimary(context), fontWeight: FontWeight.w600),
      ),
      childrenPadding: const EdgeInsets.only(top: 12, bottom: 8),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SearchField(
              label: 'Nom complet',
              onChanged: (value) {
                setState(() => _searchName = value);
                _loadEmployees(resetPage: true);
              },
            ),
            _SearchField(
              label: 'Matricule',
              onChanged: (value) {
                setState(() => _searchMatricule = value);
                _loadEmployees(resetPage: true);
              },
            ),
            _SearchField(
              label: 'Telephone',
              onChanged: (value) {
                setState(() => _searchPhone = value);
                _loadEmployees(resetPage: true);
              },
            ),
            _SearchField(
              label: 'Email',
              onChanged: (value) {
                setState(() => _searchEmail = value);
                _loadEmployees(resetPage: true);
              },
            ),
            _SearchField(
              label: 'Competences',
              onChanged: (value) {
                setState(() => _searchSkills = value);
                _loadEmployees(resetPage: true);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBulkActions(BuildContext context) {
    if (_selectedIds.isEmpty) {
      return Row(
        children: [
          Text(
            'Selectionnez des employes pour actions en lot.',
            style: TextStyle(color: appTextMuted(context)),
          ),
        ],
      );
    }

    return Row(
      children: [
        Text(
          '${_selectedIds.length} selectionne(s)',
          style: TextStyle(color: appTextPrimary(context), fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.badge_outlined),
          label: const Text('Generer badges'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.description_outlined),
          label: const Text('Attestations'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Exporter trombinoscope'),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => setState(() => _selectedIds.clear()),
          child: const Text('Vider selection'),
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headingColor = isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFC);
    final rows = _employees;

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Aucun employe. Utilisez "Nouvel employe" pour commencer.',
            style: TextStyle(color: appTextMuted(context)),
          ),
        ),
      );
    }

    return DataTable(
      headingRowColor: MaterialStateProperty.all(headingColor),
      columns: const [
        DataColumn(label: Text('Photo')),
        DataColumn(label: Text('Matricule')),
        DataColumn(label: Text('Nom complet')),
        DataColumn(label: Text('Departement')),
        DataColumn(label: Text('Poste')),
        DataColumn(label: Text('Contrat')),
        DataColumn(label: Text('Anciennete')),
        DataColumn(label: Text('Actions')),
      ],
      rows: rows
          .map(
            (emp) => DataRow(
              selected: _selectedIds.contains(emp.id),
              onSelectChanged: (value) => _toggleSelection(emp.id, value ?? false),
              cells: [
                DataCell(CircleAvatar(child: Text(emp.fullName.substring(0, 1)))),
                DataCell(Text(emp.matricule)),
                DataCell(
                  SizedBox(
                    width: 180,
                    child: Text(
                      emp.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ),
                DataCell(Text(_departmentLabel(emp.department))),
                DataCell(Text(_roleLabel(emp.role))),
                DataCell(Text('${emp.contractType} / ${emp.contractStatus}')),
                DataCell(Text(emp.tenure)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Voir dossier',
                        icon: const Icon(Icons.visibility_outlined),
                        onPressed: () => _openDetail(emp),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Actions',
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditEmployeeDialog(emp);
                          } else if (value == 'delete') {
                            _confirmDeleteEmployee(emp);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Modifier'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Supprimer'),
                          ),
                        ],
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

  Widget _buildPagination(BuildContext context) {
    if (_loading || _totalEmployees == 0) {
      return const SizedBox.shrink();
    }

    final start = _page * _pageSize + 1;
    final end = _page * _pageSize + _employees.length;
    final canPrev = _page > 0;
    final canNext = end < _totalEmployees;

    return Row(
      children: [
        Text(
          '$start-$end sur $_totalEmployees',
          style: TextStyle(color: appTextMuted(context)),
        ),
        const Spacer(),
        TextButton(
          onPressed: canPrev
              ? () {
                  setState(() => _page -= 1);
                  _loadEmployees();
                }
              : null,
          child: const Text('Precedent'),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: canNext
              ? () {
                  setState(() => _page += 1);
                  _loadEmployees();
                }
              : null,
          child: const Text('Suivant'),
        ),
      ],
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
      width: 190,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
        ),
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

class _FilterOptionDropdown extends StatelessWidget {
  const _FilterOptionDropdown({
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
    final entries = [
      const _IdLabelOption(id: '', label: 'Tous'),
      ...options,
    ];
    return SizedBox(
      width: 190,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
        ),
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
        onChanged: (selected) => onChanged(selected ?? ''),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.label, required this.onChanged});

  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: TextField(
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: const Icon(Icons.search),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _NewEmployeeWizardDialog extends StatefulWidget {
  const _NewEmployeeWizardDialog({
    required this.existing,
    required this.departmentOptions,
    required this.roleOptions,
  });

  final List<Employe> existing;
  final List<_IdLabelOption> departmentOptions;
  final List<_IdLabelOption> roleOptions;

  @override
  State<_NewEmployeeWizardDialog> createState() => _NewEmployeeWizardDialogState();
}

class _NewEmployeeWizardDialogState extends State<_NewEmployeeWizardDialog> {
  int _currentStep = 0;
  String _matricule = '';

  String? _errorMessage;

  final TextEditingController _matriculeCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _dateNaissanceCtrl = TextEditingController();
  final TextEditingController _lieuNaissanceCtrl = TextEditingController();
  final TextEditingController _nationaliteCtrl = TextEditingController();
  final TextEditingController _etatCivilDetailCtrl = TextEditingController();
  final TextEditingController _nirCtrl = TextEditingController();
  final TextEditingController _situationFamilialeCtrl = TextEditingController();
  final TextEditingController _adresseCtrl = TextEditingController();
  final TextEditingController _contactUrgenceCtrl = TextEditingController();
  final TextEditingController _cniCtrl = TextEditingController();
  final TextEditingController _passeportCtrl = TextEditingController();
  final TextEditingController _permisCtrl = TextEditingController();
  final TextEditingController _titreSejourCtrl = TextEditingController();
  final TextEditingController _ribCtrl = TextEditingController();
  final TextEditingController _bicCtrl = TextEditingController();
  final TextEditingController _salaireVerseCtrl = TextEditingController();
  final TextEditingController _contractCtrl = TextEditingController();
  final TextEditingController _statusCtrl = TextEditingController(text: 'Actif');
  final TextEditingController _hireDateCtrl = TextEditingController();
  final TextEditingController _contractStartDateCtrl = TextEditingController();
  final TextEditingController _contractEndDateCtrl = TextEditingController();
  final TextEditingController _periodeEssaiDureeCtrl = TextEditingController();
  final TextEditingController _periodeEssaiFinCtrl = TextEditingController();
  final TextEditingController _tempsTravailTypeCtrl = TextEditingController();
  final TextEditingController _tempsPartielPourcentageCtrl = TextEditingController();
  final TextEditingController _classificationCtrl = TextEditingController();
  final TextEditingController _coefficientCtrl = TextEditingController();
  final TextEditingController _conventionCollectiveCtrl = TextEditingController();
  final TextEditingController _statutCadreCtrl = TextEditingController();
  final TextEditingController _avenantsCtrl = TextEditingController();
  final TextEditingController _charteCtrl = TextEditingController();
  final TextEditingController _confidentialiteCtrl = TextEditingController();
  final TextEditingController _clausesSigneesCtrl = TextEditingController();
  final TextEditingController _carteVitaleCtrl = TextEditingController();
  final TextEditingController _justificatifDomicileCtrl = TextEditingController();
  final TextEditingController _diplomesCertifiesCtrl = TextEditingController();
  final TextEditingController _habilitationsCtrl = TextEditingController();
  final TextEditingController _departmentCtrl = TextEditingController();
  final TextEditingController _roleCtrl = TextEditingController();
  final TextEditingController _posteActuelCtrl = TextEditingController();
  final TextEditingController _postePrecedentCtrl = TextEditingController();
  final TextEditingController _promotionCtrl = TextEditingController();
  final TextEditingController _augmentationCtrl = TextEditingController();
  final TextEditingController _objectifsCtrl = TextEditingController();
  final TextEditingController _evaluationCtrl = TextEditingController();
  final TextEditingController _managerCtrl = TextEditingController();
  final TextEditingController _entiteLegaleCtrl = TextEditingController();
  final TextEditingController _siteAffectationCtrl = TextEditingController();
  final TextEditingController _centreCoutCtrl = TextEditingController();
  final TextEditingController _diplomeCtrl = TextEditingController();
  final TextEditingController _certificationCtrl = TextEditingController();
  final TextEditingController _formationsSuiviesCtrl = TextEditingController();
  final TextEditingController _formationsPlanifieesCtrl = TextEditingController();
  final TextEditingController _competencesTechCtrl = TextEditingController();
  final TextEditingController _competencesComportCtrl = TextEditingController();
  final TextEditingController _languesCtrl = TextEditingController();
  final TextEditingController _congesRestantsCtrl = TextEditingController();
  final TextEditingController _rttRestantsCtrl = TextEditingController();
  final TextEditingController _absencesJustifieesCtrl = TextEditingController();
  final TextEditingController _retardsCtrl = TextEditingController();
  final TextEditingController _teletravailCtrl = TextEditingController();
  final TextEditingController _dernierPointageCtrl = TextEditingController();
  final TextEditingController _planningContractuelCtrl = TextEditingController();
  final TextEditingController _quotaHeuresCtrl = TextEditingController();
  final TextEditingController _soldeCongesCalculeCtrl = TextEditingController();
  final TextEditingController _rttPeriodeCtrl = TextEditingController();
  final TextEditingController _salaireBaseCtrl = TextEditingController();
  final TextEditingController _primePerformanceCtrl = TextEditingController();
  final TextEditingController _mutuelleCtrl = TextEditingController();
  final TextEditingController _ticketRestaurantCtrl = TextEditingController();
  final TextEditingController _dernierBulletinCtrl = TextEditingController();
  final TextEditingController _historiqueBulletinsCtrl = TextEditingController();
  final TextEditingController _regimeFiscalCtrl = TextEditingController();
  final TextEditingController _tauxPasCtrl = TextEditingController();
  final TextEditingController _modePaiementCtrl = TextEditingController();
  final TextEditingController _variablesRecurrenceCtrl = TextEditingController();
  final TextEditingController _equipmentCtrl = TextEditingController();
  final TextEditingController _pcPortableCtrl = TextEditingController();
  final TextEditingController _telephoneProCtrl = TextEditingController();
  final TextEditingController _badgeAccesCtrl = TextEditingController();
  final TextEditingController _licenceCtrl = TextEditingController();
  final TextEditingController _consentementRgpdCtrl = TextEditingController();
  final TextEditingController _habilitationsSystemesCtrl = TextEditingController();
  final TextEditingController _historiqueModificationsCtrl = TextEditingController();
  final TextEditingController _visitesMedicalesCtrl = TextEditingController();
  final TextEditingController _aptitudeMedicaleCtrl = TextEditingController();
  final TextEditingController _restrictionsPosteCtrl = TextEditingController();
  final TextEditingController _accountCtrl = TextEditingController();

  bool _createAccount = true;
  bool _onboardingChecklist = true;

  @override
  void dispose() {
    _matriculeCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dateNaissanceCtrl.dispose();
    _situationFamilialeCtrl.dispose();
    _adresseCtrl.dispose();
    _contactUrgenceCtrl.dispose();
    _cniCtrl.dispose();
    _passeportCtrl.dispose();
    _permisCtrl.dispose();
    _ribCtrl.dispose();
    _salaireVerseCtrl.dispose();
    _contractCtrl.dispose();
    _statusCtrl.dispose();
    _hireDateCtrl.dispose();
    _contractStartDateCtrl.dispose();
    _avenantsCtrl.dispose();
    _charteCtrl.dispose();
    _confidentialiteCtrl.dispose();
    _departmentCtrl.dispose();
    _roleCtrl.dispose();
    _posteActuelCtrl.dispose();
    _postePrecedentCtrl.dispose();
    _promotionCtrl.dispose();
    _augmentationCtrl.dispose();
    _objectifsCtrl.dispose();
    _evaluationCtrl.dispose();
    _diplomeCtrl.dispose();
    _certificationCtrl.dispose();
    _formationsSuiviesCtrl.dispose();
    _formationsPlanifieesCtrl.dispose();
    _competencesTechCtrl.dispose();
    _competencesComportCtrl.dispose();
    _languesCtrl.dispose();
    _congesRestantsCtrl.dispose();
    _rttRestantsCtrl.dispose();
    _absencesJustifieesCtrl.dispose();
    _retardsCtrl.dispose();
    _teletravailCtrl.dispose();
    _dernierPointageCtrl.dispose();
    _salaireBaseCtrl.dispose();
    _primePerformanceCtrl.dispose();
    _mutuelleCtrl.dispose();
    _ticketRestaurantCtrl.dispose();
    _dernierBulletinCtrl.dispose();
    _historiqueBulletinsCtrl.dispose();
    _equipmentCtrl.dispose();
    _pcPortableCtrl.dispose();
    _telephoneProCtrl.dispose();
    _badgeAccesCtrl.dispose();
    _licenceCtrl.dispose();
    _accountCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _matricule = _generateMatricule();
    _matriculeCtrl.text = _matricule;
  }

  String _generateMatricule() {
    final stamp = DateTime.now().millisecondsSinceEpoch.toString();
    return 'EMP-${stamp.substring(stamp.length - 4)}';
  }

  Future<bool> _isDuplicateEmail(String email) async {
    final localMatch = widget.existing.any((e) => e.email.toLowerCase() == email.toLowerCase());
    if (localMatch) return true;
    return DaoRegistry.instance.employes.existsByEmail(email);
  }

  Future<bool> _isDuplicateMatricule(String matricule) async {
    final localMatch = widget.existing.any((e) => e.matricule == matricule);
    if (localMatch) return true;
    return DaoRegistry.instance.employes.existsByMatricule(matricule);
  }

  List<String> _parseList(String input) {
    return input
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<bool> _validateStep(int step) async {
    setState(() => _errorMessage = null);
    if (step == 0) {
      if (_nameCtrl.text.trim().isEmpty) {
        _errorMessage = 'Le nom complet est requis.';
        return false;
      }
      if (_emailCtrl.text.trim().isEmpty || !_emailCtrl.text.contains('@')) {
        _errorMessage = 'Un email valide est requis.';
        return false;
      }
      if (_phoneCtrl.text.trim().isEmpty) {
        _errorMessage = 'Le telephone est requis.';
        return false;
      }
      if (await _isDuplicateEmail(_emailCtrl.text.trim())) {
        _errorMessage = 'Email deja utilise.';
        return false;
      }
      if (await _isDuplicateMatricule(_matricule)) {
        _matricule = _generateMatricule();
        _matriculeCtrl.text = _matricule;
      }
    }
    if (step == 1) {
      if (_contractCtrl.text.trim().isEmpty) {
        _errorMessage = 'Le type de contrat est requis.';
        return false;
      }
      if (_statusCtrl.text.trim().isEmpty) {
        _errorMessage = 'Le statut du contrat est requis.';
        return false;
      }
      if (_hireDateCtrl.text.trim().isEmpty || !_hireDateCtrl.text.contains('-')) {
        _errorMessage = 'La date d embauche est requise.';
        return false;
      }
    }
    if (step == 2) {
      if (_departmentCtrl.text.trim().isEmpty) {
        _errorMessage = 'Le departement est requis.';
        return false;
      }
      if (_roleCtrl.text.trim().isEmpty) {
        _errorMessage = 'Le poste est requis.';
        return false;
      }
    }
    if (step == 3) {
      if (_createAccount && _accountCtrl.text.trim().isEmpty) {
        _errorMessage = 'Identifiant utilisateur requis.';
        return false;
      }
    }
    return true;
  }

  Employe _buildEmploye() {
    final hireDate = DateTime.tryParse(_hireDateCtrl.text.trim()) ?? DateTime.now();
    return Employe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      matricule: _matricule,
      fullName: _nameCtrl.text.trim(),
      department: _departmentCtrl.text.trim(),
      role: _roleCtrl.text.trim(),
      contractType: _contractCtrl.text.trim(),
      contractStatus: _statusCtrl.text.trim(),
      tenure: '0 an',
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      skills: _parseList('${_competencesTechCtrl.text},${_competencesComportCtrl.text}'),
      hireDate: hireDate,
      status: _statusCtrl.text.trim(),
      dateNaissance: _dateNaissanceCtrl.text.trim(),
      lieuNaissance: _lieuNaissanceCtrl.text.trim(),
      nationalite: _nationaliteCtrl.text.trim(),
      etatCivilDetaille: _etatCivilDetailCtrl.text.trim(),
      nir: _nirCtrl.text.trim(),
      situationFamiliale: _situationFamilialeCtrl.text.trim(),
      adresse: _adresseCtrl.text.trim(),
      contactUrgence: _contactUrgenceCtrl.text.trim(),
      cni: _cniCtrl.text.trim(),
      passeport: _passeportCtrl.text.trim(),
      permis: _permisCtrl.text.trim(),
      titreSejour: _titreSejourCtrl.text.trim(),
      rib: _ribCtrl.text.trim(),
      bic: _bicCtrl.text.trim(),
      salaireVerse: _salaireVerseCtrl.text.trim(),
      posteActuel: _posteActuelCtrl.text.trim(),
      postePrecedent: _postePrecedentCtrl.text.trim(),
      dernierePromotion: _promotionCtrl.text.trim(),
      augmentation: _augmentationCtrl.text.trim(),
      objectifs: _objectifsCtrl.text.trim(),
      evaluation: _evaluationCtrl.text.trim(),
      contractStartDate: _contractStartDateCtrl.text.trim(),
      contractEndDate: _contractEndDateCtrl.text.trim(),
      periodeEssaiDuree: _periodeEssaiDureeCtrl.text.trim(),
      periodeEssaiFin: _periodeEssaiFinCtrl.text.trim(),
      tempsTravailType: _tempsTravailTypeCtrl.text.trim(),
      tempsPartielPourcentage: _tempsPartielPourcentageCtrl.text.trim(),
      classification: _classificationCtrl.text.trim(),
      coefficient: _coefficientCtrl.text.trim(),
      conventionCollective: _conventionCollectiveCtrl.text.trim(),
      statutCadre: _statutCadreCtrl.text.trim(),
      avenants: _avenantsCtrl.text.trim(),
      charteInformatique: _charteCtrl.text.trim(),
      confidentialite: _confidentialiteCtrl.text.trim(),
      clausesSignees: _clausesSigneesCtrl.text.trim(),
      carteVitale: _carteVitaleCtrl.text.trim(),
      justificatifDomicile: _justificatifDomicileCtrl.text.trim(),
      diplomesCertifies: _diplomesCertifiesCtrl.text.trim(),
      habilitations: _habilitationsCtrl.text.trim(),
      diplome: _diplomeCtrl.text.trim(),
      certification: _certificationCtrl.text.trim(),
      formationsSuivies: _parseList(_formationsSuiviesCtrl.text),
      formationsPlanifiees: _parseList(_formationsPlanifieesCtrl.text),
      competencesTech: _competencesTechCtrl.text.trim(),
      competencesComport: _competencesComportCtrl.text.trim(),
      langues: _languesCtrl.text.trim(),
      congesRestants: _congesRestantsCtrl.text.trim(),
      rttRestants: _rttRestantsCtrl.text.trim(),
      absencesJustifiees: _absencesJustifieesCtrl.text.trim(),
      retards: _retardsCtrl.text.trim(),
      teletravail: _teletravailCtrl.text.trim(),
      dernierPointage: _dernierPointageCtrl.text.trim(),
      planningContractuel: _planningContractuelCtrl.text.trim(),
      quotaHeures: _quotaHeuresCtrl.text.trim(),
      soldeCongesCalcule: _soldeCongesCalculeCtrl.text.trim(),
      rttPeriode: _rttPeriodeCtrl.text.trim(),
      salaireBase: _salaireBaseCtrl.text.trim(),
      primePerformance: _primePerformanceCtrl.text.trim(),
      mutuelle: _mutuelleCtrl.text.trim(),
      ticketRestaurant: _ticketRestaurantCtrl.text.trim(),
      dernierBulletin: _dernierBulletinCtrl.text.trim(),
      historiqueBulletins: _historiqueBulletinsCtrl.text.trim(),
      regimeFiscal: _regimeFiscalCtrl.text.trim(),
      tauxPas: _tauxPasCtrl.text.trim(),
      modePaiement: _modePaiementCtrl.text.trim(),
      variablesRecurrence: _variablesRecurrenceCtrl.text.trim(),
      pcPortable: _pcPortableCtrl.text.trim(),
      telephonePro: _telephoneProCtrl.text.trim(),
      badgeAcces: _badgeAccesCtrl.text.trim(),
      licence: _licenceCtrl.text.trim(),
      manager: _managerCtrl.text.trim(),
      entiteLegale: _entiteLegaleCtrl.text.trim(),
      siteAffectation: _siteAffectationCtrl.text.trim(),
      centreCout: _centreCoutCtrl.text.trim(),
      consentementRgpd: _consentementRgpdCtrl.text.trim(),
      habilitationsSystemes: _habilitationsSystemesCtrl.text.trim(),
      historiqueModifications: _historiqueModificationsCtrl.text.trim(),
      visitesMedicales: _visitesMedicalesCtrl.text.trim(),
      aptitudeMedicale: _aptitudeMedicaleCtrl.text.trim(),
      restrictionsPoste: _restrictionsPosteCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvel employe'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Stepper(
          currentStep: _currentStep,
          controlsBuilder: (context, details) {
            final isLast = _currentStep == 3;
            return Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(isLast ? 'Terminer' : 'Continuer'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Retour'),
                ),
                const Spacer(),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
              ],
            );
          },
          onStepContinue: () async {
            if (!await _validateStep(_currentStep)) return;
            if (_currentStep < 3) {
              setState(() => _currentStep += 1);
            } else {
              Navigator.of(context).pop(_buildEmploye());
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            } else {
              Navigator.of(context).pop();
            }
          },
          steps: [
            Step(
              title: const Text('Identification'),
              isActive: _currentStep >= 0,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StepSectionTitle(label: 'Identite'),
                  _FieldWrap(
                    children: [
                      _WizardField(controller: _matriculeCtrl, label: 'Matricule', readOnly: true),
                      _WizardField(controller: _nameCtrl, label: 'Nom complet'),
                      _WizardField(controller: _nationaliteCtrl, label: 'Nationalite'),
                      _WizardField(controller: _lieuNaissanceCtrl, label: 'Lieu naissance'),
                      _WizardField(controller: _nirCtrl, label: 'Numero securite sociale (NIR)'),
                      _WizardField(controller: _emailCtrl, label: 'Email'),
                      _WizardField(controller: _phoneCtrl, label: 'Telephone'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StepSectionTitle(label: 'Etat civil'),
                  _FieldWrap(
                    children: [
                      _WizardField(controller: _dateNaissanceCtrl, label: 'Date naissance (YYYY-MM-DD)'),
                      _WizardField(controller: _situationFamilialeCtrl, label: 'Situation familiale'),
                      _WizardField(controller: _etatCivilDetailCtrl, label: 'Etat civil detaille'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StepSectionTitle(label: 'Adresse et contacts'),
                  _FieldWrap(
                    children: [
                      _WizardField(controller: _adresseCtrl, label: 'Adresse'),
                      _WizardField(controller: _contactUrgenceCtrl, label: 'Contact urgence'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StepSectionTitle(label: 'Documents identite'),
                  _FieldWrap(
                    children: [
                      _WizardField(controller: _cniCtrl, label: 'CNI'),
                      _WizardField(controller: _passeportCtrl, label: 'Passeport'),
                      _WizardField(controller: _permisCtrl, label: 'Permis'),
                      _WizardField(controller: _titreSejourCtrl, label: 'Titre de sejour'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StepSectionTitle(label: 'Donnees bancaires'),
                  _FieldWrap(
                    children: [
                      _WizardField(controller: _ribCtrl, label: 'RIB'),
                      _WizardField(controller: _bicCtrl, label: 'BIC'),
                      _WizardField(controller: _salaireVerseCtrl, label: 'Salaire verse'),
                    ],
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Contrat'),
              isActive: _currentStep >= 1,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StepSectionTitle(label: 'Contrat en cours'),
                  _FieldWrap(
                    children: [
                      _WizardField(controller: _contractCtrl, label: 'Type contrat (CDI/CDD/Stage)'),
                      _WizardField(controller: _statusCtrl, label: 'Statut contrat (Actif/Suspendu/Parti)'),
                      _WizardField(controller: _hireDateCtrl, label: 'Date embauche (YYYY-MM-DD)'),
                      _WizardField(controller: _contractStartDateCtrl, label: 'Date debut contrat'),
                      _WizardField(controller: _contractEndDateCtrl, label: 'Date fin contrat'),
                      _WizardField(controller: _periodeEssaiDureeCtrl, label: 'Periode essai (duree)'),
                      _WizardField(controller: _periodeEssaiFinCtrl, label: 'Periode essai (fin)'),
                      _WizardField(controller: _tempsTravailTypeCtrl, label: 'Temps de travail (plein/partiel)'),
                      _WizardField(controller: _tempsPartielPourcentageCtrl, label: 'Temps partiel (%)'),
                      _WizardField(controller: _classificationCtrl, label: 'Classification'),
                      _WizardField(controller: _coefficientCtrl, label: 'Coefficient'),
                      _WizardField(controller: _conventionCollectiveCtrl, label: 'Convention collective'),
                      _WizardField(controller: _statutCadreCtrl, label: 'Statut cadre (Oui/Non)'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StepSectionTitle(label: 'Documents RH'),
                  _FieldWrap(
                    children: [
                      _WizardField(controller: _avenantsCtrl, label: 'Avenants'),
                      _WizardField(controller: _charteCtrl, label: 'Charte informatique'),
                      _WizardField(controller: _confidentialiteCtrl, label: 'Confidentialite'),
                      _WizardField(controller: _clausesSigneesCtrl, label: 'Clauses signees'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StepSectionTitle(label: 'Documents obligatoires'),
                  _FieldWrap(
                    children: [
                      _WizardField(controller: _carteVitaleCtrl, label: 'Carte vitale / attestation'),
                      _WizardField(controller: _justificatifDomicileCtrl, label: 'Justificatif domicile'),
                      _WizardField(controller: _diplomesCertifiesCtrl, label: 'Diplomes certifies'),
                      _WizardField(controller: _habilitationsCtrl, label: 'Habilitations'),
                    ],
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Affectation'),
              isActive: _currentStep >= 2,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StepSectionTitle(label: 'Affectation'),
                  _FieldWrap(
                    children: [
                      _WizardSelectField(
                        controller: _departmentCtrl,
                        label: 'Departement',
                        options: widget.departmentOptions,
                      ),
                      _WizardSelectField(
                        controller: _roleCtrl,
                        label: 'Poste',
                        options: widget.roleOptions,
                      ),
                      _WizardField(controller: _posteActuelCtrl, label: 'Poste actuel'),
                      _WizardField(controller: _postePrecedentCtrl, label: 'Poste precedent'),
                      _WizardField(controller: _managerCtrl, label: 'Manager direct'),
                      _WizardField(controller: _entiteLegaleCtrl, label: 'Entite legale'),
                      _WizardField(controller: _siteAffectationCtrl, label: 'Site / etablissement'),
                      _WizardField(controller: _centreCoutCtrl, label: 'Centre de cout'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StepSectionTitle(label: 'Evolution'),
                  _FieldWrap(
                    children: [
                      _WizardField(controller: _promotionCtrl, label: 'Derniere promotion'),
                      _WizardField(controller: _augmentationCtrl, label: 'Augmentation'),
                      _WizardField(controller: _objectifsCtrl, label: 'Objectifs N+1'),
                      _WizardField(controller: _evaluationCtrl, label: 'Evaluation annuelle'),
                    ],
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Equipements'),
              isActive: _currentStep >= 3,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StepSectionTitle(label: 'Equipements et acces'),
                  _FieldWrap(
                    children: [
                      _WizardField(controller: _equipmentCtrl, label: 'Materiel attribue'),
                      _WizardField(controller: _pcPortableCtrl, label: 'PC portable'),
                      _WizardField(controller: _telephoneProCtrl, label: 'Telephone pro'),
                      _WizardField(controller: _badgeAccesCtrl, label: 'Badge acces'),
                      _WizardField(controller: _licenceCtrl, label: 'Licence'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StepSectionTitle(label: 'Remuneration'),
                  _FieldWrap(
                    children: [
                      _WizardField(controller: _salaireBaseCtrl, label: 'Salaire de base'),
                      _WizardField(controller: _primePerformanceCtrl, label: 'Prime performance'),
                      _WizardField(controller: _mutuelleCtrl, label: 'Mutuelle'),
                      _WizardField(controller: _ticketRestaurantCtrl, label: 'Ticket restaurant'),
                      _WizardField(controller: _dernierBulletinCtrl, label: 'Dernier bulletin'),
                      _WizardField(controller: _historiqueBulletinsCtrl, label: 'Historique bulletins'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StepSectionTitle(label: 'Paie et fiscalite'),
                  _FieldWrap(
                    children: [
                      _WizardField(controller: _regimeFiscalCtrl, label: 'Regime fiscal'),
                      _WizardField(controller: _tauxPasCtrl, label: 'Taux PAS'),
                      _WizardField(controller: _modePaiementCtrl, label: 'Mode paiement'),
                      _WizardField(controller: _variablesRecurrenceCtrl, label: 'Variables recurrentes'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StepSectionTitle(label: 'Presences et absences'),
                  _FieldWrap(
                    children: [
                      _WizardField(controller: _congesRestantsCtrl, label: 'Conges restants'),
                      _WizardField(controller: _rttRestantsCtrl, label: 'RTT restants'),
                      _WizardField(controller: _absencesJustifieesCtrl, label: 'Absences justifiees'),
                      _WizardField(controller: _retardsCtrl, label: 'Retards'),
                      _WizardField(controller: _teletravailCtrl, label: 'Teletravail'),
                      _WizardField(controller: _dernierPointageCtrl, label: 'Dernier pointage'),
                      _WizardField(controller: _planningContractuelCtrl, label: 'Planning contractuel'),
                      _WizardField(controller: _quotaHeuresCtrl, label: 'Quota heures'),
                      _WizardField(controller: _soldeCongesCalculeCtrl, label: 'Solde conges calcule'),
                      _WizardField(controller: _rttPeriodeCtrl, label: 'RTT par periode'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StepSectionTitle(label: 'Formations et competences'),
                  _FieldWrap(
                    children: [
                      _WizardField(controller: _diplomeCtrl, label: 'Dernier diplome'),
                      _WizardField(controller: _certificationCtrl, label: 'Certification'),
                      _WizardField(
                        controller: _formationsSuiviesCtrl,
                        label: 'Formations suivies (liste)',
                        helperText: 'Separer par virgules',
                      ),
                      _WizardField(
                        controller: _formationsPlanifieesCtrl,
                        label: 'Formations planifiees (liste)',
                        helperText: 'Separer par virgules',
                      ),
                      _WizardField(controller: _competencesTechCtrl, label: 'Competences techniques'),
                      _WizardField(controller: _competencesComportCtrl, label: 'Competences comportementales'),
                      _WizardField(controller: _languesCtrl, label: 'Langues'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StepSectionTitle(label: 'Conformite et securite'),
                  _FieldWrap(
                    children: [
                      _WizardField(controller: _consentementRgpdCtrl, label: 'Consentement RGPD'),
                      _WizardField(controller: _habilitationsSystemesCtrl, label: 'Habilitations systemes'),
                      _WizardField(controller: _historiqueModificationsCtrl, label: 'Historique modifications'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StepSectionTitle(label: 'Sante et securite'),
                  _FieldWrap(
                    children: [
                      _WizardField(controller: _visitesMedicalesCtrl, label: 'Visites medicales'),
                      _WizardField(controller: _aptitudeMedicaleCtrl, label: 'Aptitude medicale'),
                      _WizardField(controller: _restrictionsPosteCtrl, label: 'Restrictions poste'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _createAccount,
                    onChanged: (value) => setState(() => _createAccount = value),
                    title: const Text('Creer un compte utilisateur'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_createAccount)
                    _WizardField(controller: _accountCtrl, label: 'Identifiant utilisateur'),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _onboardingChecklist,
                    onChanged: (value) => setState(() => _onboardingChecklist = value),
                    title: const Text('Checklist onboarding'),
                    contentPadding: EdgeInsets.zero,
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

class _StepSectionTitle extends StatelessWidget {
  const _StepSectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: appTextPrimary(context),
        ),
      ),
    );
  }
}

class _FieldWrap extends StatelessWidget {
  const _FieldWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: children,
    );
  }
}

class _WizardField extends StatelessWidget {
  const _WizardField({
    required this.controller,
    required this.label,
    this.readOnly = false,
    this.helperText,
  });

  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
        ),
      ),
    );
  }
}

class _WizardSelectField extends StatelessWidget {
  const _WizardSelectField({
    required this.controller,
    required this.label,
    required this.options,
  });

  final TextEditingController controller;
  final String label;
  final List<_IdLabelOption> options;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return _WizardField(controller: controller, label: label);
    }

    final normalizedOptions = options.any((opt) => opt.id == controller.text) || controller.text.isEmpty
        ? options
        : [_IdLabelOption(id: controller.text, label: controller.text), ...options];
    final value = controller.text.isEmpty ? normalizedOptions.first.id : controller.text;

    return SizedBox(
      width: 260,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: normalizedOptions
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
        onChanged: (selected) {
          controller.text = selected ?? '';
        },
      ),
    );
  }
}

class _EditEmployeeDialog extends StatefulWidget {
  const _EditEmployeeDialog({
    required this.employe,
    required this.existing,
    required this.departmentOptions,
    required this.roleOptions,
  });

  final Employe employe;
  final List<Employe> existing;
  final List<_IdLabelOption> departmentOptions;
  final List<_IdLabelOption> roleOptions;

  @override
  State<_EditEmployeeDialog> createState() => _EditEmployeeDialogState();
}

class _EditEmployeeDialogState extends State<_EditEmployeeDialog> {
  final Map<String, TextEditingController> _controllers = {};
  String? _errorMessage;

  TextEditingController _ctrl(String key, String initial) {
    return _controllers.putIfAbsent(key, () => TextEditingController(text: initial));
  }

  @override
  void dispose() {
    for (final ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<bool> _isDuplicateEmail(String email) async {
    final localMatch = widget.existing.any(
      (e) => e.id != widget.employe.id && e.email.toLowerCase() == email.toLowerCase(),
    );
    if (localMatch) return true;
    return DaoRegistry.instance.employes.existsByEmail(email, excludeId: widget.employe.id);
  }

  List<String> _parseList(String input) {
    return input
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    final name = _ctrl('fullName', widget.employe.fullName).text.trim();
    final email = _ctrl('email', widget.employe.email).text.trim();
    final department = _ctrl('department', widget.employe.department).text.trim();
    final role = _ctrl('role', widget.employe.role).text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Le nom complet est requis.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Un email valide est requis.');
      return;
    }
    if (await _isDuplicateEmail(email)) {
      setState(() => _errorMessage = 'Email deja utilise.');
      return;
    }
    if (department.isEmpty || role.isEmpty) {
      setState(() => _errorMessage = 'Departement et poste requis.');
      return;
    }

    final updated = Employe(
      id: widget.employe.id,
      matricule: widget.employe.matricule,
      fullName: name,
      department: department,
      role: role,
      contractType: _ctrl('contractType', widget.employe.contractType).text.trim(),
      contractStatus: _ctrl('contractStatus', widget.employe.contractStatus).text.trim(),
      tenure: widget.employe.tenure,
      phone: _ctrl('phone', widget.employe.phone).text.trim(),
      email: email,
      skills: _parseList(
        '${_ctrl('competencesTech', widget.employe.competencesTech).text},'
        '${_ctrl('competencesComport', widget.employe.competencesComport).text}',
      ),
      hireDate: widget.employe.hireDate,
      status: _ctrl('status', widget.employe.status).text.trim(),
      dateNaissance: _ctrl('dateNaissance', widget.employe.dateNaissance).text.trim(),
      lieuNaissance: _ctrl('lieuNaissance', widget.employe.lieuNaissance).text.trim(),
      nationalite: _ctrl('nationalite', widget.employe.nationalite).text.trim(),
      etatCivilDetaille: _ctrl('etatCivilDetaille', widget.employe.etatCivilDetaille).text.trim(),
      nir: _ctrl('nir', widget.employe.nir).text.trim(),
      situationFamiliale: _ctrl('situationFamiliale', widget.employe.situationFamiliale).text.trim(),
      adresse: _ctrl('adresse', widget.employe.adresse).text.trim(),
      contactUrgence: _ctrl('contactUrgence', widget.employe.contactUrgence).text.trim(),
      cni: _ctrl('cni', widget.employe.cni).text.trim(),
      passeport: _ctrl('passeport', widget.employe.passeport).text.trim(),
      permis: _ctrl('permis', widget.employe.permis).text.trim(),
      titreSejour: _ctrl('titreSejour', widget.employe.titreSejour).text.trim(),
      rib: _ctrl('rib', widget.employe.rib).text.trim(),
      bic: _ctrl('bic', widget.employe.bic).text.trim(),
      salaireVerse: _ctrl('salaireVerse', widget.employe.salaireVerse).text.trim(),
      posteActuel: _ctrl('posteActuel', widget.employe.posteActuel).text.trim(),
      postePrecedent: _ctrl('postePrecedent', widget.employe.postePrecedent).text.trim(),
      dernierePromotion: _ctrl('dernierePromotion', widget.employe.dernierePromotion).text.trim(),
      augmentation: _ctrl('augmentation', widget.employe.augmentation).text.trim(),
      objectifs: _ctrl('objectifs', widget.employe.objectifs).text.trim(),
      evaluation: _ctrl('evaluation', widget.employe.evaluation).text.trim(),
      contractStartDate: _ctrl('contractStartDate', widget.employe.contractStartDate).text.trim(),
      contractEndDate: _ctrl('contractEndDate', widget.employe.contractEndDate).text.trim(),
      periodeEssaiDuree: _ctrl('periodeEssaiDuree', widget.employe.periodeEssaiDuree).text.trim(),
      periodeEssaiFin: _ctrl('periodeEssaiFin', widget.employe.periodeEssaiFin).text.trim(),
      tempsTravailType: _ctrl('tempsTravailType', widget.employe.tempsTravailType).text.trim(),
      tempsPartielPourcentage: _ctrl('tempsPartielPourcentage', widget.employe.tempsPartielPourcentage).text.trim(),
      classification: _ctrl('classification', widget.employe.classification).text.trim(),
      coefficient: _ctrl('coefficient', widget.employe.coefficient).text.trim(),
      conventionCollective: _ctrl('conventionCollective', widget.employe.conventionCollective).text.trim(),
      statutCadre: _ctrl('statutCadre', widget.employe.statutCadre).text.trim(),
      avenants: _ctrl('avenants', widget.employe.avenants).text.trim(),
      charteInformatique: _ctrl('charteInformatique', widget.employe.charteInformatique).text.trim(),
      confidentialite: _ctrl('confidentialite', widget.employe.confidentialite).text.trim(),
      clausesSignees: _ctrl('clausesSignees', widget.employe.clausesSignees).text.trim(),
      carteVitale: _ctrl('carteVitale', widget.employe.carteVitale).text.trim(),
      justificatifDomicile: _ctrl('justificatifDomicile', widget.employe.justificatifDomicile).text.trim(),
      diplomesCertifies: _ctrl('diplomesCertifies', widget.employe.diplomesCertifies).text.trim(),
      habilitations: _ctrl('habilitations', widget.employe.habilitations).text.trim(),
      diplome: _ctrl('diplome', widget.employe.diplome).text.trim(),
      certification: _ctrl('certification', widget.employe.certification).text.trim(),
      formationsSuivies: _parseList(_ctrl('formationsSuivies', widget.employe.formationsSuivies.join(', ')).text),
      formationsPlanifiees: _parseList(_ctrl('formationsPlanifiees', widget.employe.formationsPlanifiees.join(', ')).text),
      competencesTech: _ctrl('competencesTech', widget.employe.competencesTech).text.trim(),
      competencesComport: _ctrl('competencesComport', widget.employe.competencesComport).text.trim(),
      langues: _ctrl('langues', widget.employe.langues).text.trim(),
      congesRestants: _ctrl('congesRestants', widget.employe.congesRestants).text.trim(),
      rttRestants: _ctrl('rttRestants', widget.employe.rttRestants).text.trim(),
      absencesJustifiees: _ctrl('absencesJustifiees', widget.employe.absencesJustifiees).text.trim(),
      retards: _ctrl('retards', widget.employe.retards).text.trim(),
      teletravail: _ctrl('teletravail', widget.employe.teletravail).text.trim(),
      dernierPointage: _ctrl('dernierPointage', widget.employe.dernierPointage).text.trim(),
      planningContractuel: _ctrl('planningContractuel', widget.employe.planningContractuel).text.trim(),
      quotaHeures: _ctrl('quotaHeures', widget.employe.quotaHeures).text.trim(),
      soldeCongesCalcule: _ctrl('soldeCongesCalcule', widget.employe.soldeCongesCalcule).text.trim(),
      rttPeriode: _ctrl('rttPeriode', widget.employe.rttPeriode).text.trim(),
      salaireBase: _ctrl('salaireBase', widget.employe.salaireBase).text.trim(),
      primePerformance: _ctrl('primePerformance', widget.employe.primePerformance).text.trim(),
      mutuelle: _ctrl('mutuelle', widget.employe.mutuelle).text.trim(),
      ticketRestaurant: _ctrl('ticketRestaurant', widget.employe.ticketRestaurant).text.trim(),
      dernierBulletin: _ctrl('dernierBulletin', widget.employe.dernierBulletin).text.trim(),
      historiqueBulletins: _ctrl('historiqueBulletins', widget.employe.historiqueBulletins).text.trim(),
      regimeFiscal: _ctrl('regimeFiscal', widget.employe.regimeFiscal).text.trim(),
      tauxPas: _ctrl('tauxPas', widget.employe.tauxPas).text.trim(),
      modePaiement: _ctrl('modePaiement', widget.employe.modePaiement).text.trim(),
      variablesRecurrence: _ctrl('variablesRecurrence', widget.employe.variablesRecurrence).text.trim(),
      pcPortable: _ctrl('pcPortable', widget.employe.pcPortable).text.trim(),
      telephonePro: _ctrl('telephonePro', widget.employe.telephonePro).text.trim(),
      badgeAcces: _ctrl('badgeAcces', widget.employe.badgeAcces).text.trim(),
      licence: _ctrl('licence', widget.employe.licence).text.trim(),
      manager: _ctrl('manager', widget.employe.manager).text.trim(),
      entiteLegale: _ctrl('entiteLegale', widget.employe.entiteLegale).text.trim(),
      siteAffectation: _ctrl('siteAffectation', widget.employe.siteAffectation).text.trim(),
      centreCout: _ctrl('centreCout', widget.employe.centreCout).text.trim(),
      consentementRgpd: _ctrl('consentementRgpd', widget.employe.consentementRgpd).text.trim(),
      habilitationsSystemes: _ctrl('habilitationsSystemes', widget.employe.habilitationsSystemes).text.trim(),
      historiqueModifications: _ctrl('historiqueModifications', widget.employe.historiqueModifications).text.trim(),
      visitesMedicales: _ctrl('visitesMedicales', widget.employe.visitesMedicales).text.trim(),
      aptitudeMedicale: _ctrl('aptitudeMedicale', widget.employe.aptitudeMedicale).text.trim(),
      restrictionsPoste: _ctrl('restrictionsPoste', widget.employe.restrictionsPoste).text.trim(),
    );

    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier employe'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EditSection(
              title: 'Etat civil',
              children: [
                _EditField(controller: _ctrl('fullName', widget.employe.fullName), label: 'Nom complet'),
                _EditField(controller: _ctrl('dateNaissance', widget.employe.dateNaissance), label: 'Date naissance'),
                _EditField(controller: _ctrl('lieuNaissance', widget.employe.lieuNaissance), label: 'Lieu naissance'),
                _EditField(controller: _ctrl('nationalite', widget.employe.nationalite), label: 'Nationalite'),
                _EditField(controller: _ctrl('situationFamiliale', widget.employe.situationFamiliale), label: 'Situation familiale'),
                _EditField(controller: _ctrl('etatCivilDetaille', widget.employe.etatCivilDetaille), label: 'Etat civil detaille'),
                _EditField(controller: _ctrl('nir', widget.employe.nir), label: 'Numero securite sociale'),
              ],
            ),
            _EditSection(
              title: 'Identite et contacts',
              children: [
                _EditField(controller: _ctrl('matricule', widget.employe.matricule), label: 'Matricule', readOnly: true),
                _EditField(controller: _ctrl('phone', widget.employe.phone), label: 'Telephone'),
                _EditField(controller: _ctrl('email', widget.employe.email), label: 'Email'),
                _EditField(controller: _ctrl('adresse', widget.employe.adresse), label: 'Adresse'),
                _EditField(controller: _ctrl('contactUrgence', widget.employe.contactUrgence), label: 'Contact urgence'),
              ],
            ),
            _EditSection(
              title: 'Documents identite',
              children: [
                _EditField(controller: _ctrl('cni', widget.employe.cni), label: 'CNI'),
                _EditField(controller: _ctrl('passeport', widget.employe.passeport), label: 'Passeport'),
                _EditField(controller: _ctrl('permis', widget.employe.permis), label: 'Permis'),
                _EditField(controller: _ctrl('titreSejour', widget.employe.titreSejour), label: 'Titre de sejour'),
              ],
            ),
            _EditSection(
              title: 'Donnees bancaires',
              children: [
                _EditField(controller: _ctrl('rib', widget.employe.rib), label: 'RIB'),
                _EditField(controller: _ctrl('bic', widget.employe.bic), label: 'BIC'),
                _EditField(controller: _ctrl('salaireVerse', widget.employe.salaireVerse), label: 'Salaire verse'),
              ],
            ),
            _EditSection(
              title: 'Affectation',
              children: [
                _EditSelectField(
                  controller: _ctrl('department', widget.employe.department),
                  label: 'Departement',
                  options: widget.departmentOptions,
                ),
                _EditSelectField(
                  controller: _ctrl('role', widget.employe.role),
                  label: 'Poste',
                  options: widget.roleOptions,
                ),
                _EditField(controller: _ctrl('status', widget.employe.status), label: 'Statut employe'),
                _EditField(controller: _ctrl('manager', widget.employe.manager), label: 'Manager direct'),
                _EditField(controller: _ctrl('entiteLegale', widget.employe.entiteLegale), label: 'Entite legale'),
                _EditField(controller: _ctrl('siteAffectation', widget.employe.siteAffectation), label: 'Site / etablissement'),
                _EditField(controller: _ctrl('centreCout', widget.employe.centreCout), label: 'Centre de cout'),
              ],
            ),
            _EditSection(
              title: 'Carriere professionnelle',
              children: [
                _EditField(controller: _ctrl('posteActuel', widget.employe.posteActuel), label: 'Poste actuel'),
                _EditField(controller: _ctrl('postePrecedent', widget.employe.postePrecedent), label: 'Poste precedent'),
                _EditField(controller: _ctrl('dernierePromotion', widget.employe.dernierePromotion), label: 'Derniere promotion'),
                _EditField(controller: _ctrl('augmentation', widget.employe.augmentation), label: 'Augmentation'),
                _EditField(controller: _ctrl('objectifs', widget.employe.objectifs), label: 'Objectifs N+1'),
                _EditField(controller: _ctrl('evaluation', widget.employe.evaluation), label: 'Evaluation annuelle'),
              ],
            ),
            _EditSection(
              title: 'Contrats et documents',
              children: [
                _EditField(controller: _ctrl('contractType', widget.employe.contractType), label: 'Type contrat'),
                _EditField(controller: _ctrl('contractStatus', widget.employe.contractStatus), label: 'Statut contrat'),
                _EditField(controller: _ctrl('contractStartDate', widget.employe.contractStartDate), label: 'Date debut'),
                _EditField(controller: _ctrl('contractEndDate', widget.employe.contractEndDate), label: 'Date fin'),
                _EditField(controller: _ctrl('periodeEssaiDuree', widget.employe.periodeEssaiDuree), label: 'Periode essai (duree)'),
                _EditField(controller: _ctrl('periodeEssaiFin', widget.employe.periodeEssaiFin), label: 'Periode essai (fin)'),
                _EditField(controller: _ctrl('tempsTravailType', widget.employe.tempsTravailType), label: 'Temps de travail'),
                _EditField(controller: _ctrl('tempsPartielPourcentage', widget.employe.tempsPartielPourcentage), label: 'Temps partiel (%)'),
                _EditField(controller: _ctrl('classification', widget.employe.classification), label: 'Classification'),
                _EditField(controller: _ctrl('coefficient', widget.employe.coefficient), label: 'Coefficient'),
                _EditField(controller: _ctrl('conventionCollective', widget.employe.conventionCollective), label: 'Convention collective'),
                _EditField(controller: _ctrl('statutCadre', widget.employe.statutCadre), label: 'Statut cadre'),
                _EditField(controller: _ctrl('avenants', widget.employe.avenants), label: 'Avenants'),
                _EditField(controller: _ctrl('charteInformatique', widget.employe.charteInformatique), label: 'Charte informatique'),
                _EditField(controller: _ctrl('confidentialite', widget.employe.confidentialite), label: 'Confidentialite'),
                _EditField(controller: _ctrl('clausesSignees', widget.employe.clausesSignees), label: 'Clauses signees'),
              ],
            ),
            _EditSection(
              title: 'Documents obligatoires',
              children: [
                _EditField(controller: _ctrl('carteVitale', widget.employe.carteVitale), label: 'Carte vitale / attestation'),
                _EditField(controller: _ctrl('justificatifDomicile', widget.employe.justificatifDomicile), label: 'Justificatif domicile'),
                _EditField(controller: _ctrl('diplomesCertifies', widget.employe.diplomesCertifies), label: 'Diplomes certifies'),
                _EditField(controller: _ctrl('habilitations', widget.employe.habilitations), label: 'Habilitations'),
              ],
            ),
            _EditSection(
              title: 'Formations et competences',
              children: [
                _EditField(controller: _ctrl('diplome', widget.employe.diplome), label: 'Dernier diplome'),
                _EditField(controller: _ctrl('certification', widget.employe.certification), label: 'Certification'),
                _EditField(controller: _ctrl('formationsSuivies', widget.employe.formationsSuivies.join(', ')), label: 'Formations suivies'),
                _EditField(controller: _ctrl('formationsPlanifiees', widget.employe.formationsPlanifiees.join(', ')), label: 'Formations planifiees'),
                _EditField(controller: _ctrl('competencesTech', widget.employe.competencesTech), label: 'Competences techniques'),
                _EditField(controller: _ctrl('competencesComport', widget.employe.competencesComport), label: 'Competences comportementales'),
                _EditField(controller: _ctrl('langues', widget.employe.langues), label: 'Langues'),
              ],
            ),
            _EditSection(
              title: 'Presences et absences',
              children: [
                _EditField(controller: _ctrl('congesRestants', widget.employe.congesRestants), label: 'Conges restants'),
                _EditField(controller: _ctrl('rttRestants', widget.employe.rttRestants), label: 'RTT restants'),
                _EditField(controller: _ctrl('absencesJustifiees', widget.employe.absencesJustifiees), label: 'Absences justifiees'),
                _EditField(controller: _ctrl('retards', widget.employe.retards), label: 'Retards'),
                _EditField(controller: _ctrl('teletravail', widget.employe.teletravail), label: 'Teletravail'),
                _EditField(controller: _ctrl('dernierPointage', widget.employe.dernierPointage), label: 'Dernier pointage'),
                _EditField(controller: _ctrl('planningContractuel', widget.employe.planningContractuel), label: 'Planning contractuel'),
                _EditField(controller: _ctrl('quotaHeures', widget.employe.quotaHeures), label: 'Quota heures'),
                _EditField(controller: _ctrl('soldeCongesCalcule', widget.employe.soldeCongesCalcule), label: 'Solde conges calcule'),
                _EditField(controller: _ctrl('rttPeriode', widget.employe.rttPeriode), label: 'RTT par periode'),
              ],
            ),
            _EditSection(
              title: 'Remuneration et avantages',
              children: [
                _EditField(controller: _ctrl('salaireBase', widget.employe.salaireBase), label: 'Salaire de base'),
                _EditField(controller: _ctrl('primePerformance', widget.employe.primePerformance), label: 'Prime performance'),
                _EditField(controller: _ctrl('mutuelle', widget.employe.mutuelle), label: 'Mutuelle'),
                _EditField(controller: _ctrl('ticketRestaurant', widget.employe.ticketRestaurant), label: 'Ticket restaurant'),
                _EditField(controller: _ctrl('dernierBulletin', widget.employe.dernierBulletin), label: 'Dernier bulletin'),
                _EditField(controller: _ctrl('historiqueBulletins', widget.employe.historiqueBulletins), label: 'Historique bulletins'),
                _EditField(controller: _ctrl('regimeFiscal', widget.employe.regimeFiscal), label: 'Regime fiscal'),
                _EditField(controller: _ctrl('tauxPas', widget.employe.tauxPas), label: 'Taux PAS'),
                _EditField(controller: _ctrl('modePaiement', widget.employe.modePaiement), label: 'Mode paiement'),
                _EditField(controller: _ctrl('variablesRecurrence', widget.employe.variablesRecurrence), label: 'Variables recurrentes'),
              ],
            ),
            _EditSection(
              title: 'Equipements et acces',
              children: [
                _EditField(controller: _ctrl('pcPortable', widget.employe.pcPortable), label: 'PC portable'),
                _EditField(controller: _ctrl('telephonePro', widget.employe.telephonePro), label: 'Telephone pro'),
                _EditField(controller: _ctrl('badgeAcces', widget.employe.badgeAcces), label: 'Badge acces'),
                _EditField(controller: _ctrl('licence', widget.employe.licence), label: 'Licence'),
              ],
            ),
            _EditSection(
              title: 'Conformite et securite',
              children: [
                _EditField(controller: _ctrl('consentementRgpd', widget.employe.consentementRgpd), label: 'Consentement RGPD'),
                _EditField(controller: _ctrl('habilitationsSystemes', widget.employe.habilitationsSystemes), label: 'Habilitations systemes'),
                _EditField(controller: _ctrl('historiqueModifications', widget.employe.historiqueModifications), label: 'Historique modifications'),
              ],
            ),
            _EditSection(
              title: 'Sante et securite',
              children: [
                _EditField(controller: _ctrl('visitesMedicales', widget.employe.visitesMedicales), label: 'Visites medicales'),
                _EditField(controller: _ctrl('aptitudeMedicale', widget.employe.aptitudeMedicale), label: 'Aptitude medicale'),
                _EditField(controller: _ctrl('restrictionsPoste', widget.employe.restrictionsPoste), label: 'Restrictions poste'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditSection extends StatelessWidget {
  const _EditSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
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
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: children,
            ),
          ],
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.controller,
    required this.label,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String label;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _EditSelectField extends StatelessWidget {
  const _EditSelectField({
    required this.controller,
    required this.label,
    required this.options,
  });

  final TextEditingController controller;
  final String label;
  final List<_IdLabelOption> options;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return _EditField(controller: controller, label: label);
    }

    final normalizedOptions = options.any((opt) => opt.id == controller.text) || controller.text.isEmpty
        ? options
        : [_IdLabelOption(id: controller.text, label: controller.text), ...options];
    final value = controller.text.isEmpty ? normalizedOptions.first.id : controller.text;

    return SizedBox(
      width: 260,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: normalizedOptions
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
        onChanged: (selected) {
          controller.text = selected ?? '';
        },
      ),
    );
  }
}

class _EpochRange {
  const _EpochRange(this.start, this.end);

  final int start;
  final int end;
}

class _IdLabelOption {
  const _IdLabelOption({required this.id, required this.label});

  final String id;
  final String label;
}

class _NormalizationResult {
  const _NormalizationResult(this.employees, this.updated);

  final List<Employe> employees;
  final List<Employe> updated;
}

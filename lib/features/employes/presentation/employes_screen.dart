import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
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
  final List<Employe> _allEmployees = [
    Employe(
      id: '1',
      matricule: 'EMP-0021',
      fullName: 'Amina Diallo',
      department: 'Marketing',
      role: 'Chef de projet',
      contractType: 'CDI',
      contractStatus: 'Actif',
      tenure: '4 ans',
      phone: '90 11 22 33',
      email: 'amina.diallo@entreprise.tg',
      skills: ['Gestion', 'Communication'],
      hireDate: DateTime(2020, 4, 2),
      status: 'Actif',
    ),
    Employe(
      id: '2',
      matricule: 'EMP-0044',
      fullName: 'Yann Leclerc',
      department: 'Finance',
      role: 'Comptable',
      contractType: 'CDD',
      contractStatus: 'Actif',
      tenure: '1 an',
      phone: '90 44 55 66',
      email: 'yann.leclerc@entreprise.tg',
      skills: ['Fiscalite', 'Budget'],
      hireDate: DateTime(2023, 2, 15),
      status: 'Actif',
    ),
    Employe(
      id: '3',
      matricule: 'EMP-0078',
      fullName: 'Samuel Mensah',
      department: 'IT',
      role: 'Dev Flutter',
      contractType: 'CDI',
      contractStatus: 'Actif',
      tenure: '2 ans',
      phone: '90 77 88 99',
      email: 'samuel.mensah@entreprise.tg',
      skills: ['Flutter', 'SQLite'],
      hireDate: DateTime(2022, 7, 1),
      status: 'Actif',
    ),
  ];

  final Set<String> _selectedIds = {};

  String _filterDepartment = 'Tous';
  String _filterContract = 'Tous';
  String _filterStatus = 'Tous';
  String _filterHireDate = '';

  String _searchName = '';
  String _searchMatricule = '';
  String _searchPhone = '';
  String _searchEmail = '';
  String _searchSkills = '';

  List<Employe> get _filteredEmployees {
    return _allEmployees.where((emp) {
      final matchDept = _filterDepartment == 'Tous' || emp.department == _filterDepartment;
      final matchContract = _filterContract == 'Tous' || emp.contractType == _filterContract;
      final matchStatus = _filterStatus == 'Tous' || emp.status == _filterStatus;
      final matchHireDate = _filterHireDate.isEmpty || emp.hireDate.toIso8601String().startsWith(_filterHireDate);

      final matchName = _searchName.isEmpty || emp.fullName.toLowerCase().contains(_searchName.toLowerCase());
      final matchMatricule = _searchMatricule.isEmpty || emp.matricule.toLowerCase().contains(_searchMatricule.toLowerCase());
      final matchPhone = _searchPhone.isEmpty || emp.phone.contains(_searchPhone);
      final matchEmail = _searchEmail.isEmpty || emp.email.toLowerCase().contains(_searchEmail.toLowerCase());
      final matchSkills = _searchSkills.isEmpty || emp.skills.join(' ').toLowerCase().contains(_searchSkills.toLowerCase());

      return matchDept && matchContract && matchStatus && matchHireDate && matchName && matchMatricule && matchPhone && matchEmail && matchSkills;
    }).toList();
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
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: EmployeeDetailScreen(employe: employe),
      ),
    );
  }

  void _showNewEmployeeWizard() {
    showDialog<Employe>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _NewEmployeeWizardDialog(existing: _allEmployees),
      ),
    ).then((created) {
      if (created == null) return;
      setState(() => _allEmployees.add(created));
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
          const SectionHeader(
            title: 'Registre du personnel',
            subtitle: 'Vue globale des employes et statut contrat.',
          ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditEmployeeDialog(Employe employe) async {
    final updated = await showDialog<Employe>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: _EditEmployeeDialog(
          employe: employe,
          existing: _allEmployees,
        ),
      ),
    );

    if (updated == null) return;
    final index = _allEmployees.indexWhere((e) => e.id == employe.id);
    if (index == -1) return;
    setState(() => _allEmployees[index] = updated);
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
    setState(() => _allEmployees.removeWhere((e) => e.id == employe.id));
    showOperationNotice(context, message: 'Employe supprime.', success: true);
  }

  Widget _buildFilterRow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 980;
        final filters = [
          _FilterDropdown(
            label: 'Departement',
            value: _filterDepartment,
            items: const ['Tous', 'Marketing', 'Finance', 'IT'],
            onChanged: (value) => setState(() => _filterDepartment = value),
          ),
          _FilterDropdown(
            label: 'Contrat',
            value: _filterContract,
            items: const ['Tous', 'CDI', 'CDD', 'Stage'],
            onChanged: (value) => setState(() => _filterContract = value),
          ),
          _FilterDropdown(
            label: 'Statut',
            value: _filterStatus,
            items: const ['Tous', 'Actif', 'Suspendu', 'Parti'],
            onChanged: (value) => setState(() => _filterStatus = value),
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
              onChanged: (value) => setState(() => _filterHireDate = value.trim()),
            ),
          ),
        ];

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

        if (isWide) {
          return Row(
            children: [
              ...filters.map((w) => Padding(padding: const EdgeInsets.only(right: 12), child: w)),
              const Spacer(),
              actionButton,
            ],
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...filters,
            actionButton,
          ],
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
              onChanged: (value) => setState(() => _searchName = value),
            ),
            _SearchField(
              label: 'Matricule',
              onChanged: (value) => setState(() => _searchMatricule = value),
            ),
            _SearchField(
              label: 'Telephone',
              onChanged: (value) => setState(() => _searchPhone = value),
            ),
            _SearchField(
              label: 'Email',
              onChanged: (value) => setState(() => _searchEmail = value),
            ),
            _SearchField(
              label: 'Competences',
              onChanged: (value) => setState(() => _searchSkills = value),
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
    final rows = _filteredEmployees;

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
                DataCell(Text(emp.fullName)),
                DataCell(Text(emp.department)),
                DataCell(Text(emp.role)),
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
        decoration: InputDecoration(
          labelText: label,
          filled: true,
        ),
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
  const _NewEmployeeWizardDialog({required this.existing});

  final List<Employe> existing;

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
  final TextEditingController _situationFamilialeCtrl = TextEditingController();
  final TextEditingController _adresseCtrl = TextEditingController();
  final TextEditingController _contactUrgenceCtrl = TextEditingController();
  final TextEditingController _cniCtrl = TextEditingController();
  final TextEditingController _passeportCtrl = TextEditingController();
  final TextEditingController _permisCtrl = TextEditingController();
  final TextEditingController _ribCtrl = TextEditingController();
  final TextEditingController _salaireVerseCtrl = TextEditingController();
  final TextEditingController _contractCtrl = TextEditingController();
  final TextEditingController _statusCtrl = TextEditingController(text: 'Actif');
  final TextEditingController _hireDateCtrl = TextEditingController();
  final TextEditingController _contractStartDateCtrl = TextEditingController();
  final TextEditingController _avenantsCtrl = TextEditingController();
  final TextEditingController _charteCtrl = TextEditingController();
  final TextEditingController _confidentialiteCtrl = TextEditingController();
  final TextEditingController _departmentCtrl = TextEditingController();
  final TextEditingController _roleCtrl = TextEditingController();
  final TextEditingController _posteActuelCtrl = TextEditingController();
  final TextEditingController _postePrecedentCtrl = TextEditingController();
  final TextEditingController _promotionCtrl = TextEditingController();
  final TextEditingController _augmentationCtrl = TextEditingController();
  final TextEditingController _objectifsCtrl = TextEditingController();
  final TextEditingController _evaluationCtrl = TextEditingController();
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
  final TextEditingController _salaireBaseCtrl = TextEditingController();
  final TextEditingController _primePerformanceCtrl = TextEditingController();
  final TextEditingController _mutuelleCtrl = TextEditingController();
  final TextEditingController _ticketRestaurantCtrl = TextEditingController();
  final TextEditingController _dernierBulletinCtrl = TextEditingController();
  final TextEditingController _historiqueBulletinsCtrl = TextEditingController();
  final TextEditingController _equipmentCtrl = TextEditingController();
  final TextEditingController _pcPortableCtrl = TextEditingController();
  final TextEditingController _telephoneProCtrl = TextEditingController();
  final TextEditingController _badgeAccesCtrl = TextEditingController();
  final TextEditingController _licenceCtrl = TextEditingController();
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

  bool _isDuplicateEmail(String email) {
    return widget.existing.any((e) => e.email.toLowerCase() == email.toLowerCase());
  }

  bool _isDuplicateMatricule(String matricule) {
    return widget.existing.any((e) => e.matricule == matricule);
  }

  List<String> _parseList(String input) {
    return input
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  bool _validateStep(int step) {
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
      if (_isDuplicateEmail(_emailCtrl.text.trim())) {
        _errorMessage = 'Email deja utilise.';
        return false;
      }
      if (_isDuplicateMatricule(_matricule)) {
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
      situationFamiliale: _situationFamilialeCtrl.text.trim(),
      adresse: _adresseCtrl.text.trim(),
      contactUrgence: _contactUrgenceCtrl.text.trim(),
      cni: _cniCtrl.text.trim(),
      passeport: _passeportCtrl.text.trim(),
      permis: _permisCtrl.text.trim(),
      rib: _ribCtrl.text.trim(),
      salaireVerse: _salaireVerseCtrl.text.trim(),
      posteActuel: _posteActuelCtrl.text.trim(),
      postePrecedent: _postePrecedentCtrl.text.trim(),
      dernierePromotion: _promotionCtrl.text.trim(),
      augmentation: _augmentationCtrl.text.trim(),
      objectifs: _objectifsCtrl.text.trim(),
      evaluation: _evaluationCtrl.text.trim(),
      contractStartDate: _contractStartDateCtrl.text.trim(),
      avenants: _avenantsCtrl.text.trim(),
      charteInformatique: _charteCtrl.text.trim(),
      confidentialite: _confidentialiteCtrl.text.trim(),
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
      salaireBase: _salaireBaseCtrl.text.trim(),
      primePerformance: _primePerformanceCtrl.text.trim(),
      mutuelle: _mutuelleCtrl.text.trim(),
      ticketRestaurant: _ticketRestaurantCtrl.text.trim(),
      dernierBulletin: _dernierBulletinCtrl.text.trim(),
      historiqueBulletins: _historiqueBulletinsCtrl.text.trim(),
      pcPortable: _pcPortableCtrl.text.trim(),
      telephonePro: _telephoneProCtrl.text.trim(),
      badgeAcces: _badgeAccesCtrl.text.trim(),
      licence: _licenceCtrl.text.trim(),
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
          onStepContinue: () {
            if (!_validateStep(_currentStep)) return;
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StepSectionTitle(label: 'Donnees bancaires'),
                  _FieldWrap(
                    children: [
                      _WizardField(controller: _ribCtrl, label: 'RIB'),
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StepSectionTitle(label: 'Documents RH'),
                  _FieldWrap(
                    children: [
                      _WizardField(controller: _avenantsCtrl, label: 'Avenants'),
                      _WizardField(controller: _charteCtrl, label: 'Charte informatique'),
                      _WizardField(controller: _confidentialiteCtrl, label: 'Confidentialite'),
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
                      _WizardField(controller: _departmentCtrl, label: 'Departement'),
                      _WizardField(controller: _roleCtrl, label: 'Poste'),
                      _WizardField(controller: _posteActuelCtrl, label: 'Poste actuel'),
                      _WizardField(controller: _postePrecedentCtrl, label: 'Poste precedent'),
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
                  _StepSectionTitle(label: 'Presences et absences'),
                  _FieldWrap(
                    children: [
                      _WizardField(controller: _congesRestantsCtrl, label: 'Conges restants'),
                      _WizardField(controller: _rttRestantsCtrl, label: 'RTT restants'),
                      _WizardField(controller: _absencesJustifieesCtrl, label: 'Absences justifiees'),
                      _WizardField(controller: _retardsCtrl, label: 'Retards'),
                      _WizardField(controller: _teletravailCtrl, label: 'Teletravail'),
                      _WizardField(controller: _dernierPointageCtrl, label: 'Dernier pointage'),
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

class _EditEmployeeDialog extends StatefulWidget {
  const _EditEmployeeDialog({required this.employe, required this.existing});

  final Employe employe;
  final List<Employe> existing;

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

  bool _isDuplicateEmail(String email) {
    return widget.existing.any(
      (e) => e.id != widget.employe.id && e.email.toLowerCase() == email.toLowerCase(),
    );
  }

  List<String> _parseList(String input) {
    return input
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  void _save() {
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
    if (_isDuplicateEmail(email)) {
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
      situationFamiliale: _ctrl('situationFamiliale', widget.employe.situationFamiliale).text.trim(),
      adresse: _ctrl('adresse', widget.employe.adresse).text.trim(),
      contactUrgence: _ctrl('contactUrgence', widget.employe.contactUrgence).text.trim(),
      cni: _ctrl('cni', widget.employe.cni).text.trim(),
      passeport: _ctrl('passeport', widget.employe.passeport).text.trim(),
      permis: _ctrl('permis', widget.employe.permis).text.trim(),
      rib: _ctrl('rib', widget.employe.rib).text.trim(),
      salaireVerse: _ctrl('salaireVerse', widget.employe.salaireVerse).text.trim(),
      posteActuel: _ctrl('posteActuel', widget.employe.posteActuel).text.trim(),
      postePrecedent: _ctrl('postePrecedent', widget.employe.postePrecedent).text.trim(),
      dernierePromotion: _ctrl('dernierePromotion', widget.employe.dernierePromotion).text.trim(),
      augmentation: _ctrl('augmentation', widget.employe.augmentation).text.trim(),
      objectifs: _ctrl('objectifs', widget.employe.objectifs).text.trim(),
      evaluation: _ctrl('evaluation', widget.employe.evaluation).text.trim(),
      contractStartDate: _ctrl('contractStartDate', widget.employe.contractStartDate).text.trim(),
      avenants: _ctrl('avenants', widget.employe.avenants).text.trim(),
      charteInformatique: _ctrl('charteInformatique', widget.employe.charteInformatique).text.trim(),
      confidentialite: _ctrl('confidentialite', widget.employe.confidentialite).text.trim(),
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
      salaireBase: _ctrl('salaireBase', widget.employe.salaireBase).text.trim(),
      primePerformance: _ctrl('primePerformance', widget.employe.primePerformance).text.trim(),
      mutuelle: _ctrl('mutuelle', widget.employe.mutuelle).text.trim(),
      ticketRestaurant: _ctrl('ticketRestaurant', widget.employe.ticketRestaurant).text.trim(),
      dernierBulletin: _ctrl('dernierBulletin', widget.employe.dernierBulletin).text.trim(),
      historiqueBulletins: _ctrl('historiqueBulletins', widget.employe.historiqueBulletins).text.trim(),
      pcPortable: _ctrl('pcPortable', widget.employe.pcPortable).text.trim(),
      telephonePro: _ctrl('telephonePro', widget.employe.telephonePro).text.trim(),
      badgeAcces: _ctrl('badgeAcces', widget.employe.badgeAcces).text.trim(),
      licence: _ctrl('licence', widget.employe.licence).text.trim(),
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
                _EditField(controller: _ctrl('situationFamiliale', widget.employe.situationFamiliale), label: 'Situation familiale'),
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
              ],
            ),
            _EditSection(
              title: 'Donnees bancaires',
              children: [
                _EditField(controller: _ctrl('rib', widget.employe.rib), label: 'RIB'),
                _EditField(controller: _ctrl('salaireVerse', widget.employe.salaireVerse), label: 'Salaire verse'),
              ],
            ),
            _EditSection(
              title: 'Affectation',
              children: [
                _EditField(controller: _ctrl('department', widget.employe.department), label: 'Departement'),
                _EditField(controller: _ctrl('role', widget.employe.role), label: 'Poste'),
                _EditField(controller: _ctrl('status', widget.employe.status), label: 'Statut employe'),
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
                _EditField(controller: _ctrl('avenants', widget.employe.avenants), label: 'Avenants'),
                _EditField(controller: _ctrl('charteInformatique', widget.employe.charteInformatique), label: 'Charte informatique'),
                _EditField(controller: _ctrl('confidentialite', widget.employe.confidentialite), label: 'Confidentialite'),
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

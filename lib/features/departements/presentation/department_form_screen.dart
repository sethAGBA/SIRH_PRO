import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/dao/dao_registry.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/models/departement.dart';

class DepartmentFormScreen extends StatefulWidget {
  const DepartmentFormScreen({super.key, this.departement});

  final Departement? departement;

  @override
  State<DepartmentFormScreen> createState() => _DepartmentFormScreenState();
}

class _DepartmentFormScreenState extends State<DepartmentFormScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _managerCtrl;
  late final TextEditingController _headcountCtrl;
  late final TextEditingController _budgetCtrl;
  late final TextEditingController _poleCtrl;
  late final TextEditingController _sizeCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _extensionCtrl;
  late final TextEditingController _adresseCtrl;
  late final TextEditingController _parentDeptCtrl;
  late final TextEditingController _dateCreationCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _responsablesCtrl;
  late final TextEditingController _cadresCountCtrl;
  late final TextEditingController _techniciensCountCtrl;
  late final TextEditingController _supportCountCtrl;
  late final TextEditingController _variationAnnuelleCtrl;
  late final TextEditingController _tauxAbsenteismeCtrl;
  late final TextEditingController _productiviteMoyenneCtrl;
  late final TextEditingController _satisfactionEquipeCtrl;
  late final TextEditingController _turnoverDepartementCtrl;
  late final TextEditingController _budgetVsRealiseCtrl;
  late final TextEditingController _salairesTotauxCtrl;
  late final TextEditingController _primesVariablesCtrl;
  late final TextEditingController _chargesSocialesCtrl;
  late final TextEditingController _coutMoyenEmployeCtrl;
  late final TextEditingController _objectifPrincipalCtrl;
  late final TextEditingController _indicateurObjectifCtrl;
  late final TextEditingController _projetEnCoursCtrl;
  late final TextEditingController _ressourcesNecessairesCtrl;
  String _status = 'Brouillon';
  List<_SelectOption> _parentOptions = [];
  bool _loadingParents = true;
  List<_SelectOption> _managerOptions = [];
  bool _loadingManagers = true;

  String? _errorMessage;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.departement?.name ?? '');
    _managerCtrl = TextEditingController(text: widget.departement?.managerId ?? '');
    _headcountCtrl = TextEditingController(
      text: widget.departement != null ? widget.departement!.headcount.toString() : '',
    );
    _budgetCtrl = TextEditingController(text: widget.departement?.budget ?? '');
    _poleCtrl = TextEditingController(text: widget.departement?.pole ?? '');
    _sizeCtrl = TextEditingController(text: widget.departement?.size ?? '');
    _locationCtrl = TextEditingController(text: widget.departement?.location ?? '');
    _codeCtrl = TextEditingController(text: widget.departement?.code ?? '');
    _descriptionCtrl = TextEditingController(text: widget.departement?.description ?? '');
    _emailCtrl = TextEditingController(text: widget.departement?.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.departement?.phone ?? '');
    _extensionCtrl = TextEditingController(text: widget.departement?.extension ?? '');
    _adresseCtrl = TextEditingController(text: widget.departement?.adresse ?? '');
    _parentDeptCtrl = TextEditingController(text: widget.departement?.parentDepartementId ?? '');
    _dateCreationCtrl = TextEditingController(text: widget.departement?.dateCreation ?? '');
    _notesCtrl = TextEditingController(text: widget.departement?.notes ?? '');
    _responsablesCtrl = TextEditingController(text: widget.departement?.responsables ?? '');
    _cadresCountCtrl = TextEditingController(text: widget.departement?.cadresCount ?? '');
    _techniciensCountCtrl = TextEditingController(text: widget.departement?.techniciensCount ?? '');
    _supportCountCtrl = TextEditingController(text: widget.departement?.supportCount ?? '');
    _variationAnnuelleCtrl = TextEditingController(text: widget.departement?.variationAnnuelle ?? '');
    _tauxAbsenteismeCtrl = TextEditingController(text: widget.departement?.tauxAbsenteisme ?? '');
    _productiviteMoyenneCtrl = TextEditingController(text: widget.departement?.productiviteMoyenne ?? '');
    _satisfactionEquipeCtrl = TextEditingController(text: widget.departement?.satisfactionEquipe ?? '');
    _turnoverDepartementCtrl = TextEditingController(text: widget.departement?.turnoverDepartement ?? '');
    _budgetVsRealiseCtrl = TextEditingController(text: widget.departement?.budgetVsRealise ?? '');
    _salairesTotauxCtrl = TextEditingController(text: widget.departement?.salairesTotaux ?? '');
    _primesVariablesCtrl = TextEditingController(text: widget.departement?.primesVariables ?? '');
    _chargesSocialesCtrl = TextEditingController(text: widget.departement?.chargesSociales ?? '');
    _coutMoyenEmployeCtrl = TextEditingController(text: widget.departement?.coutMoyenEmploye ?? '');
    _objectifPrincipalCtrl = TextEditingController(text: widget.departement?.objectifPrincipal ?? '');
    _indicateurObjectifCtrl = TextEditingController(text: widget.departement?.indicateurObjectif ?? '');
    _projetEnCoursCtrl = TextEditingController(text: widget.departement?.projetEnCours ?? '');
    _ressourcesNecessairesCtrl = TextEditingController(text: widget.departement?.ressourcesNecessaires ?? '');
    _status = widget.departement?.status ?? 'Brouillon';
    _loadParentOptions();
    _loadManagerOptions();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _managerCtrl.dispose();
    _headcountCtrl.dispose();
    _budgetCtrl.dispose();
    _poleCtrl.dispose();
    _sizeCtrl.dispose();
    _locationCtrl.dispose();
    _codeCtrl.dispose();
    _descriptionCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _extensionCtrl.dispose();
    _adresseCtrl.dispose();
    _parentDeptCtrl.dispose();
    _dateCreationCtrl.dispose();
    _notesCtrl.dispose();
    _responsablesCtrl.dispose();
    _cadresCountCtrl.dispose();
    _techniciensCountCtrl.dispose();
    _supportCountCtrl.dispose();
    _variationAnnuelleCtrl.dispose();
    _tauxAbsenteismeCtrl.dispose();
    _productiviteMoyenneCtrl.dispose();
    _satisfactionEquipeCtrl.dispose();
    _turnoverDepartementCtrl.dispose();
    _budgetVsRealiseCtrl.dispose();
    _salairesTotauxCtrl.dispose();
    _primesVariablesCtrl.dispose();
    _chargesSocialesCtrl.dispose();
    _coutMoyenEmployeCtrl.dispose();
    _objectifPrincipalCtrl.dispose();
    _indicateurObjectifCtrl.dispose();
    _projetEnCoursCtrl.dispose();
    _ressourcesNecessairesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadParentOptions() async {
    final rows = await DaoRegistry.instance.departements.list(orderBy: 'nom ASC');
    final currentId = widget.departement?.id ?? '';
    final options = rows
        .map(
          (row) => _SelectOption(
            id: (row['id'] as String?) ?? '',
            label: (row['nom'] as String?) ?? '',
          ),
        )
        .where((opt) => opt.id.isNotEmpty && opt.label.trim().isNotEmpty && opt.id != currentId)
        .toList()
      ..sort((a, b) => a.label.compareTo(b.label));
    if (!mounted) return;
    setState(() {
      _parentOptions = options;
      _loadingParents = false;
    });
    if (_parentDeptCtrl.text.trim().isEmpty && (widget.departement?.parentDepartement ?? '').isNotEmpty) {
      final match = options.firstWhere(
        (opt) => opt.label == widget.departement!.parentDepartement,
        orElse: () => _SelectOption.empty,
      );
      if (match.id.isNotEmpty) {
        _parentDeptCtrl.text = match.id;
      }
    }
  }

  Future<void> _loadManagerOptions() async {
    final rows = await DaoRegistry.instance.employes.list(orderBy: 'nom_complet ASC');
    final options = rows
        .map(
          (row) => _SelectOption(
            id: (row['id'] as String?) ?? '',
            label: (row['nom_complet'] as String?) ?? '',
          ),
        )
        .where((opt) => opt.id.isNotEmpty && opt.label.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => a.label.compareTo(b.label));

    if (!mounted) return;
    setState(() {
      _managerOptions = options;
      _loadingManagers = false;
    });
    if (_managerCtrl.text.trim().isEmpty && (widget.departement?.manager ?? '').isNotEmpty) {
      final match = options.firstWhere(
        (opt) => opt.label == widget.departement!.manager,
        orElse: () => _SelectOption.empty,
      );
      if (match.id.isNotEmpty) {
        _managerCtrl.text = match.id;
      }
    }
  }

  bool _isValidDate(String input) {
    if (input.trim().isEmpty) return true;
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(input.trim())) return false;
    return DateTime.tryParse(input.trim()) != null;
  }

  Future<bool> _isDuplicateCode(String code) async {
    if (code.trim().isEmpty) return false;
    return DaoRegistry.instance.departements.existsByCode(code.trim(), excludeId: widget.departement?.id);
  }

  void _save() {
    final id = widget.departement?.id ?? 'dep-${DateTime.now().millisecondsSinceEpoch}';
    final count = int.tryParse(_headcountCtrl.text.trim()) ?? 0;
    Navigator.of(context).pop(
      Departement(
        id: id,
        name: _nameCtrl.text.trim(),
        manager: _resolveManagerName(_managerCtrl.text.trim()),
        managerId: _managerCtrl.text.trim(),
        headcount: count,
        budget: _budgetCtrl.text.trim(),
        pole: _poleCtrl.text.trim(),
        size: _sizeCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        code: _codeCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        extension: _extensionCtrl.text.trim(),
        adresse: _adresseCtrl.text.trim(),
        parentDepartement: _resolveParentName(_parentDeptCtrl.text.trim()),
        parentDepartementId: _parentDeptCtrl.text.trim(),
        dateCreation: _dateCreationCtrl.text.trim(),
        notes: _notesCtrl.text.trim(),
        responsables: _responsablesCtrl.text.trim(),
        cadresCount: _cadresCountCtrl.text.trim(),
        techniciensCount: _techniciensCountCtrl.text.trim(),
        supportCount: _supportCountCtrl.text.trim(),
        variationAnnuelle: _variationAnnuelleCtrl.text.trim(),
        tauxAbsenteisme: _tauxAbsenteismeCtrl.text.trim(),
        productiviteMoyenne: _productiviteMoyenneCtrl.text.trim(),
        satisfactionEquipe: _satisfactionEquipeCtrl.text.trim(),
        turnoverDepartement: _turnoverDepartementCtrl.text.trim(),
        budgetVsRealise: _budgetVsRealiseCtrl.text.trim(),
        salairesTotaux: _salairesTotauxCtrl.text.trim(),
        primesVariables: _primesVariablesCtrl.text.trim(),
        chargesSociales: _chargesSocialesCtrl.text.trim(),
        coutMoyenEmploye: _coutMoyenEmployeCtrl.text.trim(),
        objectifPrincipal: _objectifPrincipalCtrl.text.trim(),
        indicateurObjectif: _indicateurObjectifCtrl.text.trim(),
        projetEnCours: _projetEnCoursCtrl.text.trim(),
        ressourcesNecessaires: _ressourcesNecessairesCtrl.text.trim(),
        status: _status,
        deletedAt: widget.departement?.deletedAt,
      ),
    );
  }

  Future<bool> _validateStep(int step) async {
    setState(() => _errorMessage = null);
    if (step == 0) {
      if (_codeCtrl.text.trim().isNotEmpty && await _isDuplicateCode(_codeCtrl.text.trim())) {
        _errorMessage = 'Code deja utilise.';
        return false;
      }
      if (_nameCtrl.text.trim().isEmpty) {
        _errorMessage = 'Le nom est requis.';
        return false;
      }
      if (_managerCtrl.text.trim().isEmpty) {
        _errorMessage = 'Le manager est requis.';
        return false;
      }
      if (_poleCtrl.text.trim().isEmpty) {
        _errorMessage = 'Le pole est requis.';
        return false;
      }
      if (_sizeCtrl.text.trim().isEmpty) {
        _errorMessage = 'La taille est requise.';
        return false;
      }
      if (_locationCtrl.text.trim().isEmpty) {
        _errorMessage = 'La localisation est requise.';
        return false;
      }
      if (_emailCtrl.text.trim().isNotEmpty && !_emailCtrl.text.contains('@')) {
        _errorMessage = 'Email invalide.';
        return false;
      }
      if (!_isValidDate(_dateCreationCtrl.text)) {
        _errorMessage = 'Date creation invalide (YYYY-MM-DD).';
        return false;
      }
    }
    if (step == 1) {
      final count = int.tryParse(_headcountCtrl.text.trim()) ?? 0;
      if (count <= 0) {
        _errorMessage = 'Effectif invalide.';
        return false;
      }
      if (_budgetCtrl.text.trim().isEmpty) {
        _errorMessage = 'Le budget est requis.';
        return false;
      }
    }
    return true;
  }

  String _resolveParentName(String id) {
    if (id.trim().isEmpty) return '';
    final match = _parentOptions.firstWhere(
      (opt) => opt.id == id,
      orElse: () => _SelectOption.empty,
    );
    if (match.label.isNotEmpty) return match.label;
    return _parentDeptCtrl.text.trim();
  }

  String _resolveManagerName(String id) {
    if (id.trim().isEmpty) return '';
    final match = _managerOptions.firstWhere(
      (opt) => opt.id == id,
      orElse: () => _SelectOption.empty,
    );
    if (match.label.isNotEmpty) return match.label;
    return id;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.departement != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier departement' : 'Creer departement'),
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
        child: Stepper(
          currentStep: _currentStep,
          controlsBuilder: (context, details) {
            final isLast = _currentStep == 5;
            return Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(isLast ? 'Enregistrer' : 'Continuer'),
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
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
              ],
            );
          },
          onStepContinue: () async {
            if (!await _validateStep(_currentStep)) return;
            if (_currentStep < 5) {
              setState(() => _currentStep += 1);
            } else {
              _save();
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
              title: const Text('Informations'),
              isActive: _currentStep >= 0,
              content: AppCard(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _FormField(controller: _codeCtrl, label: 'Code'),
                    _FormField(controller: _nameCtrl, label: 'Nom'),
                    _FormField(controller: _descriptionCtrl, label: 'Description'),
                    _FormSelectField(
                      controller: _managerCtrl,
                      label: 'Manager',
                      options: _managerOptions,
                      loading: _loadingManagers,
                    ),
                    _FormField(controller: _poleCtrl, label: 'Pole'),
                    _FormField(controller: _sizeCtrl, label: 'Taille'),
                    _FormField(controller: _locationCtrl, label: 'Localisation'),
                    _FormField(controller: _dateCreationCtrl, label: 'Date creation (YYYY-MM-DD)'),
                    _FormDropdown(
                      label: 'Statut',
                      value: _status,
                      items: const ['Brouillon', 'Actif', 'Archive'],
                      onChanged: (value) => setState(() => _status = value),
                    ),
                  ],
                ),
              ),
            ),
            Step(
              title: const Text('Effectifs & budget'),
              isActive: _currentStep >= 1,
              content: AppCard(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _FormField(controller: _headcountCtrl, label: 'Effectif'),
                    _FormField(controller: _budgetCtrl, label: 'Budget masse salariale'),
                  ],
                ),
              ),
            ),
            Step(
              title: const Text('Contact & localisation'),
              isActive: _currentStep >= 2,
              content: AppCard(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _FormField(controller: _emailCtrl, label: 'Email'),
                    _FormField(controller: _phoneCtrl, label: 'Telephone'),
                    _FormField(controller: _extensionCtrl, label: 'Extension'),
                    _FormField(controller: _adresseCtrl, label: 'Adresse'),
                    _FormSelectField(
                      controller: _parentDeptCtrl,
                      label: 'Departement parent',
                      options: _parentOptions,
                      loading: _loadingParents,
                    ),
                  ],
                ),
              ),
            ),
            Step(
              title: const Text('Organisation'),
              isActive: _currentStep >= 3,
              content: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Structure et rattachements',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: appTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rattachements hierarchiques (N+1, N+2) et equipes.',
                      style: TextStyle(color: appTextMuted(context)),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _FormField(controller: _managerCtrl, label: 'Manager (N+1)'),
                        _FormField(controller: _responsablesCtrl, label: 'Responsables'),
                        _FormField(controller: _poleCtrl, label: 'Pole de rattachement'),
                        _FormField(controller: _sizeCtrl, label: 'Niveau departement'),
                        _FormField(controller: _locationCtrl, label: 'Site principal'),
                        _FormField(controller: _nameCtrl, label: 'Departements lies (liste)'),
                        _FormField(controller: _budgetCtrl, label: 'Ressources necessaires'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Step(
              title: const Text('Indicateurs'),
              isActive: _currentStep >= 4,
              content: AppCard(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _FormField(controller: _cadresCountCtrl, label: 'Cadres'),
                    _FormField(controller: _techniciensCountCtrl, label: 'Techniciens'),
                    _FormField(controller: _supportCountCtrl, label: 'Support'),
                    _FormField(controller: _variationAnnuelleCtrl, label: 'Variation annuelle'),
                    _FormField(controller: _tauxAbsenteismeCtrl, label: 'Taux absenteisme'),
                    _FormField(controller: _productiviteMoyenneCtrl, label: 'Productivite moyenne'),
                    _FormField(controller: _satisfactionEquipeCtrl, label: 'Satisfaction equipe'),
                    _FormField(controller: _turnoverDepartementCtrl, label: 'Turn-over departement'),
                    _FormField(controller: _budgetVsRealiseCtrl, label: 'Budget vs realise'),
                    _FormField(controller: _salairesTotauxCtrl, label: 'Salaires totaux'),
                    _FormField(controller: _primesVariablesCtrl, label: 'Primes et variables'),
                    _FormField(controller: _chargesSocialesCtrl, label: 'Charges sociales'),
                    _FormField(controller: _coutMoyenEmployeCtrl, label: 'Cout moyen employe'),
                  ],
                ),
              ),
            ),
            Step(
              title: const Text('Objectifs & projets'),
              isActive: _currentStep >= 5,
              content: AppCard(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _FormField(controller: _objectifPrincipalCtrl, label: 'Objectif principal'),
                    _FormField(controller: _indicateurObjectifCtrl, label: 'Indicateur'),
                    _FormField(controller: _projetEnCoursCtrl, label: 'Projet en cours'),
                    _FormField(controller: _ressourcesNecessairesCtrl, label: 'Ressources necessaires'),
                    _FormField(controller: _notesCtrl, label: 'Notes'),
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

class _FormField extends StatelessWidget {
  const _FormField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
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
      width: 220,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: (value) => onChanged(value ?? items.first),
      ),
    );
  }
}

class _FormDropdownField extends StatelessWidget {
  const _FormDropdownField({
    required this.controller,
    required this.label,
    required this.items,
    required this.loading,
  });

  final TextEditingController controller;
  final String label;
  final List<String> items;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading || items.isEmpty) {
      return _FormField(controller: controller, label: label);
    }
    final normalizedItems = items.contains(controller.text) || controller.text.isEmpty
        ? items
        : [controller.text, ...items];
    final value = controller.text.isEmpty ? normalizedItems.first : controller.text;
    if (controller.text.isEmpty && normalizedItems.isNotEmpty) {
      controller.text = value;
    }
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: normalizedItems
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: (value) => controller.text = value ?? '',
      ),
    );
  }
}

class _FormSelectField extends StatelessWidget {
  const _FormSelectField({
    required this.controller,
    required this.label,
    required this.options,
    required this.loading,
  });

  final TextEditingController controller;
  final String label;
  final List<_SelectOption> options;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading || options.isEmpty) {
      return _FormField(controller: controller, label: label);
    }
    final normalizedOptions = options.any((opt) => opt.id == controller.text) || controller.text.isEmpty
        ? options
        : [_SelectOption(id: controller.text, label: controller.text), ...options];
    final value = controller.text.isEmpty ? normalizedOptions.first.id : controller.text;
    if (controller.text.isEmpty && normalizedOptions.isNotEmpty) {
      controller.text = value;
    }
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: normalizedOptions
            .map(
              (opt) => DropdownMenuItem(
                value: opt.id,
                child: Text(opt.label),
              ),
            )
            .toList(),
        onChanged: (value) => controller.text = value ?? '',
      ),
    );
  }
}

class _SelectOption {
  const _SelectOption({required this.id, required this.label});
  static const _SelectOption empty = _SelectOption(id: '', label: '');

  final String id;
  final String label;
}

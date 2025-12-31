import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../shared/models/departement.dart';
import '../../../shared/models/org_node.dart';
import 'department_detail_screen.dart';

class DepartementsScreen extends StatefulWidget {
  const DepartementsScreen({super.key});

  @override
  State<DepartementsScreen> createState() => _DepartementsScreenState();
}

class _DepartementsScreenState extends State<DepartementsScreen> {
  final List<Departement> _departements = [
    const Departement(
      id: 'dep-1',
      name: 'Marketing',
      manager: 'A. Diallo',
      headcount: 32,
      budget: 'FCFA 420k',
      pole: 'Commercial',
      size: 'Moyen',
      location: 'Lome',
    ),
    const Departement(
      id: 'dep-2',
      name: 'Finance',
      manager: 'Y. Leclerc',
      headcount: 18,
      budget: 'FCFA 310k',
      pole: 'Support',
      size: 'Petit',
      location: 'Lome',
    ),
    const Departement(
      id: 'dep-3',
      name: 'IT',
      manager: 'S. Mensah',
      headcount: 24,
      budget: 'FCFA 510k',
      pole: 'Operations',
      size: 'Moyen',
      location: 'Kara',
    ),
  ];

  String _filterPole = 'Tous';
  String _filterSize = 'Tous';
  String _filterLocation = 'Tous';
  String _searchQuery = '';

  List<Departement> get _filteredDepartments {
    return _departements.where((dep) {
      final matchPole = _filterPole == 'Tous' || dep.pole == _filterPole;
      final matchSize = _filterSize == 'Tous' || dep.size == _filterSize;
      final matchLocation = _filterLocation == 'Tous' || dep.location == _filterLocation;
      final matchSearch =
          _searchQuery.isEmpty || dep.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchPole && matchSize && matchLocation && matchSearch;
    }).toList();
  }

  void _openDepartment(Departement departement) {
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: DepartmentDetailScreen(departement: departement),
      ),
    );
  }

  void _showCreateDepartment() {
    _openDepartmentForm();
  }

  void _showAssignManager(Departement departement) {
    final managerCtrl = TextEditingController(text: departement.manager);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Affecter manager'),
        content: TextField(
          controller: managerCtrl,
          decoration: const InputDecoration(labelText: 'Manager'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final index = _departements.indexWhere((d) => d.id == departement.id);
              if (index != -1) {
                setState(() {
                  _departements[index] = Departement(
                    id: departement.id,
                    name: departement.name,
                    manager: managerCtrl.text.trim(),
                    headcount: departement.headcount,
                    budget: departement.budget,
                    pole: departement.pole,
                    size: departement.size,
                    location: departement.location,
                  );
                });
              }
              Navigator.of(context).pop();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    ).then((_) => managerCtrl.dispose());
  }

  void _showEditStructure(Departement departement) {
    _openDepartmentForm(departement: departement);
  }

  Future<void> _openDepartmentForm({Departement? departement}) async {
    final created = await showDialog<Departement>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _DepartmentFormScreen(departement: departement),
      ),
    );

    if (created == null) return;

    setState(() {
      final index = _departements.indexWhere((d) => d.id == created.id);
      if (index == -1) {
        _departements.add(created);
      } else {
        _departements[index] = created;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mutedText = appTextMuted(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Organisation',
            subtitle: 'Suivi des departements et effectifs.',
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Recherche departement...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value.trim()),
                      ),
                    ),
                    _FilterDropdown(
                      label: 'Pole',
                      value: _filterPole,
                      items: const ['Tous', 'Commercial', 'Support', 'Operations'],
                      onChanged: (value) => setState(() => _filterPole = value),
                    ),
                    _FilterDropdown(
                      label: 'Taille',
                      value: _filterSize,
                      items: const ['Tous', 'Petit', 'Moyen', 'Grand'],
                      onChanged: (value) => setState(() => _filterSize = value),
                    ),
                    _FilterDropdown(
                      label: 'Localisation',
                      value: _filterLocation,
                      items: const ['Tous', 'Lome', 'Kara', 'Sokode'],
                      onChanged: (value) => setState(() => _filterLocation = value),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _showCreateDepartment,
                      icon: const Icon(Icons.add),
                      label: const Text('Creer departement'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _filteredDepartments
                .map(
                  (dep) => _DepartmentCard(
                    departement: dep,
                    onOpen: () => _openDepartment(dep),
                    onEditStructure: () => _showEditStructure(dep),
                    onAssignManager: () => _showAssignManager(dep),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: SizedBox(
              height: 320,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Organigramme',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: appTextPrimary(context),
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('Export PDF'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.image_outlined),
                        label: const Text('Export PNG'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.open_with),
                        label: const Text('Edition drag & drop'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _OrgChartCanvas(
                      mutedText: mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  const _DepartmentCard({
    required this.departement,
    required this.onOpen,
    required this.onEditStructure,
    required this.onAssignManager,
  });

  final Departement departement;
  final VoidCallback onOpen;
  final VoidCallback onEditStructure;
  final VoidCallback onAssignManager;

  @override
  Widget build(BuildContext context) {
    final primaryText = appTextPrimary(context);
    final mutedText = appTextMuted(context);

    return AppCard(
      child: InkWell(
        onTap: onOpen,
        child: SizedBox(
          width: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      departement.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEditStructure();
                      if (value == 'manager') onAssignManager();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Modifier structure')),
                      PopupMenuItem(value: 'manager', child: Text('Affecter manager')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Manager: ${departement.manager}',
                style: TextStyle(fontSize: 12, color: mutedText),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.people, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${departement.headcount} employes',
                    style: TextStyle(fontSize: 12, color: primaryText),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.payments, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    departement.budget,
                    style: TextStyle(fontSize: 12, color: primaryText),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${departement.pole} - ${departement.location}',
                style: TextStyle(fontSize: 12, color: mutedText),
              ),
            ],
          ),
        ),
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

class _OrgChartCanvas extends StatefulWidget {
  const _OrgChartCanvas({required this.mutedText});

  final Color mutedText;

  @override
  State<_OrgChartCanvas> createState() => _OrgChartCanvasState();
}

class _OrgChartCanvasState extends State<_OrgChartCanvas> {
  final List<OrgNode> _nodes = [
    OrgNode(id: 'n1', label: 'Direction RH', position: const Offset(40, 24)),
    OrgNode(id: 'n2', label: 'Recrutement', position: const Offset(260, 24), parentId: 'n1'),
    OrgNode(id: 'n3', label: 'Formation', position: const Offset(480, 24), parentId: 'n1'),
    OrgNode(id: 'n4', label: 'Paie', position: const Offset(260, 140), parentId: 'n1'),
  ];

  String? _linkSourceId;

  void _startLink(String nodeId) {
    setState(() => _linkSourceId = nodeId);
  }

  void _finishLink(String nodeId) {
    if (_linkSourceId == null || _linkSourceId == nodeId) return;
    setState(() {
      final targetIndex = _nodes.indexWhere((n) => n.id == nodeId);
      if (targetIndex != -1) {
        _nodes[targetIndex] = _nodes[targetIndex].copyWith(parentId: _linkSourceId);
      }
      _linkSourceId = null;
    });
  }

  void _cancelLink() {
    setState(() => _linkSourceId = null);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _cancelLink,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: appBorderColor(context)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _OrgLinesPainter(nodes: _nodes),
                ),
                ..._nodes.map(
                  (node) => Positioned(
                    left: node.position.dx,
                    top: node.position.dy,
                    child: _OrgNodeCard(
                      node: node,
                      isLinkSource: _linkSourceId == node.id,
                      onDrag: (delta) {
                        setState(() {
                          final index = _nodes.indexWhere((n) => n.id == node.id);
                          if (index == -1) return;
                          final next = node.position + delta;
                          _nodes[index] = node.copyWith(
                            position: Offset(
                              next.dx.clamp(0, constraints.maxWidth - 160),
                              next.dy.clamp(0, constraints.maxHeight - 64),
                            ),
                          );
                        });
                      },
                      onLinkTap: () {
                        if (_linkSourceId == null) {
                          _startLink(node.id);
                        } else {
                          _finishLink(node.id);
                        }
                      },
                    ),
                  ),
                ),
                if (_nodes.isEmpty)
                  Center(
                    child: Text(
                      'Aucun noeud. Ajoutez un departement.',
                      style: TextStyle(color: widget.mutedText),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrgNodeCard extends StatelessWidget {
  const _OrgNodeCard({
    required this.node,
    required this.isLinkSource,
    required this.onDrag,
    required this.onLinkTap,
  });

  final OrgNode node;
  final bool isLinkSource;
  final ValueChanged<Offset> onDrag;
  final VoidCallback onLinkTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) => onDrag(details.delta),
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isLinkSource ? AppColors.primary.withOpacity(0.12) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLinkSource ? AppColors.primary : appBorderColor(context),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.account_tree, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                node.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: appTextPrimary(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: onLinkTap,
              child: Icon(
                Icons.link,
                size: 16,
                color: isLinkSource ? AppColors.primary : appTextMuted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrgLinesPainter extends CustomPainter {
  _OrgLinesPainter({required this.nodes});

  final List<OrgNode> nodes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.4)
      ..strokeWidth = 1.5;

    for (final node in nodes) {
      if (node.parentId == null) continue;
      final parent = nodes.firstWhere(
        (n) => n.id == node.parentId,
        orElse: () => node,
      );
      if (parent.id == node.id) continue;
      final start = Offset(parent.position.dx + 80, parent.position.dy + 64);
      final end = Offset(node.position.dx + 80, node.position.dy);
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrgLinesPainter oldDelegate) {
    return oldDelegate.nodes != nodes;
  }
}

class _DepartmentFormScreen extends StatefulWidget {
  const _DepartmentFormScreen({this.departement});

  final Departement? departement;

  @override
  State<_DepartmentFormScreen> createState() => _DepartmentFormScreenState();
}

class _DepartmentFormScreenState extends State<_DepartmentFormScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _managerCtrl;
  late final TextEditingController _headcountCtrl;
  late final TextEditingController _budgetCtrl;
  late final TextEditingController _poleCtrl;
  late final TextEditingController _sizeCtrl;
  late final TextEditingController _locationCtrl;

  String? _errorMessage;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.departement?.name ?? '');
    _managerCtrl = TextEditingController(text: widget.departement?.manager ?? '');
    _headcountCtrl = TextEditingController(
      text: widget.departement != null ? widget.departement!.headcount.toString() : '',
    );
    _budgetCtrl = TextEditingController(text: widget.departement?.budget ?? '');
    _poleCtrl = TextEditingController(text: widget.departement?.pole ?? '');
    _sizeCtrl = TextEditingController(text: widget.departement?.size ?? '');
    _locationCtrl = TextEditingController(text: widget.departement?.location ?? '');
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
    super.dispose();
  }

  void _save() {
    if (!_validateStep(0) || !_validateStep(1) || !_validateStep(2)) {
      return;
    }

    final id = widget.departement?.id ?? 'dep-${DateTime.now().millisecondsSinceEpoch}';
    final count = int.tryParse(_headcountCtrl.text.trim()) ?? 0;
    Navigator.of(context).pop(
      Departement(
        id: id,
        name: _nameCtrl.text.trim(),
        manager: _managerCtrl.text.trim(),
        headcount: count,
        budget: _budgetCtrl.text.trim(),
        pole: _poleCtrl.text.trim(),
        size: _sizeCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
      ),
    );
  }

  bool _validateStep(int step) {
    setState(() => _errorMessage = null);
    if (step == 0) {
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
            final isLast = _currentStep == 2;
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
          onStepContinue: () {
            if (!_validateStep(_currentStep)) return;
            if (_currentStep < 2) {
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
                    _FormField(controller: _nameCtrl, label: 'Nom'),
                    _FormField(controller: _managerCtrl, label: 'Manager'),
                    _FormField(controller: _poleCtrl, label: 'Pole'),
                    _FormField(controller: _sizeCtrl, label: 'Taille'),
                    _FormField(controller: _locationCtrl, label: 'Localisation'),
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
              title: const Text('Organisation'),
              isActive: _currentStep >= 2,
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

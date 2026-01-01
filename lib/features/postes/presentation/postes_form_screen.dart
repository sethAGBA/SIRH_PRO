import 'package:flutter/material.dart';

import '../../../core/database/dao/dao_registry.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/models/poste.dart';

class PostesFormScreen extends StatefulWidget {
  const PostesFormScreen({
    super.key,
    required this.departmentOptions,
    this.poste,
  });

  final List<DepartmentOption> departmentOptions;
  final Poste? poste;

  @override
  State<PostesFormScreen> createState() => _PostesFormScreenState();
}

class _PostesFormScreenState extends State<PostesFormScreen> {
  late final TextEditingController _codeCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _departmentCtrl;
  late final TextEditingController _levelCtrl;
  late final TextEditingController _descriptionCtrl;
  String _status = 'Brouillon';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController(text: widget.poste?.code ?? '');
    _titleCtrl = TextEditingController(text: widget.poste?.title ?? '');
    _departmentCtrl = TextEditingController(text: widget.poste?.departmentId ?? '');
    _levelCtrl = TextEditingController(text: widget.poste?.level ?? '');
    _descriptionCtrl = TextEditingController(text: widget.poste?.description ?? '');
    _status = widget.poste?.status ?? 'Brouillon';
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _titleCtrl.dispose();
    _departmentCtrl.dispose();
    _levelCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<bool> _validate() async {
    setState(() => _errorMessage = null);
    if (_titleCtrl.text.trim().isEmpty) {
      _errorMessage = 'Intitule requis.';
      return false;
    }
    if (_departmentCtrl.text.trim().isEmpty) {
      _errorMessage = 'Departement requis.';
      return false;
    }
    if (_codeCtrl.text.trim().isNotEmpty) {
      final exists = await DaoRegistry.instance.postes.existsByCode(
        _codeCtrl.text.trim(),
        excludeId: widget.poste?.id,
      );
      if (exists) {
        _errorMessage = 'Code deja utilise.';
        return false;
      }
    }
    return true;
  }

  String _resolveDepartmentName(String id) {
    final match = widget.departmentOptions.firstWhere(
      (opt) => opt.id == id,
      orElse: () => const DepartmentOption(id: '', label: ''),
    );
    return match.label.isEmpty ? id : match.label;
  }

  void _save() async {
    if (!await _validate()) return;
    final id = widget.poste?.id ?? 'poste-${DateTime.now().millisecondsSinceEpoch}';
    Navigator.of(context).pop(
      Poste(
        id: id,
        title: _titleCtrl.text.trim(),
        departmentId: _departmentCtrl.text.trim(),
        departmentName: _resolveDepartmentName(_departmentCtrl.text.trim()),
        level: _levelCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        code: _codeCtrl.text.trim(),
        status: _status,
        deletedAt: widget.poste?.deletedAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.poste != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier poste' : 'Creer poste'),
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
            AppCard(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _FormField(controller: _codeCtrl, label: 'Code'),
                  _FormField(controller: _titleCtrl, label: 'Intitule'),
                  _FormSelectField(
                    controller: _departmentCtrl,
                    label: 'Departement',
                    options: widget.departmentOptions,
                  ),
                  _FormField(controller: _levelCtrl, label: 'Niveau'),
                  _FormField(controller: _descriptionCtrl, label: 'Description'),
                  _FormDropdown(
                    label: 'Statut',
                    value: _status,
                    items: const ['Brouillon', 'Actif', 'Archive'],
                    onChanged: (value) => setState(() => _status = value),
                  ),
                ],
              ),
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

class _FormField extends StatelessWidget {
  const _FormField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
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
      width: 240,
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

class _FormSelectField extends StatelessWidget {
  const _FormSelectField({
    required this.controller,
    required this.label,
    required this.options,
  });

  final TextEditingController controller;
  final String label;
  final List<DepartmentOption> options;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return _FormField(controller: controller, label: label);
    }
    final normalized = options.any((opt) => opt.id == controller.text) || controller.text.isEmpty
        ? options
        : [DepartmentOption(id: controller.text, label: controller.text), ...options];
    final value = controller.text.isEmpty ? normalized.first.id : controller.text;
    if (controller.text.isEmpty && normalized.isNotEmpty) {
      controller.text = value;
    }
    return SizedBox(
      width: 240,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: normalized
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

class DepartmentOption {
  const DepartmentOption({required this.id, required this.label});

  final String id;
  final String label;
}

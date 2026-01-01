import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../core/database/dao/dao_registry.dart';
import '../../../core/security/auth_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/operation_notice.dart';
import '../../../core/widgets/section_header.dart';

class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  final List<_RoleProfile> _roles = const [
    _RoleProfile(
      title: 'Administrateur RH',
      access: 'Acces total systeme',
      modules: ['Tous modules', 'Parametres', 'Audit'],
    ),
    _RoleProfile(
      title: 'Directeur RH',
      access: 'Decisions strategiques',
      modules: ['Tous modules RH', 'Validation budgets', 'Reporting'],
    ),
    _RoleProfile(
      title: 'Responsable RH',
      access: 'Gestion operationnelle',
      modules: ['Employes', 'Recrutement', 'Formation', 'Discipline'],
    ),
    _RoleProfile(
      title: 'Gestionnaire paie',
      access: 'Paie & declarations',
      modules: ['Variables', 'Bulletins', 'Charges sociales'],
    ),
    _RoleProfile(
      title: 'Manager',
      access: 'Equipe et validations',
      modules: ['Conges', 'Evaluations', 'Recrutement'],
    ),
    _RoleProfile(
      title: 'Employe',
      access: 'Self-service',
      modules: ['Profil', 'Paie', 'Notes frais', 'Formations'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Parametres & administration',
              subtitle: 'Configuration entreprise, utilisateurs et conformite.',
            ),
            const SizedBox(height: 16),
            AppCard(
              child: TabBar(
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: appTextMuted(context),
                tabs: const [
                  Tab(text: 'Entreprise'),
                  Tab(text: 'Utilisateurs & securite'),
                  Tab(text: 'Roles & permissions'),
                  Tab(text: 'Conformite & audit'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 760,
              child: TabBarView(
                children: [
                  const _EntrepriseTab(),
                  _UsersTab(roles: _roles, onCreate: () => _openCreateUser(context)),
                  _RolesTab(roles: _roles),
                  const _AuditTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreateUser(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => const Dialog.fullscreen(child: _CreateUserDialog()),
    );
  }
}

class _EntrepriseTab extends StatelessWidget {
  const _EntrepriseTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Informations societe', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Raison sociale', value: 'SIRH Pro SA'),
                const _InfoRow(label: 'SIRET', value: 'TG123456789'),
                const _InfoRow(label: 'Convention collective', value: 'Industrie & services'),
                const _InfoRow(label: 'Adresse', value: 'Lome, Quartier administratif'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Structure organisationnelle', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Departements', value: '8'),
                const _InfoRow(label: 'Poles', value: '4'),
                const _InfoRow(label: 'Sites', value: '3'),
                const _InfoRow(label: 'Organigramme', value: 'A jour'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Grilles & baremes', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Grilles salariales', value: '8 niveaux'),
                const _InfoRow(label: 'Classifications', value: 'A, B, C'),
                const _InfoRow(label: 'Baremes primes', value: 'Performance, anciennete'),
                const _InfoRow(label: 'Indemnites', value: 'Transport, logement'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Templates documents RH', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Contrat CDI', value: 'Actif'),
                const _InfoRow(label: 'Attestation employeur', value: 'Actif'),
                const _InfoRow(label: 'Avenant', value: 'Actif'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UsersTab extends StatefulWidget {
  const _UsersTab({required this.roles, required this.onCreate});

  final List<_RoleProfile> roles;
  final Future<void> Function() onCreate;

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  List<_UserAccount> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    final rows = await DaoRegistry.instance.utilisateurs.list(orderBy: 'created_at DESC');
    final users = rows
        .map(
          (row) => _UserAccount(
            id: row['id'] as String,
            name: (row['nom'] as String?) ?? 'Utilisateur',
            email: (row['email'] as String?) ?? '',
            role: (row['role'] as String?) ?? 'Employe',
            status: (row['statut'] as String?) ?? 'Actif',
            lastLogin: _formatLastLogin(row['last_login'] as int?),
          ),
        )
        .toList();
    if (!mounted) return;
    setState(() {
      _users = users;
      _loading = false;
    });
  }

  String _formatLastLogin(int? value) {
    if (value == null || value == 0) return 'Jamais';
    final date = DateTime.fromMillisecondsSinceEpoch(value);
    return '${date.year}-${_two(date.month)}-${_two(date.day)}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _MetricCard(title: 'Utilisateurs actifs', value: '${_users.where((u) => u.status == 'Actif').length}', subtitle: 'Total'),
              _MetricCard(title: 'Roles definis', value: '${widget.roles.length}', subtitle: 'Profils acces'),
              const _MetricCard(title: 'Alertes securite', value: '2', subtitle: 'A verifier'),
              const _MetricCard(title: 'MFA active', value: '80%', subtitle: 'Comptes'),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Comptes utilisateurs', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await widget.onCreate();
                        await _loadUsers();
                      },
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Creer utilisateur'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_loading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  )
                else
                  DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.05)
                          : const Color(0xFFF8FAFC),
                    ),
                    columns: const [
                      DataColumn(label: Text('Utilisateur')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Role')),
                      DataColumn(label: Text('Statut')),
                      DataColumn(label: Text('Derniere connexion')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: _users
                        .map(
                          (user) => DataRow(
                            cells: [
                              DataCell(Text(user.name)),
                              DataCell(Text(user.email)),
                              DataCell(Text(user.role)),
                              DataCell(_StatusChip(status: user.status)),
                              DataCell(Text(user.lastLogin)),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => _openUserDetail(context, user),
                                      icon: const Icon(Icons.visibility_outlined),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        final updated = await _openEditUser(context, user);
                                        if (updated) {
                                          await _loadUsers();
                                        }
                                      },
                                      icon: const Icon(Icons.edit_outlined),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        final deleted = await _confirmDelete(context, user);
                                        if (deleted) {
                                          await _loadUsers();
                                        }
                                      },
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                    IconButton(
                                      onPressed: () => _openChangePassword(context, user),
                                      icon: const Icon(Icons.lock_reset),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RolesTab extends StatelessWidget {
  const _RolesTab({required this.roles});

  final List<_RoleProfile> roles;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Roles & permissions', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                ...roles.map((role) => _RoleRow(role: role)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditTab extends StatelessWidget {
  const _AuditTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Conformite & audit', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Logs horodates', value: 'Actifs'),
                const _InfoRow(label: 'Modifications sensibles', value: 'Suivi complet'),
                const _InfoRow(label: 'Sauvegarde quotidienne', value: '02:00 AM'),
                const _InfoRow(label: 'RGPD', value: 'Consentements actifs'),
                const _InfoRow(label: 'Archivage legal', value: '5 ans min'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Historique recent', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: '05/05 - Edition contrat', value: 'Admin RH'),
                const _InfoRow(label: '03/05 - Suppression utilisateur', value: 'Admin RH'),
                const _InfoRow(label: '01/05 - Export paie', value: 'Gestionnaire'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.subtitle});

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: SizedBox(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: appTextMuted(context), fontSize: 12)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: appTextPrimary(context))),
            const SizedBox(height: 6),
            Text(subtitle, style: TextStyle(color: appTextMuted(context), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _RoleRow extends StatelessWidget {
  const _RoleRow({required this.role});

  final _RoleProfile role;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(role.title, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
          const SizedBox(height: 6),
          Text(role.access, style: TextStyle(color: appTextMuted(context))),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: role.modules.map((module) => _Tag(text: module)).toList(),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: AppColors.primary, fontSize: 12)),
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
          Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context)))),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  Color _statusColor() {
    switch (status) {
      case 'Actif':
        return AppColors.success;
      case 'Suspendu':
        return AppColors.alert;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _RoleProfile {
  const _RoleProfile({
    required this.title,
    required this.access,
    required this.modules,
  });

  final String title;
  final String access;
  final List<String> modules;
}

class _UserAccount {
  const _UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.lastLogin,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String lastLogin;
}

Future<bool> _confirmDelete(BuildContext context, _UserAccount user) async {
  final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Supprimer utilisateur'),
            content: Text('Supprimer le compte ${user.name} ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: const Text('Supprimer'),
              ),
            ],
          );
        },
      ) ??
      false;

  if (!confirm) return false;
  try {
    await DaoRegistry.instance.utilisateurs.delete(user.id);
    showOperationNotice(context, message: 'Utilisateur supprime.', success: true);
    return true;
  } catch (_) {
    showOperationNotice(context, message: 'Echec suppression utilisateur.', success: false);
    return false;
  }
}

Future<void> _openUserDetail(BuildContext context, _UserAccount user) async {
  await showDialog(
    context: context,
    builder: (_) => Dialog.fullscreen(child: _UserDetailDialog(user: user)),
  );
}

Future<bool> _openEditUser(BuildContext context, _UserAccount user) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => Dialog.fullscreen(child: _EditUserDialog(user: user)),
  );
  return result ?? false;
}

void _openChangePassword(BuildContext context, _UserAccount user) {
  showDialog(
    context: context,
    builder: (_) => Dialog.fullscreen(child: _ChangePasswordDialog(user: user)),
  );
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog({required this.user});

  final _UserAccount user;

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Changer mot de passe'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: _busy ? null : _handleSave,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Enregistrer'),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Utilisateur', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
              const SizedBox(height: 12),
              _InfoRow(label: 'Nom', value: widget.user.name),
              _InfoRow(label: 'Email', value: widget.user.email),
              const SizedBox(height: 12),
              if (_error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                  ),
                  child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmer mot de passe'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    setState(() {
      _error = null;
      _busy = true;
    });

    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    if (password.isEmpty || confirm.isEmpty) {
      setState(() {
        _error = 'Veuillez remplir les deux champs.';
        _busy = false;
      });
      return;
    }
    if (!_isStrongPassword(password)) {
      setState(() {
        _error = 'Mot de passe faible (maj, min, chiffre, 8+).';
        _busy = false;
      });
      return;
    }
    if (password != confirm) {
      setState(() {
        _error = 'Les mots de passe ne correspondent pas.';
        _busy = false;
      });
      return;
    }

    try {
      await AuthService().updatePasswordByEmail(widget.user.email, password);
      if (!mounted) return;
      showOperationNotice(context, message: 'Mot de passe mis a jour.', success: true);
      Navigator.of(context).pop();
    } catch (_) {
      setState(() {
        _error = 'Echec mise a jour mot de passe.';
        _busy = false;
      });
      showOperationNotice(context, message: 'Echec mise a jour mot de passe.', success: false);
    }
  }

  bool _isStrongPassword(String value) {
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d).{8,}$');
    return regex.hasMatch(value);
  }
}


class _CreateUserDialog extends StatefulWidget {
  const _CreateUserDialog();

  @override
  State<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String _role = 'Employe';
  String _status = 'Actif';
  String _department = 'RH';
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creer utilisateur'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: _busy ? null : _handleSave,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Enregistrer'),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Informations utilisateur', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
              const SizedBox(height: 12),
              if (_error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                  ),
                  child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                ),
                const SizedBox(height: 12),
              ],
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _FormField(label: 'Nom complet', controller: _nameController),
                  _FormField(label: 'Email', controller: _emailController),
                  _FormField(label: 'Telephone', controller: _phoneController),
                  _FormDropdown(
                    label: 'Departement',
                    value: _department,
                    items: const ['RH', 'Finance', 'IT', 'Operations'],
                    onChanged: (value) => setState(() => _department = value),
                  ),
                  _FormDropdown(
                    label: 'Role',
                    value: _role,
                    items: const [
                      'Administrateur RH',
                      'Directeur RH',
                      'Responsable RH',
                      'Gestionnaire paie',
                      'Manager',
                      'Employe',
                    ],
                    onChanged: (value) => setState(() => _role = value),
                  ),
                  _FormDropdown(
                    label: 'Statut',
                    value: _status,
                    items: const ['Actif', 'Suspendu'],
                    onChanged: (value) => setState(() => _status = value),
                  ),
                  _FormField(label: 'Mot de passe', controller: _passwordController, obscureText: true),
                  _FormField(label: 'Confirmer', controller: _confirmController, obscureText: true),
                ],
              ),
              const SizedBox(height: 12),
              const _InfoRow(label: 'Regle securite', value: 'MFA obligatoire'),
              const _InfoRow(label: 'Mot de passe temporaire', value: 'Defini par admin'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    setState(() {
      _error = null;
      _busy = true;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _error = 'Nom requis.';
        _busy = false;
      });
      return;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (email.isNotEmpty && !emailRegex.hasMatch(email)) {
      setState(() {
        _error = 'Email invalide.';
        _busy = false;
      });
      return;
    }
    if (password.isEmpty || confirm.isEmpty) {
      setState(() {
        _error = 'Mot de passe requis.';
        _busy = false;
      });
      return;
    }
    if (!_isStrongPassword(password)) {
      setState(() {
        _error = 'Mot de passe faible (maj, min, chiffre, 8+).';
        _busy = false;
      });
      return;
    }
    if (password != confirm) {
      setState(() {
        _error = 'Les mots de passe ne correspondent pas.';
        _busy = false;
      });
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final id = 'usr-$now';
    final hash = sha256.convert(utf8.encode(password)).toString();

    try {
      await DaoRegistry.instance.utilisateurs.insert({
        'id': id,
        'nom': name,
        'email': email,
        'role': _role,
        'statut': _status,
        'telephone': phone,
        'departement': _department,
        'password_hash': hash,
        'is_active': _status == 'Actif' ? 1 : 0,
        'must_change_password': 0,
        'last_login': null,
        'created_at': now,
        'updated_at': now,
      });

      if (!mounted) return;
      showOperationNotice(context, message: 'Utilisateur cree.', success: true);
      Navigator.of(context).pop(true);
    } catch (_) {
      setState(() {
        _error = 'Echec creation utilisateur.';
        _busy = false;
      });
      showOperationNotice(context, message: 'Echec creation utilisateur.', success: false);
    }
  }

  bool _isStrongPassword(String value) {
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d).{8,}$');
    return regex.hasMatch(value);
  }
}

class _UserDetailDialog extends StatelessWidget {
  const _UserDetailDialog({required this.user});

  final _UserAccount user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil utilisateur'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Informations', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
              const SizedBox(height: 12),
              _InfoRow(label: 'Nom', value: user.name),
              _InfoRow(label: 'Email', value: user.email),
              _InfoRow(label: 'Role', value: user.role),
              _InfoRow(label: 'Statut', value: user.status),
              _InfoRow(label: 'Derniere connexion', value: user.lastLogin),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditUserDialog extends StatefulWidget {
  const _EditUserDialog({required this.user});

  final _UserAccount user;

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late String _role;
  late String _status;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _role = widget.user.role;
    _status = widget.user.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier utilisateur'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: _busy ? null : _handleSave,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Enregistrer'),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Informations utilisateur', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
              const SizedBox(height: 12),
              if (_error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                  ),
                  child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                ),
                const SizedBox(height: 12),
              ],
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _FormField(label: 'Nom complet', controller: _nameController),
                  _FormField(label: 'Email', controller: _emailController),
                  _FormDropdown(
                    label: 'Role',
                    value: _role,
                    items: const [
                      'Administrateur RH',
                      'Directeur RH',
                      'Responsable RH',
                      'Gestionnaire paie',
                      'Manager',
                      'Employe',
                    ],
                    onChanged: (value) => setState(() => _role = value),
                  ),
                  _FormDropdown(
                    label: 'Statut',
                    value: _status,
                    items: const ['Actif', 'Suspendu'],
                    onChanged: (value) => setState(() => _status = value),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    setState(() {
      _error = null;
      _busy = true;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    if (name.isEmpty) {
      setState(() {
        _error = 'Nom requis.';
        _busy = false;
      });
      return;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (email.isNotEmpty && !emailRegex.hasMatch(email)) {
      setState(() {
        _error = 'Email invalide.';
        _busy = false;
      });
      return;
    }

    try {
      await DaoRegistry.instance.utilisateurs.update(widget.user.id, {
        'nom': name,
        'email': email,
        'role': _role,
        'statut': _status,
        'is_active': _status == 'Actif' ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      if (!mounted) return;
      showOperationNotice(context, message: 'Utilisateur mis a jour.', success: true);
      Navigator.of(context).pop(true);
    } catch (_) {
      setState(() {
        _error = 'Echec modification utilisateur.';
        _busy = false;
      });
      showOperationNotice(context, message: 'Echec modification utilisateur.', success: false);
    }
  }
}
class _FormField extends StatelessWidget {
  const _FormField({required this.label, required this.controller, this.obscureText = false});

  final String label;
  final TextEditingController controller;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
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
        isExpanded: true,
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

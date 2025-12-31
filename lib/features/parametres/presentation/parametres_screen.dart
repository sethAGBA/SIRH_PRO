import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
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

  void _openCreateUser(BuildContext context) {
    showDialog(
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

class _UsersTab extends StatelessWidget {
  const _UsersTab({required this.roles, required this.onCreate});

  final List<_RoleProfile> roles;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final users = [
      const _UserAccount(name: 'Awa Komla', role: 'Administrateur RH', status: 'Actif', lastLogin: '2024-05-12'),
      const _UserAccount(name: 'Noel Mensah', role: 'Gestionnaire paie', status: 'Actif', lastLogin: '2024-05-10'),
      const _UserAccount(name: 'Laura B.', role: 'Manager', status: 'Suspendu', lastLogin: '2024-04-28'),
    ];
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _MetricCard(title: 'Utilisateurs actifs', value: '24', subtitle: 'Total'),
              _MetricCard(title: 'Roles definis', value: '6', subtitle: 'Profils acces'),
              _MetricCard(title: 'Alertes securite', value: '2', subtitle: 'A verifier'),
              _MetricCard(title: 'MFA active', value: '80%', subtitle: 'Comptes'),
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
                      onPressed: onCreate,
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Creer utilisateur'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.05)
                        : const Color(0xFFF8FAFC),
                  ),
                  columns: const [
                    DataColumn(label: Text('Utilisateur')),
                    DataColumn(label: Text('Role')),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Derniere connexion')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: users
                      .map(
                        (user) => DataRow(
                          cells: [
                            DataCell(Text(user.name)),
                            DataCell(Text(user.role)),
                            DataCell(_StatusChip(status: user.status)),
                            DataCell(Text(user.lastLogin)),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(onPressed: () {}, icon: const Icon(Icons.visibility_outlined)),
                                  IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
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
    required this.name,
    required this.role,
    required this.status,
    required this.lastLogin,
  });

  final String name;
  final String role;
  final String status;
  final String lastLogin;
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
  String _role = 'Employe';
  String _status = 'Actif';
  String _department = 'RH';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
            onPressed: () {},
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
                ],
              ),
              const SizedBox(height: 12),
              const _InfoRow(label: 'Regle securite', value: 'MFA obligatoire'),
              const _InfoRow(label: 'Mot de passe temporaire', value: 'Auto genere'),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

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

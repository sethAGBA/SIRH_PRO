import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';

class NotesFraisScreen extends StatefulWidget {
  const NotesFraisScreen({super.key});

  @override
  State<NotesFraisScreen> createState() => _NotesFraisScreenState();
}

class _NotesFraisScreenState extends State<NotesFraisScreen> {
  final List<_ExpenseRequest> _requests = const [
    _ExpenseRequest(
      employee: 'Amina Diallo',
      category: 'Deplacement',
      amount: 120000,
      status: 'En attente',
      delay: '4 jours',
      date: '2024-05-06',
      description: 'Mission client, taxi + parking',
      distanceKm: 32,
      approvals: 'Manager en attente',
    ),
    _ExpenseRequest(
      employee: 'Yann Leclerc',
      category: 'Repas',
      amount: 58000,
      status: 'Validee',
      delay: '2 jours',
      date: '2024-05-04',
      description: 'Repas equipe projet',
      distanceKm: 0,
      approvals: 'Manager valide',
    ),
    _ExpenseRequest(
      employee: 'Samuel Mensah',
      category: 'Hebergement',
      amount: 210000,
      status: 'Remboursee',
      delay: '6 jours',
      date: '2024-04-29',
      description: 'Hotel mission Kara',
      distanceKm: 0,
      approvals: 'Compta valide',
    ),
    _ExpenseRequest(
      employee: 'Laura B.',
      category: 'Fournitures',
      amount: 48000,
      status: 'Refusee',
      delay: '1 jour',
      date: '2024-05-02',
      description: 'Fournitures bureau',
      distanceKm: 0,
      approvals: 'Refus compta',
    ),
  ];

  void _openExpenseDetail(_ExpenseRequest request) {
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(child: _ExpenseDetailDialog(request: request)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Notes de frais',
              subtitle: 'Demandes de remboursement et politiques.',
            ),
            const SizedBox(height: 16),
            AppCard(
              child: TabBar(
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: appTextMuted(context),
                tabs: const [
                  Tab(text: 'Tableau'),
                  Tab(text: 'Nouvelle note'),
                  Tab(text: 'Politique'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 740,
              child: TabBarView(
                children: [
                  _TableauTab(requests: _requests, onOpen: _openExpenseDetail),
                  const _FormulaireTab(),
                  const _PolitiqueTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableauTab extends StatelessWidget {
  const _TableauTab({required this.requests, required this.onOpen});

  final List<_ExpenseRequest> requests;
  final ValueChanged<_ExpenseRequest> onOpen;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _MetricCard(title: 'Total a rembourser', value: 'FCFA 436k', subtitle: 'Mois en cours'),
              _MetricCard(title: 'Delai moyen', value: '3.2 jours', subtitle: 'Traitement'),
              _MetricCard(title: 'Depassements', value: '4 rappels', subtitle: 'A relancer'),
              _MetricCard(title: 'Demandes en attente', value: '6', subtitle: 'Validation'),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Demandes de remboursement', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.05)
                        : const Color(0xFFF8FAFC),
                  ),
                  columns: const [
                    DataColumn(label: Text('Employe')),
                    DataColumn(label: Text('Categorie')),
                    DataColumn(label: Text('Montant')),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Delai')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: requests
                      .map(
                        (request) => DataRow(
                          cells: [
                            DataCell(Text(request.employee)),
                            DataCell(Text(request.category)),
                            DataCell(Text(_fmtAmount(request.amount))),
                            DataCell(_StatusChip(status: request.status)),
                            DataCell(Text(request.delay)),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(onPressed: () => onOpen(request), icon: const Icon(Icons.visibility_outlined)),
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
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rappels depassements delais', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Amina Diallo', value: 'En attente 4 jours'),
                const _InfoRow(label: 'Koffi S.', value: 'En attente 6 jours'),
                const _InfoRow(label: 'Equipe IT', value: 'Validation compta'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormulaireTab extends StatelessWidget {
  const _FormulaireTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Formulaire note de frais', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _FieldBox(label: 'Employe', hint: 'Nom complet'),
                    _FieldBox(label: 'Categorie', hint: 'Deplacement, Repas, Hebergement, Fournitures'),
                    _FieldBox(label: 'Date', hint: '2024-05-10'),
                    _FieldBox(label: 'Montant', hint: 'FCFA 0'),
                    _FieldBox(label: 'Km (si deplacement)', hint: '0'),
                    _FieldBox(label: 'Barreme kilometrique', hint: 'Auto'),
                    _FieldBox(label: 'Plafond categorie', hint: 'Auto'),
                    _FieldBox(label: 'Justificatifs', hint: 'Tickets, factures'),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(onPressed: () {}, child: const Text('Scanner justificatifs')),
                    OutlinedButton(onPressed: () {}, child: const Text('Calculer barreme')),
                    OutlinedButton(onPressed: () {}, child: const Text('Verifier plafonds')),
                    OutlinedButton(onPressed: () {}, child: const Text('Soumettre validation')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Circuit de validation', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Visa hierarchique', value: 'Manager'),
                const _InfoRow(label: 'Validation comptable', value: 'Service compta'),
                const _InfoRow(label: 'Paiement', value: 'Virement mensuel'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PolitiqueTab extends StatelessWidget {
  const _PolitiqueTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Baremes par categorie', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Deplacement', value: 'FCFA 150/km'),
                const _InfoRow(label: 'Repas', value: 'Plafond FCFA 8k/jour'),
                const _InfoRow(label: 'Hebergement', value: 'Plafond FCFA 45k/nuit'),
                const _InfoRow(label: 'Fournitures', value: 'Plafond FCFA 30k'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Regles de gestion', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Frais remboursables', value: 'Deplacement, repas, hebergement'),
                const _InfoRow(label: 'Non remboursables', value: 'Loisirs, alcool'),
                const _InfoRow(label: 'Delai soumission', value: '7 jours apres depense'),
                const _InfoRow(label: 'Justificatifs obligatoires', value: 'Tickets / factures'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Circuit de validation', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'N+1', value: 'Visa hierarchique'),
                const _InfoRow(label: 'Compta', value: 'Validation finale'),
                const _InfoRow(label: 'Paiement', value: 'Virement mensuel'),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  Color _statusColor() {
    switch (status) {
      case 'Validee':
        return AppColors.success;
      case 'Remboursee':
        return AppColors.primary;
      case 'Refusee':
        return AppColors.danger;
      default:
        return AppColors.alert;
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

class _FieldBox extends StatelessWidget {
  const _FieldBox({required this.label, required this.hint});

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: TextField(
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: appTextMuted(context)))),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor ?? appTextPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseRequest {
  const _ExpenseRequest({
    required this.employee,
    required this.category,
    required this.amount,
    required this.status,
    required this.delay,
    required this.date,
    required this.description,
    required this.distanceKm,
    required this.approvals,
  });

  final String employee;
  final String category;
  final int amount;
  final String status;
  final String delay;
  final String date;
  final String description;
  final int distanceKm;
  final String approvals;
}

class _ExpenseDetailDialog extends StatelessWidget {
  const _ExpenseDetailDialog({required this.request});

  final _ExpenseRequest request;

  int? _plafondMax() {
    switch (request.category) {
      case 'Deplacement':
        return 50000;
      case 'Repas':
        return 8000;
      case 'Hebergement':
        return 45000;
      case 'Fournitures':
        return 30000;
      default:
        return null;
    }
  }

  String _controlLabel() {
    final plafond = _plafondMax();
    final status = _controlStatus();
    if (plafond == null) {
      return status;
    }
    return '$status (plafond ${_fmtAmount(plafond)})';
  }

  String _controlStatus() {
    final plafond = _plafondMax();
    if (plafond == null) {
      return 'A verifier';
    }
    return request.amount > plafond ? 'Hors plafond' : 'Conforme';
  }

  List<_InfoRow> _policyRows() {
    switch (request.category) {
      case 'Deplacement':
        return const [
          _InfoRow(label: 'Bareme categorie', value: 'FCFA 150/km'),
          _InfoRow(label: 'Plafond journalier', value: 'FCFA 50k'),
          _InfoRow(label: 'Justificatifs requis', value: 'Ticket carburant'),
          _InfoRow(label: 'Statut controle', value: ''),
        ];
      case 'Repas':
        return const [
          _InfoRow(label: 'Bareme categorie', value: 'Plafond FCFA 8k/jour'),
          _InfoRow(label: 'Justificatifs requis', value: 'Ticket obligatoire'),
          _InfoRow(label: 'Regle conviviale', value: '1 repas/jour'),
          _InfoRow(label: 'Statut controle', value: ''),
        ];
      case 'Hebergement':
        return const [
          _InfoRow(label: 'Bareme categorie', value: 'Plafond FCFA 45k/nuit'),
          _InfoRow(label: 'Justificatifs requis', value: 'Facture hotel'),
          _InfoRow(label: 'Duree max', value: '5 nuits'),
          _InfoRow(label: 'Statut controle', value: ''),
        ];
      case 'Fournitures':
        return const [
          _InfoRow(label: 'Bareme categorie', value: 'Plafond FCFA 30k'),
          _InfoRow(label: 'Justificatifs requis', value: 'Facture obligatoire'),
          _InfoRow(label: 'Liste autorisee', value: 'Papeterie, petits materiels'),
          _InfoRow(label: 'Statut controle', value: ''),
        ];
      default:
        return const [
          _InfoRow(label: 'Bareme categorie', value: 'Non defini'),
          _InfoRow(label: 'Justificatifs requis', value: 'Selon politique'),
          _InfoRow(label: 'Statut controle', value: ''),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note de frais - ${request.employee}'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Valider'),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.block, size: 18),
            label: const Text('Refuser'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Details demande', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Employe', value: request.employee),
                  _InfoRow(label: 'Categorie', value: request.category),
                  _InfoRow(label: 'Date', value: request.date),
                  _InfoRow(label: 'Montant', value: _fmtAmount(request.amount)),
                  _InfoRow(label: 'Kilometrage', value: '${request.distanceKm} km'),
                  _InfoRow(label: 'Description', value: request.description),
                  _InfoRow(label: 'Statut', value: request.status),
                  _InfoRow(label: 'Validation', value: request.approvals),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Justificatifs', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: const [
                      _AttachmentCard(label: 'Ticket taxi.pdf'),
                      _AttachmentCard(label: 'Facture hotel.pdf'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Ajouter justificatif'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Plafonds & regles appliquees', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                  const SizedBox(height: 12),
                  ..._policyRows().map(
                    (row) => row.label == 'Statut controle'
                        ? _InfoRow(
                            label: row.label,
                            value: _controlLabel(),
                            valueColor: _controlStatus() == 'Hors plafond' ? AppColors.danger : AppColors.success,
                          )
                        : row,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Historique validation', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                  const SizedBox(height: 12),
                  const _InfoRow(label: 'Soumission', value: '2024-05-06 09:20'),
                  const _InfoRow(label: 'Visa manager', value: 'En attente'),
                  const _InfoRow(label: 'Validation compta', value: 'Non lance'),
                  const _InfoRow(label: 'Paiement', value: 'Planifie'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  const _AttachmentCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: SizedBox(
        width: 180,
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: TextStyle(color: appTextPrimary(context)))),
          ],
        ),
      ),
    );
  }
}

String _fmtAmount(int value) {
  return 'FCFA ${value.toString().replaceAllMapped(RegExp(r'\\B(?=(\\d{3})+(?!\\d))'), (match) => ' ')}';
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';

class PaieRemunerationScreen extends StatefulWidget {
  const PaieRemunerationScreen({super.key});

  @override
  State<PaieRemunerationScreen> createState() => _PaieRemunerationScreenState();
}

class _PaieRemunerationScreenState extends State<PaieRemunerationScreen> {
  final List<_PayrollProcess> _processes = const [
    _PayrollProcess(
      period: 'Mars 2024',
      status: 'En cours',
      imports: 'Absences, HS, primes',
      progress: 0.62,
    ),
    _PayrollProcess(
      period: 'Fevrier 2024',
      status: 'Valide',
      imports: 'Absences, primes',
      progress: 1.0,
    ),
    _PayrollProcess(
      period: 'Janvier 2024',
      status: 'Archive',
      imports: 'Absences, HS, primes',
      progress: 1.0,
    ),
  ];

  final List<_Payslip> _payslips = const [
    _Payslip(
      number: 'BP-2024-032',
      employee: 'Awa Komla',
      matricule: 'RH-0012',
      job: 'Analyste RH',
      period: 'Mars 2024',
      gross: 520000,
      net: 410000,
    ),
    _Payslip(
      number: 'BP-2024-033',
      employee: 'Noel Mensah',
      matricule: 'IT-0044',
      job: 'Dev Flutter',
      period: 'Mars 2024',
      gross: 680000,
      net: 520000,
    ),
  ];

  final List<_PayrollVariable> _variables = const [
    _PayrollVariable(title: 'Prime anciennete', value: 'Auto 2%/an'),
    _PayrollVariable(title: 'Prime performance', value: 'Selon evaluation'),
    _PayrollVariable(title: 'Prime presenteisme', value: 'Fixe mensuelle'),
    _PayrollVariable(title: 'Indemnite transport', value: 'Barreme interne'),
    _PayrollVariable(title: 'Tickets restaurant', value: 'Jours travailles'),
    _PayrollVariable(title: 'Avantages en nature', value: 'Vehicule, telephone'),
  ];

  final List<_SalaryHistory> _history = const [
    _SalaryHistory(period: '2022', salary: 420000, change: '+5%'),
    _SalaryHistory(period: '2023', salary: 460000, change: '+10%'),
    _SalaryHistory(period: '2024', salary: 520000, change: '+13%'),
  ];

  void _openPayslip(_Payslip payslip) {
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(child: _PayslipDialog(payslip: payslip)),
    );
  }

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
              title: 'Paie & remuneration',
              subtitle: 'Traitement paie, bulletins et historique.',
            ),
            const SizedBox(height: 16),
            AppCard(
              child: TabBar(
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: appTextMuted(context),
                tabs: const [
                  Tab(text: 'Traitement'),
                  Tab(text: 'Bulletins'),
                  Tab(text: 'Variables'),
                  Tab(text: 'Historique'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 740,
              child: TabBarView(
                children: [
                  _TraitementTab(processes: _processes),
                  _BulletinsTab(payslips: _payslips, onOpen: _openPayslip),
                  _VariablesTab(variables: _variables),
                  _HistoriqueTab(history: _history),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TraitementTab extends StatelessWidget {
  const _TraitementTab({required this.processes});

  final List<_PayrollProcess> processes;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _MetricCard(title: 'Masse salariale', value: 'FCFA 1.2M', subtitle: 'Mois en cours'),
              _MetricCard(title: 'Bulletins a generer', value: '18', subtitle: 'Mars 2024'),
              _MetricCard(title: 'Cotisations sociales', value: 'FCFA 240k', subtitle: 'Estimation'),
              _MetricCard(title: 'Virements', value: '2 en attente', subtitle: 'Validation banque'),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Traitement de la paie', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                ...processes.map((process) => _ProcessRow(process: process)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(onPressed: () {}, child: const Text('Importer variables')),
                    OutlinedButton(onPressed: () {}, child: const Text('Calculer cotisations')),
                    OutlinedButton(onPressed: () {}, child: const Text('Generer bulletins')),
                    OutlinedButton(onPressed: () {}, child: const Text('Virement bancaire')),
                    OutlinedButton(onPressed: () {}, child: const Text('Declaration DSN')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletinsTab extends StatelessWidget {
  const _BulletinsTab({required this.payslips, required this.onOpen});

  final List<_Payslip> payslips;
  final ValueChanged<_Payslip> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: payslips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final payslip = payslips[index];
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bulletin ${payslip.number}', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
              const SizedBox(height: 6),
              Text('${payslip.employee} • ${payslip.job} • ${payslip.period}', style: TextStyle(color: appTextMuted(context))),
              const SizedBox(height: 6),
              Text('Brut: ${_fmtAmount(payslip.gross)} • Net: ${_fmtAmount(payslip.net)}',
                  style: TextStyle(color: appTextMuted(context), fontSize: 12)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(onPressed: () => onOpen(payslip), child: const Text('Voir bulletin')),
                  OutlinedButton(onPressed: () {}, child: const Text('Exporter PDF')),
                  OutlinedButton(onPressed: () {}, child: const Text('Envoyer email')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VariablesTab extends StatelessWidget {
  const _VariablesTab({required this.variables});

  final List<_PayrollVariable> variables;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: variables.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final variable = variables[index];
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(variable.title, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
              const SizedBox(height: 6),
              Text(variable.value, style: TextStyle(color: appTextMuted(context))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(onPressed: () {}, child: const Text('Parametrer')),
                  OutlinedButton(onPressed: () {}, child: const Text('Historique')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HistoriqueTab extends StatelessWidget {
  const _HistoriqueTab({required this.history});

  final List<_SalaryHistory> history;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Evolution salaire', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                ...history.map(
                  (item) => _InfoRow(
                    label: item.period,
                    value: '${_fmtAmount(item.salary)} • ${item.change}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Comparaison marche', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _InfoRow(label: 'Mediane secteur', value: 'FCFA 480k'),
                const _InfoRow(label: 'Position interne', value: '+8%'),
                const _InfoRow(label: 'Ecart H/F', value: '4%'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Analyse ecarts salariaux', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                const _ProgressRow(label: 'Cadres', value: 0.68, detail: 'Moyenne FCFA 780k'),
                const _ProgressRow(label: 'Employes', value: 0.52, detail: 'Moyenne FCFA 360k'),
                const _ProgressRow(label: 'Techniciens', value: 0.74, detail: 'Moyenne FCFA 420k'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PayslipDialog extends StatelessWidget {
  const _PayslipDialog({required this.payslip});

  final _Payslip payslip;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Bulletin ${payslip.number}'),
          automaticallyImplyLeading: false,
          actions: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('PDF'),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.mail_outline, size: 18),
              label: const Text('Email'),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Identification'),
              Tab(text: 'Temps travail'),
              Tab(text: 'Brut'),
              Tab(text: 'Cotisations'),
              Tab(text: 'Net a payer'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _PayslipSection(
              title: 'Identification',
              items: [
                const _InfoRow(label: 'Employeur', value: 'SYSCOHADA SARL'),
                _InfoRow(label: 'SIRET', value: 'TG123456789'),
                _InfoRow(label: 'Salarie', value: payslip.employee),
                _InfoRow(label: 'Matricule', value: payslip.matricule),
                _InfoRow(label: 'Poste', value: payslip.job),
                _InfoRow(label: 'Periode', value: payslip.period),
                _InfoRow(label: 'Numero bulletin', value: payslip.number),
              ],
            ),
            const _PayslipSection(
              title: 'Temps de travail',
              items: [
                _InfoRow(label: 'Heures contractuelles', value: '173.33'),
                _InfoRow(label: 'Heures travaillees', value: '168.0'),
                _InfoRow(label: 'Heures supplementaires', value: '6.5'),
                _InfoRow(label: 'Absences deduites', value: '2.0'),
                _InfoRow(label: 'Conges payes pris', value: '1.0'),
              ],
            ),
            const _PayslipSection(
              title: 'Remuneration brute',
              items: [
                _InfoRow(label: 'Salaire de base', value: 'FCFA 420k'),
                _InfoRow(label: 'Primes (anciennete)', value: 'FCFA 18k'),
                _InfoRow(label: 'Primes performance', value: 'FCFA 40k'),
                _InfoRow(label: 'Avantages en nature', value: 'FCFA 12k'),
                _InfoRow(label: 'HS majorees', value: 'FCFA 30k'),
                _InfoRow(label: 'Total brut', value: 'FCFA 520k'),
              ],
            ),
            const _PayslipSection(
              title: 'Cotisations',
              items: [
                _InfoRow(label: 'Securite sociale', value: 'FCFA 22k'),
                _InfoRow(label: 'Retraite', value: 'FCFA 18k'),
                _InfoRow(label: 'Chomage', value: 'FCFA 6k'),
                _InfoRow(label: 'CSG/CRDS', value: 'FCFA 4k'),
                _InfoRow(label: 'Cotisations salariales', value: 'FCFA 50k'),
                _InfoRow(label: 'Cotisations patronales', value: 'FCFA 62k'),
                _InfoRow(label: 'Total cotisations', value: 'FCFA 112k'),
              ],
            ),
            const _PayslipSection(
              title: 'Net a payer',
              items: [
                _InfoRow(label: 'Net imposable', value: 'FCFA 460k'),
                _InfoRow(label: 'Prelevement source', value: 'FCFA 20k'),
                _InfoRow(label: 'Autres retenues', value: 'FCFA 30k'),
                _InfoRow(label: 'NET A PAYER', value: 'FCFA 410k'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PayslipSection extends StatelessWidget {
  const _PayslipSection({required this.title, required this.items});

  final String title;
  final List<_InfoRow> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
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

class _ProcessRow extends StatelessWidget {
  const _ProcessRow({required this.process});

  final _PayrollProcess process;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(process.period, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
          const SizedBox(height: 6),
          Text('${process.status} • ${process.imports}', style: TextStyle(color: appTextMuted(context))),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: process.progress,
            minHeight: 6,
            backgroundColor: AppColors.primary.withOpacity(0.08),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.label, required this.value, required this.detail});

  final String label;
  final double value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: AppColors.primary.withOpacity(0.08),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(detail, style: TextStyle(color: appTextMuted(context), fontSize: 12)),
            ],
          ),
        ],
      ),
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

class _PayrollProcess {
  const _PayrollProcess({
    required this.period,
    required this.status,
    required this.imports,
    required this.progress,
  });

  final String period;
  final String status;
  final String imports;
  final double progress;
}

class _Payslip {
  const _Payslip({
    required this.number,
    required this.employee,
    required this.matricule,
    required this.job,
    required this.period,
    required this.gross,
    required this.net,
  });

  final String number;
  final String employee;
  final String matricule;
  final String job;
  final String period;
  final int gross;
  final int net;
}

class _PayrollVariable {
  const _PayrollVariable({required this.title, required this.value});

  final String title;
  final String value;
}

class _SalaryHistory {
  const _SalaryHistory({required this.period, required this.salary, required this.change});

  final String period;
  final int salary;
  final String change;
}

String _fmtAmount(int value) {
  return 'FCFA ${value.toString().replaceAllMapped(RegExp(r'\\B(?=(\\d{3})+(?!\\d))'), (match) => ' ')}';
}

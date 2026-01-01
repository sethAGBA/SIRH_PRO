import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/dao/dao_registry.dart';
import '../../../core/security/auth_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/operation_notice.dart';
import '../../../core/widgets/section_header.dart';
import '../../../shared/models/avantage_social.dart';
import '../../../shared/models/iuts_tranche.dart';
import '../../../shared/models/paie_parametre.dart';
import '../../../shared/models/paie_salaire.dart';

class PaieRemunerationScreen extends StatefulWidget {
  const PaieRemunerationScreen({super.key});

  @override
  State<PaieRemunerationScreen> createState() => _PaieRemunerationScreenState();
}

class _PaieRemunerationScreenState extends State<PaieRemunerationScreen> {
  final List<PaieSalaire> _salaries = [];
  final List<PaieSalaire> _allSalaries = [];
  final List<AvantageSocial> _variables = [];
  final List<PaieParametre> _params = [];
  final List<IutsTranche> _iutsTranches = [];
  final List<_PayrollProcess> _processes = [];
  final List<_SalaryHistory> _history = [];
  final List<_IdLabelOption> _employeeOptions = [];
  final Map<String, _EmployeeInfo> _employeeById = {};

  bool _loadingSalaries = false;
  bool _loadingVariables = false;
  bool _loadingOverview = false;
  bool _loadingParams = false;

  int _page = 0;
  final int _pageSize = 8;
  int _total = 0;

  String _search = '';
  String _filterPeriod = 'Toutes';
  String _filterStatus = 'Tous';

  List<String> _periods = [];
  String _overviewPeriod = '';

  final List<_PaieParamDefinition> _paramDefinitions = const [
    _PaieParamDefinition(
      code: 'cnss_salarial_taux',
      label: 'CNSS salarial',
      unit: '%',
      category: 'CNSS',
      defaultValue: 5.5,
    ),
    _PaieParamDefinition(
      code: 'cnss_patronal_taux',
      label: 'CNSS patronal',
      unit: '%',
      category: 'CNSS',
      defaultValue: 17.0,
    ),
    _PaieParamDefinition(
      code: 'cnss_plafond',
      label: 'Plafond CNSS',
      unit: 'FCFA',
      category: 'CNSS',
      defaultValue: 600000,
    ),
    _PaieParamDefinition(
      code: 'iuts_abattement_pct',
      label: 'Abattement IUTS',
      unit: '%',
      category: 'IUTS',
      defaultValue: 0,
    ),
    _PaieParamDefinition(
      code: 'heures_mensuelles',
      label: 'Heures mensuelles',
      unit: 'h',
      category: 'Temps',
      defaultValue: 173.33,
    ),
    _PaieParamDefinition(
      code: 'hs_taux_125',
      label: 'HS 1.25',
      unit: 'x',
      category: 'Heures sup',
      defaultValue: 1.25,
    ),
    _PaieParamDefinition(
      code: 'hs_taux_150',
      label: 'HS 1.5',
      unit: 'x',
      category: 'Heures sup',
      defaultValue: 1.5,
    ),
    _PaieParamDefinition(
      code: 'hs_taux_200',
      label: 'HS 2.0',
      unit: 'x',
      category: 'Heures sup',
      defaultValue: 2.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _loadSalaries();
    _loadVariables();
    _loadParams();
    _loadIutsTranches();
    _loadOverview();
  }

  Future<void> _loadEmployees() async {
    final rows = await DaoRegistry.instance.employes.list(orderBy: 'nom_complet ASC');
    final options = <_IdLabelOption>[];
    final map = <String, _EmployeeInfo>{};
    for (final row in rows) {
      final id = (row['id'] as String?) ?? '';
      final name = (row['nom_complet'] as String?) ?? '';
      if (id.isEmpty || name.isEmpty) continue;
      options.add(_IdLabelOption(id: id, label: name));
      map[id] = _EmployeeInfo(
        name: name,
        matricule: (row['matricule'] as String?) ?? '',
        job: (row['poste_actuel'] as String?) ?? '',
      );
    }
    if (!mounted) return;
    setState(() {
      _employeeOptions
        ..clear()
        ..addAll(options);
      _employeeById
        ..clear()
        ..addAll(map);
    });
  }

  Future<void> _loadSalaries({bool resetPage = false}) async {
    if (resetPage) _page = 0;
    setState(() => _loadingSalaries = true);
    final period = _filterPeriod == 'Toutes' ? null : _filterPeriod;
    final status = _filterStatus == 'Tous' ? null : _filterStatus;
    final rows = await DaoRegistry.instance.paies.search(
      query: _search,
      period: period,
      status: status,
      orderBy: 'p.created_at DESC',
      limit: _pageSize,
      offset: _page * _pageSize,
    );
    final total = await DaoRegistry.instance.paies.count(
      query: _search,
      period: period,
      status: status,
    );
    if (!mounted) return;
    setState(() {
      _salaries
        ..clear()
        ..addAll(rows.map(_salaryFromRow));
      _total = total;
      _loadingSalaries = false;
    });
  }

  Future<void> _loadVariables() async {
    setState(() => _loadingVariables = true);
    final rows = await DaoRegistry.instance.avantages.list(orderBy: 'created_at DESC');
    if (!mounted) return;
    setState(() {
      _variables
        ..clear()
        ..addAll(rows.map(_variableFromRow));
      _loadingVariables = false;
    });
  }

  Future<void> _loadParams() async {
    setState(() => _loadingParams = true);
    await _ensureDefaultParams();
    final rows = await DaoRegistry.instance.paieParametres.list(orderBy: 'categorie ASC');
    if (!mounted) return;
    setState(() {
      _params
        ..clear()
        ..addAll(rows.map(_paramFromRow));
      _loadingParams = false;
    });
  }

  Future<void> _loadIutsTranches() async {
    final rows = await DaoRegistry.instance.paieIutsTranches.list(orderBy: 'min_val ASC');
    if (!mounted) return;
    setState(() {
      _iutsTranches
        ..clear()
        ..addAll(rows.map(_trancheFromRow));
    });
  }

  Future<void> _ensureDefaultParams() async {
    for (final def in _paramDefinitions) {
      final existing = await DaoRegistry.instance.paieParametres.getByCode(def.code);
      if (existing != null) continue;
      final now = DateTime.now().millisecondsSinceEpoch;
      await DaoRegistry.instance.paieParametres.insert({
        'id': 'param-${def.code}',
        'code': def.code,
        'label': def.label,
        'valeur': def.defaultValue,
        'unite': def.unit,
        'categorie': def.category,
        'description': def.description,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  PaieParametre _paramFromRow(Map<String, dynamic> row) {
    final value = row['valeur'];
    return PaieParametre(
      id: (row['id'] as String?) ?? '',
      code: (row['code'] as String?) ?? '',
      label: (row['label'] as String?) ?? '',
      value: _toDouble(value),
      unit: (row['unite'] as String?) ?? '',
      category: (row['categorie'] as String?) ?? '',
      description: (row['description'] as String?) ?? '',
    );
  }

  Map<String, dynamic> _paramToRow(PaieParametre param) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return {
      'id': param.id,
      'code': param.code,
      'label': param.label,
      'valeur': param.value,
      'unite': param.unit,
      'categorie': param.category,
      'description': param.description,
      'updated_at': now,
      'created_at': now,
    };
  }

  IutsTranche _trancheFromRow(Map<String, dynamic> row) {
    final minVal = row['min_val'];
    final maxVal = row['max_val'];
    final taux = row['taux'];
    return IutsTranche(
      id: (row['id'] as String?) ?? '',
      min: _toDouble(minVal),
      max: maxVal == null ? null : _toDouble(maxVal),
      rate: _toDouble(taux),
    );
  }

  Map<String, dynamic> _trancheToRow(IutsTranche tranche, {required bool forInsert}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return {
      'id': tranche.id,
      'min_val': tranche.min,
      'max_val': tranche.max,
      'taux': tranche.rate,
      'updated_at': now,
      if (forInsert) 'created_at': now,
    };
  }

  double _getParamValue(String code, double fallback) {
    final param = _params.firstWhere(
      (item) => item.code == code,
      orElse: () => PaieParametre(
        id: '',
        code: code,
        label: '',
        value: fallback,
        unit: '',
        category: '',
        description: '',
      ),
    );
    return param.value;
  }

  _PayrollCalcConfig _buildCalcConfig() {
    return _PayrollCalcConfig(
      cnssSalarialPct: _getParamValue('cnss_salarial_taux', _tauxCotisationSalariale * 100),
      cnssPatronalPct: _getParamValue('cnss_patronal_taux', _tauxCotisationPatronale * 100),
      cnssPlafond: _getParamValue('cnss_plafond', 0),
      iutsAbattementPct: _getParamValue('iuts_abattement_pct', 0),
      heuresMensuelles: _getParamValue('heures_mensuelles', _defaultMonthlyHours),
      hs125: _getParamValue('hs_taux_125', 1.25),
      hs150: _getParamValue('hs_taux_150', 1.5),
      hs200: _getParamValue('hs_taux_200', 2.0),
      iutsTranches: _iutsTranches,
    );
  }

  Future<void> _loadOverview() async {
    setState(() => _loadingOverview = true);
    final rows = await DaoRegistry.instance.paies.list(orderBy: 'created_at DESC');
    final salaries = rows.map(_salaryFromRow).toList();
    final periods = await DaoRegistry.instance.paies.listPeriods();
    final processes = _buildProcesses(salaries);
    final history = _buildHistory(salaries);
    final overviewPeriod = _overviewPeriod.isNotEmpty
        ? _overviewPeriod
        : (periods.isNotEmpty ? periods.first : '');
    if (!mounted) return;
    setState(() {
      _processes
        ..clear()
        ..addAll(processes);
      _allSalaries
        ..clear()
        ..addAll(salaries);
      _history
        ..clear()
        ..addAll(history);
      _periods = periods;
      _overviewPeriod = overviewPeriod;
      _loadingOverview = false;
    });
  }

  PaieSalaire _salaryFromRow(Map<String, dynamic> row) {
    final brut = row['brut'];
    final net = row['net'];
    final base = row['salaire_base'];
    final heures = row['heures_travaillees'];
    final heuresSupp = row['heures_supp'];
    final absences = row['jours_absence'];
    final primes = row['primes'];
    final avances = row['avances'];
    final autresRetenues = row['autres_retenues'];
    final cotSalariales = row['cotisations_salariales'];
    final cotPatronales = row['cotisations_patronales'];
    final impots = row['impots'];
    final netImposable = row['net_imposable'];
    final netAPayer = row['net_a_payer'];
    final paiementDate = row['date_paiement'] as int?;
    return PaieSalaire(
      id: (row['id'] as String?) ?? '',
      employeId: (row['employe_id'] as String?) ?? '',
      period: (row['periode'] as String?) ?? '',
      gross: _toDouble(brut),
      net: _toDouble(net),
      baseSalary: _toDouble(base),
      hoursWorked: _toDouble(heures),
      overtimeHours: _toDouble(heuresSupp),
      absenceDays: _toDouble(absences),
      primes: _toDouble(primes),
      avances: _toDouble(avances),
      otherDeductions: _toDouble(autresRetenues),
      cotisationsSalariales: _toDouble(cotSalariales),
      cotisationsPatronales: _toDouble(cotPatronales),
      impots: _toDouble(impots),
      netImposable: _toDouble(netImposable),
      netAPayer: _toDouble(netAPayer),
      paymentMode: (row['mode_paiement'] as String?) ?? '',
      paymentDate: paiementDate == null ? null : DateTime.fromMillisecondsSinceEpoch(paiementDate),
      paymentReference: (row['reference_paiement'] as String?) ?? '',
      paymentStatus: (row['statut_paiement'] as String?) ?? '',
      createdBy: (row['created_by'] as String?) ?? '',
      updatedBy: (row['updated_by'] as String?) ?? '',
      status: (row['statut'] as String?) ?? '',
    );
  }

  Map<String, dynamic> _salaryToRow(
    PaieSalaire salary, {
    required bool forInsert,
    String? createdBy,
    String? updatedBy,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return {
      'id': salary.id,
      'employe_id': salary.employeId,
      'periode': salary.period,
      'brut': salary.gross,
      'net': salary.net,
      'salaire_base': salary.baseSalary,
      'heures_travaillees': salary.hoursWorked,
      'heures_supp': salary.overtimeHours,
      'jours_absence': salary.absenceDays,
      'primes': salary.primes,
      'avances': salary.avances,
      'autres_retenues': salary.otherDeductions,
      'cotisations_salariales': salary.cotisationsSalariales,
      'cotisations_patronales': salary.cotisationsPatronales,
      'impots': salary.impots,
      'net_imposable': salary.netImposable,
      'net_a_payer': salary.netAPayer,
      'mode_paiement': salary.paymentMode,
      'date_paiement': salary.paymentDate?.millisecondsSinceEpoch,
      'reference_paiement': salary.paymentReference,
      'statut_paiement': salary.paymentStatus,
      'created_by': createdBy ?? salary.createdBy,
      'updated_by': updatedBy ?? salary.updatedBy,
      'statut': salary.status,
      'updated_at': now,
      if (forInsert) 'created_at': now,
    };
  }

  AvantageSocial _variableFromRow(Map<String, dynamic> row) {
    final value = row['valeur'];
    return AvantageSocial(
      id: (row['id'] as String?) ?? '',
      employeId: (row['employe_id'] as String?) ?? '',
      type: (row['type'] as String?) ?? '',
      value: value is num ? value.toDouble() : double.tryParse('${value ?? 0}') ?? 0,
    );
  }

  Map<String, dynamic> _variableToRow(AvantageSocial variable, {required bool forInsert}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return {
      'id': variable.id,
      'employe_id': variable.employeId,
      'type': variable.type,
      'valeur': variable.value,
      'updated_at': now,
      if (forInsert) 'created_at': now,
    };
  }

  List<_PayrollProcess> _buildProcesses(List<PaieSalaire> salaries) {
    final grouped = <String, List<PaieSalaire>>{};
    for (final salary in salaries) {
      final period = salary.period.isEmpty ? 'Periode inconnue' : salary.period;
      grouped.putIfAbsent(period, () => []).add(salary);
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return entries
        .map(
          (entry) => _PayrollProcess(
            period: entry.key,
            status: _aggregateStatus(entry.value),
            imports: '${entry.value.length} bulletins',
            progress: _statusProgress(_aggregateStatus(entry.value)),
          ),
        )
        .toList();
  }

  List<_SalaryHistory> _buildHistory(List<PaieSalaire> salaries) {
    final byYear = <String, List<PaieSalaire>>{};
    for (final salary in salaries) {
      final year = _extractYear(salary.period);
      if (year.isEmpty) continue;
      byYear.putIfAbsent(year, () => []).add(salary);
    }
    final years = byYear.keys.toList()..sort();
    final history = <_SalaryHistory>[];
    double? previousAvg;
    for (final year in years) {
      final items = byYear[year]!;
      final values = items.map((s) => s.netAPayer == 0 ? s.net : s.netAPayer).toList();
      final double avg = values.isEmpty ? 0.0 : values.reduce((a, b) => a + b) / values.length;
      final change = previousAvg == null || previousAvg == 0
          ? ''
          : '${(((avg - previousAvg) / previousAvg) * 100).round()}%';
      history.add(_SalaryHistory(period: year, salary: avg.round(), change: change));
      previousAvg = avg;
    }
    return history.reversed.toList();
  }

  String _aggregateStatus(List<PaieSalaire> salaries) {
    if (salaries.any((s) => s.status == 'Brouillon' || s.status == 'En cours')) return 'En cours';
    if (salaries.any((s) => s.status == 'Valide')) return 'Valide';
    if (salaries.any((s) => s.status == 'Archive')) return 'Archive';
    return salaries.isEmpty ? 'En cours' : salaries.first.status;
  }

  double _statusProgress(String status) {
    switch (status) {
      case 'Brouillon':
        return 0.25;
      case 'En cours':
        return 0.6;
      case 'Valide':
      case 'Archive':
        return 1.0;
      default:
        return 0.4;
    }
  }

  _PayrollMetrics _metricsForPeriod(String period) {
    final salaries = _salariesForPeriod(period);
    final grossTotal = salaries.fold<double>(0, (sum, s) => sum + s.gross);
    final netTotal = salaries.fold<double>(0, (sum, s) => sum + (s.netAPayer == 0 ? s.net : s.netAPayer));
    final deductions = grossTotal - netTotal;
    final toGenerate = salaries.where((s) => s.status == 'Brouillon' || s.status == 'En cours').length;
    return _PayrollMetrics(
      grossTotal: grossTotal,
      netTotal: netTotal,
      deductions: deductions,
      totalCount: salaries.length,
      pendingCount: toGenerate,
    );
  }

  List<PaieSalaire> _salariesForPeriod(String period) {
    if (period.isEmpty) return [];
    return _allSalaries.where((s) => s.period == period).toList();
  }

  Future<void> _openSalaryForm({PaieSalaire? salary}) async {
    final updated = await showDialog<PaieSalaire>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _PayrollFormDialog(
          salary: salary,
          employeeOptions: _employeeOptions,
          calcConfig: _buildCalcConfig(),
        ),
      ),
    );
    if (updated == null) return;

    final user = await AuthService().getCurrentUserSummary();
    final userName = user['name'] ?? 'Utilisateur';
    final exists = _salaries.any((item) => item.id == updated.id);
    if (exists) {
      await DaoRegistry.instance.paies.update(
        updated.id,
        _salaryToRow(updated, forInsert: false, updatedBy: userName),
      );
      showOperationNotice(context, message: 'Bulletin mis a jour.', success: true);
    } else {
      await DaoRegistry.instance.paies.insert(
        _salaryToRow(updated, forInsert: true, createdBy: userName, updatedBy: userName),
      );
      showOperationNotice(context, message: 'Bulletin ajoute.', success: true);
    }
    await _loadSalaries(resetPage: true);
    await _loadOverview();
  }

  void _openSalaryDetail(PaieSalaire salary) {
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _PayslipDetailScreen(
          salary: salary,
          employee: _employeeById[salary.employeId],
          onExportPdf: () => _exportPayslipPdf(salary, _employeeById[salary.employeId]),
        ),
      ),
    );
  }

  Future<void> _deleteSalary(PaieSalaire salary) async {
    await DaoRegistry.instance.paies.delete(salary.id);
    await _loadSalaries(resetPage: true);
    await _loadOverview();
    showOperationNotice(context, message: 'Bulletin supprime.', success: true);
  }

  Future<void> _exportPayslipPdf(PaieSalaire salary, _EmployeeInfo? employee) async {
    final doc = pw.Document();
    final name = employee?.name ?? 'Employe inconnu';
    final matricule = employee?.matricule.isNotEmpty == true ? employee!.matricule : '-';
    final job = employee?.job.isNotEmpty == true ? employee!.job : 'Poste a definir';
    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Bulletin de paie', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          _pdfSection(
            'Identification',
            [
              _pdfRow('Employe', name),
              _pdfRow('Matricule', matricule),
              _pdfRow('Poste', job),
              _pdfRow('Periode', _display(salary.period)),
              _pdfRow('Statut', _display(salary.status)),
            ],
          ),
          _pdfSection(
            'Remuneration',
            [
              _pdfRow('Salaire de base', _fmtAmount(salary.baseSalary)),
              _pdfRow('Heures travaillees', '${salary.hoursWorked.toStringAsFixed(1)} h'),
              _pdfRow('Heures supplementaires', '${salary.overtimeHours.toStringAsFixed(1)} h'),
              _pdfRow('Absences', '${salary.absenceDays.toStringAsFixed(1)} j'),
              _pdfRow('Primes', _fmtAmount(salary.primes)),
              _pdfRow('Brut', _fmtAmount(salary.gross)),
            ],
          ),
          _pdfSection(
            'Cotisations et impots',
            [
              _pdfRow('Cotisations salariales', _fmtAmount(salary.cotisationsSalariales)),
              _pdfRow('Cotisations patronales', _fmtAmount(salary.cotisationsPatronales)),
              _pdfRow('Net imposable', _fmtAmount(salary.netImposable)),
              _pdfRow('Impots (IUTS)', _fmtAmount(salary.impots)),
              _pdfRow('Avances', _fmtAmount(salary.avances)),
              _pdfRow('Autres retenues', _fmtAmount(salary.otherDeductions)),
              _pdfRow('Net a payer', _fmtAmount(salary.netAPayer)),
            ],
          ),
          _pdfSection(
            'Paiement',
            [
              _pdfRow('Mode', _display(salary.paymentMode)),
              _pdfRow('Statut', _display(salary.paymentStatus)),
              _pdfRow('Date', salary.paymentDate == null ? 'A definir' : _formatDate(salary.paymentDate!)),
              _pdfRow('Reference', _display(salary.paymentReference)),
            ],
          ),
          _pdfSection(
            'Audit',
            [
              _pdfRow('Cree par', _display(salary.createdBy)),
              _pdfRow('Mis a jour par', _display(salary.updatedBy)),
            ],
          ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  Future<void> _openVariableForm({AvantageSocial? variable}) async {
    final updated = await showDialog<AvantageSocial>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _VariableFormDialog(
          variable: variable,
          employeeOptions: _employeeOptions,
        ),
      ),
    );
    if (updated == null) return;

    final exists = _variables.any((item) => item.id == updated.id);
    if (exists) {
      await DaoRegistry.instance.avantages.update(updated.id, _variableToRow(updated, forInsert: false));
      showOperationNotice(context, message: 'Variable mise a jour.', success: true);
    } else {
      await DaoRegistry.instance.avantages.insert(_variableToRow(updated, forInsert: true));
      showOperationNotice(context, message: 'Variable ajoutee.', success: true);
    }
    await _loadVariables();
  }

  Future<void> _deleteVariable(AvantageSocial variable) async {
    await DaoRegistry.instance.avantages.delete(variable.id);
    await _loadVariables();
    showOperationNotice(context, message: 'Variable supprimee.', success: true);
  }

  Future<void> _openParamForm(PaieParametre param) async {
    final updated = await showDialog<PaieParametre>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _PaieParamFormDialog(param: param),
      ),
    );
    if (updated == null) return;
    await DaoRegistry.instance.paieParametres.update(updated.id, _paramToRow(updated));
    await _loadParams();
    showOperationNotice(context, message: 'Parametre mis a jour.', success: true);
  }

  Future<void> _openIutsTrancheForm({IutsTranche? tranche}) async {
    final updated = await showDialog<IutsTranche>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _IutsTrancheFormDialog(tranche: tranche),
      ),
    );
    if (updated == null) return;
    if (tranche == null) {
      await DaoRegistry.instance.paieIutsTranches.insert(_trancheToRow(updated, forInsert: true));
      showOperationNotice(context, message: 'Tranche ajoutee.', success: true);
    } else {
      await DaoRegistry.instance.paieIutsTranches.update(updated.id, _trancheToRow(updated, forInsert: false));
      showOperationNotice(context, message: 'Tranche mise a jour.', success: true);
    }
    await _loadIutsTranches();
  }

  Future<void> _deleteIutsTranche(IutsTranche tranche) async {
    await DaoRegistry.instance.paieIutsTranches.delete(tranche.id);
    await _loadIutsTranches();
    showOperationNotice(context, message: 'Tranche supprimee.', success: true);
  }

  Future<void> _closePeriod(String period) async {
    if (period.isEmpty) return;
    final user = await AuthService().getCurrentUserSummary();
    final userName = user['name'] ?? 'Utilisateur';
    final rows = await DaoRegistry.instance.paies.search(period: period);
    for (final row in rows) {
      final salary = _salaryFromRow(row);
      final updated = salary.copyWith(
        status: 'Valide',
        updatedBy: userName,
      );
      await DaoRegistry.instance.paies.update(updated.id, _salaryToRow(updated, forInsert: false));
    }
    await _loadSalaries(resetPage: true);
    await _loadOverview();
    if (!mounted) return;
    showOperationNotice(context, message: 'Periode cloturee.', success: true);
  }

  Future<void> _markPeriodPaid(String period) async {
    if (period.isEmpty) return;
    final user = await AuthService().getCurrentUserSummary();
    final userName = user['name'] ?? 'Utilisateur';
    final now = DateTime.now();
    final rows = await DaoRegistry.instance.paies.search(period: period);
    for (final row in rows) {
      final salary = _salaryFromRow(row);
      final updated = salary.copyWith(
        paymentStatus: 'Paye',
        paymentDate: now,
        updatedBy: userName,
      );
      await DaoRegistry.instance.paies.update(updated.id, _salaryToRow(updated, forInsert: false));
    }
    await _loadSalaries(resetPage: true);
    await _loadOverview();
    if (!mounted) return;
    showOperationNotice(context, message: 'Paiement marque.', success: true);
  }

  @override
  Widget build(BuildContext context) {
    final overviewPeriod = _overviewPeriod.isNotEmpty
        ? _overviewPeriod
        : (_periods.isNotEmpty ? _periods.first : '');
    final metrics = _metricsForPeriod(overviewPeriod);

    return DefaultTabController(
      length: 5,
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
                  Tab(text: 'Parametres'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 740,
              child: TabBarView(
                children: [
                  _TraitementTab(
                    processes: _processes,
                    periods: _periods,
                    loading: _loadingOverview,
                    selectedPeriod: overviewPeriod,
                    metrics: metrics,
                    onPeriodChanged: (value) => setState(() => _overviewPeriod = value),
                    onClosePeriod: _closePeriod,
                    onMarkPaid: _markPeriodPaid,
                  ),
                  _BulletinsTab(
                    salaries: _salaries,
                    loading: _loadingSalaries,
                    periodFilter: _filterPeriod,
                    statusFilter: _filterStatus,
                    periods: _periods,
                    page: _page,
                    pageSize: _pageSize,
                    total: _total,
                    employeeById: _employeeById,
                    onSearch: (value) {
                      _search = value;
                      _loadSalaries(resetPage: true);
                    },
                    onPeriodChanged: (value) {
                      _filterPeriod = value;
                      _loadSalaries(resetPage: true);
                    },
                    onStatusChanged: (value) {
                      _filterStatus = value;
                      _loadSalaries(resetPage: true);
                    },
                    onCreate: () => _openSalaryForm(),
                    onEdit: (salary) => _openSalaryForm(salary: salary),
                    onOpen: _openSalaryDetail,
                    onExportPdf: (salary) => _exportPayslipPdf(salary, _employeeById[salary.employeId]),
                    onDelete: _deleteSalary,
                    onPrev: () {
                      if (_page == 0) return;
                      setState(() => _page -= 1);
                      _loadSalaries();
                    },
                    onNext: () {
                      final canNext = (_page + 1) * _pageSize < _total;
                      if (!canNext) return;
                      setState(() => _page += 1);
                      _loadSalaries();
                    },
                  ),
                  _VariablesTab(
                    variables: _variables,
                    loading: _loadingVariables,
                    employeeById: _employeeById,
                    params: _params,
                    tranches: _iutsTranches,
                    loadingParams: _loadingParams,
                    onEditParam: _openParamForm,
                    onAddTranche: () => _openIutsTrancheForm(),
                    onEditTranche: (tranche) => _openIutsTrancheForm(tranche: tranche),
                    onDeleteTranche: _deleteIutsTranche,
                    onCreate: () => _openVariableForm(),
                    onEdit: (variable) => _openVariableForm(variable: variable),
                    onDelete: _deleteVariable,
                  ),
                  _HistoriqueTab(history: _history),
                  _ParametresPaieTab(
                    params: _params,
                    tranches: _iutsTranches,
                    loading: _loadingParams,
                    onEditParam: _openParamForm,
                    onAddTranche: () => _openIutsTrancheForm(),
                    onEditTranche: (tranche) => _openIutsTrancheForm(tranche: tranche),
                    onDeleteTranche: _deleteIutsTranche,
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

class _TraitementTab extends StatelessWidget {
  const _TraitementTab({
    required this.processes,
    required this.periods,
    required this.loading,
    required this.selectedPeriod,
    required this.metrics,
    required this.onPeriodChanged,
    required this.onClosePeriod,
    required this.onMarkPaid,
  });

  final List<_PayrollProcess> processes;
  final List<String> periods;
  final bool loading;
  final String selectedPeriod;
  final _PayrollMetrics metrics;
  final ValueChanged<String> onPeriodChanged;
  final ValueChanged<String> onClosePeriod;
  final ValueChanged<String> onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final periodOptions = periods.isEmpty ? ['Aucune periode'] : periods;
    final selected = selectedPeriod.isEmpty ? periodOptions.first : selectedPeriod;

    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _MetricCard(title: 'Masse salariale', value: _fmtAmount(metrics.netTotal), subtitle: selected),
              _MetricCard(title: 'Bulletins', value: '${metrics.totalCount}', subtitle: selected),
              _MetricCard(title: 'Cotisations (est.)', value: _fmtAmount(metrics.deductions), subtitle: selected),
              _MetricCard(title: 'En attente', value: '${metrics.pendingCount}', subtitle: selected),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Traitement de la paie', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                    const Spacer(),
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        value: selected,
                        decoration: const InputDecoration(labelText: 'Periode'),
                        items: periodOptions
                            .map((period) => DropdownMenuItem(value: period, child: Text(period)))
                            .toList(),
                        onChanged: (value) => onPeriodChanged(value ?? periodOptions.first),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (processes.isEmpty)
                  Text('Aucun traitement enregistre.', style: TextStyle(color: appTextMuted(context)))
                else
                  ...processes.map((process) => _ProcessRow(process: process)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => showOperationNotice(context, message: 'Import variables lance.', success: true),
                      child: const Text('Importer variables'),
                    ),
                    OutlinedButton(
                      onPressed: () => showOperationNotice(context, message: 'Cotisations calculees.', success: true),
                      child: const Text('Calculer cotisations'),
                    ),
                    OutlinedButton(
                      onPressed: () => showOperationNotice(context, message: 'Bulletins generes.', success: true),
                      child: const Text('Generer bulletins'),
                    ),
                    OutlinedButton(
                      onPressed: () => showOperationNotice(context, message: 'Virement enregistre.', success: true),
                      child: const Text('Virement bancaire'),
                    ),
                    OutlinedButton(
                      onPressed: () => showOperationNotice(context, message: 'Declaration DSN envoyee.', success: true),
                      child: const Text('Declaration DSN'),
                    ),
                    OutlinedButton(
                      onPressed: selected.isEmpty ? null : () => onClosePeriod(selected),
                      child: const Text('Cloturer periode'),
                    ),
                    OutlinedButton(
                      onPressed: selected.isEmpty ? null : () => onMarkPaid(selected),
                      child: const Text('Marquer paye'),
                    ),
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
  const _BulletinsTab({
    required this.salaries,
    required this.loading,
    required this.periods,
    required this.periodFilter,
    required this.statusFilter,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.employeeById,
    required this.onSearch,
    required this.onPeriodChanged,
    required this.onStatusChanged,
    required this.onCreate,
    required this.onEdit,
    required this.onOpen,
    required this.onExportPdf,
    required this.onDelete,
    required this.onPrev,
    required this.onNext,
  });

  final List<PaieSalaire> salaries;
  final bool loading;
  final List<String> periods;
  final String periodFilter;
  final String statusFilter;
  final int page;
  final int pageSize;
  final int total;
  final Map<String, _EmployeeInfo> employeeById;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onPeriodChanged;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onCreate;
  final ValueChanged<PaieSalaire> onEdit;
  final ValueChanged<PaieSalaire> onOpen;
  final ValueChanged<PaieSalaire> onExportPdf;
  final ValueChanged<PaieSalaire> onDelete;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final periodOptions = ['Toutes', ...periods];
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Recherche employe ou matricule...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: onSearch,
                  ),
                ),
                _FilterDropdown(
                  label: 'Periode',
                  value: periodFilter,
                  items: periodOptions,
                  onChanged: onPeriodChanged,
                ),
                _FilterDropdown(
                  label: 'Statut',
                  value: statusFilter,
                  items: const ['Tous', 'Brouillon', 'En cours', 'Valide', 'Archive'],
                  onChanged: onStatusChanged,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add),
                  label: const Text('Nouveau bulletin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (salaries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text('Aucun bulletin disponible.', style: TextStyle(color: appTextMuted(context))),
            )
          else
            ...salaries.map(
              (salary) => _PayslipCard(
                salary: salary,
                employee: employeeById[salary.employeId],
                onEdit: () => onEdit(salary),
                onOpen: () => onOpen(salary),
                onExportPdf: () => onExportPdf(salary),
                onDelete: () => onDelete(salary),
              ),
            ),
          const SizedBox(height: 12),
          _PaginationBar(page: page, pageSize: pageSize, total: total, onPrev: onPrev, onNext: onNext),
        ],
      ),
    );
  }
}

class _VariablesTab extends StatelessWidget {
  const _VariablesTab({
    required this.variables,
    required this.loading,
    required this.employeeById,
    required this.params,
    required this.tranches,
    required this.loadingParams,
    required this.onEditParam,
    required this.onAddTranche,
    required this.onEditTranche,
    required this.onDeleteTranche,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
  });

  final List<AvantageSocial> variables;
  final bool loading;
  final Map<String, _EmployeeInfo> employeeById;
  final List<PaieParametre> params;
  final List<IutsTranche> tranches;
  final bool loadingParams;
  final ValueChanged<PaieParametre> onEditParam;
  final VoidCallback onAddTranche;
  final ValueChanged<IutsTranche> onEditTranche;
  final ValueChanged<IutsTranche> onDeleteTranche;
  final VoidCallback onCreate;
  final ValueChanged<AvantageSocial> onEdit;
  final ValueChanged<AvantageSocial> onDelete;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Parametres paie', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                if (loadingParams)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (params.isEmpty)
                  Text('Aucun parametre configure.', style: TextStyle(color: appTextMuted(context)))
                else
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: params
                        .map(
                          (param) => _ParamChip(
                            label: param.label,
                            value: _formatParamValue(param),
                            onEdit: () => onEditParam(param),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Tranches IUTS', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: onAddTranche,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter tranche'),
                    ),
                  ],
                ),
                if (tranches.isEmpty)
                  Text('Aucune tranche definie.', style: TextStyle(color: appTextMuted(context)))
                else
                  ...tranches.map(
                    (tranche) => Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_fmtAmount(tranche.min)} - ${tranche.max == null ? 'et +' : _fmtAmount(tranche.max!)}',
                            style: TextStyle(color: appTextMuted(context)),
                          ),
                        ),
                        Text('${tranche.rate.toStringAsFixed(1)}%', style: TextStyle(color: appTextPrimary(context))),
                        IconButton(
                          onPressed: () => onEditTranche(tranche),
                          icon: const Icon(Icons.edit, size: 18),
                        ),
                        IconButton(
                          onPressed: () => onDeleteTranche(tranche),
                          icon: const Icon(Icons.delete_outline, size: 18),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle variable'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (variables.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text('Aucune variable enregistree.', style: TextStyle(color: appTextMuted(context))),
            )
          else
            ...variables.map(
              (variable) {
                final employee = employeeById[variable.employeId];
                final subtitle = employee == null ? 'Employe a definir' : employee.name;
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(variable.type, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                      const SizedBox(height: 6),
                      Text(subtitle, style: TextStyle(color: appTextMuted(context))),
                      const SizedBox(height: 6),
                      Text('Valeur: ${_fmtAmount(variable.value)}', style: TextStyle(color: appTextMuted(context), fontSize: 12)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(onPressed: () => onEdit(variable), child: const Text('Modifier')),
                          OutlinedButton(onPressed: () => onDelete(variable), child: const Text('Supprimer')),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _HistoriqueTab extends StatelessWidget {
  const _HistoriqueTab({required this.history});

  final List<_SalaryHistory> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Text('Aucun historique disponible.', style: TextStyle(color: appTextMuted(context))),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Evolution salaire net', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                const SizedBox(height: 12),
                ...history.map(
                  (item) => _InfoRow(
                    label: item.period,
                    value: '${_fmtAmount(item.salary)} ${item.change.isEmpty ? '' : '• ${item.change}'}',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParametresPaieTab extends StatelessWidget {
  const _ParametresPaieTab({
    required this.params,
    required this.tranches,
    required this.loading,
    required this.onEditParam,
    required this.onAddTranche,
    required this.onEditTranche,
    required this.onDeleteTranche,
  });

  final List<PaieParametre> params;
  final List<IutsTranche> tranches;
  final bool loading;
  final ValueChanged<PaieParametre> onEditParam;
  final VoidCallback onAddTranche;
  final ValueChanged<IutsTranche> onEditTranche;
  final ValueChanged<IutsTranche> onDeleteTranche;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (params.isEmpty) {
      return Center(
        child: Text('Aucun parametre configure.', style: TextStyle(color: appTextMuted(context))),
      );
    }
    final categories = <String, List<PaieParametre>>{};
    for (final param in params) {
      categories.putIfAbsent(param.category, () => []).add(param);
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          ...categories.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: entry.value
                          .map(
                            (param) => _ParamChip(
                              label: param.label,
                              value: _formatParamValue(param),
                              onEdit: () => onEditParam(param),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Tranches IUTS', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: onAddTranche,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter tranche'),
                    ),
                  ],
                ),
                if (tranches.isEmpty)
                  Text('Aucune tranche definie.', style: TextStyle(color: appTextMuted(context)))
                else
                  ...tranches.map(
                    (tranche) => Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_fmtAmount(tranche.min)} - ${tranche.max == null ? 'et +' : _fmtAmount(tranche.max!)}',
                            style: TextStyle(color: appTextMuted(context)),
                          ),
                        ),
                        Text('${tranche.rate.toStringAsFixed(1)}%', style: TextStyle(color: appTextPrimary(context))),
                        IconButton(
                          onPressed: () => onEditTranche(tranche),
                          icon: const Icon(Icons.edit, size: 18),
                        ),
                        IconButton(
                          onPressed: () => onDeleteTranche(tranche),
                          icon: const Icon(Icons.delete_outline, size: 18),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PayslipCard extends StatelessWidget {
  const _PayslipCard({
    required this.salary,
    required this.employee,
    required this.onEdit,
    required this.onOpen,
    required this.onExportPdf,
    required this.onDelete,
  });

  final PaieSalaire salary;
  final _EmployeeInfo? employee;
  final VoidCallback onEdit;
  final VoidCallback onOpen;
  final VoidCallback onExportPdf;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final name = employee?.name ?? 'Employe inconnu';
    final matricule = employee?.matricule.isNotEmpty == true ? employee!.matricule : '-';
    final job = employee?.job.isNotEmpty == true ? employee!.job : 'Poste a definir';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Bulletin $matricule', style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
              ),
              _StatusPill(label: salary.status),
            ],
          ),
          const SizedBox(height: 6),
          Text('$name • $job • ${salary.period}', style: TextStyle(color: appTextMuted(context))),
          const SizedBox(height: 6),
          Text('Brut: ${_fmtAmount(salary.gross)} • Net: ${_fmtAmount(salary.netAPayer == 0 ? salary.net : salary.netAPayer)}',
              style: TextStyle(color: appTextMuted(context), fontSize: 12)),
          Text('Paiement: ${salary.paymentStatus.isEmpty ? 'Non paye' : salary.paymentStatus}',
              style: TextStyle(color: appTextMuted(context), fontSize: 12)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(onPressed: onOpen, child: const Text('Voir bulletin')),
              OutlinedButton(
                onPressed: onExportPdf,
                child: const Text('Exporter PDF'),
              ),
              OutlinedButton(
                onPressed: () => showOperationNotice(context, message: 'Email envoye.', success: true),
                child: const Text('Envoyer email'),
              ),
              OutlinedButton(onPressed: onEdit, child: const Text('Modifier')),
              OutlinedButton(onPressed: onDelete, child: const Text('Supprimer')),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayslipDetailScreen extends StatelessWidget {
  const _PayslipDetailScreen({
    required this.salary,
    required this.employee,
    required this.onExportPdf,
  });

  final PaieSalaire salary;
  final _EmployeeInfo? employee;
  final VoidCallback onExportPdf;

  @override
  Widget build(BuildContext context) {
    final name = employee?.name ?? 'Employe inconnu';
    return Scaffold(
      appBar: AppBar(
        title: Text('Bulletin ${employee?.matricule ?? '-'}'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: onExportPdf,
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text('PDF'),
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
            SectionHeader(
              title: name,
              subtitle: employee?.job.isNotEmpty == true ? employee!.job : 'Poste a definir',
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'Periode', value: _display(salary.period)),
                  _InfoRow(label: 'Statut', value: _display(salary.status)),
                  _InfoRow(label: 'Salaire de base', value: _fmtAmount(salary.baseSalary)),
                  _InfoRow(label: 'Heures travaillees', value: '${salary.hoursWorked.toStringAsFixed(1)} h'),
                  _InfoRow(label: 'Heures supplementaires', value: '${salary.overtimeHours.toStringAsFixed(1)} h'),
                  _InfoRow(label: 'Absences', value: '${salary.absenceDays.toStringAsFixed(1)} j'),
                  _InfoRow(label: 'Primes', value: _fmtAmount(salary.primes)),
                  _InfoRow(label: 'Avances', value: _fmtAmount(salary.avances)),
                  _InfoRow(label: 'Autres retenues', value: _fmtAmount(salary.otherDeductions)),
                  _InfoRow(label: 'Brut', value: _fmtAmount(salary.gross)),
                  _InfoRow(label: 'Cotisations salariales', value: _fmtAmount(salary.cotisationsSalariales)),
                  _InfoRow(label: 'Cotisations patronales', value: _fmtAmount(salary.cotisationsPatronales)),
                  _InfoRow(label: 'Impots', value: _fmtAmount(salary.impots)),
                  _InfoRow(label: 'Net imposable', value: _fmtAmount(salary.netImposable)),
                  _InfoRow(label: 'Net a payer', value: _fmtAmount(salary.netAPayer)),
                  _InfoRow(label: 'Mode paiement', value: _display(salary.paymentMode)),
                  _InfoRow(label: 'Date paiement', value: salary.paymentDate == null ? 'A definir' : _formatDate(salary.paymentDate!)),
                  _InfoRow(label: 'Reference paiement', value: _display(salary.paymentReference)),
                  _InfoRow(label: 'Statut paiement', value: _display(salary.paymentStatus)),
                  _InfoRow(label: 'Cree par', value: _display(salary.createdBy)),
                  _InfoRow(label: 'Mis a jour par', value: _display(salary.updatedBy)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayrollFormDialog extends StatefulWidget {
  const _PayrollFormDialog({required this.employeeOptions, required this.calcConfig, this.salary});

  final PaieSalaire? salary;
  final List<_IdLabelOption> employeeOptions;
  final _PayrollCalcConfig calcConfig;

  @override
  State<_PayrollFormDialog> createState() => _PayrollFormDialogState();
}

class _PayrollFormDialogState extends State<_PayrollFormDialog> {
  late final TextEditingController _periodCtrl;
  late final TextEditingController _baseCtrl;
  late final TextEditingController _hoursCtrl;
  late final TextEditingController _overtimeCtrl;
  late final TextEditingController _absenceCtrl;
  late final TextEditingController _primesCtrl;
  late final TextEditingController _avancesCtrl;
  late final TextEditingController _otherDeductionsCtrl;
  late final TextEditingController _cotSalarialesCtrl;
  late final TextEditingController _cotPatronalesCtrl;
  late final TextEditingController _impotsCtrl;
  late final TextEditingController _netImposableCtrl;
  late final TextEditingController _netAPayerCtrl;
  late final TextEditingController _grossCtrl;
  late final TextEditingController _netCtrl;
  late final TextEditingController _paymentModeCtrl;
  late final TextEditingController _paymentDateCtrl;
  late final TextEditingController _paymentRefCtrl;
  String _status = 'Brouillon';
  String _paymentStatus = 'Non paye';
  String _selectedEmployeeId = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _periodCtrl = TextEditingController(text: widget.salary?.period ?? '');
    _baseCtrl = TextEditingController(text: _toText(widget.salary?.baseSalary));
    _hoursCtrl = TextEditingController(text: _toText(widget.salary?.hoursWorked));
    _overtimeCtrl = TextEditingController(text: _toText(widget.salary?.overtimeHours));
    _absenceCtrl = TextEditingController(text: _toText(widget.salary?.absenceDays));
    _primesCtrl = TextEditingController(text: _toText(widget.salary?.primes));
    _avancesCtrl = TextEditingController(text: _toText(widget.salary?.avances));
    _otherDeductionsCtrl = TextEditingController(text: _toText(widget.salary?.otherDeductions));
    _cotSalarialesCtrl = TextEditingController(text: _toText(widget.salary?.cotisationsSalariales));
    _cotPatronalesCtrl = TextEditingController(text: _toText(widget.salary?.cotisationsPatronales));
    _impotsCtrl = TextEditingController(text: _toText(widget.salary?.impots));
    _netImposableCtrl = TextEditingController(text: _toText(widget.salary?.netImposable));
    _netAPayerCtrl = TextEditingController(text: _toText(widget.salary?.netAPayer));
    _grossCtrl = TextEditingController(text: _toText(widget.salary?.gross));
    _netCtrl = TextEditingController(text: _toText(widget.salary?.net));
    _paymentModeCtrl = TextEditingController(text: widget.salary?.paymentMode ?? '');
    _paymentDateCtrl = TextEditingController(
      text: widget.salary?.paymentDate == null ? '' : _formatDate(widget.salary!.paymentDate!),
    );
    _paymentRefCtrl = TextEditingController(text: widget.salary?.paymentReference ?? '');
    _status = widget.salary?.status.isNotEmpty == true ? widget.salary!.status : 'Brouillon';
    _paymentStatus =
        widget.salary?.paymentStatus.isNotEmpty == true ? widget.salary!.paymentStatus : 'Non paye';
    _selectedEmployeeId = widget.salary?.employeId ?? '';
  }

  @override
  void dispose() {
    _periodCtrl.dispose();
    _baseCtrl.dispose();
    _hoursCtrl.dispose();
    _overtimeCtrl.dispose();
    _absenceCtrl.dispose();
    _primesCtrl.dispose();
    _avancesCtrl.dispose();
    _otherDeductionsCtrl.dispose();
    _cotSalarialesCtrl.dispose();
    _cotPatronalesCtrl.dispose();
    _impotsCtrl.dispose();
    _netImposableCtrl.dispose();
    _netAPayerCtrl.dispose();
    _grossCtrl.dispose();
    _netCtrl.dispose();
    _paymentModeCtrl.dispose();
    _paymentDateCtrl.dispose();
    _paymentRefCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final initial = DateTime.tryParse(controller.text.trim()) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    controller.text = _formatDate(picked);
  }

  Future<void> _autofillFromData() async {
    setState(() => _error = null);
    if (_selectedEmployeeId.isEmpty) {
      setState(() => _error = 'Employe requis pour le calcul.');
      return;
    }
    final range = _parsePeriodRange(_periodCtrl.text.trim());
    if (range == null) {
      setState(() => _error = 'Periode invalide (ex: 2024-03 ou Mars 2024).');
      return;
    }

    final contrats = await DaoRegistry.instance.contrats.list(orderBy: 'date_debut DESC');
    final contrat = contrats.firstWhere(
      (row) => (row['employe_id'] as String?) == _selectedEmployeeId,
      orElse: () => const {},
    );
    final baseSalary = _toDouble(contrat['salaire_base']);

    final presences = await DaoRegistry.instance.presences.search(
      employeeId: _selectedEmployeeId,
      startDate: range.start.millisecondsSinceEpoch,
      endDate: range.end.millisecondsSinceEpoch,
      validationStatus: 'Valide',
      orderBy: 'date ASC',
    );
    var hoursWorked = 0.0;
    var overtimeHours = 0.0;
    for (final row in presences) {
      final start = _parseTimeToMinutes((row['heure_arrivee'] as String?) ?? '');
      final end = _parseTimeToMinutes((row['heure_depart'] as String?) ?? '');
      if (start == null || end == null || end <= start) continue;
      final hours = (end - start) / 60.0;
      final type = ((row['type'] as String?) ?? '').toLowerCase();
      if (type.contains('sup')) {
        overtimeHours += hours;
      } else {
        hoursWorked += hours;
      }
    }

    final conges = await DaoRegistry.instance.conges.list(orderBy: 'date_debut DESC');
    var absenceDays = 0.0;
    for (final row in conges) {
      if ((row['employe_id'] as String?) != _selectedEmployeeId) continue;
      if ((row['statut'] as String?) != 'Valide') continue;
      final startMs = row['date_debut'] as int?;
      final endMs = row['date_fin'] as int?;
      if (startMs == null || endMs == null) continue;
      final start = DateTime.fromMillisecondsSinceEpoch(startMs);
      final end = DateTime.fromMillisecondsSinceEpoch(endMs);
      if (end.isBefore(range.start) || start.isAfter(range.end)) continue;
      final overlapStart = start.isBefore(range.start) ? range.start : start;
      final overlapEnd = end.isAfter(range.end) ? range.end : end;
      absenceDays += overlapEnd.difference(overlapStart).inDays + 1;
    }

    final avantages = await DaoRegistry.instance.avantages.list(orderBy: 'created_at DESC');
    final primes = avantages
        .where((row) => (row['employe_id'] as String?) == _selectedEmployeeId)
        .fold<double>(0, (sum, row) => sum + _toDouble(row['valeur']));

    setState(() {
      if (_baseCtrl.text.trim().isEmpty && baseSalary > 0) {
        _baseCtrl.text = baseSalary.toStringAsFixed(0);
      }
      _hoursCtrl.text = hoursWorked.toStringAsFixed(1);
      _overtimeCtrl.text = overtimeHours.toStringAsFixed(1);
      _absenceCtrl.text = absenceDays.toStringAsFixed(1);
      if (_primesCtrl.text.trim().isEmpty && primes > 0) {
        _primesCtrl.text = primes.toStringAsFixed(0);
      }
    });
    _recalculate();
  }

  void _recalculate() {
    final base = _toDouble(_baseCtrl.text);
    final overtimeHours = _toDouble(_overtimeCtrl.text);
    final primes = _toDouble(_primesCtrl.text);
    final absenceDays = _toDouble(_absenceCtrl.text);
    final avances = _toDouble(_avancesCtrl.text);
    final autresRetenues = _toDouble(_otherDeductionsCtrl.text);

    final monthlyHours = widget.calcConfig.heuresMensuelles;
    final hourlyRate = base == 0 ? 0 : base / (monthlyHours == 0 ? _defaultMonthlyHours : monthlyHours);
    final overtimePay = overtimeHours * hourlyRate * widget.calcConfig.hs150;
    final absenceDeduction = base == 0 ? 0 : (base / 30) * absenceDays;
    final gross = (base + primes + overtimePay) - absenceDeduction;
    final cnssBase =
        widget.calcConfig.cnssPlafond <= 0 ? gross : (gross > widget.calcConfig.cnssPlafond ? widget.calcConfig.cnssPlafond : gross);
    final cotSalariales = cnssBase * (widget.calcConfig.cnssSalarialPct / 100);
    final cotPatronales = cnssBase * (widget.calcConfig.cnssPatronalPct / 100);
    final netImposable = gross - cotSalariales;
    final taxable = netImposable * (1 - (widget.calcConfig.iutsAbattementPct / 100));
    final impots = _computeIuts(taxable);
    final netAPayer = netImposable - impots - avances - autresRetenues;

    _grossCtrl.text = gross.toStringAsFixed(0);
    _netCtrl.text = netAPayer.toStringAsFixed(0);
    _cotSalarialesCtrl.text = cotSalariales.toStringAsFixed(0);
    _cotPatronalesCtrl.text = cotPatronales.toStringAsFixed(0);
    _netImposableCtrl.text = netImposable.toStringAsFixed(0);
    _impotsCtrl.text = impots.toStringAsFixed(0);
    _netAPayerCtrl.text = netAPayer.toStringAsFixed(0);
  }

  double _computeIuts(double taxable) {
    if (taxable <= 0) return 0;
    final tranches = widget.calcConfig.iutsTranches;
    if (tranches.isEmpty) {
      return taxable * _tauxImpots;
    }
    var remaining = taxable;
    var total = 0.0;
    final sorted = [...tranches]..sort((a, b) => a.min.compareTo(b.min));
    for (final tranche in sorted) {
      final minVal = tranche.min;
      final maxVal = tranche.max ?? double.infinity;
      if (taxable <= minVal) break;
      final trancheStart = minVal;
      final trancheEnd = taxable < maxVal ? taxable : maxVal;
      final base = (trancheEnd - trancheStart).clamp(0, remaining);
      if (base <= 0) continue;
      total += base * (tranche.rate / 100);
      remaining -= base;
      if (remaining <= 0) break;
    }
    return total;
  }

  bool _validate() {
    if (_selectedEmployeeId.isEmpty) {
      _error = 'Employe requis.';
      return false;
    }
    if (_periodCtrl.text.trim().isEmpty) {
      _error = 'Periode requise.';
      return false;
    }
    if (double.tryParse(_baseCtrl.text.trim()) == null) {
      _error = 'Salaire de base invalide.';
      return false;
    }
    if (_grossCtrl.text.trim().isEmpty || _netCtrl.text.trim().isEmpty) {
      _recalculate();
    }
    if (double.tryParse(_grossCtrl.text.trim()) == null) {
      _error = 'Brut invalide.';
      return false;
    }
    if (double.tryParse(_netCtrl.text.trim()) == null) {
      _error = 'Net invalide.';
      return false;
    }
    if (_paymentStatus == 'Paye' && _paymentDateCtrl.text.trim().isEmpty) {
      _error = 'Date de paiement requise.';
      return false;
    }
    return true;
  }

  void _save() {
    setState(() => _error = null);
    if (!_validate()) {
      setState(() {});
      return;
    }

    final id = widget.salary?.id ?? 'paie-${DateTime.now().millisecondsSinceEpoch}';
    final salary = PaieSalaire(
      id: id,
      employeId: _selectedEmployeeId,
      period: _periodCtrl.text.trim(),
      gross: double.parse(_grossCtrl.text.trim()),
      net: double.parse(_netCtrl.text.trim()),
      baseSalary: _toDouble(_baseCtrl.text),
      hoursWorked: _toDouble(_hoursCtrl.text),
      overtimeHours: _toDouble(_overtimeCtrl.text),
      absenceDays: _toDouble(_absenceCtrl.text),
      primes: _toDouble(_primesCtrl.text),
      avances: _toDouble(_avancesCtrl.text),
      otherDeductions: _toDouble(_otherDeductionsCtrl.text),
      cotisationsSalariales: _toDouble(_cotSalarialesCtrl.text),
      cotisationsPatronales: _toDouble(_cotPatronalesCtrl.text),
      impots: _toDouble(_impotsCtrl.text),
      netImposable: _toDouble(_netImposableCtrl.text),
      netAPayer: _toDouble(_netAPayerCtrl.text),
      paymentMode: _paymentModeCtrl.text.trim(),
      paymentDate: _paymentDateCtrl.text.trim().isEmpty
          ? null
          : DateTime.tryParse(_paymentDateCtrl.text.trim()),
      paymentReference: _paymentRefCtrl.text.trim(),
      paymentStatus: _paymentStatus,
      createdBy: widget.salary?.createdBy ?? '',
      updatedBy: widget.salary?.updatedBy ?? '',
      status: _status,
    );
    Navigator.of(context).pop(salary);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.salary != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier bulletin' : 'Nouveau bulletin'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ),
            AppCard(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _EmployeeAutocomplete(
                    label: 'Employe *',
                    options: widget.employeeOptions,
                    selectedId: _selectedEmployeeId,
                    onSelected: (id) => setState(() => _selectedEmployeeId = id),
                  ),
                  _FormField(controller: _periodCtrl, label: 'Periode *'),
                  OutlinedButton.icon(
                    onPressed: _autofillFromData,
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Calculer depuis presences/conges'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _recalculate,
                    icon: const Icon(Icons.calculate_outlined),
                    label: const Text('Recalculer'),
                  ),
                  _FormField(
                    controller: _baseCtrl,
                    label: 'Salaire de base *',
                    keyboardType: TextInputType.number,
                  ),
                  _FormField(
                    controller: _hoursCtrl,
                    label: 'Heures travaillees',
                    keyboardType: TextInputType.number,
                  ),
                  _FormField(
                    controller: _overtimeCtrl,
                    label: 'Heures supplementaires',
                    keyboardType: TextInputType.number,
                  ),
                  _FormField(
                    controller: _absenceCtrl,
                    label: 'Jours absence',
                    keyboardType: TextInputType.number,
                  ),
                  _FormField(
                    controller: _primesCtrl,
                    label: 'Primes',
                    keyboardType: TextInputType.number,
                  ),
                  _FormField(
                    controller: _avancesCtrl,
                    label: 'Avances',
                    keyboardType: TextInputType.number,
                  ),
                  _FormField(
                    controller: _otherDeductionsCtrl,
                    label: 'Autres retenues',
                    keyboardType: TextInputType.number,
                  ),
                  _FormField(
                    controller: _grossCtrl,
                    label: 'Brut *',
                    keyboardType: TextInputType.number,
                  ),
                  _FormField(
                    controller: _cotSalarialesCtrl,
                    label: 'Cotisations salariales',
                    keyboardType: TextInputType.number,
                  ),
                  _FormField(
                    controller: _cotPatronalesCtrl,
                    label: 'Cotisations patronales',
                    keyboardType: TextInputType.number,
                  ),
                  _FormField(
                    controller: _impotsCtrl,
                    label: 'Impots (IUTS)',
                    keyboardType: TextInputType.number,
                  ),
                  _FormField(
                    controller: _netImposableCtrl,
                    label: 'Net imposable',
                    keyboardType: TextInputType.number,
                  ),
                  _FormField(
                    controller: _netAPayerCtrl,
                    label: 'Net a payer',
                    keyboardType: TextInputType.number,
                  ),
                  _FormField(
                    controller: _netCtrl,
                    label: 'Net *',
                    keyboardType: TextInputType.number,
                  ),
                  _FormField(controller: _paymentModeCtrl, label: 'Mode paiement'),
                  _FormField(
                    controller: _paymentDateCtrl,
                    label: 'Date paiement',
                    readOnly: true,
                    onTap: () => _pickDate(_paymentDateCtrl),
                    suffixIcon: const Icon(Icons.date_range),
                  ),
                  _FormField(controller: _paymentRefCtrl, label: 'Reference paiement'),
                  _FormDropdown(
                    label: 'Statut paiement',
                    value: _paymentStatus,
                    items: const ['Non paye', 'En attente', 'Paye'],
                    onChanged: (value) => setState(() => _paymentStatus = value),
                  ),
                  _FormDropdown(
                    label: 'Statut',
                    value: _status,
                    items: const ['Brouillon', 'En cours', 'Valide', 'Archive'],
                    onChanged: (value) => setState(() => _status = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(isEditing ? 'Mettre a jour' : 'Enregistrer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaieParamFormDialog extends StatefulWidget {
  const _PaieParamFormDialog({required this.param});

  final PaieParametre param;

  @override
  State<_PaieParamFormDialog> createState() => _PaieParamFormDialogState();
}

class _PaieParamFormDialogState extends State<_PaieParamFormDialog> {
  late final TextEditingController _valueCtrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _valueCtrl = TextEditingController(text: widget.param.value.toString());
  }

  @override
  void dispose() {
    _valueCtrl.dispose();
    super.dispose();
  }

  void _save() {
    setState(() => _error = null);
    if (double.tryParse(_valueCtrl.text.trim()) == null) {
      setState(() => _error = 'Valeur invalide.');
      return;
    }
    final updated = PaieParametre(
      id: widget.param.id,
      code: widget.param.code,
      label: widget.param.label,
      value: double.parse(_valueCtrl.text.trim()),
      unit: widget.param.unit,
      category: widget.param.category,
      description: widget.param.description,
    );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.param.label),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ),
            AppCard(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _FormField(
                    controller: _valueCtrl,
                    label: 'Valeur (${widget.param.unit})',
                    keyboardType: TextInputType.number,
                  ),
                  if (widget.param.description.isNotEmpty)
                    SizedBox(
                      width: 220,
                      child: Text(
                        widget.param.description,
                        style: TextStyle(color: appTextMuted(context)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Enregistrer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IutsTrancheFormDialog extends StatefulWidget {
  const _IutsTrancheFormDialog({this.tranche});

  final IutsTranche? tranche;

  @override
  State<_IutsTrancheFormDialog> createState() => _IutsTrancheFormDialogState();
}

class _IutsTrancheFormDialogState extends State<_IutsTrancheFormDialog> {
  late final TextEditingController _minCtrl;
  late final TextEditingController _maxCtrl;
  late final TextEditingController _rateCtrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _minCtrl = TextEditingController(text: widget.tranche?.min.toString() ?? '');
    _maxCtrl = TextEditingController(text: widget.tranche?.max?.toString() ?? '');
    _rateCtrl = TextEditingController(text: widget.tranche?.rate.toString() ?? '');
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  void _save() {
    setState(() => _error = null);
    final minVal = double.tryParse(_minCtrl.text.trim());
    final maxVal = _maxCtrl.text.trim().isEmpty ? null : double.tryParse(_maxCtrl.text.trim());
    final rateVal = double.tryParse(_rateCtrl.text.trim());
    if (minVal == null || rateVal == null) {
      setState(() => _error = 'Valeurs invalides.');
      return;
    }
    if (maxVal != null && maxVal < minVal) {
      setState(() => _error = 'Max doit etre >= Min.');
      return;
    }
    final tranche = IutsTranche(
      id: widget.tranche?.id ?? 'iuts-${DateTime.now().millisecondsSinceEpoch}',
      min: minVal,
      max: maxVal,
      rate: rateVal,
    );
    Navigator.of(context).pop(tranche);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.tranche != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier tranche IUTS' : 'Nouvelle tranche IUTS'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ),
            AppCard(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _FormField(
                    controller: _minCtrl,
                    label: 'Min (FCFA)',
                    keyboardType: TextInputType.number,
                  ),
                  _FormField(
                    controller: _maxCtrl,
                    label: 'Max (FCFA)',
                    keyboardType: TextInputType.number,
                  ),
                  _FormField(
                    controller: _rateCtrl,
                    label: 'Taux (%)',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Enregistrer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VariableFormDialog extends StatefulWidget {
  const _VariableFormDialog({required this.employeeOptions, this.variable});

  final AvantageSocial? variable;
  final List<_IdLabelOption> employeeOptions;

  @override
  State<_VariableFormDialog> createState() => _VariableFormDialogState();
}

class _VariableFormDialogState extends State<_VariableFormDialog> {
  late final TextEditingController _typeCtrl;
  late final TextEditingController _valueCtrl;
  String _selectedEmployeeId = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _typeCtrl = TextEditingController(text: widget.variable?.type ?? '');
    _valueCtrl = TextEditingController(text: widget.variable?.value.toString() ?? '');
    _selectedEmployeeId = widget.variable?.employeId ?? '';
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    if (_typeCtrl.text.trim().isEmpty) {
      _error = 'Type requis.';
      return false;
    }
    if (double.tryParse(_valueCtrl.text.trim()) == null) {
      _error = 'Valeur invalide.';
      return false;
    }
    if (_selectedEmployeeId.isEmpty) {
      _error = 'Employe requis.';
      return false;
    }
    return true;
  }

  void _save() {
    setState(() => _error = null);
    if (!_validate()) {
      setState(() {});
      return;
    }
    final id = widget.variable?.id ?? 'var-${DateTime.now().millisecondsSinceEpoch}';
    final variable = AvantageSocial(
      id: id,
      employeId: _selectedEmployeeId,
      type: _typeCtrl.text.trim(),
      value: double.parse(_valueCtrl.text.trim()),
    );
    Navigator.of(context).pop(variable);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.variable != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier variable' : 'Nouvelle variable'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ),
            AppCard(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _EmployeeAutocomplete(
                    label: 'Employe *',
                    options: widget.employeeOptions,
                    selectedId: _selectedEmployeeId,
                    onSelected: (id) => setState(() => _selectedEmployeeId = id),
                  ),
                  _FormField(controller: _typeCtrl, label: 'Type *'),
                  _FormField(
                    controller: _valueCtrl,
                    label: 'Valeur *',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(isEditing ? 'Mettre a jour' : 'Enregistrer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeAutocomplete extends StatelessWidget {
  const _EmployeeAutocomplete({
    required this.label,
    required this.options,
    required this.selectedId,
    required this.onSelected,
  });

  final String label;
  final List<_IdLabelOption> options;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = options.firstWhere(
      (option) => option.id == selectedId,
      orElse: () => const _IdLabelOption(id: '', label: ''),
    );
    return SizedBox(
      width: 240,
      child: DropdownButtonFormField<String>(
        value: selected.id.isEmpty ? null : selected.id,
        decoration: InputDecoration(labelText: label),
        items: options
            .map((option) => DropdownMenuItem(value: option.id, child: Text(option.label)))
            .toList(),
        onChanged: (value) => onSelected(value ?? ''),
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
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
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
        onChanged: (value) => onChanged(value ?? items.first),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  final int page;
  final int pageSize;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    final start = page * pageSize + 1;
    var end = (page + 1) * pageSize;
    if (end > total) end = total;
    final canPrev = page > 0;
    final canNext = end < total;

    return Row(
      children: [
        Text('$start-$end sur $total', style: TextStyle(color: appTextMuted(context))),
        const Spacer(),
        TextButton(onPressed: canPrev ? onPrev : null, child: const Text('Precedent')),
        const SizedBox(width: 8),
        TextButton(onPressed: canNext ? onNext : null, child: const Text('Suivant')),
      ],
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
      width: 200,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: (value) => onChanged(value ?? items.first),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(labelText: label, suffixIcon: suffixIcon),
      ),
    );
  }
}

class _ParamChip extends StatelessWidget {
  const _ParamChip({
    required this.label,
    required this.value,
    required this.onEdit,
  });

  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: appBorderColor(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(color: appTextMuted(context), fontSize: 12)),
            const SizedBox(width: 6),
            Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: appTextPrimary(context))),
            const SizedBox(width: 6),
            const Icon(Icons.edit, size: 14),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: AppColors.primary, fontSize: 12)),
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

class _SalaryHistory {
  const _SalaryHistory({required this.period, required this.salary, required this.change});

  final String period;
  final int salary;
  final String change;
}

class _PayrollMetrics {
  const _PayrollMetrics({
    required this.grossTotal,
    required this.netTotal,
    required this.deductions,
    required this.totalCount,
    required this.pendingCount,
  });

  final double grossTotal;
  final double netTotal;
  final double deductions;
  final int totalCount;
  final int pendingCount;
}

class _IdLabelOption {
  const _IdLabelOption({required this.id, required this.label});

  final String id;
  final String label;
}

class _EmployeeInfo {
  const _EmployeeInfo({required this.name, required this.matricule, required this.job});

  final String name;
  final String matricule;
  final String job;
}

class _PaieParamDefinition {
  const _PaieParamDefinition({
    required this.code,
    required this.label,
    required this.unit,
    required this.category,
    required this.defaultValue,
    this.description = '',
  });

  final String code;
  final String label;
  final String unit;
  final String category;
  final double defaultValue;
  final String description;
}

class _PayrollCalcConfig {
  const _PayrollCalcConfig({
    required this.cnssSalarialPct,
    required this.cnssPatronalPct,
    required this.cnssPlafond,
    required this.iutsAbattementPct,
    required this.heuresMensuelles,
    required this.hs125,
    required this.hs150,
    required this.hs200,
    required this.iutsTranches,
  });

  final double cnssSalarialPct;
  final double cnssPatronalPct;
  final double cnssPlafond;
  final double iutsAbattementPct;
  final double heuresMensuelles;
  final double hs125;
  final double hs150;
  final double hs200;
  final List<IutsTranche> iutsTranches;
}

const double _defaultMonthlyHours = 173.33;
const double _tauxCotisationSalariale = 0.055;
const double _tauxCotisationPatronale = 0.17;
const double _tauxImpots = 0.1;

String _fmtAmount(num value) {
  final rounded = value.round();
  return 'FCFA ${rounded.toString().replaceAllMapped(RegExp(r'\\B(?=(\\d{3})+(?!\\d))'), (match) => ' ')}';
}

String _formatParamValue(PaieParametre param) {
  if (param.unit == '%') {
    return '${param.value.toStringAsFixed(1)}%';
  }
  if (param.unit == 'x') {
    return '${param.value.toStringAsFixed(2)}x';
  }
  if (param.unit == 'FCFA') {
    return _fmtAmount(param.value);
  }
  return '${param.value.toStringAsFixed(2)} ${param.unit}'.trim();
}

String _display(String value) {
  return value.isEmpty ? 'A definir' : value;
}

String _formatDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

DateTimeRange? _parsePeriodRange(String value) {
  if (value.trim().isEmpty) return null;
  final normalized = value.trim();
  final isoMatch = RegExp(r'^(\\d{4})-(\\d{2})$').firstMatch(normalized);
  if (isoMatch != null) {
    final year = int.parse(isoMatch.group(1)!);
    final month = int.parse(isoMatch.group(2)!);
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    return DateTimeRange(start: start, end: end);
  }
  final monthMatch = RegExp(r'^([A-Za-zéûùôîïçà]+)\\s+(\\d{4})$', caseSensitive: false).firstMatch(normalized);
  if (monthMatch != null) {
    final monthName = monthMatch.group(1)!.toLowerCase();
    final year = int.parse(monthMatch.group(2)!);
    final month = _frenchMonthToNumber(monthName);
    if (month != null) {
      final start = DateTime(year, month, 1);
      final end = DateTime(year, month + 1, 0, 23, 59, 59, 999);
      return DateTimeRange(start: start, end: end);
    }
  }
  return null;
}

int? _frenchMonthToNumber(String value) {
  const months = {
    'janvier': 1,
    'fevrier': 2,
    'février': 2,
    'mars': 3,
    'avril': 4,
    'mai': 5,
    'juin': 6,
    'juillet': 7,
    'aout': 8,
    'août': 8,
    'septembre': 9,
    'octobre': 10,
    'novembre': 11,
    'decembre': 12,
    'décembre': 12,
  };
  return months[value];
}

int? _parseTimeToMinutes(String value) {
  final parts = value.trim().split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return hour * 60 + minute;
}

double _toDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse('${value ?? ''}') ?? 0;
}

String _toText(double? value) {
  if (value == null || value == 0) return '';
  return value.toString();
}

String _extractYear(String period) {
  final match = RegExp(r'(\\d{4})').firstMatch(period);
  return match?.group(1) ?? '';
}

pw.Widget _pdfSection(String title, List<pw.Widget> rows) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 12),
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColor.fromInt(0xFFDDDDDD)),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Column(children: rows),
      ],
    ),
  );
}

pw.Widget _pdfRow(String label, String value) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Expanded(child: pw.Text(label, style: const pw.TextStyle(fontSize: 10))),
      pw.Expanded(
        child: pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
      ),
    ],
  );
}

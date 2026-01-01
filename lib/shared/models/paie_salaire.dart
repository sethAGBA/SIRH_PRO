class PaieSalaire {
  const PaieSalaire({
    required this.id,
    required this.employeId,
    required this.period,
    required this.gross,
    required this.net,
    required this.baseSalary,
    required this.hoursWorked,
    required this.overtimeHours,
    required this.absenceDays,
    required this.primes,
    required this.avances,
    required this.otherDeductions,
    required this.cotisationsSalariales,
    required this.cotisationsPatronales,
    required this.impots,
    required this.netImposable,
    required this.netAPayer,
    required this.paymentMode,
    required this.paymentDate,
    required this.paymentReference,
    required this.paymentStatus,
    required this.createdBy,
    required this.updatedBy,
    required this.status,
  });

  final String id;
  final String employeId;
  final String period;
  final double gross;
  final double net;
  final double baseSalary;
  final double hoursWorked;
  final double overtimeHours;
  final double absenceDays;
  final double primes;
  final double avances;
  final double otherDeductions;
  final double cotisationsSalariales;
  final double cotisationsPatronales;
  final double impots;
  final double netImposable;
  final double netAPayer;
  final String paymentMode;
  final DateTime? paymentDate;
  final String paymentReference;
  final String paymentStatus;
  final String createdBy;
  final String updatedBy;
  final String status;

  PaieSalaire copyWith({
    String? id,
    String? employeId,
    String? period,
    double? gross,
    double? net,
    double? baseSalary,
    double? hoursWorked,
    double? overtimeHours,
    double? absenceDays,
    double? primes,
    double? avances,
    double? otherDeductions,
    double? cotisationsSalariales,
    double? cotisationsPatronales,
    double? impots,
    double? netImposable,
    double? netAPayer,
    String? paymentMode,
    DateTime? paymentDate,
    String? paymentReference,
    String? paymentStatus,
    String? createdBy,
    String? updatedBy,
    String? status,
  }) {
    return PaieSalaire(
      id: id ?? this.id,
      employeId: employeId ?? this.employeId,
      period: period ?? this.period,
      gross: gross ?? this.gross,
      net: net ?? this.net,
      baseSalary: baseSalary ?? this.baseSalary,
      hoursWorked: hoursWorked ?? this.hoursWorked,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      absenceDays: absenceDays ?? this.absenceDays,
      primes: primes ?? this.primes,
      avances: avances ?? this.avances,
      otherDeductions: otherDeductions ?? this.otherDeductions,
      cotisationsSalariales: cotisationsSalariales ?? this.cotisationsSalariales,
      cotisationsPatronales: cotisationsPatronales ?? this.cotisationsPatronales,
      impots: impots ?? this.impots,
      netImposable: netImposable ?? this.netImposable,
      netAPayer: netAPayer ?? this.netAPayer,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentReference: paymentReference ?? this.paymentReference,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      status: status ?? this.status,
    );
  }
}

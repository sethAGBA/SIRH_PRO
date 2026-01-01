class CongeAbsence {
  const CongeAbsence({
    required this.id,
    required this.employeId,
    required this.employeName,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.motif,
    required this.justificatif,
    required this.nbJours,
    required this.dateReprise,
    required this.interim,
    required this.contact,
    required this.commentaire,
    required this.decisionMotif,
  });

  final String id;
  final String employeId;
  final String employeName;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String motif;
  final String justificatif;
  final double nbJours;
  final DateTime? dateReprise;
  final String interim;
  final String contact;
  final String commentaire;
  final String decisionMotif;
}

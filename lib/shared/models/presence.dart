class Presence {
  const Presence({
    required this.id,
    required this.employeId,
    required this.employeName,
    required this.date,
    required this.heureArrivee,
    required this.heureDepart,
    required this.status,
    required this.type,
    required this.source,
    required this.lieu,
    required this.justification,
    required this.validationStatus,
    required this.validator,
    required this.commentaire,
  });

  final String id;
  final String employeId;
  final String employeName;
  final DateTime date;
  final String heureArrivee;
  final String heureDepart;
  final String status;
  final String type;
  final String source;
  final String lieu;
  final String justification;
  final String validationStatus;
  final String validator;
  final String commentaire;
}

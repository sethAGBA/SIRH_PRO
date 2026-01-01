class EntretienIndividuel {
  const EntretienIndividuel({
    required this.id,
    required this.employeId,
    required this.employeNom,
    required this.poste,
    required this.manager,
    required this.date,
    required this.status,
    required this.type,
    required this.lieu,
    required this.objectifs,
    required this.notes,
    required this.actions,
  });

  final String id;
  final String employeId;
  final String employeNom;
  final String poste;
  final String manager;
  final DateTime date;
  final String status;
  final String type;
  final String lieu;
  final String objectifs;
  final String notes;
  final String actions;
}

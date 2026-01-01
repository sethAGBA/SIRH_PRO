class Poste {
  const Poste({
    required this.id,
    required this.title,
    required this.departmentId,
    required this.departmentName,
    required this.level,
    required this.description,
    required this.code,
    this.status = 'Actif',
    this.deletedAt,
  });

  final String id;
  final String title;
  final String departmentId;
  final String departmentName;
  final String level;
  final String description;
  final String code;
  final String status;
  final int? deletedAt;
}

class FormationSession {
  const FormationSession({
    required this.id,
    required this.title,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.status,
    required this.location,
    required this.participants,
    required this.description,
    required this.trainer,
    required this.mode,
    required this.objectifs,
  });

  final String id;
  final String title;
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final String status;
  final String location;
  final int participants;
  final String description;
  final String trainer;
  final String mode;
  final String objectifs;
}

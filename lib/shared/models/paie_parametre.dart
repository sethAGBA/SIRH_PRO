class PaieParametre {
  const PaieParametre({
    required this.id,
    required this.code,
    required this.label,
    required this.value,
    required this.unit,
    required this.category,
    required this.description,
  });

  final String id;
  final String code;
  final String label;
  final double value;
  final String unit;
  final String category;
  final String description;
}

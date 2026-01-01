class IutsTranche {
  const IutsTranche({
    required this.id,
    required this.min,
    required this.max,
    required this.rate,
  });

  final String id;
  final double min;
  final double? max;
  final double rate;
}

class OvertimeBreakdown {
  const OvertimeBreakdown({
    required this.normalHours,
    required this.overtime25,
    required this.overtime50,
    required this.rttAccrued,
  });

  final double normalHours;
  final double overtime25;
  final double overtime50;
  final double rttAccrued;
}

OvertimeBreakdown computeOvertimeBreakdown({
  required double totalHours,
  required double contractHours,
  double overtime25Cap = 8.0,
  double rttRate = 0.0,
}) {
  final double normal = totalHours <= contractHours ? totalHours : contractHours;
  final double overtime = totalHours > contractHours ? totalHours - contractHours : 0.0;
  final double overtime25 = overtime > overtime25Cap ? overtime25Cap : overtime;
  final double overtime50 = overtime > overtime25Cap ? overtime - overtime25Cap : 0.0;
  final double rttAccrued = overtime * rttRate;

  return OvertimeBreakdown(
    normalHours: normal,
    overtime25: overtime25,
    overtime50: overtime50,
    rttAccrued: rttAccrued,
  );
}

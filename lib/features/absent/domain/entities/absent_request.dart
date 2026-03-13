/// Represents an absent request entry in the domain layer.
class AbsentRequest {
  final String id;
  final String absentNo;
  final AbsentType type;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final DateTime entryTime;
  final List<String> filePaths;
  final String status;
  final String? rejectionReason;

  const AbsentRequest({
    required this.id,
    required this.absentNo,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.entryTime,
    required this.filePaths,
    this.status = 'Waiting for approval',
    this.rejectionReason,
  });

  double get absentDays {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    if (end.isBefore(start)) return 0;

    final days = end.difference(start).inDays + 1;
    return days.toDouble();
  }
}

enum AbsentType {
  sick('Sakit'),
  permit('Izin');

  final String label;
  const AbsentType(this.label);
}

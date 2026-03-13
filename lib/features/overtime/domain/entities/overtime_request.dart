/// Represents an overtime request entry in the domain layer.
class OvertimeRequest {
  final String id;
  final String overtimeNo;
  final OvertimeType type;
  final DateTime overtimeDate;
  final String scheduleShift;
  final String scheduleHours;
  final DateTime startAt;
  final DateTime endAt;
  final double durationHours;
  final List<String> evidenceFiles;
  final DateTime entryTime;
  final String status;
  final String? rejectionReason;

  const OvertimeRequest({
    required this.id,
    required this.overtimeNo,
    required this.type,
    required this.overtimeDate,
    required this.scheduleShift,
    required this.scheduleHours,
    required this.startAt,
    required this.endAt,
    required this.durationHours,
    required this.evidenceFiles,
    required this.entryTime,
    this.status = 'Waiting for approval',
    this.rejectionReason,
  });
}

enum OvertimeType {
  workday('Lembur Hari Kerja'),
  weekend('Lembur Akhir Pekan'),
  holiday('Lembur Hari Libur');

  final String label;
  const OvertimeType(this.label);
}

/// Dummy descriptions for each overtime type.
const Map<OvertimeType, String> overtimeTypeHints = {
  OvertimeType.workday: 'Digunakan saat lembur di hari kerja aktif.',
  OvertimeType.weekend: 'Digunakan saat lembur di hari Sabtu/Minggu.',
  OvertimeType.holiday: 'Digunakan saat lembur di hari libur nasional.',
};

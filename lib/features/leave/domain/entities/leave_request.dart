/// Represents a leave request entry in the domain layer.
class LeaveRequest {
  final String id;
  final String leaveNo;
  final LeaveType type;
  final LeaveDayMode dayMode;
  final DateTime startDate;
  final DateTime endDate;
  final double leaveDays;
  final String substituteId;
  final String substituteName;
  final String substitutePosition;
  final String notes;
  final DateTime entryTime;
  final String status;
  final String? rejectionReason;

  const LeaveRequest({
    required this.id,
    required this.leaveNo,
    required this.type,
    required this.dayMode,
    required this.startDate,
    required this.endDate,
    required this.leaveDays,
    required this.substituteId,
    required this.substituteName,
    required this.substitutePosition,
    required this.notes,
    required this.entryTime,
    this.status = 'Waiting for approval',
    this.rejectionReason,
  });
}

enum LeaveType {
  annual('Annual'),
  sick('Sick'),
  unpaid('Unpaid');

  final String label;
  const LeaveType(this.label);
}

enum LeaveDayMode {
  fullDay('Full Day'),
  halfDay('Half Day');

  final String label;
  const LeaveDayMode(this.label);
}

/// Dummy leave balances used for UI preview until API integration.
const Map<LeaveType, String> leaveTypeBalances = {
  LeaveType.annual: '12 Days',
  LeaveType.sick: '6 Days',
  LeaveType.unpaid: 'Unlimited',
};

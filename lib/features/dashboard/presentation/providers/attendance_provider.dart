import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks daily check-in / check-out status.
class AttendanceState {
  final bool isCheckedIn;
  final bool isCheckedOut;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String? workLocation;
  final String shift;

  const AttendanceState({
    this.isCheckedIn = false,
    this.isCheckedOut = false,
    this.checkInTime,
    this.checkOutTime,
    this.workLocation,
    this.shift = '09:00 - 18:00',
  });

  AttendanceState copyWith({
    bool? isCheckedIn,
    bool? isCheckedOut,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? workLocation,
    String? shift,
  }) {
    return AttendanceState(
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      isCheckedOut: isCheckedOut ?? this.isCheckedOut,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      workLocation: workLocation ?? this.workLocation,
      shift: shift ?? this.shift,
    );
  }
}

class AttendanceNotifier extends Notifier<AttendanceState> {
  @override
  AttendanceState build() => const AttendanceState();

  void checkIn({required String workLocation}) {
    state = state.copyWith(
      isCheckedIn: true,
      checkInTime: DateTime.now(),
      workLocation: workLocation,
    );
  }

  void checkOut() {
    state = state.copyWith(
      isCheckedOut: true,
      checkOutTime: DateTime.now(),
    );
  }
}

final attendanceProvider =
    NotifierProvider<AttendanceNotifier, AttendanceState>(
  AttendanceNotifier.new,
);

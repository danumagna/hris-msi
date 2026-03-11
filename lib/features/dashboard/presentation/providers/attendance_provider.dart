import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks daily check-in / check-out status.
class AttendanceState {
  final bool isCheckedIn;
  final bool isCheckedOut;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  const AttendanceState({
    this.isCheckedIn = false,
    this.isCheckedOut = false,
    this.checkInTime,
    this.checkOutTime,
  });

  AttendanceState copyWith({
    bool? isCheckedIn,
    bool? isCheckedOut,
    DateTime? checkInTime,
    DateTime? checkOutTime,
  }) {
    return AttendanceState(
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      isCheckedOut: isCheckedOut ?? this.isCheckedOut,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
    );
  }
}

class AttendanceNotifier extends Notifier<AttendanceState> {
  @override
  AttendanceState build() => const AttendanceState();

  void checkIn() {
    state = state.copyWith(
      isCheckedIn: true,
      checkInTime: DateTime.now(),
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

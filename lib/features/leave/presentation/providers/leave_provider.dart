import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/leave_request.dart';

/// Manages the list of submitted leave requests.
class LeaveNotifier extends Notifier<List<LeaveRequest>> {
  @override
  List<LeaveRequest> build() => [];

  void add(LeaveRequest item) {
    state = [...state, item];
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
  }
}

final leaveProvider = NotifierProvider<LeaveNotifier, List<LeaveRequest>>(
  LeaveNotifier.new,
);

/// Filter state for the leave list page.
class LeaveFilter {
  final DateTime periodStart;
  final DateTime periodEnd;
  final LeaveType? type;
  final String searchQuery;

  const LeaveFilter({
    required this.periodStart,
    required this.periodEnd,
    this.type,
    this.searchQuery = '',
  });

  LeaveFilter copyWith({
    DateTime? periodStart,
    DateTime? periodEnd,
    LeaveType? type,
    bool clearType = false,
    String? searchQuery,
  }) {
    return LeaveFilter(
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      type: clearType ? null : (type ?? this.type),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class LeaveFilterNotifier extends Notifier<LeaveFilter> {
  @override
  LeaveFilter build() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    return LeaveFilter(periodStart: monthStart, periodEnd: monthEnd);
  }

  void setPeriod(DateTime start, DateTime end) {
    final selectedMonthStart = DateTime(start.year, start.month, 1);

    // Enforce month-based filter even if user picks a cross-month range.
    final selectedMonthEnd =
        (start.year == end.year && start.month == end.month)
        ? DateTime(end.year, end.month + 1, 0)
        : DateTime(start.year, start.month + 1, 0);

    state = state.copyWith(
      periodStart: selectedMonthStart,
      periodEnd: selectedMonthEnd,
    );
  }

  void setType(LeaveType? type) {
    if (type == null) {
      state = state.copyWith(clearType: true);
    } else {
      state = state.copyWith(type: type);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final leaveFilterProvider = NotifierProvider<LeaveFilterNotifier, LeaveFilter>(
  LeaveFilterNotifier.new,
);

/// Provides the filtered leave request list.
final filteredLeaveRequestsProvider = Provider<List<LeaveRequest>>((ref) {
  final all = ref.watch(leaveProvider);
  final filter = ref.watch(leaveFilterProvider);

  final filtered = all.where((item) {
    final afterStart = !item.startDate.isBefore(
      DateTime(
        filter.periodStart.year,
        filter.periodStart.month,
        filter.periodStart.day,
      ),
    );
    final beforeEnd = !item.endDate.isAfter(
      DateTime(
        filter.periodEnd.year,
        filter.periodEnd.month,
        filter.periodEnd.day,
        23,
        59,
        59,
      ),
    );
    if (!afterStart || !beforeEnd) return false;

    if (filter.type != null && item.type != filter.type) return false;

    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      if (!item.leaveNo.toLowerCase().contains(q) &&
          !item.notes.toLowerCase().contains(q) &&
          !item.substituteName.toLowerCase().contains(q)) {
        return false;
      }
    }

    return true;
  }).toList();

  filtered.sort((a, b) => b.entryTime.compareTo(a.entryTime));
  return filtered;
});

/// Provides total leave days for current filtered list.
final totalLeaveDaysProvider = Provider<double>((ref) {
  final items = ref.watch(filteredLeaveRequestsProvider);
  return items.fold<double>(0, (sum, item) => sum + item.leaveDays);
});

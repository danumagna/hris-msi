import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/overtime_request.dart';

/// Manages the list of submitted overtime requests.
class OvertimeNotifier extends Notifier<List<OvertimeRequest>> {
  @override
  List<OvertimeRequest> build() => [];

  void add(OvertimeRequest item) {
    state = [...state, item];
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
  }
}

final overtimeProvider =
    NotifierProvider<OvertimeNotifier, List<OvertimeRequest>>(
      OvertimeNotifier.new,
    );

/// Filter state for the overtime list page.
class OvertimeFilter {
  final DateTime periodStart;
  final DateTime periodEnd;
  final OvertimeType? type;
  final String searchQuery;

  const OvertimeFilter({
    required this.periodStart,
    required this.periodEnd,
    this.type,
    this.searchQuery = '',
  });

  OvertimeFilter copyWith({
    DateTime? periodStart,
    DateTime? periodEnd,
    OvertimeType? type,
    bool clearType = false,
    String? searchQuery,
  }) {
    return OvertimeFilter(
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      type: clearType ? null : (type ?? this.type),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class OvertimeFilterNotifier extends Notifier<OvertimeFilter> {
  @override
  OvertimeFilter build() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    return OvertimeFilter(periodStart: monthStart, periodEnd: monthEnd);
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

  void setType(OvertimeType? type) {
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

final overtimeFilterProvider =
    NotifierProvider<OvertimeFilterNotifier, OvertimeFilter>(
      OvertimeFilterNotifier.new,
    );

/// Provides the filtered overtime request list.
final filteredOvertimesProvider = Provider<List<OvertimeRequest>>((ref) {
  final all = ref.watch(overtimeProvider);
  final filter = ref.watch(overtimeFilterProvider);

  return all.where((item) {
    final afterStart = !item.overtimeDate.isBefore(
      DateTime(
        filter.periodStart.year,
        filter.periodStart.month,
        filter.periodStart.day,
      ),
    );
    final beforeEnd = !item.overtimeDate.isAfter(
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
      if (!item.overtimeNo.toLowerCase().contains(q) &&
          !item.type.label.toLowerCase().contains(q) &&
          !item.scheduleShift.toLowerCase().contains(q)) {
        return false;
      }
    }

    return true;
  }).toList();
});

/// Provides total overtime hours for current filtered list.
final totalOvertimeHoursProvider = Provider<double>((ref) {
  final items = ref.watch(filteredOvertimesProvider);
  return items.fold<double>(0, (sum, item) => sum + item.durationHours);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/absent_request.dart';

/// Manages the list of submitted absent requests.
class AbsentNotifier extends Notifier<List<AbsentRequest>> {
  @override
  List<AbsentRequest> build() => [];

  void add(AbsentRequest item) {
    state = [...state, item];
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
  }
}

final absentProvider = NotifierProvider<AbsentNotifier, List<AbsentRequest>>(
  AbsentNotifier.new,
);

/// Filter state for the absent list page.
class AbsentFilter {
  final DateTime periodStart;
  final DateTime periodEnd;
  final AbsentType? type;
  final String searchQuery;

  const AbsentFilter({
    required this.periodStart,
    required this.periodEnd,
    this.type,
    this.searchQuery = '',
  });

  AbsentFilter copyWith({
    DateTime? periodStart,
    DateTime? periodEnd,
    AbsentType? type,
    bool clearType = false,
    String? searchQuery,
  }) {
    return AbsentFilter(
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      type: clearType ? null : (type ?? this.type),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AbsentFilterNotifier extends Notifier<AbsentFilter> {
  @override
  AbsentFilter build() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    return AbsentFilter(periodStart: monthStart, periodEnd: monthEnd);
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

  void setType(AbsentType? type) {
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

final absentFilterProvider =
    NotifierProvider<AbsentFilterNotifier, AbsentFilter>(
      AbsentFilterNotifier.new,
    );

/// Provides the filtered absent request list.
final filteredAbsentsProvider = Provider<List<AbsentRequest>>((ref) {
  final all = ref.watch(absentProvider);
  final filter = ref.watch(absentFilterProvider);

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
      if (!item.absentNo.toLowerCase().contains(q) &&
          !item.description.toLowerCase().contains(q) &&
          !item.type.label.toLowerCase().contains(q)) {
        return false;
      }
    }

    return true;
  }).toList();

  filtered.sort((a, b) => b.entryTime.compareTo(a.entryTime));
  return filtered;
});

/// Provides total absent days for current filtered list.
final totalAbsentDaysProvider = Provider<double>((ref) {
  final items = ref.watch(filteredAbsentsProvider);
  return items.fold<double>(0, (sum, item) => sum + item.absentDays);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reimbursement.dart';

/// Manages the list of submitted reimbursements.
class ReimbursementNotifier extends Notifier<List<Reimbursement>> {
  @override
  List<Reimbursement> build() => [];

  void add(Reimbursement item) {
    state = [...state, item];
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
  }
}

final reimbursementProvider =
    NotifierProvider<ReimbursementNotifier, List<Reimbursement>>(
      ReimbursementNotifier.new,
    );

/// Filter state for the reimbursement list page.
class ReimbursementFilter {
  final DateTime periodStart;
  final DateTime periodEnd;
  final ReimburseType? type;
  final String searchQuery;

  const ReimbursementFilter({
    required this.periodStart,
    required this.periodEnd,
    this.type,
    this.searchQuery = '',
  });

  ReimbursementFilter copyWith({
    DateTime? periodStart,
    DateTime? periodEnd,
    ReimburseType? type,
    bool clearType = false,
    String? searchQuery,
  }) {
    return ReimbursementFilter(
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      type: clearType ? null : (type ?? this.type),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ReimbursementFilterNotifier extends Notifier<ReimbursementFilter> {
  @override
  ReimbursementFilter build() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return ReimbursementFilter(
      periodStart: today,
      periodEnd: today.add(const Duration(days: 7)),
    );
  }

  void setPeriod(DateTime start, DateTime end) {
    state = state.copyWith(periodStart: start, periodEnd: end);
  }

  void setType(ReimburseType? type) {
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

final reimbursementFilterProvider =
    NotifierProvider<ReimbursementFilterNotifier, ReimbursementFilter>(
      ReimbursementFilterNotifier.new,
    );

/// Provides the filtered reimbursement list.
final filteredReimbursementsProvider = Provider<List<Reimbursement>>((ref) {
  final all = ref.watch(reimbursementProvider);
  final filter = ref.watch(reimbursementFilterProvider);

  return all.where((r) {
    // Period filter
    final afterStart = !r.transactionStartDate.isBefore(
      DateTime(
        filter.periodStart.year,
        filter.periodStart.month,
        filter.periodStart.day,
      ),
    );
    final beforeEnd = !r.transactionEndDate.isAfter(
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

    // Type filter
    if (filter.type != null && r.type != filter.type) return false;

    // Search filter
    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      if (!r.title.toLowerCase().contains(q) &&
          !r.description.toLowerCase().contains(q)) {
        return false;
      }
    }

    return true;
  }).toList();
});

/// Provides the total cost of the filtered reimbursements.
final totalCostProvider = Provider<double>((ref) {
  final items = ref.watch(filteredReimbursementsProvider);
  return items.fold<double>(0, (sum, r) => sum + r.amount);
});

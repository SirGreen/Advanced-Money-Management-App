import 'package:uuid/uuid.dart';
import '../../data/services/notification_service.dart';
import '../repositories/scheduled_expenditure_repository.dart';
import '../repositories/expenditure_repository.dart';
import '../entities/scheduled_expenditure.dart';
import '../entities/expenditure.dart';
import 'package:flutter/foundation.dart';

class RecurringTransactionService {
  final ScheduledExpenditureRepository _scheduledRepo;
  final ExpenditureRepository _expenditureRepo;
  final NotificationService _notificationService; // Add this
  final Uuid _uuid = const Uuid();

  RecurringTransactionService(
    this._scheduledRepo,
    this._expenditureRepo,
    this._notificationService,
  );

  Future<void> scheduleReminderFor(ScheduledExpenditure rule) async {
    if (rule.reminderDaysBefore == null || !rule.isActive) return;

    // Calculate next due date
    final now = DateTime.now();
    DateTime checkDate = rule.lastCreatedDate != null
        ? rule.lastCreatedDate!.add(const Duration(days: 1))
        : rule.startDate;

    final nextDueDate = _calculateNextDueDate(checkDate, rule);

    if (nextDueDate != null) {
      final reminderDate = nextDueDate.subtract(
        Duration(days: rule.reminderDaysBefore!),
      );

      // Schedule only if in future
      if (reminderDate.isAfter(now)) {
        await _notificationService.scheduleReminder(
          id: rule.participantId, // We need an int ID. hashCode?
          title: "Recurring Transaction Reminder",
          body: "${rule.name} is due on ${_formatDate(nextDueDate)}",
          scheduledDate: reminderDate,
        );
        debugPrint("Scheduled reminder for ${rule.name} at $reminderDate");
      }
    }
  }

  Future<void> cancelReminderFor(ScheduledExpenditure rule) async {
    await _notificationService.cancelReminder(rule.participantId);
    debugPrint("Cancelled reminder for ${rule.name}");
  }

  String _formatDate(DateTime d) => "${d.day}/${d.month}";

  // Helper to generate consistent int ID from string ID
  // ...

  /// Checks and creates any due transactions. Returns count of created items.
  Future<int> checkAndCreateTransactions() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      int createdCount = 0;

      final allRules = await _scheduledRepo.getAll();

      for (final rule in allRules) {
        if (!rule.isActive) continue;

        // Disable if past end date
        if (rule.endDate != null && rule.endDate!.isBefore(today)) {
          rule.isActive = false;
          await _scheduledRepo.update(rule);
          continue;
        }

        // Determine where to start checking
        // If we made one before, start checking from the day AFTER that.
        // If never made, start from startDate.
        DateTime checkDate = rule.lastCreatedDate != null
            ? rule.lastCreatedDate!.add(const Duration(days: 1))
            : rule.startDate;

        // Prevent infinite loop if checkDate is far in past (limit catch-up to 365 days mostly)
        int loopGuard = 0;

        // "Catch-up" loop
        while (loopGuard < 500) {
          // Safety break
          loopGuard++;
          DateTime? nextDueDate = _calculateNextDueDate(checkDate, rule);

          // Stop if no due date or future due date
          if (nextDueDate == null) break;

          if (nextDueDate.isAfter(now) && !_isSameDate(nextDueDate, now)) {
            break;
          }

          // Stop if passed end date
          if (rule.endDate != null && nextDueDate.isAfter(rule.endDate!)) {
            break;
          }

          // If due date is before checked start date (shouldn't happen with correct logic but safety)
          if (nextDueDate.isBefore(checkDate)) {
            // Force advance
            checkDate = nextDueDate.add(const Duration(days: 1));
            continue;
          }

          // Create the transaction!
          final newExpenditure = Expenditure(
            id: _uuid.v4(),
            articleName: rule.name,
            amount: rule.amount,
            date: nextDueDate,
            mainTagId: rule.mainTagId,
            subTagIds: rule.subTagIds,
            isIncome: rule.isIncome,
            scheduledExpenditureId: rule.id,
            currencyCode: rule.currencyCode,
          );

          await _expenditureRepo.addExpenditure(newExpenditure);
          createdCount++;

          // Update rule's last created date
          rule.lastCreatedDate = nextDueDate;
          await _scheduledRepo.update(rule);

          // Advance checkDate
          checkDate = nextDueDate.add(const Duration(days: 1));
        }
      }
      return createdCount;
    } catch (e, stack) {
      debugPrint("Error in RecurringTransactionService: $e");
      debugPrint(stack.toString());
      return 0; // Return 0 so UI doesn't freeze
    }
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Calculate next due date ON or AFTER 'from'
  DateTime? _calculateNextDueDate(DateTime from, ScheduledExpenditure rule) {
    if (rule.lastCreatedDate == null &&
        (from.isBefore(DateTime.now()) || _isSameDate(from, DateTime.now()))) {
      // First run check
      if (_isSameDate(from, rule.startDate)) {
        return from;
      }
    }

    switch (rule.scheduleType) {
      case ScheduleType.fixedInterval:
        // Simple: Start Date + N * Interval
        // Find K such that Start + K*Interval >= from
        final interval = rule.scheduleValue;
        if (interval <= 0) return null; // Invalid

        if (from.isBefore(rule.startDate)) return rule.startDate;

        final diff = from.difference(rule.startDate).inDays;

        // We want the smallest integer K >= 0 such that: startDate + K*interval >= from
        // diff = from - startDate
        // We want K*interval >= diff  =>  K >= diff / interval
        // Since we are iterating checkDate which is lastCreated + 1, we basically want the next one.

        // Easier logic: if from aligns, return from. Else next align.
        if (diff < 0) return rule.startDate;

        final remainder = diff % interval;
        if (remainder == 0) return from;

        return from.add(Duration(days: interval - remainder));

      case ScheduleType.dayOfMonth:
        // Target: rule.scheduleValue (e.g., 5th)
        // We want closest date D >= from such that D.day == scheduleValue

        int targetDay = rule.scheduleValue;
        if (targetDay > 31) targetDay = 31; // Clamp

        DateTime candidate = DateTime(from.year, from.month, targetDay);

        // Handle invalid dates (e.g. Feb 30 -> Mar 2).
        // We want strictly the "Nth day" or "Last day if Nth doesn't exist"?
        // Simpler approach: Just use DateTime constructor behavior (overflows) or strict month check.
        // Let's assume strict month check for correctness.

        // If from.month has fewer days than targetDay, skip to next month?
        // Or clamp to end of month? Usually "Monthly on 31st" means last day of months with <31 days.
        // Let's use "last day of month" logic if overflow.

        int lastDayOfCurrentMonth = DateTime(from.year, from.month + 1, 0).day;
        int actualDay = targetDay > lastDayOfCurrentMonth
            ? lastDayOfCurrentMonth
            : targetDay;

        candidate = DateTime(from.year, from.month, actualDay);

        if (candidate.isBefore(from) && !_isSameDate(candidate, from)) {
          // Move to next month
          int nextMonth = from.month + 1;
          int year = from.year;
          if (nextMonth > 12) {
            nextMonth = 1;
            year++;
          }
          int lastDayOfNextMonth = DateTime(year, nextMonth + 1, 0).day;
          int actualDayNext = targetDay > lastDayOfNextMonth
              ? lastDayOfNextMonth
              : targetDay;
          return DateTime(year, nextMonth, actualDayNext);
        }
        return candidate;

      case ScheduleType.endOfMonth:
        // Closest end-of-month >= from
        DateTime endOfThisMonth = DateTime(from.year, from.month + 1, 0);
        if (endOfThisMonth.isBefore(from) &&
            !_isSameDate(endOfThisMonth, from)) {
          return DateTime(from.year, from.month + 2, 0);
        }
        return endOfThisMonth;

      case ScheduleType.daysBeforeEndOfMonth:
        // e.g. 5 days before end of month
        int offset = rule.scheduleValue;
        DateTime endOfThisMonth = DateTime(from.year, from.month + 1, 0);
        DateTime target = endOfThisMonth.subtract(Duration(days: offset));

        if (target.isBefore(from) && !_isSameDate(target, from)) {
          DateTime endOfNextMonth = DateTime(from.year, from.month + 2, 0);
          return endOfNextMonth.subtract(Duration(days: offset));
        }
        return target;
    }
  }
}

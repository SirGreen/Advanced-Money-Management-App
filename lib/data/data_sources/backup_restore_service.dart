import 'dart:convert';
import 'package:hive/hive.dart';
import '../../domain/entities/expenditure.dart';
import '../../domain/entities/tag.dart';
import '../../domain/entities/scheduled_expenditure.dart';
import '../../domain/entities/settings.dart';
import '../../domain/entities/saving_goal.dart';
import '../../domain/entities/saving_contribution.dart';

class BackupRestoreService {
  static const String expenditureBoxName = 'expenditures';
  static const String tagBoxName = 'tags';
  static const String scheduledExpenditureBoxName = 'scheduled_expenditures';
  static const String settingsBoxName = 'settings';
  static const String savingGoalBoxName = 'saving_goals';
  static const String savingContributionBoxName = 'saving_contributions';

  /// Export all data to JSON string
  Future<String> exportAllData() async {
    try {
      final backupData = <String, dynamic>{};

      // Export expenditures
      if (Hive.isBoxOpen(expenditureBoxName)) {
        final box = Hive.box<Expenditure>(expenditureBoxName);
        backupData['expenditures'] = box.values
            .map(
              (e) => {
                'id': e.id,
                'articleName': e.articleName,
                'amount': e.amount,
                'date': e.date.toIso8601String(),
                'mainTagId': e.mainTagId,
                'subTagIds': e.subTagIds,
                'receiptImagePath': e.receiptImagePath,
                'scheduledExpenditureId': e.scheduledExpenditureId,
                'isIncome': e.isIncome,
                'currencyCode': e.currencyCode,
                'notes': e.notes,
                'createdAt': e.createdAt.toIso8601String(),
                'updatedAt': e.updatedAt.toIso8601String(),
              },
            )
            .toList();
      } else {
        backupData['expenditures'] = [];
      }

      // Export tags
      if (Hive.isBoxOpen(tagBoxName)) {
        final box = Hive.box<Tag>(tagBoxName);
        backupData['tags'] = box.values
            .map(
              (e) => {
                'id': e.id,
                'name': e.name,
                'colorValue': e.colorValue,
                'iconName': e.iconName,
                'imagePath': e.imagePath,
                'isDefault': e.isDefault,
                'budgetAmount': e.budgetAmount,
                'budgetInterval': e.budgetInterval,
              },
            )
            .toList();
      } else {
        backupData['tags'] = [];
      }

      // Export scheduled expenditures
      if (Hive.isBoxOpen(scheduledExpenditureBoxName)) {
        final box = Hive.box<ScheduledExpenditure>(scheduledExpenditureBoxName);
        backupData['scheduled_expenditures'] = box.values
            .map(
              (e) => {
                'id': e.id,
                'name': e.name,
                'amount': e.amount,
                'mainTagId': e.mainTagId,
                'subTagIds': e.subTagIds,
                'scheduleType': e.scheduleType.index,
                'scheduleValue': e.scheduleValue,
                'startDate': e.startDate.toIso8601String(),
                'lastCreatedDate': e.lastCreatedDate?.toIso8601String(),
                'isActive': e.isActive,
                'endDate': e.endDate?.toIso8601String(),
                'isIncome': e.isIncome,
                'currencyCode': e.currencyCode,
                'reminderDaysBefore': e.reminderDaysBefore,
              },
            )
            .toList();
      } else {
        backupData['scheduled_expenditures'] = [];
      }

      // Export settings
      if (Hive.isBoxOpen(settingsBoxName)) {
        final box = Hive.box<Settings>(settingsBoxName);
        final settings = box.get(0);
        if (settings != null) {
          backupData['settings'] = {
            'dividerType': settings.dividerType.index,
            'paydayStartDay': settings.paydayStartDay,
            'fixedIntervalDays': settings.fixedIntervalDays,
            'languageCode': settings.languageCode,
            'paginationLimit': settings.paginationLimit,
            'primaryCurrencyCode': settings.primaryCurrencyCode,
            'converterFromCurrency': settings.converterFromCurrency,
            'converterToCurrency': settings.converterToCurrency,
            'remindersEnabled': settings.remindersEnabled,
            'lastBackupDate': settings.lastBackupDate?.toIso8601String(),
            'userContext': settings.userContext,
            'privacyModeEnabled': settings.privacyModeEnabled,
          };
        }
      }

      // Export saving goals
      if (Hive.isBoxOpen(savingGoalBoxName)) {
        final box = Hive.box<SavingGoal>(savingGoalBoxName);
        backupData['saving_goals'] = box.values.map((e) => e.toJson()).toList();
      } else {
        backupData['saving_goals'] = [];
      }

      // Export saving contributions
      if (Hive.isBoxOpen(savingContributionBoxName)) {
        final box = Hive.box<SavingContribution>(savingContributionBoxName);
        backupData['saving_contributions'] = box.values.map((e) => e.toJson()).toList();
      } else {
        backupData['saving_contributions'] = [];
      }

      // Convert to JSON string with pretty printing
      return jsonEncode(backupData);
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  /// Import data from JSON string
  Future<void> importAllData(String jsonString) async {
    try {
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Import expenditures
      if (backupData.containsKey('expenditures')) {
        final box = await Hive.openBox<Expenditure>(expenditureBoxName);
        await box.clear();

        for (final item in backupData['expenditures'] as List) {
          final expenditure = Expenditure.fromJson(
            item as Map<String, dynamic>,
          );
          await box.put(expenditure.id, expenditure);
        }
      }

      // Import tags
      if (backupData.containsKey('tags')) {
        final box = await Hive.openBox<Tag>(tagBoxName);
        await box.clear();

        for (final item in backupData['tags'] as List) {
          final tag = Tag(
            id: item['id'] ?? '',
            name: item['name'] ?? '',
            colorValue: item['colorValue'] as int? ?? 0xFF000000,
            iconName: item['iconName'] ?? 'tag',
            imagePath: item['imagePath'],
            isDefault: item['isDefault'] as bool? ?? false,
            budgetAmount: (item['budgetAmount'] as num?)?.toDouble(),
            budgetInterval: item['budgetInterval'] as String? ?? 'None',
          );
          await box.put(tag.id, tag);
        }
      }

      // Import scheduled expenditures
      if (backupData.containsKey('scheduled_expenditures')) {
        final box = await Hive.openBox<ScheduledExpenditure>(
          scheduledExpenditureBoxName,
        );
        await box.clear();

        for (final item in backupData['scheduled_expenditures'] as List) {
          final scheduleTypeIndex = item['scheduleType'] as int? ?? 0;
          final scheduleType = ScheduleType.values[scheduleTypeIndex];

          final scheduled = ScheduledExpenditure(
            id: item['id'] ?? '',
            name: item['name'] ?? '',
            amount: (item['amount'] as num?)?.toDouble() ?? 0.0,
            mainTagId: item['mainTagId'] ?? '',
            subTagIds: List<String>.from(item['subTagIds'] as List? ?? []),
            scheduleType: scheduleType,
            scheduleValue: item['scheduleValue'] as int? ?? 0,
            startDate: DateTime.parse(
              item['startDate'] ?? DateTime.now().toIso8601String(),
            ),
            lastCreatedDate: item['lastCreatedDate'] != null
                ? DateTime.parse(item['lastCreatedDate'])
                : null,
            isActive: item['isActive'] as bool? ?? true,
            endDate: item['endDate'] != null
                ? DateTime.parse(item['endDate'])
                : null,
            isIncome: item['isIncome'] as bool? ?? false,
            currencyCode: item['currencyCode'] ?? 'USD',
            reminderDaysBefore: item['reminderDaysBefore'] as int?,
          );
          await box.put(scheduled.id, scheduled);
        }
      }

      // Import settings
      if (backupData.containsKey('settings')) {
        final box = await Hive.openBox<Settings>(settingsBoxName);
        final settingsData = backupData['settings'] as Map<String, dynamic>;

        final settings = Settings(
          dividerType: _parseDividerType(settingsData['dividerType']),
          paydayStartDay: settingsData['paydayStartDay'] as int? ?? 1,
          fixedIntervalDays: settingsData['fixedIntervalDays'] as int? ?? 7,
          languageCode: settingsData['languageCode'],
          paginationLimit: settingsData['paginationLimit'] as int? ?? 50,
          primaryCurrencyCode: settingsData['primaryCurrencyCode'] ?? 'JPY',
          converterFromCurrency:
              settingsData['converterFromCurrency'] ?? 'USD',
          converterToCurrency: settingsData['converterToCurrency'] ?? 'JPY',
          remindersEnabled:
              settingsData['remindersEnabled'] as bool? ?? false,
          lastBackupDate: settingsData['lastBackupDate'] != null
              ? DateTime.parse(settingsData['lastBackupDate'])
              : null,
          userContext: settingsData['userContext'],
          privacyModeEnabled:
              settingsData['privacyModeEnabled'] as bool? ?? false,
          geminiApiKey: settingsData['geminiApiKey'],
        );

        await box.put(0, settings);
      }

      // Import saving goals
      if (backupData.containsKey('saving_goals')) {
        final box = await Hive.openBox<SavingGoal>(savingGoalBoxName);
        await box.clear();

        for (final item in backupData['saving_goals'] as List) {
          final goal = SavingGoal.fromJson(item as Map<String, dynamic>);
          await box.put(goal.id, goal);
        }
      }

      // Import saving contributions
      if (backupData.containsKey('saving_contributions')) {
        final box = await Hive.openBox<SavingContribution>(savingContributionBoxName);
        await box.clear();

        for (final item in backupData['saving_contributions'] as List) {
          final contribution = SavingContribution.fromJson(item as Map<String, dynamic>);
          await box.put(contribution.id, contribution);
        }
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  static ScheduleType _parseScheduleType(String? value) {
    switch (value) {
      case 'dayOfMonth':
        return ScheduleType.dayOfMonth;
      case 'endOfMonth':
        return ScheduleType.endOfMonth;
      case 'daysBeforeEndOfMonth':
        return ScheduleType.daysBeforeEndOfMonth;
      case 'fixedInterval':
        return ScheduleType.fixedInterval;
      default:
        return ScheduleType.dayOfMonth;
    }
  }

  static DividerType _parseDividerType(dynamic value) {
    if (value is int) {
      return DividerType.values[value];
    }
    final strValue = value?.toString();
    switch (strValue) {
      case 'monthly':
        return DividerType.monthly;
      case 'paydayCycle':
        return DividerType.paydayCycle;
      case 'fixedInterval':
        return DividerType.fixedInterval;
      default:
        return DividerType.monthly;
    }
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('vi')
  ];

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet. Let\'s add one!'**
  String get noTransactions;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @manageTags.
  ///
  /// In en, this message translates to:
  /// **'Manage Tags'**
  String get manageTags;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @manageScheduled.
  ///
  /// In en, this message translates to:
  /// **'Manage Scheduled'**
  String get manageScheduled;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @transactionType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get transactionType;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @expenseName.
  ///
  /// In en, this message translates to:
  /// **'Expense Name'**
  String get expenseName;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Income Source'**
  String get source;

  /// No description provided for @articleName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get articleName;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @amountOptional.
  ///
  /// In en, this message translates to:
  /// **'Amount (optional)'**
  String get amountOptional;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @mainTag.
  ///
  /// In en, this message translates to:
  /// **'Main Tag'**
  String get mainTag;

  /// No description provided for @subTags.
  ///
  /// In en, this message translates to:
  /// **'Sub-tags'**
  String get subTags;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this record?'**
  String get confirmDeleteMessage;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectTags.
  ///
  /// In en, this message translates to:
  /// **'Select Tags'**
  String get selectTags;

  /// No description provided for @addNewTag.
  ///
  /// In en, this message translates to:
  /// **'Add New Tag'**
  String get addNewTag;

  /// No description provided for @noAmountSet.
  ///
  /// In en, this message translates to:
  /// **'Amount Not Set'**
  String get noAmountSet;

  /// No description provided for @netBalance.
  ///
  /// In en, this message translates to:
  /// **'Net Balance'**
  String get netBalance;

  /// No description provided for @spendingReport.
  ///
  /// In en, this message translates to:
  /// **'Spending Report'**
  String get spendingReport;

  /// No description provided for @totalSpending.
  ///
  /// In en, this message translates to:
  /// **'Total Spending'**
  String get totalSpending;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get byCategory;

  /// No description provided for @nameInput.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get nameInput;

  /// No description provided for @validNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get validNumber;

  /// No description provided for @selectMainTag.
  ///
  /// In en, this message translates to:
  /// **'Please select a main tag'**
  String get selectMainTag;

  /// No description provided for @selectSubTag.
  ///
  /// In en, this message translates to:
  /// **'Select Sub-tags'**
  String get selectSubTag;

  /// No description provided for @selectTag.
  ///
  /// In en, this message translates to:
  /// **'Please select a tag'**
  String get selectTag;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get end;

  /// No description provided for @amountChanged.
  ///
  /// In en, this message translates to:
  /// **'Amount Changed'**
  String get amountChanged;

  /// No description provided for @confirmUpdateAllExpenses.
  ///
  /// In en, this message translates to:
  /// **'Update all past transactions with this new amount?'**
  String get confirmUpdateAllExpenses;

  /// No description provided for @noChange.
  ///
  /// In en, this message translates to:
  /// **'No, keep past amounts'**
  String get noChange;

  /// No description provided for @updateAll.
  ///
  /// In en, this message translates to:
  /// **'Yes, update all'**
  String get updateAll;

  /// No description provided for @applyForRelatedTransaction.
  ///
  /// In en, this message translates to:
  /// **'Handle Past Transactions'**
  String get applyForRelatedTransaction;

  /// No description provided for @confirmDeleteRuleInstance.
  ///
  /// In en, this message translates to:
  /// **'When deleting this rule, do you want to also delete all past transactions it created?'**
  String get confirmDeleteRuleInstance;

  /// No description provided for @leaveUnchanged.
  ///
  /// In en, this message translates to:
  /// **'No, keep past transactions'**
  String get leaveUnchanged;

  /// No description provided for @changeAll.
  ///
  /// In en, this message translates to:
  /// **'Yes, delete everything'**
  String get changeAll;

  /// No description provided for @finalConfirm.
  ///
  /// In en, this message translates to:
  /// **'Final Confirmation'**
  String get finalConfirm;

  /// No description provided for @confirmShouldDeleteInstance.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this rule AND all of its related transactions? This action cannot be undone.'**
  String get confirmShouldDeleteInstance;

  /// No description provided for @confirmDeleteOnlyRule.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this rule? Past transactions will be kept as manual entries.'**
  String get confirmDeleteOnlyRule;

  /// No description provided for @performDeleteion.
  ///
  /// In en, this message translates to:
  /// **'Perform Deletion'**
  String get performDeleteion;

  /// No description provided for @editAutoTrans.
  ///
  /// In en, this message translates to:
  /// **'Edit Scheduled Transaction'**
  String get editAutoTrans;

  /// No description provided for @addAutoTrans.
  ///
  /// In en, this message translates to:
  /// **'Add Scheduled Transaction'**
  String get addAutoTrans;

  /// No description provided for @repeatSetting.
  ///
  /// In en, this message translates to:
  /// **'Repeat Settings'**
  String get repeatSetting;

  /// No description provided for @repeatType.
  ///
  /// In en, this message translates to:
  /// **'Repeat Type'**
  String get repeatType;

  /// No description provided for @dayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Specific day of the month'**
  String get dayOfMonth;

  /// No description provided for @endOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Last day of the month'**
  String get endOfMonth;

  /// No description provided for @daysBeforeEoM.
  ///
  /// In en, this message translates to:
  /// **'N days before end of month'**
  String get daysBeforeEoM;

  /// No description provided for @fixedInterval.
  ///
  /// In en, this message translates to:
  /// **'Fixed Interval'**
  String get fixedInterval;

  /// No description provided for @msgFixedInterval.
  ///
  /// In en, this message translates to:
  /// **'Group by a set number of days.'**
  String get msgFixedInterval;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDateOptional.
  ///
  /// In en, this message translates to:
  /// **'End Date (optional)'**
  String get endDateOptional;

  /// No description provided for @noEndDate.
  ///
  /// In en, this message translates to:
  /// **'No end date (repeats forever)'**
  String get noEndDate;

  /// No description provided for @clearEndDate.
  ///
  /// In en, this message translates to:
  /// **'Clear End Date'**
  String get clearEndDate;

  /// No description provided for @howManyDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'Days before'**
  String get howManyDaysBefore;

  /// No description provided for @enterOneOrMoreDay.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number greater than 0'**
  String get enterOneOrMoreDay;

  /// No description provided for @intervalDays.
  ///
  /// In en, this message translates to:
  /// **'Interval (in days)'**
  String get intervalDays;

  /// No description provided for @chooseColor.
  ///
  /// In en, this message translates to:
  /// **'Choose Color'**
  String get chooseColor;

  /// No description provided for @editTag.
  ///
  /// In en, this message translates to:
  /// **'Edit Tag'**
  String get editTag;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add New Tag'**
  String get addTag;

  /// No description provided for @tagName.
  ///
  /// In en, this message translates to:
  /// **'Tag Name'**
  String get tagName;

  /// No description provided for @inputTagName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a tag name'**
  String get inputTagName;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @selectImgFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select image from gallery'**
  String get selectImgFromGallery;

  /// No description provided for @msgAddTrans.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get msgAddTrans;

  /// No description provided for @addNewRule.
  ///
  /// In en, this message translates to:
  /// **'Add New Rule'**
  String get addNewRule;

  /// No description provided for @noAutoRule.
  ///
  /// In en, this message translates to:
  /// **'No scheduled transaction rules exist.'**
  String get noAutoRule;

  /// No description provided for @noTag.
  ///
  /// In en, this message translates to:
  /// **'No tags exist.'**
  String get noTag;

  /// No description provided for @deleteRule.
  ///
  /// In en, this message translates to:
  /// **'Delete this rule'**
  String get deleteRule;

  /// No description provided for @noDataForReport.
  ///
  /// In en, this message translates to:
  /// **'Not enough data to create a report.'**
  String get noDataForReport;

  /// No description provided for @interval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get interval;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom...'**
  String get custom;

  /// No description provided for @customDays.
  ///
  /// In en, this message translates to:
  /// **'Custom Days (1-180)'**
  String get customDays;

  /// No description provided for @enterNumOfDays.
  ///
  /// In en, this message translates to:
  /// **'Enter number of days'**
  String get enterNumOfDays;

  /// No description provided for @confirmReset.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset?'**
  String get confirmReset;

  /// No description provided for @confirmDeleteEverything.
  ///
  /// In en, this message translates to:
  /// **'All expenditures, tags, and scheduled rules will be deleted. This action cannot be undone.'**
  String get confirmDeleteEverything;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @transListGroup.
  ///
  /// In en, this message translates to:
  /// **'Transaction List Grouping'**
  String get transListGroup;

  /// No description provided for @calendarMonth.
  ///
  /// In en, this message translates to:
  /// **'By Calendar Month'**
  String get calendarMonth;

  /// No description provided for @msgCalendarMonth.
  ///
  /// In en, this message translates to:
  /// **'Group from the 1st to the end of the month.'**
  String get msgCalendarMonth;

  /// No description provided for @paydayCycle.
  ///
  /// In en, this message translates to:
  /// **'By Payday Cycle'**
  String get paydayCycle;

  /// No description provided for @msgPaydayCycle.
  ///
  /// In en, this message translates to:
  /// **'Group from a specified start day to the day before in the next month.'**
  String get msgPaydayCycle;

  /// No description provided for @cycleStartDate.
  ///
  /// In en, this message translates to:
  /// **'Cycle Start Day'**
  String get cycleStartDate;

  /// No description provided for @dangerousOperation.
  ///
  /// In en, this message translates to:
  /// **'Dangerous Operations'**
  String get dangerousOperation;

  /// No description provided for @resetAllData.
  ///
  /// In en, this message translates to:
  /// **'Reset All Data'**
  String get resetAllData;

  /// No description provided for @resetApp.
  ///
  /// In en, this message translates to:
  /// **'Returns the app to its initial state.'**
  String get resetApp;

  /// No description provided for @tagInUse.
  ///
  /// In en, this message translates to:
  /// **'Tag in Use'**
  String get tagInUse;

  /// No description provided for @deleteAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Delete and Continue'**
  String get deleteAndContinue;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search Transactions'**
  String get searchTransactions;

  /// No description provided for @keyword.
  ///
  /// In en, this message translates to:
  /// **'Keyword'**
  String get keyword;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @paginationLimit.
  ///
  /// In en, this message translates to:
  /// **'Pagination Limit'**
  String get paginationLimit;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// No description provided for @filterByDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by Date'**
  String get filterByDate;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @enterMoreCharsForSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Enter more characters for suggestions'**
  String get enterMoreCharsForSuggestion;

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear Selection'**
  String get clearSelection;

  /// No description provided for @expenseBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Expense Breakdown'**
  String get expenseBreakdown;

  /// No description provided for @incomeBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Income Breakdown'**
  String get incomeBreakdown;

  /// No description provided for @allTimeMoneyLeft.
  ///
  /// In en, this message translates to:
  /// **'All-Time Balance'**
  String get allTimeMoneyLeft;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// Warning message that a tag is being used for an expense
  ///
  /// In en, this message translates to:
  /// **'The tag \"{tagName}\" is currently in use. If you delete it, related transactions will be moved to the \'Other\' category. Do you want to continue?'**
  String warningTagInUse(String tagName);

  /// Confirm delete tag
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the \"{tagName}\" tag?'**
  String removeTag(String tagName);

  /// Formats a number as a currency value. The symbol will be determined by the locale.
  ///
  /// In en, this message translates to:
  /// **'\${value}'**
  String currencyValue(String value);

  /// Error message shown when saving an image fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to save image: {error}'**
  String imageSaveFailed(Object error);

  /// Label for a specific day of the month.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String dayOfMonthLabel(int day);

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @dateNewestFirst.
  ///
  /// In en, this message translates to:
  /// **'Date (Newest first)'**
  String get dateNewestFirst;

  /// No description provided for @dateOldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Date (Oldest first)'**
  String get dateOldestFirst;

  /// No description provided for @amountHighestFirst.
  ///
  /// In en, this message translates to:
  /// **'Amount (High to low)'**
  String get amountHighestFirst;

  /// No description provided for @amountLowestFirst.
  ///
  /// In en, this message translates to:
  /// **'Amount (Low to high)'**
  String get amountLowestFirst;

  /// No description provided for @nameAZ.
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get nameAZ;

  /// No description provided for @nameZA.
  ///
  /// In en, this message translates to:
  /// **'Name (Z-A)'**
  String get nameZA;

  /// No description provided for @advancedSearch.
  ///
  /// In en, this message translates to:
  /// **'Advanced search'**
  String get advancedSearch;

  /// No description provided for @minAmount.
  ///
  /// In en, this message translates to:
  /// **'Min amount'**
  String get minAmount;

  /// No description provided for @maxAmount.
  ///
  /// In en, this message translates to:
  /// **'Max amount'**
  String get maxAmount;

  /// No description provided for @anyDate.
  ///
  /// In en, this message translates to:
  /// **'Any date'**
  String get anyDate;

  /// No description provided for @currencyConverter.
  ///
  /// In en, this message translates to:
  /// **'Currency converter'**
  String get currencyConverter;

  /// No description provided for @amountToConvert.
  ///
  /// In en, this message translates to:
  /// **'Amount to convert'**
  String get amountToConvert;

  /// No description provided for @swapCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Swap currencies'**
  String get swapCurrencies;

  /// No description provided for @scanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt'**
  String get scanReceipt;

  /// No description provided for @processingImage.
  ///
  /// In en, this message translates to:
  /// **'Processing image'**
  String get processingImage;

  /// No description provided for @takePicture.
  ///
  /// In en, this message translates to:
  /// **'Take a picture'**
  String get takePicture;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from gallery'**
  String get selectFromGallery;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @addManually.
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get addManually;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Household Budget App'**
  String get appName;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Add notes (e.g. details, location)'**
  String get notesHint;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @suggestTags.
  ///
  /// In en, this message translates to:
  /// **'Suggest tags'**
  String get suggestTags;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @optionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Details (optional)'**
  String get optionalDetails;

  /// No description provided for @analyzingYourReceipt.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your receipt'**
  String get analyzingYourReceipt;

  /// No description provided for @uploadAnExistingImage.
  ///
  /// In en, this message translates to:
  /// **'Upload an existing image'**
  String get uploadAnExistingImage;

  /// No description provided for @useYourCameraToScan.
  ///
  /// In en, this message translates to:
  /// **'Use your camera to scan'**
  String get useYourCameraToScan;

  /// No description provided for @letAiDoTheHeavyLifting.
  ///
  /// In en, this message translates to:
  /// **'Let AI do the heavy lifting'**
  String get letAiDoTheHeavyLifting;

  /// No description provided for @scanYourReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan your receipt'**
  String get scanYourReceipt;

  /// No description provided for @exportingData.
  ///
  /// In en, this message translates to:
  /// **'Exporting data...'**
  String get exportingData;

  /// No description provided for @exportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Export cancelled.'**
  String get exportCancelled;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @importWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite all current data in the app. This action cannot be undone. Are you sure you want to proceed?'**
  String get importWarningMessage;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully!'**
  String get importSuccess;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Please try again.'**
  String get importFailed;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data management'**
  String get dataManagement;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @exportDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your data to a file.'**
  String get exportDataSubtitle;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @importDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore data from a file.'**
  String get importDataSubtitle;

  /// No description provided for @searchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get searchByName;

  /// No description provided for @amountRange.
  ///
  /// In en, this message translates to:
  /// **'Amount range'**
  String get amountRange;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @noTagsYet.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get noTagsYet;

  /// No description provided for @noScheduledRules.
  ///
  /// In en, this message translates to:
  /// **'No scheduled rules'**
  String get noScheduledRules;

  /// No description provided for @tapToAddFirstRule.
  ///
  /// In en, this message translates to:
  /// **'Tap to add your first rule'**
  String get tapToAddFirstRule;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @ruleName.
  ///
  /// In en, this message translates to:
  /// **'Rule name'**
  String get ruleName;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get optional;

  /// No description provided for @defaultTag.
  ///
  /// In en, this message translates to:
  /// **'Default tag'**
  String get defaultTag;

  /// No description provided for @tapToAddFirstTag.
  ///
  /// In en, this message translates to:
  /// **'Tap to add your first tag'**
  String get tapToAddFirstTag;

  /// No description provided for @searchCurrency.
  ///
  /// In en, this message translates to:
  /// **'Search currency'**
  String get searchCurrency;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @convertFrom.
  ///
  /// In en, this message translates to:
  /// **'Convert from'**
  String get convertFrom;

  /// No description provided for @convertTo.
  ///
  /// In en, this message translates to:
  /// **'Convert to'**
  String get convertTo;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// Label for N days before end of month.
  ///
  /// In en, this message translates to:
  /// **'{value} days before end of month'**
  String daysBeforeEndOfMonthWithValue(int value);

  /// Label for fixed interval in days.
  ///
  /// In en, this message translates to:
  /// **'Every {value} days'**
  String fixedIntervalWithValue(int value);

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export successful: {path}'**
  String exportSuccess(String path);

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @allTimeBalance.
  ///
  /// In en, this message translates to:
  /// **'All-time balance'**
  String get allTimeBalance;

  /// No description provided for @changeCurrency.
  ///
  /// In en, this message translates to:
  /// **'Change Currency'**
  String get changeCurrency;

  /// Confirmation message for currency conversion.
  ///
  /// In en, this message translates to:
  /// **'Convert all records from {oldCode} to {newCode}? This requires retrieving exchange rates.'**
  String confirmCurrencyConversion(String oldCode, String newCode);

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @exchangeRateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve exchange rate. Please try again later.'**
  String get exchangeRateError;

  /// No description provided for @addCustomRate.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Exchange Rate'**
  String get addCustomRate;

  /// No description provided for @exchangeRate.
  ///
  /// In en, this message translates to:
  /// **'Exchange Rate'**
  String get exchangeRate;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @primaryCurrency.
  ///
  /// In en, this message translates to:
  /// **'Primary Currency'**
  String get primaryCurrency;

  /// No description provided for @customExchangeRates.
  ///
  /// In en, this message translates to:
  /// **'Custom Exchange Rates'**
  String get customExchangeRates;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @languageName.
  ///
  /// In en, this message translates to:
  /// **'{languageCode, select, ja{日本語} en{English} vi{Tiếng Việt} other{Unknown}}'**
  String languageName(String languageCode);

  /// The name of a currency.
  ///
  /// In en, this message translates to:
  /// **'{currencyCode, select, JPY{Japanese Yen (JPY)} USD{US Dollar (USD)} EUR{Euro (EUR)} CNY{Chinese Yuan (CNY)} RUB{Russian Ruble (RUB)} VND{Vietnamese Dong (VND)} AUD{Australian Dollar (AUD)} KRW{South Korean Won (KRW)} THB{Thai Baht (THB)} PHP{Philippine Peso (PHP)} MYR{Malaysian Ringgit (MYR)} GBP{British Pound (GBP)} CAD{Canadian Dollar (CAD)} CHF{Swiss Franc (CHF)} HKD{Hong Kong Dollar (HKD)} SGD{Singapore Dollar (SGD)} INR{Indian Rupee (INR)} BRL{Brazilian Real (BRL)} ZAR{South African Rand (ZAR)} other{Unknown}}'**
  String currencyName(String currencyCode);

  /// Label for days unit.
  ///
  /// In en, this message translates to:
  /// **'{day} days'**
  String daysUnit(int day);

  /// No description provided for @editSavingGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit Saving Goal'**
  String get editSavingGoal;

  /// No description provided for @addSavingGoal.
  ///
  /// In en, this message translates to:
  /// **'Add Saving Goal'**
  String get addSavingGoal;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal Name'**
  String get goalName;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get targetAmount;

  /// No description provided for @currentAmount.
  ///
  /// In en, this message translates to:
  /// **'Current Amount'**
  String get currentAmount;

  /// No description provided for @annualInterestRate.
  ///
  /// In en, this message translates to:
  /// **'Annual Interest Rate'**
  String get annualInterestRate;

  /// No description provided for @assets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get savings;

  /// No description provided for @investments.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get investments;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon'**
  String get featureComingSoon;

  /// No description provided for @noSavingGoals.
  ///
  /// In en, this message translates to:
  /// **'No saving goals yet'**
  String get noSavingGoals;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @addPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Add Portfolio'**
  String get addPortfolio;

  /// No description provided for @addNewPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Add New Portfolio'**
  String get addNewPortfolio;

  /// No description provided for @portfolioName.
  ///
  /// In en, this message translates to:
  /// **'Portfolio Name'**
  String get portfolioName;

  /// No description provided for @noPortfolios.
  ///
  /// In en, this message translates to:
  /// **'No portfolios yet'**
  String get noPortfolios;

  /// No description provided for @noInvestments.
  ///
  /// In en, this message translates to:
  /// **'No investments yet'**
  String get noInvestments;

  /// No description provided for @addInvestment.
  ///
  /// In en, this message translates to:
  /// **'Add Investment'**
  String get addInvestment;

  /// No description provided for @portfolioNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Stocks, Crypto'**
  String get portfolioNameHint;

  /// No description provided for @editInvestment.
  ///
  /// In en, this message translates to:
  /// **'Edit Investment'**
  String get editInvestment;

  /// No description provided for @investmentSymbol.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get investmentSymbol;

  /// No description provided for @investmentSymbolHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., AAPL, BTC'**
  String get investmentSymbolHint;

  /// No description provided for @investmentName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get investmentName;

  /// No description provided for @investmentNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Apple Inc.'**
  String get investmentNameHint;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @averageBuyPrice.
  ///
  /// In en, this message translates to:
  /// **'Average Buy Price'**
  String get averageBuyPrice;

  /// No description provided for @inputQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a quantity'**
  String get inputQuantity;

  /// No description provided for @inputAverageBuyPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter an average buy price'**
  String get inputAverageBuyPrice;

  /// No description provided for @estimatedValueAt.
  ///
  /// In en, this message translates to:
  /// **'Est. value at {date}'**
  String estimatedValueAt(String date);

  /// No description provided for @editSavingAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit Saving Account'**
  String get editSavingAccount;

  /// No description provided for @addSavingAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Saving Account'**
  String get addSavingAccount;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @openingDate.
  ///
  /// In en, this message translates to:
  /// **'Opening Date'**
  String get openingDate;

  /// No description provided for @closingDate.
  ///
  /// In en, this message translates to:
  /// **'Closing Date'**
  String get closingDate;

  /// No description provided for @stillActive.
  ///
  /// In en, this message translates to:
  /// **'Still Active'**
  String get stillActive;

  /// No description provided for @clearClosingDate.
  ///
  /// In en, this message translates to:
  /// **'Clear Closing Date'**
  String get clearClosingDate;

  /// No description provided for @savingAccounts.
  ///
  /// In en, this message translates to:
  /// **'Saving Accounts'**
  String get savingAccounts;

  /// No description provided for @noSavingAccounts.
  ///
  /// In en, this message translates to:
  /// **'No Saving Accounts'**
  String get noSavingAccounts;

  /// No description provided for @savingGoals.
  ///
  /// In en, this message translates to:
  /// **'Saving Goals'**
  String get savingGoals;

  /// No description provided for @contribution.
  ///
  /// In en, this message translates to:
  /// **'Contribution'**
  String get contribution;

  /// No description provided for @contributionAdded.
  ///
  /// In en, this message translates to:
  /// **'Contribution Added'**
  String get contributionAdded;

  /// No description provided for @addContribution.
  ///
  /// In en, this message translates to:
  /// **'Add Contribution'**
  String get addContribution;

  /// No description provided for @contributionAmount.
  ///
  /// In en, this message translates to:
  /// **'Contribution Amount'**
  String get contributionAmount;

  /// No description provided for @saveAsTransaction.
  ///
  /// In en, this message translates to:
  /// **'Save as Transaction'**
  String get saveAsTransaction;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @pinsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get pinsDoNotMatch;

  /// No description provided for @setupPin.
  ///
  /// In en, this message translates to:
  /// **'Set up PIN'**
  String get setupPin;

  /// No description provided for @enterNewPin.
  ///
  /// In en, this message translates to:
  /// **'Enter New PIN'**
  String get enterNewPin;

  /// No description provided for @confirmNewPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm New PIN'**
  String get confirmNewPin;

  /// No description provided for @pinLock.
  ///
  /// In en, this message translates to:
  /// **'PIN Lock'**
  String get pinLock;

  /// No description provided for @pinIsEnabled.
  ///
  /// In en, this message translates to:
  /// **'PIN is enabled'**
  String get pinIsEnabled;

  /// No description provided for @pinIsDisabled.
  ///
  /// In en, this message translates to:
  /// **'PIN is disabled'**
  String get pinIsDisabled;

  /// No description provided for @disablePin.
  ///
  /// In en, this message translates to:
  /// **'Disable PIN'**
  String get disablePin;

  /// No description provided for @disablePinMessage.
  ///
  /// In en, this message translates to:
  /// **'Disable pin lock will wipe all data, make sure that you have a backup ready! Are you sure you want to disable the PIN lock?'**
  String get disablePinMessage;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @authenticateToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to unlock'**
  String get authenticateToUnlock;

  /// No description provided for @incorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Please try again.'**
  String get incorrectPin;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter Your PIN'**
  String get enterPin;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @totalSavings.
  ///
  /// In en, this message translates to:
  /// **'Total Savings'**
  String get totalSavings;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction;

  /// Number of transactions
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No transactions} =1{1 transaction} other{{count} transactions}}'**
  String transactions(int count);

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @resetDate.
  ///
  /// In en, this message translates to:
  /// **'Reset Date'**
  String get resetDate;

  /// No description provided for @cashFlowTimeline.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow Timeline'**
  String get cashFlowTimeline;

  /// No description provided for @createdOn.
  ///
  /// In en, this message translates to:
  /// **'Created On'**
  String get createdOn;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  /// No description provided for @restartToApply.
  ///
  /// In en, this message translates to:
  /// **'Import successful. Please restart the app to apply changes.'**
  String get restartToApply;

  /// No description provided for @restartNow.
  ///
  /// In en, this message translates to:
  /// **'Restart Now'**
  String get restartNow;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @noBudgetsSet.
  ///
  /// In en, this message translates to:
  /// **'No budgets set'**
  String get noBudgetsSet;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// No description provided for @addBudget.
  ///
  /// In en, this message translates to:
  /// **'Add Budget'**
  String get addBudget;

  /// No description provided for @editingBudgetForThisTag.
  ///
  /// In en, this message translates to:
  /// **'Editing budget for this tag'**
  String get editingBudgetForThisTag;

  /// No description provided for @selectTagForBudget.
  ///
  /// In en, this message translates to:
  /// **'Select a tag for the budget'**
  String get selectTagForBudget;

  /// No description provided for @budgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Budget Amount'**
  String get budgetAmount;

  /// No description provided for @budgetPeriod.
  ///
  /// In en, this message translates to:
  /// **'Budget Period'**
  String get budgetPeriod;

  /// No description provided for @deleteBudget.
  ///
  /// In en, this message translates to:
  /// **'Delete Budget'**
  String get deleteBudget;

  /// No description provided for @saveBudget.
  ///
  /// In en, this message translates to:
  /// **'Save Budget'**
  String get saveBudget;

  /// No description provided for @trans.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get trans;

  /// No description provided for @noTransactionsInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No transactions in this period'**
  String get noTransactionsInPeriod;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @clearTags.
  ///
  /// In en, this message translates to:
  /// **'Clear Tags'**
  String get clearTags;

  /// Shows the date when the budget resets
  ///
  /// In en, this message translates to:
  /// **'Resets on {date}'**
  String resetsOn(String date);

  /// Confirmation message for deleting a budget
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the budget for \"{tagName}\"?'**
  String confirmDeleteBudget(String tagName);

  /// Shows how much the user is over budget
  ///
  /// In en, this message translates to:
  /// **'Over budget by {amount}'**
  String overBudgetBy(String amount);

  /// Shows how much budget remains
  ///
  /// In en, this message translates to:
  /// **'Remaining: {amount}'**
  String remaining(String amount);

  /// Name of the budget period
  ///
  /// In en, this message translates to:
  /// **'{period} period'**
  String budgetPeriodName(String period);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed. Please try again.'**
  String get exportFailed;

  /// No description provided for @exportNoPassword.
  ///
  /// In en, this message translates to:
  /// **'Export cancelled: No password provided.'**
  String get exportNoPassword;

  /// No description provided for @importCancelled.
  ///
  /// In en, this message translates to:
  /// **'Import cancelled.'**
  String get importCancelled;

  /// No description provided for @importNoPassword.
  ///
  /// In en, this message translates to:
  /// **'Import cancelled: No password provided.'**
  String get importNoPassword;

  /// No description provided for @importWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Import failed: Wrong password or corrupted file.'**
  String get importWrongPassword;

  /// No description provided for @backupPassword.
  ///
  /// In en, this message translates to:
  /// **'Backup Password'**
  String get backupPassword;

  /// No description provided for @enterPasswordForBackup.
  ///
  /// In en, this message translates to:
  /// **'Enter a password for the backup'**
  String get enterPasswordForBackup;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get passwordCannotBeEmpty;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @selectOutputFile.
  ///
  /// In en, this message translates to:
  /// **'Please select an output file:'**
  String get selectOutputFile;

  /// No description provided for @forgotPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get forgotPin;

  /// No description provided for @resetConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Reset App?'**
  String get resetConfirmation;

  /// No description provided for @resetWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your app data, including transactions, settings, and backups. This action cannot be undone. Are you sure you want to proceed?'**
  String get resetWarningMessage;

  /// No description provided for @resetAndStartOver.
  ///
  /// In en, this message translates to:
  /// **'Delete & Reset'**
  String get resetAndStartOver;

  /// No description provided for @addToTotal.
  ///
  /// In en, this message translates to:
  /// **'Add to Total'**
  String get addToTotal;

  /// No description provided for @additionalAmount.
  ///
  /// In en, this message translates to:
  /// **'Additional Amount'**
  String get additionalAmount;

  /// No description provided for @forgotToAddItem.
  ///
  /// In en, this message translates to:
  /// **'Forgot to add an item? Add the amount here.'**
  String get forgotToAddItem;

  /// No description provided for @notificationReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get notificationReminderTitle;

  /// No description provided for @notificationReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Don’t forget to add your transactions today.'**
  String get notificationReminderBody;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @enableRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable reminders to get notified about adding transactions.'**
  String get enableRemindersSubtitle;

  /// No description provided for @enableReminders.
  ///
  /// In en, this message translates to:
  /// **'Enable Reminders'**
  String get enableReminders;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @notificationPermissionGuide.
  ///
  /// In en, this message translates to:
  /// **'To use reminders, allow notifications in settings.'**
  String get notificationPermissionGuide;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission denied.'**
  String get permissionDenied;

  /// No description provided for @notificationIncompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Incomplete Transactions'**
  String get notificationIncompleteTitle;

  /// No description provided for @notificationIncompleteBody.
  ///
  /// In en, this message translates to:
  /// **'{incompleteCount} matches found'**
  String notificationIncompleteBody(int incompleteCount);

  /// No description provided for @transactionsSingle.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transactionsSingle;

  /// No description provided for @clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get clearFilter;

  /// No description provided for @sortByOverbudget.
  ///
  /// In en, this message translates to:
  /// **'Sort by Overbudget'**
  String get sortByOverbudget;

  /// No description provided for @sortByPercent.
  ///
  /// In en, this message translates to:
  /// **'Sort by Percent'**
  String get sortByPercent;

  /// No description provided for @sortByAmount.
  ///
  /// In en, this message translates to:
  /// **'Sort by Amount'**
  String get sortByAmount;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'Sort by Name'**
  String get sortByName;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @unspecifiedTransactions.
  ///
  /// In en, this message translates to:
  /// **'Unspecified Transactions'**
  String get unspecifiedTransactions;

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'Over Budget'**
  String get overBudget;

  /// No description provided for @itemsNeedAttention.
  ///
  /// In en, this message translates to:
  /// **'{count} items need attention'**
  String itemsNeedAttention(int count);

  /// No description provided for @noRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'No recent transactions'**
  String get noRecentTransactions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @highSpendingAlert.
  ///
  /// In en, this message translates to:
  /// **'High Spending Alert'**
  String get highSpendingAlert;

  /// No description provided for @spendingHigherThanAverage.
  ///
  /// In en, this message translates to:
  /// **'Spending higher than average'**
  String get spendingHigherThanAverage;

  /// No description provided for @goalsEndingSoon.
  ///
  /// In en, this message translates to:
  /// **'Goals Ending Soon'**
  String get goalsEndingSoon;

  /// No description provided for @endsOn.
  ///
  /// In en, this message translates to:
  /// **'Ends on'**
  String get endsOn;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @cannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Cannot be negative'**
  String get cannotBeNegative;

  /// No description provided for @adjustTotal.
  ///
  /// In en, this message translates to:
  /// **'Adjust Total'**
  String get adjustTotal;

  /// No description provided for @adjustmentAmount.
  ///
  /// In en, this message translates to:
  /// **'Adjustment Amount'**
  String get adjustmentAmount;

  /// No description provided for @removeFromTotal.
  ///
  /// In en, this message translates to:
  /// **'Remove from Total'**
  String get removeFromTotal;

  /// No description provided for @backupReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to back up!'**
  String get backupReminderTitle;

  /// No description provided for @backupReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make sure to regularly back up your data to avoid loss.'**
  String get backupReminderSubtitle;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzing;

  /// No description provided for @analysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed. Please try again.'**
  String get analysisFailed;

  /// No description provided for @budgetAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Budget Analysis'**
  String get budgetAnalysis;

  /// No description provided for @noAnalysisSummary.
  ///
  /// In en, this message translates to:
  /// **'No analysis summary available for this period.'**
  String get noAnalysisSummary;

  /// No description provided for @onTrackToMeetBudget.
  ///
  /// In en, this message translates to:
  /// **'On track to meet your budget'**
  String get onTrackToMeetBudget;

  /// No description provided for @atRiskOfExceedingBudget.
  ///
  /// In en, this message translates to:
  /// **'At risk of exceeding your budget'**
  String get atRiskOfExceedingBudget;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @contextSaved.
  ///
  /// In en, this message translates to:
  /// **'Context saved successfully.'**
  String get contextSaved;

  /// No description provided for @errorSavingContext.
  ///
  /// In en, this message translates to:
  /// **'Error saving context. Please try again.'**
  String get errorSavingContext;

  /// No description provided for @financialContextTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Financial Context'**
  String get financialContextTitle;

  /// No description provided for @financialContextDescription.
  ///
  /// In en, this message translates to:
  /// **'Save your situation to receive more tailored recommendations.'**
  String get financialContextDescription;

  /// No description provided for @financialContextHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Student, Single income, Freelancer, etc.'**
  String get financialContextHint;

  /// No description provided for @yourContext.
  ///
  /// In en, this message translates to:
  /// **'Your Context'**
  String get yourContext;

  /// No description provided for @financialContextSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Get personalized suggestions based on your spending habits and goals.'**
  String get financialContextSubTitle;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence: {confidence}%'**
  String confidence(String confidence);

  /// No description provided for @getInsights.
  ///
  /// In en, this message translates to:
  /// **'Get Insights'**
  String get getInsights;

  /// No description provided for @analyzeWithAI.
  ///
  /// In en, this message translates to:
  /// **'Analyze with AI'**
  String get analyzeWithAI;

  /// No description provided for @reportAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Report Analysis'**
  String get reportAnalysis;

  /// No description provided for @goodPoints.
  ///
  /// In en, this message translates to:
  /// **'Good Points'**
  String get goodPoints;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// No description provided for @backupDescription.
  ///
  /// In en, this message translates to:
  /// **'Save all your financial data to a file for backup and transfer'**
  String get backupDescription;

  /// No description provided for @restoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Restore your financial data from a backup file'**
  String get restoreDescription;

  /// No description provided for @backupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data backed up successfully'**
  String get backupSuccess;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully. Please restart the app to apply changes.'**
  String get restoreSuccess;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to backup data'**
  String get backupFailed;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore data'**
  String get restoreFailed;

  /// No description provided for @selectBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Select a backup file to restore'**
  String get selectBackupFile;

  /// No description provided for @confirmRestore.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restore data? Current data will be overwritten.'**
  String get confirmRestore;

  /// No description provided for @backupFileName.
  ///
  /// In en, this message translates to:
  /// **'backup_{date}.json'**
  String backupFileName(Object date);

  /// No description provided for @noBackupFile.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noBackupFile;

  /// No description provided for @budgetWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget Warning'**
  String get budgetWarningTitle;

  /// No description provided for @budgetWarning80.
  ///
  /// In en, this message translates to:
  /// **'You have used 80% of your budget for {category}.'**
  String budgetWarning80(String category);

  /// No description provided for @budgetWarning100.
  ///
  /// In en, this message translates to:
  /// **'You have used 100% of your budget for {category}!'**
  String budgetWarning100(String category);

  /// No description provided for @privacyMode.
  String get privacyMode;

  /// No description provided for @privacyModeOn.
  String get privacyModeOn;

  /// No description provided for @privacyModeOff.
  String get privacyModeOff;

  /// No description provided for @privacyModeInfoTitle.
  String get privacyModeInfoTitle;

  /// No description provided for @privacyModeInfoBody.
  String get privacyModeInfoBody;

  /// No description provided for @privacyModeGotIt.
  String get privacyModeGotIt;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ja', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ja': return AppLocalizationsJa();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

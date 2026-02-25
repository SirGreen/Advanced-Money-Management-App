// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get noTransactions => 'No transactions yet. Let\'s add one!';

  @override
  String get reports => 'Reports';

  @override
  String get manageTags => 'Manage Tags';

  @override
  String get settings => 'Settings';

  @override
  String get manageScheduled => 'Manage Scheduled';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get transactionType => 'Type';

  @override
  String get expense => 'Expense';

  @override
  String get expenseName => 'Expense Name';

  @override
  String get income => 'Income';

  @override
  String get source => 'Income Source';

  @override
  String get articleName => 'Item Name';

  @override
  String get amount => 'Amount';

  @override
  String get amountOptional => 'Amount (optional)';

  @override
  String get date => 'Date';

  @override
  String get mainTag => 'Main Tag';

  @override
  String get subTags => 'Sub-tags';

  @override
  String get save => 'Save';

  @override
  String get update => 'Update';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmDelete => 'Confirm Deletion';

  @override
  String get confirmDeleteMessage =>
      'Are you sure you want to delete this record?';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectTags => 'Select Tags';

  @override
  String get addNewTag => 'Add New Tag';

  @override
  String get noAmountSet => 'Amount Not Set';

  @override
  String get netBalance => 'Net Balance';

  @override
  String get spendingReport => 'Spending Report';

  @override
  String get totalSpending => 'Total Spending';

  @override
  String get byCategory => 'By Category';

  @override
  String get nameInput => 'Please enter a name';

  @override
  String get validNumber => 'Please enter a valid number';

  @override
  String get selectMainTag => 'Please select a main tag';

  @override
  String get selectSubTag => 'Select Sub-tags';

  @override
  String get selectTag => 'Please select a tag';

  @override
  String get end => 'Done';

  @override
  String get amountChanged => 'Amount Changed';

  @override
  String get confirmUpdateAllExpenses =>
      'Update all past transactions with this new amount?';

  @override
  String get noChange => 'No, keep past amounts';

  @override
  String get updateAll => 'Yes, update all';

  @override
  String get applyForRelatedTransaction => 'Handle Past Transactions';

  @override
  String get confirmDeleteRuleInstance =>
      'When deleting this rule, do you want to also delete all past transactions it created?';

  @override
  String get leaveUnchanged => 'No, keep past transactions';

  @override
  String get changeAll => 'Yes, delete everything';

  @override
  String get finalConfirm => 'Final Confirmation';

  @override
  String get confirmShouldDeleteInstance =>
      'Are you sure you want to delete this rule AND all of its related transactions? This action cannot be undone.';

  @override
  String get confirmDeleteOnlyRule =>
      'Are you sure you want to delete this rule? Past transactions will be kept as manual entries.';

  @override
  String get performDeleteion => 'Perform Deletion';

  @override
  String get editAutoTrans => 'Edit Scheduled Transaction';

  @override
  String get addAutoTrans => 'Add Scheduled Transaction';

  @override
  String get repeatSetting => 'Repeat Settings';

  @override
  String get repeatType => 'Repeat Type';

  @override
  String get dayOfMonth => 'Specific day of the month';

  @override
  String get endOfMonth => 'Last day of the month';

  @override
  String get daysBeforeEoM => 'N days before end of month';

  @override
  String get fixedInterval => 'Fixed Interval';

  @override
  String get msgFixedInterval => 'Group by a set number of days.';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDateOptional => 'End Date (optional)';

  @override
  String get noEndDate => 'No end date (repeats forever)';

  @override
  String get clearEndDate => 'Clear End Date';

  @override
  String get howManyDaysBefore => 'Days before';

  @override
  String get enterOneOrMoreDay => 'Please enter a number greater than 0';

  @override
  String get intervalDays => 'Interval (in days)';

  @override
  String get chooseColor => 'Choose Color';

  @override
  String get editTag => 'Edit Tag';

  @override
  String get addTag => 'Add New Tag';

  @override
  String get tagName => 'Tag Name';

  @override
  String get inputTagName => 'Please enter a tag name';

  @override
  String get color => 'Color';

  @override
  String get icon => 'Icon';

  @override
  String get selectImgFromGallery => 'Select image from gallery';

  @override
  String get msgAddTrans => 'Add Transaction';

  @override
  String get addNewRule => 'Add New Rule';

  @override
  String get noAutoRule => 'No scheduled transaction rules exist.';

  @override
  String get noTag => 'No tags exist.';

  @override
  String get deleteRule => 'Delete this rule';

  @override
  String get noDataForReport => 'Not enough data to create a report.';

  @override
  String get interval => 'Interval';

  @override
  String get days => 'Days';

  @override
  String get custom => 'Custom...';

  @override
  String get customDays => 'Custom Days (1-180)';

  @override
  String get enterNumOfDays => 'Enter number of days';

  @override
  String get confirmReset => 'Are you sure you want to reset?';

  @override
  String get confirmDeleteEverything =>
      'All expenditures, tags, and scheduled rules will be deleted. This action cannot be undone.';

  @override
  String get reset => 'Reset';

  @override
  String get transListGroup => 'Transaction List Grouping';

  @override
  String get calendarMonth => 'By Calendar Month';

  @override
  String get msgCalendarMonth => 'Group from the 1st to the end of the month.';

  @override
  String get paydayCycle => 'By Payday Cycle';

  @override
  String get msgPaydayCycle =>
      'Group from a specified start day to the day before in the next month.';

  @override
  String get cycleStartDate => 'Cycle Start Day';

  @override
  String get dangerousOperation => 'Dangerous Operations';

  @override
  String get resetAllData => 'Reset All Data';

  @override
  String get resetApp => 'Returns the app to its initial state.';

  @override
  String get tagInUse => 'Tag in Use';

  @override
  String get deleteAndContinue => 'Delete and Continue';

  @override
  String get food => 'Food';

  @override
  String get transport => 'Transport';

  @override
  String get shopping => 'Shopping';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get other => 'Other';

  @override
  String get searchTransactions => 'Search Transactions';

  @override
  String get keyword => 'Keyword';

  @override
  String get search => 'Search';

  @override
  String get all => 'All';

  @override
  String get searchResults => 'Search Results';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get paginationLimit => 'Pagination Limit';

  @override
  String get done => 'Done';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String get filterByDate => 'Filter by Date';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get enterMoreCharsForSuggestion =>
      'Enter more characters for suggestions';

  @override
  String get clearSelection => 'Clear Selection';

  @override
  String get expenseBreakdown => 'Expense Breakdown';

  @override
  String get incomeBreakdown => 'Income Breakdown';

  @override
  String get allTimeMoneyLeft => 'All-Time Balance';

  @override
  String get dateRange => 'Date Range';

  @override
  String get changeCurrency => 'Change Currency';

  @override
  String get sortBy => 'Sort by';

  @override
  String get dateNewestFirst => 'Date (Newest first)';

  @override
  String get dateOldestFirst => 'Date (Oldest first)';

  @override
  String get amountHighestFirst => 'Amount (High to low)';

  @override
  String get amountLowestFirst => 'Amount (Low to high)';

  @override
  String get nameAZ => 'Name (A-Z)';

  @override
  String get nameZA => 'Name (Z-A)';

  @override
  String get advancedSearch => 'Advanced search';

  @override
  String get minAmount => 'Min amount';

  @override
  String get maxAmount => 'Max amount';

  @override
  String get anyDate => 'Any date';

  @override
  String get tags => 'Tags';

  @override
  String get currencyConverter => 'Currency converter';

  @override
  String get amountToConvert => 'Amount to convert';

  @override
  String get swapCurrencies => 'Swap currencies';

  @override
  String get scanReceipt => 'Scan receipt';

  @override
  String get processingImage => 'Processing image';

  @override
  String get takePicture => 'Take a picture';

  @override
  String get selectFromGallery => 'Select from gallery';

  @override
  String get moreOptions => 'More options';

  @override
  String get addManually => 'Add manually';

  @override
  String get appName => 'Household Budget App';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get notesHint => 'Add notes (e.g. details, location)';

  @override
  String get receipt => 'Receipt';

  @override
  String get suggestTags => 'Suggest tags';

  @override
  String get notes => 'Notes';

  @override
  String get optionalDetails => 'Details (optional)';

  @override
  String get analyzingYourReceipt => 'Analyzing your receipt';

  @override
  String get uploadAnExistingImage => 'Upload an existing image';

  @override
  String get useYourCameraToScan => 'Use your camera to scan';

  @override
  String get letAiDoTheHeavyLifting => 'Let AI do the heavy lifting';

  @override
  String get scanYourReceipt => 'Scan your receipt';

  @override
  String get proceed => 'Proceed';

  @override
  String get exchangeRateError =>
      'Failed to retrieve exchange rate. Please try again later.';

  @override
  String get addCustomRate => 'Add Custom Exchange Rate';

  @override
  String get exchangeRate => 'Exchange Rate';

  @override
  String get add => 'Add';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get primaryCurrency => 'Primary Currency';

  @override
  String get customExchangeRates => 'Custom Exchange Rates';

  @override
  String get noTransactionsFound => 'No transactions found';

  @override
  String get exportingData => 'Exporting data...';

  @override
  String get exportCancelled => 'Export cancelled.';

  @override
  String get warning => 'Warning';

  @override
  String get importWarningMessage =>
      'This will overwrite all current data in the app. This action cannot be undone. Are you sure you want to proceed?';

  @override
  String get importSuccess => 'Data imported successfully!';

  @override
  String get importFailed => 'Import failed. Please try again.';

  @override
  String get dataManagement => 'Data management';

  @override
  String get exportData => 'Export Data';

  @override
  String get exportDataSubtitle => 'Save your data to a file.';

  @override
  String get importData => 'Import Data';

  @override
  String get importDataSubtitle => 'Restore data from a file.';

  @override
  String get allTimeBalance => 'All-time balance';

  @override
  String get searchByName => 'Search by name';

  @override
  String get amountRange => 'Amount range';

  @override
  String get change => 'Change';

  @override
  String get select => 'Select';

  @override
  String get noTagsYet => 'No tags yet';

  @override
  String get noScheduledRules => 'No scheduled rules';

  @override
  String get tapToAddFirstRule => 'Tap to add your first rule';

  @override
  String get edit => 'Edit';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get ruleName => 'Rule name';

  @override
  String get endDate => 'End date';

  @override
  String get optional => '(optional)';

  @override
  String get defaultTag => 'Default tag';

  @override
  String get tapToAddFirstTag => 'Tap to add your first tag';

  @override
  String get searchCurrency => 'Search currency';

  @override
  String get error => 'Error';

  @override
  String get convertFrom => 'Convert from';

  @override
  String get convertTo => 'Convert to';

  @override
  String get general => 'General';

  @override
  String get display => 'Display';

  @override
  String get editSavingGoal => 'Edit Saving Goal';

  @override
  String get addSavingGoal => 'Add Saving Goal';

  @override
  String get goalName => 'Goal Name';

  @override
  String get targetAmount => 'Target Amount';

  @override
  String get currentAmount => 'Current Amount';

  @override
  String get annualInterestRate => 'Annual Interest Rate';

  @override
  String get assets => 'Assets';

  @override
  String get savings => 'Savings';

  @override
  String get investments => 'Investments';

  @override
  String get featureComingSoon => 'This feature is coming soon';

  @override
  String get noSavingGoals => 'No saving goals yet';

  @override
  String get home => 'Home';

  @override
  String get addPortfolio => 'Add Portfolio';

  @override
  String get addNewPortfolio => 'Add New Portfolio';

  @override
  String get portfolioName => 'Portfolio Name';

  @override
  String get noPortfolios => 'No portfolios yet';

  @override
  String get noInvestments => 'No investments yet';

  @override
  String get addInvestment => 'Add Investment';

  @override
  String get portfolioNameHint => 'e.g., Stocks, Crypto';

  @override
  String get editInvestment => 'Edit Investment';

  @override
  String get investmentSymbol => 'Symbol';

  @override
  String get investmentSymbolHint => 'e.g., AAPL, BTC';

  @override
  String get investmentName => 'Name';

  @override
  String get investmentNameHint => 'e.g., Apple Inc.';

  @override
  String get quantity => 'Quantity';

  @override
  String get averageBuyPrice => 'Average Buy Price';

  @override
  String get inputQuantity => 'Please enter a quantity';

  @override
  String get inputAverageBuyPrice => 'Please enter an average buy price';

  @override
  String get editSavingAccount => 'Edit Saving Account';

  @override
  String get addSavingAccount => 'Add Saving Account';

  @override
  String get accountName => 'Account Name';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get openingDate => 'Opening Date';

  @override
  String get closingDate => 'Closing Date';

  @override
  String get stillActive => 'Still Active';

  @override
  String get clearClosingDate => 'Clear Closing Date';

  @override
  String get savingAccounts => 'Saving Accounts';

  @override
  String get noSavingAccounts => 'No Saving Accounts';

  @override
  String get savingGoals => 'Saving Goals';

  @override
  String get contribution => 'Contribution';

  @override
  String get contributionAdded => 'Contribution Added';

  @override
  String get addContribution => 'Add Contribution';

  @override
  String get contributionAmount => 'Contribution Amount';

  @override
  String get saveAsTransaction => 'Save as Transaction';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get pinsDoNotMatch => 'PINs do not match';

  @override
  String get setupPin => 'Set up PIN';

  @override
  String get enterNewPin => 'Enter New PIN';

  @override
  String get confirmNewPin => 'Confirm New PIN';

  @override
  String get pinLock => 'PIN Lock';

  @override
  String get pinIsEnabled => 'PIN is enabled';

  @override
  String get pinIsDisabled => 'PIN is disabled';

  @override
  String get disablePin => 'Disable PIN';

  @override
  String get disablePinMessage =>
      'Disable pin lock will wipe all data, make sure that you have a backup ready! Are you sure you want to disable the PIN lock?';

  @override
  String get disable => 'Disable';

  @override
  String get security => 'Security';

  @override
  String get authenticateToUnlock => 'Authenticate to unlock';

  @override
  String get incorrectPin => 'Incorrect PIN. Please try again.';

  @override
  String get enterPin => 'Enter Your PIN';

  @override
  String get refresh => 'Refresh';

  @override
  String get addNew => 'Add New';

  @override
  String get totalSavings => 'Total Savings';

  @override
  String get accounts => 'Accounts';

  @override
  String get goals => 'Goals';

  @override
  String get completed => 'Completed';

  @override
  String get transaction => 'Transaction';

  @override
  String get transactionsSingle => 'Transaction';

  @override
  String get timeline => 'Timeline';

  @override
  String get currency => 'Currency';

  @override
  String get resetDate => 'Reset Date';

  @override
  String get cashFlowTimeline => 'Cash Flow Timeline';

  @override
  String get createdOn => 'Created On';

  @override
  String get lastUpdated => 'Last Updated';

  @override
  String get budgets => 'Budgets';

  @override
  String get noBudgetsSet => 'No budgets set';

  @override
  String get editBudget => 'Edit Budget';

  @override
  String get addBudget => 'Add Budget';

  @override
  String get editingBudgetForThisTag => 'Editing budget for this tag';

  @override
  String get selectTagForBudget => 'Select a tag for the budget';

  @override
  String get budgetAmount => 'Budget Amount';

  @override
  String get budgetPeriod => 'Budget Period';

  @override
  String get deleteBudget => 'Delete Budget';

  @override
  String get saveBudget => 'Save Budget';

  @override
  String get restartToApply =>
      'Import successful. Please restart the app to apply changes.';

  @override
  String get restartNow => 'Restart Now';

  @override
  String get trans => 'Transactions';

  @override
  String get noTransactionsInPeriod => 'No transactions in this period';

  @override
  String get total => 'Total';

  @override
  String get clearTags => 'Clear Tags';

  @override
  String get exportFailed => 'Export failed. Please try again.';

  @override
  String get exportNoPassword => 'Export cancelled: No password provided.';

  @override
  String get importCancelled => 'Import cancelled.';

  @override
  String get importNoPassword => 'Import cancelled: No password provided.';

  @override
  String get importWrongPassword =>
      'Import failed: Wrong password or corrupted file.';

  @override
  String get backupPassword => 'Backup Password';

  @override
  String get enterPasswordForBackup => 'Enter a password for the backup';

  @override
  String get password => 'Password';

  @override
  String get passwordCannotBeEmpty => 'Password cannot be empty';

  @override
  String get ok => 'OK';

  @override
  String get selectOutputFile => 'Please select an output file:';

  @override
  String get forgotPin => 'Forgot PIN?';

  @override
  String get resetConfirmation => 'Reset App?';

  @override
  String get resetWarningMessage =>
      'This will permanently delete all your app data, including transactions, settings, and backups. This action cannot be undone. Are you sure you want to proceed?';

  @override
  String get resetAndStartOver => 'Delete & Reset';

  @override
  String get addToTotal => 'Add to Total';

  @override
  String get additionalAmount => 'Additional Amount';

  @override
  String get forgotToAddItem => 'Forgot to add an item? Add the amount here.';

  @override
  String get notificationReminderTitle => 'Reminder';

  @override
  String get notificationReminderBody =>
      'Don’t forget to add your transactions today.';

  @override
  String get reminders => 'Reminders';

  @override
  String get enableRemindersSubtitle =>
      'Enable reminders to get notified about adding transactions.';

  @override
  String get enableReminders => 'Enable Reminders';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get notificationPermissionGuide =>
      'To use reminders, allow notifications in settings.';

  @override
  String get permissionDenied => 'Notification permission denied.';

  @override
  String get notificationIncompleteTitle => 'Incomplete Transactions';

  @override
  String get clearFilter => 'Clear Filter';

  @override
  String get sortByOverbudget => 'Sort by Overbudget';

  @override
  String get sortByPercent => 'Sort by Percent';

  @override
  String get sortByAmount => 'Sort by Amount';

  @override
  String get sortByName => 'Sort by Name';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get unspecifiedTransactions => 'Unspecified Transactions';

  @override
  String get overBudget => 'Over Budget';

  @override
  String get noRecentTransactions => 'No recent transactions';

  @override
  String get viewAll => 'View All';

  @override
  String get highSpendingAlert => 'High Spending Alert';

  @override
  String get spendingHigherThanAverage => 'Spending higher than average';

  @override
  String get goalsEndingSoon => 'Goals Ending Soon';

  @override
  String get endsOn => 'Ends on';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get cannotBeNegative => 'Cannot be negative';

  @override
  String get adjustTotal => 'Adjust Total';

  @override
  String get adjustmentAmount => 'Adjustment Amount';

  @override
  String get removeFromTotal => 'Remove from Total';

  @override
  String get backupReminderTitle => 'Don\'t forget to back up!';

  @override
  String get backupReminderSubtitle =>
      'Make sure to regularly back up your data to avoid loss.';

  @override
  String get analyzing => 'Analyzing...';

  @override
  String get analysisFailed => 'Analysis failed. Please try again.';

  @override
  String get budgetAnalysis => 'Budget Analysis';

  @override
  String get noAnalysisSummary =>
      'No analysis summary available for this period.';

  @override
  String get onTrackToMeetBudget => 'On track to meet your budget';

  @override
  String get atRiskOfExceedingBudget => 'At risk of exceeding your budget';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get contextSaved => 'Context saved successfully.';

  @override
  String get errorSavingContext => 'Error saving context. Please try again.';

  @override
  String get financialContextTitle => 'Your Financial Context';

  @override
  String get financialContextDescription =>
      'Save your situation to receive more tailored recommendations.';

  @override
  String get financialContextHint =>
      'e.g. Student, Single income, Freelancer, etc.';

  @override
  String get yourContext => 'Your Context';

  @override
  String get financialContextSubTitle =>
      'Get personalized suggestions based on your spending habits and goals.';

  @override
  String get getInsights => 'Get Insights';

  @override
  String get analyzeWithAI => 'Analyze with AI';

  @override
  String get reportAnalysis => 'Report Analysis';

  @override
  String get goodPoints => 'Good Points';

  @override
  String get expenses => 'Expenses';

  @override
  String confidence(String confidence) {
    return 'Confidence: $confidence%';
  }

  @override
  String itemsNeedAttention(int count) {
    return '$count items need attention';
  }

  @override
  String notificationIncompleteBody(int incompleteCount) {
    return '$incompleteCount transactions still incomplete. Please review them.';
  }

  @override
  String exportSuccess(String path) {
    return 'Export successful: $path';
  }

  @override
  String resetsOn(String date) {
    return 'Resets on $date';
  }

  @override
  String confirmDeleteBudget(String tag) {
    return 'Are you sure you want to delete the budget for \"$tagName\"?';
  }

  @override
  String overBudgetBy(String amount) {
    return 'Over budget by $amount';
  }

  @override
  String remaining(String amount) {
    return 'Remaining: $amount';
  }

  @override
  String budgetPeriodName(String period) {
    return '$period period';
  }

  @override
  String transactions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
      zero: 'No transactions',
    );
    return '$_temp0';
  }

  @override
  String estimatedValueAt(String date) {
    return 'Est. value at $date';
  }

  @override
  String daysBeforeEndOfMonthWithValue(int value) {
    return '$value days before end of month';
  }

  @override
  String fixedIntervalWithValue(int value) {
    return 'Every $value days';
  }

  @override
  String confirmCurrencyConversion(String oldCode, String newCode) {
    return 'Convert all records from $oldCode to $newCode? This requires retrieving exchange rates.';
  }

  @override
  String languageName(String languageCode) {
    String _temp0 = intl.Intl.selectLogic(languageCode, {
      'ja': '日本語',
      'en': 'English',
      'vi': 'Tiếng Việt',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String currencyName(String currencyCode) {
    String _temp0 = intl.Intl.selectLogic(currencyCode, {
      'JPY': 'Japanese Yen (JPY)',
      'USD': 'US Dollar (USD)',
      'EUR': 'Euro (EUR)',
      'CNY': 'Chinese Yuan (CNY)',
      'RUB': 'Russian Ruble (RUB)',
      'VND': 'Vietnamese Dong (VND)',
      'AUD': 'Australian Dollar (AUD)',
      'KRW': 'South Korean Won (KRW)',
      'THB': 'Thai Baht (THB)',
      'PHP': 'Philippine Peso (PHP)',
      'MYR': 'Malaysian Ringgit (MYR)',
      'GBP': 'British Pound (GBP)',
      'CAD': 'Canadian Dollar (CAD)',
      'CHF': 'Swiss Franc (CHF)',
      'HKD': 'Hong Kong Dollar (HKD)',
      'SGD': 'Singapore Dollar (SGD)',
      'INR': 'Indian Rupee (INR)',
      'BRL': 'Brazilian Real (BRL)',
      'ZAR': 'South African Rand (ZAR)',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String daysUnit(int day) {
    return '$day days';
  }

  @override
  String warningTagInUse(String tagName) {
    return 'The tag \"$tagName\" is currently in use. If you delete it, related transactions will be moved to the \'Other\' category. Do you want to continue?';
  }

  @override
  String removeTag(String tagName) {
    return 'Are you sure you want to delete the \"$tagName\" tag?';
  }

  @override
  String currencyValue(String value) {
    return '\$$value';
  }

  @override
  String imageSaveFailed(Object error) {
    return 'Failed to save image: $error';
  }

  @override
  String dayOfMonthLabel(int day) {
    return 'Day $day';
  }
}

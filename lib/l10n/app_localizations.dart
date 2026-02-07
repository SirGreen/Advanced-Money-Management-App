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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('vi'),
  ];

  /// No description provided for @recentTransactions.
  ///
  /// In ja, this message translates to:
  /// **'最近の支出'**
  String get recentTransactions;

  /// No description provided for @noTransactions.
  ///
  /// In ja, this message translates to:
  /// **'支出がありません。追加してみましょう！'**
  String get noTransactions;

  /// No description provided for @reports.
  ///
  /// In ja, this message translates to:
  /// **'レポート'**
  String get reports;

  /// No description provided for @manageTags.
  ///
  /// In ja, this message translates to:
  /// **'タグの管理'**
  String get manageTags;

  /// No description provided for @settings.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settings;

  /// No description provided for @manageScheduled.
  ///
  /// In ja, this message translates to:
  /// **'自動支出の管理'**
  String get manageScheduled;

  /// No description provided for @addTransaction.
  ///
  /// In ja, this message translates to:
  /// **'取引を追加'**
  String get addTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In ja, this message translates to:
  /// **'取引を編集'**
  String get editTransaction;

  /// No description provided for @transactionType.
  ///
  /// In ja, this message translates to:
  /// **'タイプ'**
  String get transactionType;

  /// No description provided for @expense.
  ///
  /// In ja, this message translates to:
  /// **'支出'**
  String get expense;

  /// No description provided for @expenseName.
  ///
  /// In ja, this message translates to:
  /// **'支出名'**
  String get expenseName;

  /// No description provided for @income.
  ///
  /// In ja, this message translates to:
  /// **'収入'**
  String get income;

  /// No description provided for @source.
  ///
  /// In ja, this message translates to:
  /// **'収入源'**
  String get source;

  /// No description provided for @articleName.
  ///
  /// In ja, this message translates to:
  /// **'品名'**
  String get articleName;

  /// No description provided for @amount.
  ///
  /// In ja, this message translates to:
  /// **'金額'**
  String get amount;

  /// No description provided for @amountOptional.
  ///
  /// In ja, this message translates to:
  /// **'金額（オプション）'**
  String get amountOptional;

  /// No description provided for @date.
  ///
  /// In ja, this message translates to:
  /// **'日付'**
  String get date;

  /// No description provided for @mainTag.
  ///
  /// In ja, this message translates to:
  /// **'メインタグ'**
  String get mainTag;

  /// No description provided for @subTags.
  ///
  /// In ja, this message translates to:
  /// **'サブタグ'**
  String get subTags;

  /// No description provided for @save.
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @update.
  ///
  /// In ja, this message translates to:
  /// **'更新'**
  String get update;

  /// No description provided for @delete.
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

  /// No description provided for @confirmDelete.
  ///
  /// In ja, this message translates to:
  /// **'削除の確認'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In ja, this message translates to:
  /// **'この記録を本当に削除しますか？'**
  String get confirmDeleteMessage;

  /// No description provided for @selectDate.
  ///
  /// In ja, this message translates to:
  /// **'日付を選択'**
  String get selectDate;

  /// No description provided for @selectTags.
  ///
  /// In ja, this message translates to:
  /// **'タグを選択'**
  String get selectTags;

  /// No description provided for @addNewTag.
  ///
  /// In ja, this message translates to:
  /// **'新しいタグを追加'**
  String get addNewTag;

  /// No description provided for @noAmountSet.
  ///
  /// In ja, this message translates to:
  /// **'金額未設定'**
  String get noAmountSet;

  /// No description provided for @netBalance.
  ///
  /// In ja, this message translates to:
  /// **'収支'**
  String get netBalance;

  /// No description provided for @spendingReport.
  ///
  /// In ja, this message translates to:
  /// **'支出レポート'**
  String get spendingReport;

  /// No description provided for @totalSpending.
  ///
  /// In ja, this message translates to:
  /// **'合計支出'**
  String get totalSpending;

  /// No description provided for @byCategory.
  ///
  /// In ja, this message translates to:
  /// **'カテゴリ別'**
  String get byCategory;

  /// No description provided for @nameInput.
  ///
  /// In ja, this message translates to:
  /// **'名前を入力してください'**
  String get nameInput;

  /// No description provided for @validNumber.
  ///
  /// In ja, this message translates to:
  /// **'有効な数値を入力してください'**
  String get validNumber;

  /// No description provided for @selectMainTag.
  ///
  /// In ja, this message translates to:
  /// **'メインタグを選択してください'**
  String get selectMainTag;

  /// No description provided for @selectSubTag.
  ///
  /// In ja, this message translates to:
  /// **'サブタグを選択'**
  String get selectSubTag;

  /// No description provided for @selectTag.
  ///
  /// In ja, this message translates to:
  /// **'タグを選択してください'**
  String get selectTag;

  /// No description provided for @end.
  ///
  /// In ja, this message translates to:
  /// **'完了'**
  String get end;

  /// No description provided for @amountChanged.
  ///
  /// In ja, this message translates to:
  /// **'金額が変更されました'**
  String get amountChanged;

  /// No description provided for @confirmUpdateAllExpenses.
  ///
  /// In ja, this message translates to:
  /// **'過去に作成されたすべての支出もこの新しい金額に更新しますか？'**
  String get confirmUpdateAllExpenses;

  /// No description provided for @noChange.
  ///
  /// In ja, this message translates to:
  /// **'過去分はそのまま'**
  String get noChange;

  /// No description provided for @updateAll.
  ///
  /// In ja, this message translates to:
  /// **'すべて更新'**
  String get updateAll;

  /// No description provided for @applyForRelatedTransaction.
  ///
  /// In ja, this message translates to:
  /// **'関連する支出の扱い'**
  String get applyForRelatedTransaction;

  /// No description provided for @confirmDeleteRuleInstance.
  ///
  /// In ja, this message translates to:
  /// **'この自動支出ルールを削除する際、過去に作成された支出も一緒に削除しますか？'**
  String get confirmDeleteRuleInstance;

  /// No description provided for @leaveUnchanged.
  ///
  /// In ja, this message translates to:
  /// **'いいえ、過去分は残す'**
  String get leaveUnchanged;

  /// No description provided for @changeAll.
  ///
  /// In ja, this message translates to:
  /// **'はい、すべて削除'**
  String get changeAll;

  /// No description provided for @finalConfirm.
  ///
  /// In ja, this message translates to:
  /// **'最終確認'**
  String get finalConfirm;

  /// No description provided for @confirmShouldDeleteInstance.
  ///
  /// In ja, this message translates to:
  /// **'本当にこのルールと関連するすべての支出を削除しますか？この操作は元に戻せません。'**
  String get confirmShouldDeleteInstance;

  /// No description provided for @confirmDeleteOnlyRule.
  ///
  /// In ja, this message translates to:
  /// **'本当にこのルールを削除しますか？過去の支出は手動の支出として残ります。'**
  String get confirmDeleteOnlyRule;

  /// No description provided for @performDeleteion.
  ///
  /// In ja, this message translates to:
  /// **'削除を実行'**
  String get performDeleteion;

  /// No description provided for @editAutoTrans.
  ///
  /// In ja, this message translates to:
  /// **'自動支出の編集'**
  String get editAutoTrans;

  /// No description provided for @addAutoTrans.
  ///
  /// In ja, this message translates to:
  /// **'自動支出の追加'**
  String get addAutoTrans;

  /// No description provided for @repeatSetting.
  ///
  /// In ja, this message translates to:
  /// **'繰り返し設定'**
  String get repeatSetting;

  /// No description provided for @repeatType.
  ///
  /// In ja, this message translates to:
  /// **'繰り返しタイプ'**
  String get repeatType;

  /// No description provided for @dayOfMonth.
  ///
  /// In ja, this message translates to:
  /// **'毎月特定の日'**
  String get dayOfMonth;

  /// No description provided for @endOfMonth.
  ///
  /// In ja, this message translates to:
  /// **'毎月末日'**
  String get endOfMonth;

  /// No description provided for @daysBeforeEoM.
  ///
  /// In ja, this message translates to:
  /// **'毎月末日からN日前'**
  String get daysBeforeEoM;

  /// No description provided for @fixedInterval.
  ///
  /// In ja, this message translates to:
  /// **'固定日'**
  String get fixedInterval;

  /// No description provided for @msgFixedInterval.
  ///
  /// In ja, this message translates to:
  /// **'指定した日数ごとに区切ります。'**
  String get msgFixedInterval;

  /// No description provided for @startDate.
  ///
  /// In ja, this message translates to:
  /// **'開始日'**
  String get startDate;

  /// No description provided for @endDateOptional.
  ///
  /// In ja, this message translates to:
  /// **'終了日 (オプション)'**
  String get endDateOptional;

  /// No description provided for @noEndDate.
  ///
  /// In ja, this message translates to:
  /// **'設定しない (無期限)'**
  String get noEndDate;

  /// No description provided for @clearEndDate.
  ///
  /// In ja, this message translates to:
  /// **'終了日をクリア'**
  String get clearEndDate;

  /// No description provided for @howManyDaysBefore.
  ///
  /// In ja, this message translates to:
  /// **'何日前'**
  String get howManyDaysBefore;

  /// No description provided for @enterOneOrMoreDay.
  ///
  /// In ja, this message translates to:
  /// **'1以上の日数を入力してください'**
  String get enterOneOrMoreDay;

  /// No description provided for @intervalDays.
  ///
  /// In ja, this message translates to:
  /// **'間隔日数'**
  String get intervalDays;

  /// No description provided for @chooseColor.
  ///
  /// In ja, this message translates to:
  /// **'色を選択'**
  String get chooseColor;

  /// No description provided for @editTag.
  ///
  /// In ja, this message translates to:
  /// **'タグの編集'**
  String get editTag;

  /// No description provided for @addTag.
  ///
  /// In ja, this message translates to:
  /// **'新しいタグを追加'**
  String get addTag;

  /// No description provided for @tagName.
  ///
  /// In ja, this message translates to:
  /// **'タグ名'**
  String get tagName;

  /// No description provided for @inputTagName.
  ///
  /// In ja, this message translates to:
  /// **'タグ名を入力してください'**
  String get inputTagName;

  /// No description provided for @color.
  ///
  /// In ja, this message translates to:
  /// **'色'**
  String get color;

  /// No description provided for @icon.
  ///
  /// In ja, this message translates to:
  /// **'アイコン'**
  String get icon;

  /// No description provided for @selectImgFromGallery.
  ///
  /// In ja, this message translates to:
  /// **'ギャラリーから画像を選択'**
  String get selectImgFromGallery;

  /// No description provided for @msgAddTrans.
  ///
  /// In ja, this message translates to:
  /// **'トランザクションの追加'**
  String get msgAddTrans;

  /// No description provided for @addNewRule.
  ///
  /// In ja, this message translates to:
  /// **'新しいルールを追加'**
  String get addNewRule;

  /// No description provided for @noAutoRule.
  ///
  /// In ja, this message translates to:
  /// **'自動支出ルールがありません。'**
  String get noAutoRule;

  /// No description provided for @noTag.
  ///
  /// In ja, this message translates to:
  /// **'タグがありません。'**
  String get noTag;

  /// No description provided for @deleteRule.
  ///
  /// In ja, this message translates to:
  /// **'このルールを削除'**
  String get deleteRule;

  /// No description provided for @noDataForReport.
  ///
  /// In ja, this message translates to:
  /// **'レポートを作成するデータがありません。'**
  String get noDataForReport;

  /// No description provided for @interval.
  ///
  /// In ja, this message translates to:
  /// **'間隔'**
  String get interval;

  /// No description provided for @days.
  ///
  /// In ja, this message translates to:
  /// **'日間'**
  String get days;

  /// No description provided for @custom.
  ///
  /// In ja, this message translates to:
  /// **'カスタム...'**
  String get custom;

  /// No description provided for @customDays.
  ///
  /// In ja, this message translates to:
  /// **'カスタム日数 (1-180)'**
  String get customDays;

  /// No description provided for @enterNumOfDays.
  ///
  /// In ja, this message translates to:
  /// **'日数を入力'**
  String get enterNumOfDays;

  /// No description provided for @confirmReset.
  ///
  /// In ja, this message translates to:
  /// **'本当にリセットしますか？'**
  String get confirmReset;

  /// No description provided for @confirmDeleteEverything.
  ///
  /// In ja, this message translates to:
  /// **'すべての支出、タグ、自動支出ルールが削除されます。この操作は元に戻せません。'**
  String get confirmDeleteEverything;

  /// No description provided for @reset.
  ///
  /// In ja, this message translates to:
  /// **'リセット'**
  String get reset;

  /// No description provided for @transListGroup.
  ///
  /// In ja, this message translates to:
  /// **'支出リストのグループ化'**
  String get transListGroup;

  /// No description provided for @calendarMonth.
  ///
  /// In ja, this message translates to:
  /// **'カレンダー月別'**
  String get calendarMonth;

  /// No description provided for @msgCalendarMonth.
  ///
  /// In ja, this message translates to:
  /// **'毎月1日から末日までで区切ります。'**
  String get msgCalendarMonth;

  /// No description provided for @paydayCycle.
  ///
  /// In ja, this message translates to:
  /// **'給料日サイクル'**
  String get paydayCycle;

  /// No description provided for @msgPaydayCycle.
  ///
  /// In ja, this message translates to:
  /// **'指定した開始日から翌月の前日までで区切ります。'**
  String get msgPaydayCycle;

  /// No description provided for @cycleStartDate.
  ///
  /// In ja, this message translates to:
  /// **'サイクル開始日'**
  String get cycleStartDate;

  /// No description provided for @dangerousOperation.
  ///
  /// In ja, this message translates to:
  /// **'危険な操作'**
  String get dangerousOperation;

  /// No description provided for @resetAllData.
  ///
  /// In ja, this message translates to:
  /// **'すべてのデータをリセット'**
  String get resetAllData;

  /// No description provided for @resetApp.
  ///
  /// In ja, this message translates to:
  /// **'アプリを初期状態に戻します。'**
  String get resetApp;

  /// No description provided for @tagInUse.
  ///
  /// In ja, this message translates to:
  /// **'タグを使用中です'**
  String get tagInUse;

  /// No description provided for @deleteAndContinue.
  ///
  /// In ja, this message translates to:
  /// **'削除して続行'**
  String get deleteAndContinue;

  /// No description provided for @food.
  ///
  /// In ja, this message translates to:
  /// **'食費'**
  String get food;

  /// No description provided for @transport.
  ///
  /// In ja, this message translates to:
  /// **'交通費'**
  String get transport;

  /// No description provided for @shopping.
  ///
  /// In ja, this message translates to:
  /// **'買い物'**
  String get shopping;

  /// No description provided for @entertainment.
  ///
  /// In ja, this message translates to:
  /// **'娯楽'**
  String get entertainment;

  /// No description provided for @other.
  ///
  /// In ja, this message translates to:
  /// **'その他'**
  String get other;

  /// No description provided for @searchTransactions.
  ///
  /// In ja, this message translates to:
  /// **'支出を検索'**
  String get searchTransactions;

  /// No description provided for @keyword.
  ///
  /// In ja, this message translates to:
  /// **'キーワード'**
  String get keyword;

  /// No description provided for @search.
  ///
  /// In ja, this message translates to:
  /// **'検索'**
  String get search;

  /// No description provided for @all.
  ///
  /// In ja, this message translates to:
  /// **'全部'**
  String get all;

  /// No description provided for @searchResults.
  ///
  /// In ja, this message translates to:
  /// **'検索結果'**
  String get searchResults;

  /// No description provided for @noResultsFound.
  ///
  /// In ja, this message translates to:
  /// **'研究は見つかりませんでした'**
  String get noResultsFound;

  /// No description provided for @paginationLimit.
  ///
  /// In ja, this message translates to:
  /// **'表示件数の設定'**
  String get paginationLimit;

  /// No description provided for @done.
  ///
  /// In ja, this message translates to:
  /// **'終わり'**
  String get done;

  /// No description provided for @selectDateRange.
  ///
  /// In ja, this message translates to:
  /// **'日付の範囲を指定'**
  String get selectDateRange;

  /// No description provided for @filterByDate.
  ///
  /// In ja, this message translates to:
  /// **'日付で絞り込む'**
  String get filterByDate;

  /// No description provided for @recommendations.
  ///
  /// In ja, this message translates to:
  /// **'おすすめタグ'**
  String get recommendations;

  /// No description provided for @enterMoreCharsForSuggestion.
  ///
  /// In ja, this message translates to:
  /// **'おすすめのためにさらに文字を入力してください'**
  String get enterMoreCharsForSuggestion;

  /// No description provided for @clearSelection.
  ///
  /// In ja, this message translates to:
  /// **'選択をクリア'**
  String get clearSelection;

  /// No description provided for @expenseBreakdown.
  ///
  /// In ja, this message translates to:
  /// **'支出の内訳'**
  String get expenseBreakdown;

  /// No description provided for @incomeBreakdown.
  ///
  /// In ja, this message translates to:
  /// **'収入の内訳'**
  String get incomeBreakdown;

  /// No description provided for @allTimeMoneyLeft.
  ///
  /// In ja, this message translates to:
  /// **'総資産'**
  String get allTimeMoneyLeft;

  /// No description provided for @dateRange.
  ///
  /// In ja, this message translates to:
  /// **'期間'**
  String get dateRange;

  /// No description provided for @changeCurrency.
  ///
  /// In ja, this message translates to:
  /// **'通貨の変更'**
  String get changeCurrency;

  /// No description provided for @sortBy.
  ///
  /// In ja, this message translates to:
  /// **'並び替え'**
  String get sortBy;

  /// No description provided for @dateNewestFirst.
  ///
  /// In ja, this message translates to:
  /// **'日付（新しい順）'**
  String get dateNewestFirst;

  /// No description provided for @dateOldestFirst.
  ///
  /// In ja, this message translates to:
  /// **'日付（古い順）'**
  String get dateOldestFirst;

  /// No description provided for @amountHighestFirst.
  ///
  /// In ja, this message translates to:
  /// **'金額（高い順）'**
  String get amountHighestFirst;

  /// No description provided for @amountLowestFirst.
  ///
  /// In ja, this message translates to:
  /// **'金額（低い順）'**
  String get amountLowestFirst;

  /// No description provided for @nameAZ.
  ///
  /// In ja, this message translates to:
  /// **'名前（A-Z）'**
  String get nameAZ;

  /// No description provided for @nameZA.
  ///
  /// In ja, this message translates to:
  /// **'名前（Z-A）'**
  String get nameZA;

  /// No description provided for @advancedSearch.
  ///
  /// In ja, this message translates to:
  /// **'詳細検索'**
  String get advancedSearch;

  /// No description provided for @minAmount.
  ///
  /// In ja, this message translates to:
  /// **'最小金額'**
  String get minAmount;

  /// No description provided for @maxAmount.
  ///
  /// In ja, this message translates to:
  /// **'最大金額'**
  String get maxAmount;

  /// No description provided for @anyDate.
  ///
  /// In ja, this message translates to:
  /// **'すべての日付'**
  String get anyDate;

  /// No description provided for @tags.
  ///
  /// In ja, this message translates to:
  /// **'タグ'**
  String get tags;

  /// No description provided for @currencyConverter.
  ///
  /// In ja, this message translates to:
  /// **'通貨換算機'**
  String get currencyConverter;

  /// No description provided for @amountToConvert.
  ///
  /// In ja, this message translates to:
  /// **'換算する金額'**
  String get amountToConvert;

  /// No description provided for @swapCurrencies.
  ///
  /// In ja, this message translates to:
  /// **'通貨を入れ替える'**
  String get swapCurrencies;

  /// No description provided for @scanReceipt.
  ///
  /// In ja, this message translates to:
  /// **'レシートをスキャン'**
  String get scanReceipt;

  /// No description provided for @processingImage.
  ///
  /// In ja, this message translates to:
  /// **'画像を処理中'**
  String get processingImage;

  /// No description provided for @takePicture.
  ///
  /// In ja, this message translates to:
  /// **'写真を撮る'**
  String get takePicture;

  /// No description provided for @selectFromGallery.
  ///
  /// In ja, this message translates to:
  /// **'ギャラリーから選択'**
  String get selectFromGallery;

  /// No description provided for @moreOptions.
  ///
  /// In ja, this message translates to:
  /// **'その他のオプション'**
  String get moreOptions;

  /// No description provided for @addManually.
  ///
  /// In ja, this message translates to:
  /// **'手動で追加'**
  String get addManually;

  /// No description provided for @appName.
  ///
  /// In ja, this message translates to:
  /// **'家計簿アプリ'**
  String get appName;

  /// No description provided for @notesOptional.
  ///
  /// In ja, this message translates to:
  /// **'メモ（任意）'**
  String get notesOptional;

  /// No description provided for @notesHint.
  ///
  /// In ja, this message translates to:
  /// **'メモを追加（例：詳細、場所など）'**
  String get notesHint;

  /// No description provided for @receipt.
  ///
  /// In ja, this message translates to:
  /// **'レシート'**
  String get receipt;

  /// No description provided for @suggestTags.
  ///
  /// In ja, this message translates to:
  /// **'タグの提案'**
  String get suggestTags;

  /// No description provided for @notes.
  ///
  /// In ja, this message translates to:
  /// **'メモ'**
  String get notes;

  /// No description provided for @optionalDetails.
  ///
  /// In ja, this message translates to:
  /// **'詳細（任意）'**
  String get optionalDetails;

  /// No description provided for @analyzingYourReceipt.
  ///
  /// In ja, this message translates to:
  /// **'レシートを解析中'**
  String get analyzingYourReceipt;

  /// No description provided for @uploadAnExistingImage.
  ///
  /// In ja, this message translates to:
  /// **'既存の画像をアップロード'**
  String get uploadAnExistingImage;

  /// No description provided for @useYourCameraToScan.
  ///
  /// In ja, this message translates to:
  /// **'カメラでスキャンする'**
  String get useYourCameraToScan;

  /// No description provided for @letAiDoTheHeavyLifting.
  ///
  /// In ja, this message translates to:
  /// **'AIにお任せください'**
  String get letAiDoTheHeavyLifting;

  /// No description provided for @scanYourReceipt.
  ///
  /// In ja, this message translates to:
  /// **'レシートをスキャン'**
  String get scanYourReceipt;

  /// No description provided for @proceed.
  ///
  /// In ja, this message translates to:
  /// **'実行'**
  String get proceed;

  /// No description provided for @exchangeRateError.
  ///
  /// In ja, this message translates to:
  /// **'為替レートの取得に失敗しました。後でもう一度お試しください。'**
  String get exchangeRateError;

  /// No description provided for @addCustomRate.
  ///
  /// In ja, this message translates to:
  /// **'カスタム為替レートを追加'**
  String get addCustomRate;

  /// No description provided for @exchangeRate.
  ///
  /// In ja, this message translates to:
  /// **'為替レート'**
  String get exchangeRate;

  /// No description provided for @add.
  ///
  /// In ja, this message translates to:
  /// **'追加'**
  String get add;

  /// No description provided for @language.
  ///
  /// In ja, this message translates to:
  /// **'言語'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In ja, this message translates to:
  /// **'システムデフォルト'**
  String get systemDefault;

  /// No description provided for @primaryCurrency.
  ///
  /// In ja, this message translates to:
  /// **'基本通貨'**
  String get primaryCurrency;

  /// No description provided for @customExchangeRates.
  ///
  /// In ja, this message translates to:
  /// **'カスタム為替レート'**
  String get customExchangeRates;

  /// No description provided for @noTransactionsFound.
  ///
  /// In ja, this message translates to:
  /// **'トランザクションが見つかりませんでした'**
  String get noTransactionsFound;

  /// No description provided for @exportingData.
  ///
  /// In ja, this message translates to:
  /// **'データをエクスポート中...'**
  String get exportingData;

  /// No description provided for @exportCancelled.
  ///
  /// In ja, this message translates to:
  /// **'エクスポートがキャンセルされました。'**
  String get exportCancelled;

  /// No description provided for @warning.
  ///
  /// In ja, this message translates to:
  /// **'警告'**
  String get warning;

  /// No description provided for @importWarningMessage.
  ///
  /// In ja, this message translates to:
  /// **'この操作はアプリ内の現在のデータをすべて上書きします。この操作は元に戻せません。続行してもよろしいですか？'**
  String get importWarningMessage;

  /// No description provided for @importSuccess.
  ///
  /// In ja, this message translates to:
  /// **'データのインポートに成功しました！'**
  String get importSuccess;

  /// No description provided for @importFailed.
  ///
  /// In ja, this message translates to:
  /// **'インポートに失敗しました。もう一度お試しください。'**
  String get importFailed;

  /// No description provided for @dataManagement.
  ///
  /// In ja, this message translates to:
  /// **'データ管理'**
  String get dataManagement;

  /// No description provided for @exportData.
  ///
  /// In ja, this message translates to:
  /// **'データをエクスポート'**
  String get exportData;

  /// No description provided for @exportDataSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'データをファイルに保存します。'**
  String get exportDataSubtitle;

  /// No description provided for @importData.
  ///
  /// In ja, this message translates to:
  /// **'データをインポート'**
  String get importData;

  /// No description provided for @importDataSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'ファイルからデータを復元します。'**
  String get importDataSubtitle;

  /// No description provided for @allTimeBalance.
  ///
  /// In ja, this message translates to:
  /// **'総資産'**
  String get allTimeBalance;

  /// No description provided for @searchByName.
  ///
  /// In ja, this message translates to:
  /// **'名前で検索'**
  String get searchByName;

  /// No description provided for @amountRange.
  ///
  /// In ja, this message translates to:
  /// **'金額の範囲'**
  String get amountRange;

  /// No description provided for @change.
  ///
  /// In ja, this message translates to:
  /// **'変更'**
  String get change;

  /// No description provided for @select.
  ///
  /// In ja, this message translates to:
  /// **'選択'**
  String get select;

  /// No description provided for @noTagsYet.
  ///
  /// In ja, this message translates to:
  /// **'タグがまだありません'**
  String get noTagsYet;

  /// No description provided for @noScheduledRules.
  ///
  /// In ja, this message translates to:
  /// **'自動ルールがありません'**
  String get noScheduledRules;

  /// No description provided for @tapToAddFirstRule.
  ///
  /// In ja, this message translates to:
  /// **'タップして最初のルールを追加'**
  String get tapToAddFirstRule;

  /// No description provided for @edit.
  ///
  /// In ja, this message translates to:
  /// **'編集'**
  String get edit;

  /// No description provided for @active.
  ///
  /// In ja, this message translates to:
  /// **'有効'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In ja, this message translates to:
  /// **'無効'**
  String get inactive;

  /// No description provided for @ruleName.
  ///
  /// In ja, this message translates to:
  /// **'ルール名'**
  String get ruleName;

  /// No description provided for @endDate.
  ///
  /// In ja, this message translates to:
  /// **'終了日'**
  String get endDate;

  /// No description provided for @optional.
  ///
  /// In ja, this message translates to:
  /// **'（任意）'**
  String get optional;

  /// No description provided for @defaultTag.
  ///
  /// In ja, this message translates to:
  /// **'デフォルトタグ'**
  String get defaultTag;

  /// No description provided for @tapToAddFirstTag.
  ///
  /// In ja, this message translates to:
  /// **'タップして最初のタグを追加'**
  String get tapToAddFirstTag;

  /// No description provided for @searchCurrency.
  ///
  /// In ja, this message translates to:
  /// **'通貨を検索'**
  String get searchCurrency;

  /// No description provided for @error.
  ///
  /// In ja, this message translates to:
  /// **'エラー'**
  String get error;

  /// No description provided for @convertFrom.
  ///
  /// In ja, this message translates to:
  /// **'変換元'**
  String get convertFrom;

  /// No description provided for @convertTo.
  ///
  /// In ja, this message translates to:
  /// **'変換先'**
  String get convertTo;

  /// No description provided for @general.
  ///
  /// In ja, this message translates to:
  /// **'一般'**
  String get general;

  /// No description provided for @display.
  ///
  /// In ja, this message translates to:
  /// **'表示'**
  String get display;

  /// No description provided for @editSavingGoal.
  ///
  /// In ja, this message translates to:
  /// **'貯金目標を編集'**
  String get editSavingGoal;

  /// No description provided for @addSavingGoal.
  ///
  /// In ja, this message translates to:
  /// **'貯金目標を追加'**
  String get addSavingGoal;

  /// No description provided for @goalName.
  ///
  /// In ja, this message translates to:
  /// **'目標名'**
  String get goalName;

  /// No description provided for @targetAmount.
  ///
  /// In ja, this message translates to:
  /// **'目標金額'**
  String get targetAmount;

  /// No description provided for @currentAmount.
  ///
  /// In ja, this message translates to:
  /// **'現在の金額'**
  String get currentAmount;

  /// No description provided for @annualInterestRate.
  ///
  /// In ja, this message translates to:
  /// **'年間利率'**
  String get annualInterestRate;

  /// No description provided for @assets.
  ///
  /// In ja, this message translates to:
  /// **'資産'**
  String get assets;

  /// No description provided for @savings.
  ///
  /// In ja, this message translates to:
  /// **'貯金'**
  String get savings;

  /// No description provided for @investments.
  ///
  /// In ja, this message translates to:
  /// **'投資'**
  String get investments;

  /// No description provided for @featureComingSoon.
  ///
  /// In ja, this message translates to:
  /// **'近日公開予定の機能'**
  String get featureComingSoon;

  /// No description provided for @noSavingGoals.
  ///
  /// In ja, this message translates to:
  /// **'貯金目標がありません'**
  String get noSavingGoals;

  /// No description provided for @home.
  ///
  /// In ja, this message translates to:
  /// **'ホーム'**
  String get home;

  /// No description provided for @addPortfolio.
  ///
  /// In ja, this message translates to:
  /// **'ポートフォリオを追加'**
  String get addPortfolio;

  /// No description provided for @addNewPortfolio.
  ///
  /// In ja, this message translates to:
  /// **'新しいポートフォリオ'**
  String get addNewPortfolio;

  /// No description provided for @portfolioName.
  ///
  /// In ja, this message translates to:
  /// **'ポートフォリオ名'**
  String get portfolioName;

  /// No description provided for @noPortfolios.
  ///
  /// In ja, this message translates to:
  /// **'ポートフォリオがありません'**
  String get noPortfolios;

  /// No description provided for @noInvestments.
  ///
  /// In ja, this message translates to:
  /// **'投資がありません'**
  String get noInvestments;

  /// No description provided for @addInvestment.
  ///
  /// In ja, this message translates to:
  /// **'投資の追加'**
  String get addInvestment;

  /// No description provided for @portfolioNameHint.
  ///
  /// In ja, this message translates to:
  /// **'例: 株式、暗号資産'**
  String get portfolioNameHint;

  /// No description provided for @editInvestment.
  ///
  /// In ja, this message translates to:
  /// **'投資の編集'**
  String get editInvestment;

  /// No description provided for @investmentSymbol.
  ///
  /// In ja, this message translates to:
  /// **'シンボル'**
  String get investmentSymbol;

  /// No description provided for @investmentSymbolHint.
  ///
  /// In ja, this message translates to:
  /// **'例: AAPL, BTC'**
  String get investmentSymbolHint;

  /// No description provided for @investmentName.
  ///
  /// In ja, this message translates to:
  /// **'名前'**
  String get investmentName;

  /// No description provided for @investmentNameHint.
  ///
  /// In ja, this message translates to:
  /// **'例: Apple Inc.'**
  String get investmentNameHint;

  /// No description provided for @quantity.
  ///
  /// In ja, this message translates to:
  /// **'数量'**
  String get quantity;

  /// No description provided for @averageBuyPrice.
  ///
  /// In ja, this message translates to:
  /// **'平均購入価格'**
  String get averageBuyPrice;

  /// No description provided for @inputQuantity.
  ///
  /// In ja, this message translates to:
  /// **'数量を入力してください'**
  String get inputQuantity;

  /// No description provided for @inputAverageBuyPrice.
  ///
  /// In ja, this message translates to:
  /// **'平均購入価格を入力してください'**
  String get inputAverageBuyPrice;

  /// No description provided for @editSavingAccount.
  ///
  /// In ja, this message translates to:
  /// **'貯蓄口座を編集'**
  String get editSavingAccount;

  /// No description provided for @addSavingAccount.
  ///
  /// In ja, this message translates to:
  /// **'貯蓄口座を追加'**
  String get addSavingAccount;

  /// No description provided for @accountName.
  ///
  /// In ja, this message translates to:
  /// **'口座名'**
  String get accountName;

  /// No description provided for @currentBalance.
  ///
  /// In ja, this message translates to:
  /// **'現在の残高'**
  String get currentBalance;

  /// No description provided for @openingDate.
  ///
  /// In ja, this message translates to:
  /// **'開設日'**
  String get openingDate;

  /// No description provided for @closingDate.
  ///
  /// In ja, this message translates to:
  /// **'解約日'**
  String get closingDate;

  /// No description provided for @stillActive.
  ///
  /// In ja, this message translates to:
  /// **'まだ有効'**
  String get stillActive;

  /// No description provided for @clearClosingDate.
  ///
  /// In ja, this message translates to:
  /// **'解約日をクリア'**
  String get clearClosingDate;

  /// No description provided for @savingAccounts.
  ///
  /// In ja, this message translates to:
  /// **'貯蓄口座'**
  String get savingAccounts;

  /// No description provided for @noSavingAccounts.
  ///
  /// In ja, this message translates to:
  /// **'貯蓄口座がありません'**
  String get noSavingAccounts;

  /// No description provided for @savingGoals.
  ///
  /// In ja, this message translates to:
  /// **'貯蓄目標'**
  String get savingGoals;

  /// No description provided for @contribution.
  ///
  /// In ja, this message translates to:
  /// **'拠出'**
  String get contribution;

  /// No description provided for @contributionAdded.
  ///
  /// In ja, this message translates to:
  /// **'拠出が追加されました'**
  String get contributionAdded;

  /// No description provided for @addContribution.
  ///
  /// In ja, this message translates to:
  /// **'拠出を追加'**
  String get addContribution;

  /// No description provided for @contributionAmount.
  ///
  /// In ja, this message translates to:
  /// **'拠出額'**
  String get contributionAmount;

  /// No description provided for @saveAsTransaction.
  ///
  /// In ja, this message translates to:
  /// **'支出として保存'**
  String get saveAsTransaction;

  /// No description provided for @selectCurrency.
  ///
  /// In ja, this message translates to:
  /// **'通貨を選択'**
  String get selectCurrency;

  /// No description provided for @pinsDoNotMatch.
  ///
  /// In ja, this message translates to:
  /// **'PINが一致しません'**
  String get pinsDoNotMatch;

  /// No description provided for @setupPin.
  ///
  /// In ja, this message translates to:
  /// **'PINを設定'**
  String get setupPin;

  /// No description provided for @enterNewPin.
  ///
  /// In ja, this message translates to:
  /// **'新しいPINを入力'**
  String get enterNewPin;

  /// No description provided for @confirmNewPin.
  ///
  /// In ja, this message translates to:
  /// **'PINを確認'**
  String get confirmNewPin;

  /// No description provided for @pinLock.
  ///
  /// In ja, this message translates to:
  /// **'PINロック'**
  String get pinLock;

  /// No description provided for @pinIsEnabled.
  ///
  /// In ja, this message translates to:
  /// **'PINが有効です'**
  String get pinIsEnabled;

  /// No description provided for @pinIsDisabled.
  ///
  /// In ja, this message translates to:
  /// **'PINが無効です'**
  String get pinIsDisabled;

  /// No description provided for @disablePin.
  ///
  /// In ja, this message translates to:
  /// **'PINを無効にする'**
  String get disablePin;

  /// No description provided for @disablePinMessage.
  ///
  /// In ja, this message translates to:
  /// **'PINロックを無効にするとすべてのデータが消去されます。必ずバックアップを用意してください。PINロックを無効にしてもよろしいですか？'**
  String get disablePinMessage;

  /// No description provided for @disable.
  ///
  /// In ja, this message translates to:
  /// **'無効にする'**
  String get disable;

  /// No description provided for @security.
  ///
  /// In ja, this message translates to:
  /// **'セキュリティ'**
  String get security;

  /// No description provided for @authenticateToUnlock.
  ///
  /// In ja, this message translates to:
  /// **'ロック解除のため認証してください'**
  String get authenticateToUnlock;

  /// No description provided for @incorrectPin.
  ///
  /// In ja, this message translates to:
  /// **'PINが間違っています。もう一度お試しください。'**
  String get incorrectPin;

  /// No description provided for @enterPin.
  ///
  /// In ja, this message translates to:
  /// **'PINを入力してください'**
  String get enterPin;

  /// No description provided for @refresh.
  ///
  /// In ja, this message translates to:
  /// **'更新'**
  String get refresh;

  /// No description provided for @addNew.
  ///
  /// In ja, this message translates to:
  /// **'新規追加'**
  String get addNew;

  /// No description provided for @totalSavings.
  ///
  /// In ja, this message translates to:
  /// **'貯蓄合計'**
  String get totalSavings;

  /// No description provided for @accounts.
  ///
  /// In ja, this message translates to:
  /// **'口座'**
  String get accounts;

  /// No description provided for @goals.
  ///
  /// In ja, this message translates to:
  /// **'目標'**
  String get goals;

  /// No description provided for @completed.
  ///
  /// In ja, this message translates to:
  /// **'完了'**
  String get completed;

  /// No description provided for @transaction.
  ///
  /// In ja, this message translates to:
  /// **'取引'**
  String get transaction;

  /// No description provided for @transactionsSingle.
  ///
  /// In ja, this message translates to:
  /// **'取引一覧'**
  String get transactionsSingle;

  /// No description provided for @timeline.
  ///
  /// In ja, this message translates to:
  /// **'タイムライン'**
  String get timeline;

  /// No description provided for @currency.
  ///
  /// In ja, this message translates to:
  /// **'通貨'**
  String get currency;

  /// No description provided for @resetDate.
  ///
  /// In ja, this message translates to:
  /// **'日付をリセット'**
  String get resetDate;

  /// No description provided for @cashFlowTimeline.
  ///
  /// In ja, this message translates to:
  /// **'キャッシュフローのタイムライン'**
  String get cashFlowTimeline;

  /// No description provided for @createdOn.
  ///
  /// In ja, this message translates to:
  /// **'作成日'**
  String get createdOn;

  /// No description provided for @lastUpdated.
  ///
  /// In ja, this message translates to:
  /// **'最終更新日'**
  String get lastUpdated;

  /// No description provided for @budgets.
  ///
  /// In ja, this message translates to:
  /// **'予算'**
  String get budgets;

  /// No description provided for @noBudgetsSet.
  ///
  /// In ja, this message translates to:
  /// **'予算が設定されていません'**
  String get noBudgetsSet;

  /// No description provided for @editBudget.
  ///
  /// In ja, this message translates to:
  /// **'予算を編集'**
  String get editBudget;

  /// No description provided for @addBudget.
  ///
  /// In ja, this message translates to:
  /// **'予算を追加'**
  String get addBudget;

  /// No description provided for @editingBudgetForThisTag.
  ///
  /// In ja, this message translates to:
  /// **'このタグの予算を編集中'**
  String get editingBudgetForThisTag;

  /// No description provided for @selectTagForBudget.
  ///
  /// In ja, this message translates to:
  /// **'予算対象のタグを選択'**
  String get selectTagForBudget;

  /// No description provided for @budgetAmount.
  ///
  /// In ja, this message translates to:
  /// **'予算金額'**
  String get budgetAmount;

  /// No description provided for @budgetPeriod.
  ///
  /// In ja, this message translates to:
  /// **'予算期間'**
  String get budgetPeriod;

  /// No description provided for @deleteBudget.
  ///
  /// In ja, this message translates to:
  /// **'予算を削除'**
  String get deleteBudget;

  /// No description provided for @saveBudget.
  ///
  /// In ja, this message translates to:
  /// **'予算を保存'**
  String get saveBudget;

  /// No description provided for @restartToApply.
  ///
  /// In ja, this message translates to:
  /// **'インポートが成功しました。変更を適用するにはアプリを再起動してください。'**
  String get restartToApply;

  /// No description provided for @restartNow.
  ///
  /// In ja, this message translates to:
  /// **'今すぐ再起動'**
  String get restartNow;

  /// No description provided for @trans.
  ///
  /// In ja, this message translates to:
  /// **'取引'**
  String get trans;

  /// No description provided for @noTransactionsInPeriod.
  ///
  /// In ja, this message translates to:
  /// **'この期間には取引がありません'**
  String get noTransactionsInPeriod;

  /// No description provided for @total.
  ///
  /// In ja, this message translates to:
  /// **'合計'**
  String get total;

  /// No description provided for @clearTags.
  ///
  /// In ja, this message translates to:
  /// **'タグをクリア'**
  String get clearTags;

  /// No description provided for @exportFailed.
  ///
  /// In ja, this message translates to:
  /// **'エクスポートに失敗しました。もう一度お試しください。'**
  String get exportFailed;

  /// No description provided for @exportNoPassword.
  ///
  /// In ja, this message translates to:
  /// **'エクスポートがキャンセルされました: パスワードが入力されていません。'**
  String get exportNoPassword;

  /// No description provided for @importCancelled.
  ///
  /// In ja, this message translates to:
  /// **'インポートがキャンセルされました。'**
  String get importCancelled;

  /// No description provided for @importNoPassword.
  ///
  /// In ja, this message translates to:
  /// **'インポートがキャンセルされました: パスワードが入力されていません。'**
  String get importNoPassword;

  /// No description provided for @importWrongPassword.
  ///
  /// In ja, this message translates to:
  /// **'インポートに失敗しました: パスワードが間違っているかファイルが破損しています。'**
  String get importWrongPassword;

  /// No description provided for @backupPassword.
  ///
  /// In ja, this message translates to:
  /// **'バックアップパスワード'**
  String get backupPassword;

  /// No description provided for @enterPasswordForBackup.
  ///
  /// In ja, this message translates to:
  /// **'バックアップ用のパスワードを入力してください'**
  String get enterPasswordForBackup;

  /// No description provided for @password.
  ///
  /// In ja, this message translates to:
  /// **'パスワード'**
  String get password;

  /// No description provided for @passwordCannotBeEmpty.
  ///
  /// In ja, this message translates to:
  /// **'パスワードは空にできません'**
  String get passwordCannotBeEmpty;

  /// No description provided for @ok.
  ///
  /// In ja, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @selectOutputFile.
  ///
  /// In ja, this message translates to:
  /// **'出力ファイルを選択してください:'**
  String get selectOutputFile;

  /// No description provided for @forgotPin.
  ///
  /// In ja, this message translates to:
  /// **'PINをお忘れですか？'**
  String get forgotPin;

  /// No description provided for @resetConfirmation.
  ///
  /// In ja, this message translates to:
  /// **'アプリをリセットしますか？'**
  String get resetConfirmation;

  /// No description provided for @resetWarningMessage.
  ///
  /// In ja, this message translates to:
  /// **'この操作はすべてのアプリデータ（取引、設定、バックアップを含む）を完全に削除します。この操作は元に戻せません。続行してもよろしいですか？'**
  String get resetWarningMessage;

  /// No description provided for @resetAndStartOver.
  ///
  /// In ja, this message translates to:
  /// **'削除してリセット'**
  String get resetAndStartOver;

  /// No description provided for @addToTotal.
  ///
  /// In ja, this message translates to:
  /// **'合計に追加'**
  String get addToTotal;

  /// No description provided for @additionalAmount.
  ///
  /// In ja, this message translates to:
  /// **'追加金額'**
  String get additionalAmount;

  /// No description provided for @forgotToAddItem.
  ///
  /// In ja, this message translates to:
  /// **'項目を追加し忘れましたか？ここで金額を追加できます。'**
  String get forgotToAddItem;

  /// No description provided for @notificationReminderTitle.
  ///
  /// In ja, this message translates to:
  /// **'リマインダー通知'**
  String get notificationReminderTitle;

  /// No description provided for @notificationReminderBody.
  ///
  /// In ja, this message translates to:
  /// **'取引の記録を忘れずに行いましょう。'**
  String get notificationReminderBody;

  /// No description provided for @reminders.
  ///
  /// In ja, this message translates to:
  /// **'リマインダー'**
  String get reminders;

  /// No description provided for @enableRemindersSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'リマインダーを有効にすると、取引の追加を忘れないように通知が届きます。'**
  String get enableRemindersSubtitle;

  /// No description provided for @enableReminders.
  ///
  /// In ja, this message translates to:
  /// **'リマインダーを有効にする'**
  String get enableReminders;

  /// No description provided for @openSettings.
  ///
  /// In ja, this message translates to:
  /// **'設定を開く'**
  String get openSettings;

  /// No description provided for @notificationPermissionGuide.
  ///
  /// In ja, this message translates to:
  /// **'リマインダーを使用するには通知の許可が必要です。設定で許可を有効にしてください。'**
  String get notificationPermissionGuide;

  /// No description provided for @permissionDenied.
  ///
  /// In ja, this message translates to:
  /// **'通知の許可が拒否されました'**
  String get permissionDenied;

  /// No description provided for @notificationIncompleteTitle.
  ///
  /// In ja, this message translates to:
  /// **'未完了の通知'**
  String get notificationIncompleteTitle;

  /// No description provided for @clearFilter.
  ///
  /// In ja, this message translates to:
  /// **'フィルターをクリア'**
  String get clearFilter;

  /// No description provided for @sortByOverbudget.
  ///
  /// In ja, this message translates to:
  /// **'予算超過順に並び替え'**
  String get sortByOverbudget;

  /// No description provided for @sortByPercent.
  ///
  /// In ja, this message translates to:
  /// **'割合順に並び替え'**
  String get sortByPercent;

  /// No description provided for @sortByAmount.
  ///
  /// In ja, this message translates to:
  /// **'金額順に並び替え'**
  String get sortByAmount;

  /// No description provided for @sortByName.
  ///
  /// In ja, this message translates to:
  /// **'名前順に並び替え'**
  String get sortByName;

  /// No description provided for @dashboard.
  ///
  /// In ja, this message translates to:
  /// **'ホーム'**
  String get dashboard;

  /// No description provided for @unspecifiedTransactions.
  ///
  /// In ja, this message translates to:
  /// **'未分類の取引'**
  String get unspecifiedTransactions;

  /// No description provided for @overBudget.
  ///
  /// In ja, this message translates to:
  /// **'予算オーバー'**
  String get overBudget;

  /// No description provided for @noRecentTransactions.
  ///
  /// In ja, this message translates to:
  /// **'最近の取引はありません'**
  String get noRecentTransactions;

  /// No description provided for @viewAll.
  ///
  /// In ja, this message translates to:
  /// **'すべて表示'**
  String get viewAll;

  /// No description provided for @highSpendingAlert.
  ///
  /// In ja, this message translates to:
  /// **'高額支出の警告'**
  String get highSpendingAlert;

  /// No description provided for @spendingHigherThanAverage.
  ///
  /// In ja, this message translates to:
  /// **'平均より支出が多いです'**
  String get spendingHigherThanAverage;

  /// No description provided for @goalsEndingSoon.
  ///
  /// In ja, this message translates to:
  /// **'まもなく終了する目標'**
  String get goalsEndingSoon;

  /// No description provided for @endsOn.
  ///
  /// In ja, this message translates to:
  /// **'終了日'**
  String get endsOn;

  /// No description provided for @upcoming.
  ///
  /// In ja, this message translates to:
  /// **'今後の予定'**
  String get upcoming;

  /// No description provided for @cannotBeNegative.
  ///
  /// In ja, this message translates to:
  /// **'負の値にはできません'**
  String get cannotBeNegative;

  /// No description provided for @adjustTotal.
  ///
  /// In ja, this message translates to:
  /// **'合計を調整'**
  String get adjustTotal;

  /// No description provided for @adjustmentAmount.
  ///
  /// In ja, this message translates to:
  /// **'調整額'**
  String get adjustmentAmount;

  /// No description provided for @removeFromTotal.
  ///
  /// In ja, this message translates to:
  /// **'合計から削除'**
  String get removeFromTotal;

  /// No description provided for @backupReminderTitle.
  ///
  /// In ja, this message translates to:
  /// **'バックアップのリマインダー'**
  String get backupReminderTitle;

  /// No description provided for @backupReminderSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'データを安全に保つため、定期的にバックアップを作成してください'**
  String get backupReminderSubtitle;

  /// No description provided for @analyzing.
  ///
  /// In ja, this message translates to:
  /// **'分析中...'**
  String get analyzing;

  /// No description provided for @analysisFailed.
  ///
  /// In ja, this message translates to:
  /// **'分析に失敗しました。もう一度お試しください。'**
  String get analysisFailed;

  /// No description provided for @budgetAnalysis.
  ///
  /// In ja, this message translates to:
  /// **'予算分析'**
  String get budgetAnalysis;

  /// No description provided for @noAnalysisSummary.
  ///
  /// In ja, this message translates to:
  /// **'分析の要約はありません。'**
  String get noAnalysisSummary;

  /// No description provided for @onTrackToMeetBudget.
  ///
  /// In ja, this message translates to:
  /// **'予算達成の見込みあり'**
  String get onTrackToMeetBudget;

  /// No description provided for @atRiskOfExceedingBudget.
  ///
  /// In ja, this message translates to:
  /// **'予算超過のリスクあり'**
  String get atRiskOfExceedingBudget;

  /// No description provided for @suggestions.
  ///
  /// In ja, this message translates to:
  /// **'提案'**
  String get suggestions;

  /// No description provided for @contextSaved.
  ///
  /// In ja, this message translates to:
  /// **'コンテキストが保存されました。'**
  String get contextSaved;

  /// No description provided for @errorSavingContext.
  ///
  /// In ja, this message translates to:
  /// **'コンテキストの保存中にエラーが発生しました。'**
  String get errorSavingContext;

  /// No description provided for @financialContextTitle.
  ///
  /// In ja, this message translates to:
  /// **'財務コンテキスト'**
  String get financialContextTitle;

  /// No description provided for @financialContextDescription.
  ///
  /// In ja, this message translates to:
  /// **'あなたの収入、支出、目標などに基づいて、より良い提案を受け取るための情報です。'**
  String get financialContextDescription;

  /// No description provided for @financialContextHint.
  ///
  /// In ja, this message translates to:
  /// **'例: 学生で月収は5万円、節約中です。'**
  String get financialContextHint;

  /// No description provided for @yourContext.
  ///
  /// In ja, this message translates to:
  /// **'あなたのコンテキスト'**
  String get yourContext;

  /// No description provided for @financialContextSubTitle.
  ///
  /// In ja, this message translates to:
  /// **'支出の傾向や目標に基づいて、パーソナライズされた提案を受け取りましょう。'**
  String get financialContextSubTitle;

  /// ユーザーに洞察を提供するボタンまたはアクションのラベル
  ///
  /// In ja, this message translates to:
  /// **'インサイトを取得'**
  String get getInsights;

  /// AIを使って分析を行うためのラベルまたはボタン
  ///
  /// In ja, this message translates to:
  /// **'AIで分析'**
  String get analyzeWithAI;

  /// AIや統計などのレポート分析セクションのタイトル
  ///
  /// In ja, this message translates to:
  /// **'分析レポート'**
  String get reportAnalysis;

  /// ユーザーの財務行動で良かった点を表すラベル
  ///
  /// In ja, this message translates to:
  /// **'良い点'**
  String get goodPoints;

  /// 費用や支出を表す一般的なラベル
  ///
  /// In ja, this message translates to:
  /// **'支出'**
  String get expenses;

  /// No description provided for @confidence.
  ///
  /// In ja, this message translates to:
  /// **'信頼度: {confidence}%'**
  String confidence(String confidence);

  /// No description provided for @itemsNeedAttention.
  ///
  /// In ja, this message translates to:
  /// **'{count} 件の項目に注意が必要です'**
  String itemsNeedAttention(int count);

  /// No description provided for @notificationIncompleteBody.
  ///
  /// In ja, this message translates to:
  /// **'{incompleteCount} 件の未完了の取引があります。確認してください。'**
  String notificationIncompleteBody(int incompleteCount);

  /// The path of successful export
  ///
  /// In ja, this message translates to:
  /// **'データを正常にエクスポートしました: {path}'**
  String exportSuccess(String path);

  /// 予算のリセット日を示すメッセージ
  ///
  /// In ja, this message translates to:
  /// **'{date} にリセット'**
  String resetsOn(String date);

  /// 予算削除の確認メッセージ
  ///
  /// In ja, this message translates to:
  /// **'「{tag}」タグの予算を本当に削除しますか？'**
  String confirmDeleteBudget(String tag);

  /// 予算超過の金額
  ///
  /// In ja, this message translates to:
  /// **'予算超過：{amount}'**
  String overBudgetBy(String amount);

  /// 予算の残額
  ///
  /// In ja, this message translates to:
  /// **'残り：{amount}'**
  String remaining(String amount);

  /// 予算期間の名前
  ///
  /// In ja, this message translates to:
  /// **'{period} の期間'**
  String budgetPeriodName(String period);

  /// 取引の件数
  ///
  /// In ja, this message translates to:
  /// **'{count, plural, =0{取引なし} =1{1 件の取引} other{{count} 件の取引}}'**
  String transactions(int count);

  /// No description provided for @estimatedValueAt.
  ///
  /// In ja, this message translates to:
  /// **'{date} 時点の予測値'**
  String estimatedValueAt(String date);

  /// No description provided for @daysBeforeEndOfMonthWithValue.
  ///
  /// In ja, this message translates to:
  /// **'月末の{value}日前'**
  String daysBeforeEndOfMonthWithValue(int value);

  /// No description provided for @fixedIntervalWithValue.
  ///
  /// In ja, this message translates to:
  /// **'{value}日ごと'**
  String fixedIntervalWithValue(int value);

  /// No description provided for @confirmCurrencyConversion.
  ///
  /// In ja, this message translates to:
  /// **'すべての記録を {oldCode} から {newCode} に換算しますか？この操作には為替レートの取得が必要です。'**
  String confirmCurrencyConversion(String oldCode, String newCode);

  /// The name of a language.
  ///
  /// In ja, this message translates to:
  /// **'{languageCode, select, ja{日本語} en{English} vi{Tiếng Việt} other{Unknown}}'**
  String languageName(String languageCode);

  /// The name of a currency.
  ///
  /// In ja, this message translates to:
  /// **'{currencyCode, select, JPY{日本円 (JPY)} USD{米ドル (USD)} EUR{ユーロ (EUR)} CNY{中国人民元 (CNY)} RUB{ロシア・ルーブル (RUB)} VND{ベトナム・ドン (VND)} AUD{オーストラリア・ドル (AUD)} KRW{韓国ウォン (KRW)} THB{タイ・バーツ (THB)} PHP{フィリピン・ペソ (PHP)} MYR{マレーシア・リンギット (MYR)} GBP{英ポンド (GBP)} CAD{カナダ・ドル (CAD)} CHF{スイス・フラン (CHF)} HKD{香港ドル (HKD)} SGD{シンガポール・ドル (SGD)} INR{インド・ルピー (INR)} BRL{ブラジル・レアル (BRL)} ZAR{南アフリカ・ランド (ZAR)} other{Unknown}}'**
  String currencyName(String currencyCode);

  /// No description provided for @daysUnit.
  ///
  /// In ja, this message translates to:
  /// **'{day} 日間'**
  String daysUnit(int day);

  /// Warning message that a tag is being used for expense
  ///
  /// In ja, this message translates to:
  /// **'「{tagName}」タグは支出に使用されています。削除した場合、関連する支出は「その他」カテゴリに移動します。続行しますか？'**
  String warningTagInUse(String tagName);

  /// Confirm delete tag
  ///
  /// In ja, this message translates to:
  /// **'「{tagName}」タグを本当に削除しますか？'**
  String removeTag(String tagName);

  /// Formats a number as Japanese Yen currency.
  ///
  /// In ja, this message translates to:
  /// **'¥{value}'**
  String currencyValue(String value);

  /// Error message shown when saving an image fails.
  ///
  /// In ja, this message translates to:
  /// **'画像の保存に失敗しました: {error}'**
  String imageSaveFailed(Object error);

  /// Label for a specific day of the month.
  ///
  /// In ja, this message translates to:
  /// **'{day} 日'**
  String dayOfMonthLabel(int day);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

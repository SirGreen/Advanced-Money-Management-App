// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get recentTransactions => '最近の支出';

  @override
  String get noTransactions => '支出がありません。追加してみましょう！';

  @override
  String get reports => 'レポート';

  @override
  String get manageTags => 'タグの管理';

  @override
  String get settings => '設定';

  @override
  String get manageScheduled => '自動支出の管理';

  @override
  String get addTransaction => '取引を追加';

  @override
  String get editTransaction => '取引を編集';

  @override
  String get transactionType => 'タイプ';

  @override
  String get expense => '支出';

  @override
  String get expenseName => '支出名';

  @override
  String get income => '収入';

  @override
  String get source => '収入源';

  @override
  String get articleName => '品名';

  @override
  String get amount => '金額';

  @override
  String get amountOptional => '金額（オプション）';

  @override
  String get date => '日付';

  @override
  String get mainTag => 'メインタグ';

  @override
  String get subTags => 'サブタグ';

  @override
  String get save => '保存';

  @override
  String get update => '更新';

  @override
  String get delete => '削除';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirmDelete => '削除の確認';

  @override
  String get confirmDeleteMessage => 'この記録を本当に削除しますか？';

  @override
  String get selectDate => '日付を選択';

  @override
  String get selectTags => 'タグを選択';

  @override
  String get addNewTag => '新しいタグを追加';

  @override
  String get noAmountSet => '金額未設定';

  @override
  String get netBalance => '収支';

  @override
  String get spendingReport => '支出レポート';

  @override
  String get totalSpending => '合計支出';

  @override
  String get byCategory => 'カテゴリ別';

  @override
  String get nameInput => '名前を入力してください';

  @override
  String get validNumber => '有効な数値を入力してください';

  @override
  String get selectMainTag => 'メインタグを選択してください';

  @override
  String get selectSubTag => 'サブタグを選択';

  @override
  String get selectTag => 'タグを選択してください';

  @override
  String get end => '完了';

  @override
  String get amountChanged => '金額が変更されました';

  @override
  String get confirmUpdateAllExpenses => '過去に作成されたすべての支出もこの新しい金額に更新しますか？';

  @override
  String get noChange => '過去分はそのまま';

  @override
  String get updateAll => 'すべて更新';

  @override
  String get applyForRelatedTransaction => '関連する支出の扱い';

  @override
  String get confirmDeleteRuleInstance =>
      'この自動支出ルールを削除する際、過去に作成された支出も一緒に削除しますか？';

  @override
  String get leaveUnchanged => 'いいえ、過去分は残す';

  @override
  String get changeAll => 'はい、すべて削除';

  @override
  String get finalConfirm => '最終確認';

  @override
  String get confirmShouldDeleteInstance =>
      '本当にこのルールと関連するすべての支出を削除しますか？この操作は元に戻せません。';

  @override
  String get confirmDeleteOnlyRule => '本当にこのルールを削除しますか？過去の支出は手動の支出として残ります。';

  @override
  String get performDeleteion => '削除を実行';

  @override
  String get editAutoTrans => '自動支出の編集';

  @override
  String get addAutoTrans => '自動支出の追加';

  @override
  String get repeatSetting => '繰り返し設定';

  @override
  String get repeatType => '繰り返しタイプ';

  @override
  String get dayOfMonth => '毎月特定の日';

  @override
  String get endOfMonth => '毎月末日';

  @override
  String get daysBeforeEoM => '毎月末日からN日前';

  @override
  String get fixedInterval => '固定日';

  @override
  String get msgFixedInterval => '指定した日数ごとに区切ります。';

  @override
  String get startDate => '開始日';

  @override
  String get endDateOptional => '終了日 (オプション)';

  @override
  String get noEndDate => '設定しない (無期限)';

  @override
  String get clearEndDate => '終了日をクリア';

  @override
  String get howManyDaysBefore => '何日前';

  @override
  String get enterOneOrMoreDay => '1以上の日数を入力してください';

  @override
  String get intervalDays => '間隔日数';

  @override
  String get chooseColor => '色を選択';

  @override
  String get editTag => 'タグの編集';

  @override
  String get addTag => '新しいタグを追加';

  @override
  String get tagName => 'タグ名';

  @override
  String get inputTagName => 'タグ名を入力してください';

  @override
  String get color => '色';

  @override
  String get icon => 'アイコン';

  @override
  String get selectImgFromGallery => 'ギャラリーから画像を選択';

  @override
  String get msgAddTrans => 'トランザクションの追加';

  @override
  String get addNewRule => '新しいルールを追加';

  @override
  String get noAutoRule => '自動支出ルールがありません。';

  @override
  String get noTag => 'タグがありません。';

  @override
  String get deleteRule => 'このルールを削除';

  @override
  String get noDataForReport => 'レポートを作成するデータがありません。';

  @override
  String get interval => '間隔';

  @override
  String get days => '日間';

  @override
  String get custom => 'カスタム...';

  @override
  String get customDays => 'カスタム日数 (1-180)';

  @override
  String get enterNumOfDays => '日数を入力';

  @override
  String get confirmReset => '本当にリセットしますか？';

  @override
  String get confirmDeleteEverything =>
      'すべての支出、タグ、自動支出ルールが削除されます。この操作は元に戻せません。';

  @override
  String get reset => 'リセット';

  @override
  String get transListGroup => '支出リストのグループ化';

  @override
  String get calendarMonth => 'カレンダー月別';

  @override
  String get msgCalendarMonth => '毎月1日から末日までで区切ります。';

  @override
  String get paydayCycle => '給料日サイクル';

  @override
  String get msgPaydayCycle => '指定した開始日から翌月の前日までで区切ります。';

  @override
  String get cycleStartDate => 'サイクル開始日';

  @override
  String get dangerousOperation => '危険な操作';

  @override
  String get resetAllData => 'すべてのデータをリセット';

  @override
  String get resetApp => 'アプリを初期状態に戻します。';

  @override
  String get tagInUse => 'タグを使用中です';

  @override
  String get deleteAndContinue => '削除して続行';

  @override
  String get food => '食費';

  @override
  String get transport => '交通費';

  @override
  String get shopping => '買い物';

  @override
  String get entertainment => '娯楽';

  @override
  String get other => 'その他';

  @override
  String get searchTransactions => '支出を検索';

  @override
  String get keyword => 'キーワード';

  @override
  String get search => '検索';

  @override
  String get all => '全部';

  @override
  String get searchResults => '検索結果';

  @override
  String get noResultsFound => '研究は見つかりませんでした';

  @override
  String get paginationLimit => '表示件数の設定';

  @override
  String get done => '終わり';

  @override
  String get selectDateRange => '日付の範囲を指定';

  @override
  String get filterByDate => '日付で絞り込む';

  @override
  String get recommendations => 'おすすめタグ';

  @override
  String get enterMoreCharsForSuggestion => 'おすすめのためにさらに文字を入力してください';

  @override
  String get clearSelection => '選択をクリア';

  @override
  String get expenseBreakdown => '支出の内訳';

  @override
  String get incomeBreakdown => '収入の内訳';

  @override
  String get allTimeMoneyLeft => '総資産';

  @override
  String get dateRange => '期間';

  @override
  String get changeCurrency => '通貨の変更';

  @override
  String get sortBy => '並び替え';

  @override
  String get dateNewestFirst => '日付（新しい順）';

  @override
  String get dateOldestFirst => '日付（古い順）';

  @override
  String get amountHighestFirst => '金額（高い順）';

  @override
  String get amountLowestFirst => '金額（低い順）';

  @override
  String get nameAZ => '名前（A-Z）';

  @override
  String get nameZA => '名前（Z-A）';

  @override
  String get advancedSearch => '詳細検索';

  @override
  String get minAmount => '最小金額';

  @override
  String get maxAmount => '最大金額';

  @override
  String get anyDate => 'すべての日付';

  @override
  String get tags => 'タグ';

  @override
  String get currencyConverter => '通貨換算機';

  @override
  String get amountToConvert => '換算する金額';

  @override
  String get swapCurrencies => '通貨を入れ替える';

  @override
  String get scanReceipt => 'レシートをスキャン';

  @override
  String get processingImage => '画像を処理中';

  @override
  String get takePicture => '写真を撮る';

  @override
  String get selectFromGallery => 'ギャラリーから選択';

  @override
  String get moreOptions => 'その他のオプション';

  @override
  String get addManually => '手動で追加';

  @override
  String get appName => '家計簿アプリ';

  @override
  String get notesOptional => 'メモ（任意）';

  @override
  String get notesHint => 'メモを追加（例：詳細、場所など）';

  @override
  String get receipt => 'レシート';

  @override
  String get suggestTags => 'タグの提案';

  @override
  String get notes => 'メモ';

  @override
  String get optionalDetails => '詳細（任意）';

  @override
  String get analyzingYourReceipt => 'レシートを解析中';

  @override
  String get uploadAnExistingImage => '既存の画像をアップロード';

  @override
  String get useYourCameraToScan => 'カメラでスキャンする';

  @override
  String get letAiDoTheHeavyLifting => 'AIにお任せください';

  @override
  String get scanYourReceipt => 'レシートをスキャン';

  @override
  String get proceed => '実行';

  @override
  String get exchangeRateError => '為替レートの取得に失敗しました。後でもう一度お試しください。';

  @override
  String get addCustomRate => 'カスタム為替レートを追加';

  @override
  String get exchangeRate => '為替レート';

  @override
  String get add => '追加';

  @override
  String get language => '言語';

  @override
  String get systemDefault => 'システムデフォルト';

  @override
  String get primaryCurrency => '基本通貨';

  @override
  String get customExchangeRates => 'カスタム為替レート';

  @override
  String get noTransactionsFound => 'トランザクションが見つかりませんでした';

  @override
  String get exportingData => 'データをエクスポート中...';

  @override
  String get exportCancelled => 'エクスポートがキャンセルされました。';

  @override
  String get warning => '警告';

  @override
  String get importWarningMessage =>
      'この操作はアプリ内の現在のデータをすべて上書きします。この操作は元に戻せません。続行してもよろしいですか？';

  @override
  String get importSuccess => 'データのインポートに成功しました！';

  @override
  String get importFailed => 'インポートに失敗しました。もう一度お試しください。';

  @override
  String get dataManagement => 'データ管理';

  @override
  String get exportData => 'データをエクスポート';

  @override
  String get exportDataSubtitle => 'データをファイルに保存します。';

  @override
  String get importData => 'データをインポート';

  @override
  String get importDataSubtitle => 'ファイルからデータを復元します。';

  @override
  String get allTimeBalance => '総資産';

  @override
  String get searchByName => '名前で検索';

  @override
  String get amountRange => '金額の範囲';

  @override
  String get change => '変更';

  @override
  String get select => '選択';

  @override
  String get noTagsYet => 'タグがまだありません';

  @override
  String get noScheduledRules => '自動ルールがありません';

  @override
  String get tapToAddFirstRule => 'タップして最初のルールを追加';

  @override
  String get edit => '編集';

  @override
  String get active => '有効';

  @override
  String get inactive => '無効';

  @override
  String get ruleName => 'ルール名';

  @override
  String get endDate => '終了日';

  @override
  String get optional => '（任意）';

  @override
  String get defaultTag => 'デフォルトタグ';

  @override
  String get tapToAddFirstTag => 'タップして最初のタグを追加';

  @override
  String get searchCurrency => '通貨を検索';

  @override
  String get error => 'エラー';

  @override
  String get convertFrom => '変換元';

  @override
  String get convertTo => '変換先';

  @override
  String get general => '一般';

  @override
  String get display => '表示';

  @override
  String get editSavingGoal => '貯金目標を編集';

  @override
  String get addSavingGoal => '貯金目標を追加';

  @override
  String get goalName => '目標名';

  @override
  String get targetAmount => '目標金額';

  @override
  String get currentAmount => '現在の金額';

  @override
  String get annualInterestRate => '年間利率';

  @override
  String get assets => '資産';

  @override
  String get savings => '貯金';

  @override
  String get investments => '投資';

  @override
  String get featureComingSoon => '近日公開予定の機能';

  @override
  String get noSavingGoals => '貯金目標がありません';

  @override
  String get home => 'ホーム';

  @override
  String get addPortfolio => 'ポートフォリオを追加';

  @override
  String get addNewPortfolio => '新しいポートフォリオ';

  @override
  String get portfolioName => 'ポートフォリオ名';

  @override
  String get noPortfolios => 'ポートフォリオがありません';

  @override
  String get noInvestments => '投資がありません';

  @override
  String get addInvestment => '投資の追加';

  @override
  String get portfolioNameHint => '例: 株式、暗号資産';

  @override
  String get editInvestment => '投資の編集';

  @override
  String get investmentSymbol => 'シンボル';

  @override
  String get investmentSymbolHint => '例: AAPL, BTC';

  @override
  String get investmentName => '名前';

  @override
  String get investmentNameHint => '例: Apple Inc.';

  @override
  String get quantity => '数量';

  @override
  String get averageBuyPrice => '平均購入価格';

  @override
  String get inputQuantity => '数量を入力してください';

  @override
  String get inputAverageBuyPrice => '平均購入価格を入力してください';

  @override
  String get editSavingAccount => '貯蓄口座を編集';

  @override
  String get addSavingAccount => '貯蓄口座を追加';

  @override
  String get accountName => '口座名';

  @override
  String get currentBalance => '現在の残高';

  @override
  String get openingDate => '開設日';

  @override
  String get closingDate => '解約日';

  @override
  String get stillActive => 'まだ有効';

  @override
  String get clearClosingDate => '解約日をクリア';

  @override
  String get savingAccounts => '貯蓄口座';

  @override
  String get noSavingAccounts => '貯蓄口座がありません';

  @override
  String get savingGoals => '貯蓄目標';

  @override
  String get contribution => '拠出';

  @override
  String get contributionAdded => '拠出が追加されました';

  @override
  String get addContribution => '拠出を追加';

  @override
  String get contributionAmount => '拠出額';

  @override
  String get saveAsTransaction => '支出として保存';

  @override
  String get selectCurrency => '通貨を選択';

  @override
  String get pinsDoNotMatch => 'PINが一致しません';

  @override
  String get setupPin => 'PINを設定';

  @override
  String get enterNewPin => '新しいPINを入力';

  @override
  String get confirmNewPin => 'PINを確認';

  @override
  String get pinLock => 'PINロック';

  @override
  String get pinIsEnabled => 'PINが有効です';

  @override
  String get pinIsDisabled => 'PINが無効です';

  @override
  String get disablePin => 'PINを無効にする';

  @override
  String get disablePinMessage =>
      'PINロックを無効にするとすべてのデータが消去されます。必ずバックアップを用意してください。PINロックを無効にしてもよろしいですか？';

  @override
  String get disable => '無効にする';

  @override
  String get security => 'セキュリティ';

  @override
  String get authenticateToUnlock => 'ロック解除のため認証してください';

  @override
  String get incorrectPin => 'PINが間違っています。もう一度お試しください。';

  @override
  String get enterPin => 'PINを入力してください';

  @override
  String get refresh => '更新';

  @override
  String get addNew => '新規追加';

  @override
  String get totalSavings => '貯蓄合計';

  @override
  String get accounts => '口座';

  @override
  String get goals => '目標';

  @override
  String get completed => '完了';

  @override
  String get transaction => '取引';

  @override
  String get transactionsSingle => '取引一覧';

  @override
  String get timeline => 'タイムライン';

  @override
  String get currency => '通貨';

  @override
  String get resetDate => '日付をリセット';

  @override
  String get cashFlowTimeline => 'キャッシュフローのタイムライン';

  @override
  String get createdOn => '作成日';

  @override
  String get lastUpdated => '最終更新日';

  @override
  String get budgets => '予算';

  @override
  String get noBudgetsSet => '予算が設定されていません';

  @override
  String get editBudget => '予算を編集';

  @override
  String get addBudget => '予算を追加';

  @override
  String get editingBudgetForThisTag => 'このタグの予算を編集中';

  @override
  String get selectTagForBudget => '予算対象のタグを選択';

  @override
  String get budgetAmount => '予算金額';

  @override
  String get budgetPeriod => '予算期間';

  @override
  String get deleteBudget => '予算を削除';

  @override
  String get saveBudget => '予算を保存';

  @override
  String get restartToApply => 'インポートが成功しました。変更を適用するにはアプリを再起動してください。';

  @override
  String get restartNow => '今すぐ再起動';

  @override
  String get trans => '取引';

  @override
  String get noTransactionsInPeriod => 'この期間には取引がありません';

  @override
  String get total => '合計';

  @override
  String get clearTags => 'タグをクリア';

  @override
  String get exportFailed => 'エクスポートに失敗しました。もう一度お試しください。';

  @override
  String get exportNoPassword => 'エクスポートがキャンセルされました: パスワードが入力されていません。';

  @override
  String get importCancelled => 'インポートがキャンセルされました。';

  @override
  String get importNoPassword => 'インポートがキャンセルされました: パスワードが入力されていません。';

  @override
  String get importWrongPassword => 'インポートに失敗しました: パスワードが間違っているかファイルが破損しています。';

  @override
  String get backupPassword => 'バックアップパスワード';

  @override
  String get enterPasswordForBackup => 'バックアップ用のパスワードを入力してください';

  @override
  String get password => 'パスワード';

  @override
  String get passwordCannotBeEmpty => 'パスワードは空にできません';

  @override
  String get ok => 'OK';

  @override
  String get selectOutputFile => '出力ファイルを選択してください:';

  @override
  String get forgotPin => 'PINをお忘れですか？';

  @override
  String get resetConfirmation => 'アプリをリセットしますか？';

  @override
  String get resetWarningMessage =>
      'この操作はすべてのアプリデータ（取引、設定、バックアップを含む）を完全に削除します。この操作は元に戻せません。続行してもよろしいですか？';

  @override
  String get resetAndStartOver => '削除してリセット';

  @override
  String get addToTotal => '合計に追加';

  @override
  String get additionalAmount => '追加金額';

  @override
  String get forgotToAddItem => '項目を追加し忘れましたか？ここで金額を追加できます。';

  @override
  String get notificationReminderTitle => 'リマインダー通知';

  @override
  String get notificationReminderBody => '取引の記録を忘れずに行いましょう。';

  @override
  String get reminders => 'リマインダー';

  @override
  String get enableRemindersSubtitle => 'リマインダーを有効にすると、取引の追加を忘れないように通知が届きます。';

  @override
  String get enableReminders => 'リマインダーを有効にする';

  @override
  String get openSettings => '設定を開く';

  @override
  String get notificationPermissionGuide =>
      'リマインダーを使用するには通知の許可が必要です。設定で許可を有効にしてください。';

  @override
  String get permissionDenied => '通知の許可が拒否されました';

  @override
  String get notificationIncompleteTitle => '未完了の通知';

  @override
  String get clearFilter => 'フィルターをクリア';

  @override
  String get sortByOverbudget => '予算超過順に並び替え';

  @override
  String get sortByPercent => '割合順に並び替え';

  @override
  String get sortByAmount => '金額順に並び替え';

  @override
  String get sortByName => '名前順に並び替え';

  @override
  String get dashboard => 'ホーム';

  @override
  String get unspecifiedTransactions => '未分類の取引';

  @override
  String get overBudget => '予算オーバー';

  @override
  String get noRecentTransactions => '最近の取引はありません';

  @override
  String get viewAll => 'すべて表示';

  @override
  String get highSpendingAlert => '高額支出の警告';

  @override
  String get spendingHigherThanAverage => '平均より支出が多いです';

  @override
  String get goalsEndingSoon => 'まもなく終了する目標';

  @override
  String get endsOn => '終了日';

  @override
  String get upcoming => '今後の予定';

  @override
  String get cannotBeNegative => '負の値にはできません';

  @override
  String get adjustTotal => '合計を調整';

  @override
  String get adjustmentAmount => '調整額';

  @override
  String get removeFromTotal => '合計から削除';

  @override
  String get backupReminderTitle => 'バックアップのリマインダー';

  @override
  String get backupReminderSubtitle => 'データを安全に保つため、定期的にバックアップを作成してください';

  @override
  String get analyzing => '分析中...';

  @override
  String get analysisFailed => '分析に失敗しました。もう一度お試しください。';

  @override
  String get budgetAnalysis => '予算分析';

  @override
  String get noAnalysisSummary => '分析の要約はありません。';

  @override
  String get onTrackToMeetBudget => '予算達成の見込みあり';

  @override
  String get atRiskOfExceedingBudget => '予算超過のリスクあり';

  @override
  String get suggestions => '提案';

  @override
  String get contextSaved => 'コンテキストが保存されました。';

  @override
  String get errorSavingContext => 'コンテキストの保存中にエラーが発生しました。';

  @override
  String get financialContextTitle => '財務コンテキスト';

  @override
  String get financialContextDescription =>
      'あなたの収入、支出、目標などに基づいて、より良い提案を受け取るための情報です。';

  @override
  String get financialContextHint => '例: 学生で月収は5万円、節約中です。';

  @override
  String get yourContext => 'あなたのコンテキスト';

  @override
  String get financialContextSubTitle => '支出の傾向や目標に基づいて、パーソナライズされた提案を受け取りましょう。';

  @override
  String get getInsights => 'インサイトを取得';

  @override
  String get analyzeWithAI => 'AIで分析';

  @override
  String get reportAnalysis => '分析レポート';

  @override
  String get goodPoints => '良い点';

  @override
  String get expenses => '支出';

  @override
  String confidence(String confidence) {
    return '信頼度: $confidence%';
  }

  @override
  String itemsNeedAttention(int count) {
    return '$count 件の項目に注意が必要です';
  }

  @override
  String notificationIncompleteBody(int incompleteCount) {
    return '$incompleteCount 件の未完了の取引があります。確認してください。';
  }

  @override
  String exportSuccess(String path) {
    return 'データを正常にエクスポートしました: $path';
  }

  @override
  String resetsOn(String date) {
    return '$date にリセット';
  }

  @override
  String confirmDeleteBudget(String tag) {
    return '「$tag」タグの予算を本当に削除しますか？';
  }

  @override
  String overBudgetBy(String amount) {
    return '予算超過：$amount';
  }

  @override
  String remaining(String amount) {
    return '残り：$amount';
  }

  @override
  String budgetPeriodName(String period) {
    return '$period の期間';
  }

  @override
  String transactions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件の取引',
      one: '1 件の取引',
      zero: '取引なし',
    );
    return '$_temp0';
  }

  @override
  String estimatedValueAt(String date) {
    return '$date 時点の予測値';
  }

  @override
  String daysBeforeEndOfMonthWithValue(int value) {
    return '月末の$value日前';
  }

  @override
  String fixedIntervalWithValue(int value) {
    return '$value日ごと';
  }

  @override
  String confirmCurrencyConversion(String oldCode, String newCode) {
    return 'すべての記録を $oldCode から $newCode に換算しますか？この操作には為替レートの取得が必要です。';
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
      'JPY': '日本円 (JPY)',
      'USD': '米ドル (USD)',
      'EUR': 'ユーロ (EUR)',
      'CNY': '中国人民元 (CNY)',
      'RUB': 'ロシア・ルーブル (RUB)',
      'VND': 'ベトナム・ドン (VND)',
      'AUD': 'オーストラリア・ドル (AUD)',
      'KRW': '韓国ウォン (KRW)',
      'THB': 'タイ・バーツ (THB)',
      'PHP': 'フィリピン・ペソ (PHP)',
      'MYR': 'マレーシア・リンギット (MYR)',
      'GBP': '英ポンド (GBP)',
      'CAD': 'カナダ・ドル (CAD)',
      'CHF': 'スイス・フラン (CHF)',
      'HKD': '香港ドル (HKD)',
      'SGD': 'シンガポール・ドル (SGD)',
      'INR': 'インド・ルピー (INR)',
      'BRL': 'ブラジル・レアル (BRL)',
      'ZAR': '南アフリカ・ランド (ZAR)',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String daysUnit(int day) {
    return '$day 日間';
  }

  @override
  String warningTagInUse(String tagName) {
    return '「$tagName」タグは支出に使用されています。削除した場合、関連する支出は「その他」カテゴリに移動します。続行しますか？';
  }

  @override
  String removeTag(String tagName) {
    return '「$tagName」タグを本当に削除しますか？';
  }

  @override
  String currencyValue(String value) {
    return '¥$value';
  }

  @override
  String imageSaveFailed(Object error) {
    return '画像の保存に失敗しました: $error';
  }

  @override
  String dayOfMonthLabel(int day) {
    return '$day 日';
  }
}

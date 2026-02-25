import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class LLMService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  // static const String _apiUrlGem15Fl =
  //     "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$_apiKey";

  Future<Map<String, dynamic>?> recommendTags(
    String articleName,
    List<String> existingTagNames,
  ) async {
    if (_apiKey.isEmpty) {
      debugPrint(
        "ERROR: GEMINI_API_KEY is not set. Please run the app with --dart-define.",
      );
      return null;
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.4,
        maxOutputTokens: 100,
        responseMimeType: 'application/json',
      ),
    );

    final prompt =
        """
    Analyze the transaction name and suggest tags.
    1. From the provided list of existing tags, pick the most relevant ones.
    2. Suggest ONE new, specific, and concise tag name if none of the existing ones are a perfect fit.

    Return a single, valid JSON object with two keys: "existing_tags" (a list of strings from the provided list) and "new_tag_suggestion" (a single string, or null).

    Existing Tags: ${existingTagNames.join(', ')}
    Transaction Name: "$articleName"
    """;

    try {
      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text != null) {
        final decodedJson = jsonDecode(response.text!);
        return decodedJson as Map<String, dynamic>;
      } else {
        debugPrint("LLM API Error: Response text is null.");
        return null;
      }
    } catch (e) {
      debugPrint("LLM Service Exception: $e");
      if (e is GenerativeAIException) {
        debugPrint("Gemini API Error details: ${e.message}");
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> processReceiptImage(
    File imageFile,
    List<String> existingTagNames,
  ) async {
    if (_apiKey.isEmpty) {
      debugPrint("ERROR: GEMINI_API_KEY is not set.");
      return null;
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );

    final bytes = await imageFile.readAsBytes();

    final prompt =
        """
    Analyze the attached receipt image and extract the following information.
    1.  **store_name**: The name of the store or merchant.
    2.  **total_amount**: The final total amount paid (look for keywords like 合計). This should be a number without currency symbols or commas.
    3.  **recommended_tags**: From the provided list of existing tags, suggest the most relevant ones based on the store name and items.
    4. **memo**: What did the user buy and how many of each item, write it as a continuous list of items (each item is accompanied with a dash and the number of items, if not confident in the number of items, do not add the dash and the number), seperated by commas

    Return the result ONLY as a single, valid JSON object with the keys "store_name", "total_amount", "recommended_tags", "memo".

    Existing Tags: ${existingTagNames.join(', ')}
    """;

    try {
      final response = await model.generateContent([
        Content.text(prompt),
        Content.data('image/jpeg', bytes),
      ]);

      if (response.text != null) {
        final decodedJson = jsonDecode(response.text!);
        return decodedJson as Map<String, dynamic>;
      } else {
        debugPrint("LLM API Error: Response text is null.");
        debugPrint(
          "Debugging info: ${response.promptFeedback?.blockReason}",
        );
        return null;
      }
    } catch (e) {
      debugPrint("LLM Service Exception: $e");
      if (e is GenerativeAIException) {
        debugPrint("Gemini API Error details: ${e.message}");
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> analyzeBudget({
    required List<Map<String, dynamic>> transactions,
    required Map<String, dynamic> budgetDetails,
    required String currentDate,
    required String budgetEndDate,
    required String? userContext,
  }) async {
    if (_apiKey.isEmpty) {
      debugPrint("ERROR: GEMINI_API_KEY is not set.");
      return null;
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-pro',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );

    final prompt =
        """
    You are a financial analyst AI. Your task is to analyze a user's transaction history against a specific budget and determine if they can meet it.

    **Context:**
    - **Current Date:** $currentDate
    - **Budget End Date:** $budgetEndDate
    - **Budget Details:** ${jsonEncode(budgetDetails)}
    - **Transaction History:** ${jsonEncode(transactions)}
    - **User's Financial Context:** ${userContext ?? "No additional context provided by the user."}

    **Instructions:**
    1.  Analyze the user's spending and income patterns within the provided transactions.
    2.  Consider the total budget amount, the amount already spent, the remaining time in the budget period, and any recurring income or expenses evident in the data.
    3.  Based on this analysis, predict whether the user is likely to meet their budget.
    4.  Provide a confidence score for your prediction (0.0 to 1.0).
    5.  Offer a concise summary explaining your reasoning.
    6.  Give actionable suggestions to help the user manage their budget better.

    **Output Format:**
    Return ONLY a single, valid JSON object with the following keys:
    - `can_meet_budget`: (boolean) Your prediction.
    - `confidence_score`: (double) Your confidence in the prediction.
    - `analysis_summary`: (String) A brief explanation of your reasoning.
    - `suggestions`: (List<String>) A list of helpful tips.
    """;

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      if (response.text != null) {
        final decodedJson = jsonDecode(response.text!);
        return decodedJson as Map<String, dynamic>;
      } else {
        debugPrint("LLM API Error: Response text is null.");
        debugPrint(
          "Debugging info: ${response.promptFeedback?.blockReason}",
        );
        return null;
      }
    } catch (e) {
      debugPrint("LLM Service Exception: $e");
      if (e is GenerativeAIException) {
        debugPrint("Gemini API Error details: ${e.message}");
      }
      return null;
    }
  }
  

  Future<Map<String, dynamic>?> analyzeFinancialReport({
  required String dateRangeStart,
  required String dateRangeEnd,
  required String? userContext,
  required double totalIncome,
  required double totalExpenses,
  required List<Map<String, dynamic>> incomeBreakdown,
  required List<Map<String, dynamic>> expenseBreakdown,
    required List<Map<String, dynamic>> transactionList,
}) async {
  if (_apiKey.isEmpty) {
    debugPrint("ERROR: GEMINI_API_KEY is not set.");
    return null;
  }

  final model = GenerativeModel(
    model: 'gemini-2.5-pro',
    apiKey: _apiKey,
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
    ),
  );

  final prompt = """
    You are an expert financial analyst AI. Your task is to provide a comprehensive analysis of a user's financial report for a specific period.

    **User's Provided Context:**
    ${userContext ?? "No personal context provided."}

    **Financial Report Summary:**
    - **Report Period:** $dateRangeStart to $dateRangeEnd
    - **Total Income:** $totalIncome
    - **Total Expenses:** $totalExpenses
    - **Income Sources Breakdown:** ${jsonEncode(incomeBreakdown)}
    - **Expense Categories Breakdown:** ${jsonEncode(expenseBreakdown)}

    **Detailed Transaction List for the Period:**
    ${jsonEncode(transactionList)}

    **Your Task:**
    Analyze all the provided data, including the detailed transaction list, keeping the user's personal context in mind. Provide clear, concise, and actionable insights. Use the transaction list to identify specific spending habits, large purchases, or recurring charges that contribute to the category totals.

    **Output Format:**
    Return ONLY a single, valid JSON object with the following keys:
    - `overall_summary`: (String) A brief, high-level summary of the user's financial health during this period. Mention specific examples from the transaction list if relevant (e.g., "You had a positive cash flow... however, a significant portion of your 'Electronics' spending was on a single purchase of 'New Laptop'").
    - `positive_observations`: (List<String>) A list of 2-3 key positive points or good habits observed from the data.
    - `actionable_suggestions`: (List<String>) A list of 2-3 specific, actionable suggestions for improvement. These should be detailed and based on the transaction data. For example, "Your 'Subscriptions' category includes 'Gym Membership' and 'Streaming Service'. Consider if both are providing full value."
    """;

  try {
    final response = await model.generateContent([Content.text(prompt)]);
    if (response.text != null) {
      final decodedJson = jsonDecode(response.text!);
      return decodedJson as Map<String, dynamic>;
    } else {
      debugPrint("LLM API Error: Response text is null.");
      return null;
    }
  } catch (e) {
    debugPrint("LLM Service Exception: $e");
    if (e is GenerativeAIException) {
      debugPrint("Gemini API Error details: ${e.message}");
    }
    return null;
  }
}
}

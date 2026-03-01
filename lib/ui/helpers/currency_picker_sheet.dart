import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

const Map<String, String> currencyFlags = {
  'JPY': '🇯🇵',
  'USD': '🇺🇸',
  'EUR': '🇪🇺',
  'CNY': '🇨🇳',
  'RUB': '🇷🇺',
  'VND': '🇻🇳',
  'AUD': '🇦🇺',
  'KRW': '🇰🇷',
  'THB': '🇹🇭',
  'PHP': '🇵🇭',
  'MYR': '🇲🇾',
  'GBP': '🇬🇧',
  'CAD': '🇨🇦',
  'CHF': '🇨🇭',
  'HKD': '🇭🇰',
  'SGD': '🇸🇬',
  'INR': '🇮🇳',
  'BRL': '🇧🇷',
  'ZAR': '🇿🇦',
};

class CurrencyPickerSheet extends StatefulWidget {
  final List<String> supportedCurrencies;
  final String title;
  const CurrencyPickerSheet({
    super.key,
    required this.supportedCurrencies,
    required this.title,
  });

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  String _searchText = '';
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredCurrencies = widget.supportedCurrencies.where((code) {
      final codeMatch = code.toLowerCase().contains(_searchText.toLowerCase());
      final nameMatch = l10n
          .currencyName(code)
          .toLowerCase()
          .contains(_searchText.toLowerCase());
      return codeMatch || nameMatch;
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) => setState(() => _searchText = value),
                decoration: InputDecoration(
                  labelText: l10n.searchCurrency,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: filteredCurrencies.length,
                  itemBuilder: (context, index) {
                    final code = filteredCurrencies[index];
                    return ListTile(
                      leading: Text(
                        currencyFlags[code] ?? '🏳️',
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(l10n.currencyName(code)),
                      subtitle: Text(code),
                      onTap: () => Navigator.of(context).pop(code),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

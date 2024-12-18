import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency_model.dart';

class CurrencyNotifier extends StateNotifier<Currency> {
  CurrencyNotifier() : super(Currency.currencies.first) {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final currencyCode = prefs.getString('currency') ?? 'USD';
    state = Currency.fromCode(currencyCode);
  }

  Future<void> setCurrency(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', code);
    state = Currency.fromCode(code);
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, Currency>((ref) {
  return CurrencyNotifier();
}); 
import '../models/currency_model.dart';

String getCurrencySymbol(String currencyCode) {
  return Currency.fromCode(currencyCode).symbol;
} 
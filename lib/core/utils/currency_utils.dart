String getCurrencySymbol(String currencyCode) {
  return Currency.fromCode(currencyCode).symbol;
} 
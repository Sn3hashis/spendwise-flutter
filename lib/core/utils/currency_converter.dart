double convertCurrency(double amount, String fromCurrency, String toCurrency) {
  // Add conversion rates (you can expand this map with more currencies)
  final rates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'JPY': 150.14,
    'INR': 83.12,
  };

  if (fromCurrency == toCurrency) return amount;
  if (!rates.containsKey(fromCurrency) || !rates.containsKey(toCurrency)) return amount;
  
  // Convert to USD first (as base currency)
  final amountInUSD = amount / rates[fromCurrency]!;
  
  // Convert from USD to target currency
  return amountInUSD * rates[toCurrency]!;
} 
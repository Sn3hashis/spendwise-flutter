String getCurrencySymbol(String currencyCode) {
  return switch (currencyCode) {
    'USD' => '\$',
    'EUR' => '€',
    'GBP' => '£',
    'JPY' => '¥',
    'INR' => '₹',
    'CNY' => '¥',
    'AUD' => 'A\$',
    'CAD' => 'C\$',
    'CHF' => 'Fr',
    'HKD' => 'HK\$',
    'NZD' => 'NZ\$',
    'SEK' => 'kr',
    'KRW' => '₩',
    'SGD' => 'S\$',
    'NOK' => 'kr',
    'MXN' => '\$',
    'BRL' => 'R\$',
    'RUB' => '₽',
    'ZAR' => 'R',
    'TRY' => '₺',
    _ => currencyCode,
  };
} 
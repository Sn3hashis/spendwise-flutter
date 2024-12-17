enum TransactionType { income, expense, transfer }
enum SortBy { highest, lowest, newest, oldest }

class TransactionFilter {
  final Set<TransactionType> types;
  final SortBy sortBy;
  final Set<String> categories;

  const TransactionFilter({
    this.types = const {},
    this.sortBy = SortBy.newest,
    this.categories = const {},
  });

  TransactionFilter copyWith({
    Set<TransactionType>? types,
    SortBy? sortBy,
    Set<String>? categories,
  }) {
    return TransactionFilter(
      types: types ?? this.types,
      sortBy: sortBy ?? this.sortBy,
      categories: categories ?? this.categories,
    );
  }
} 
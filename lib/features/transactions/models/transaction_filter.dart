import 'transaction_type.dart';

enum SortBy {
  newest,
  oldest,
  highest,
  lowest,
}

class TransactionFilter {
  final Set<TransactionType> types;
  final Set<String> categories;
  final SortBy sortBy;

  const TransactionFilter({
    this.types = const {},
    this.categories = const {},
    this.sortBy = SortBy.newest,
  });

  TransactionFilter copyWith({
    Set<TransactionType>? types,
    Set<String>? categories,
    SortBy? sortBy,
  }) {
    return TransactionFilter(
      types: types ?? this.types,
      categories: categories ?? this.categories,
      sortBy: sortBy ?? this.sortBy,
    );
  }
} 
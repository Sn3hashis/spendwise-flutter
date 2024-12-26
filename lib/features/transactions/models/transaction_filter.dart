import 'transaction_model.dart';

enum SortBy {
  newest,
  oldest,
  highest,
  lowest,
}

enum TransactionFilterType {
  all,
  income,
  expense,
  transfer,
  bankExpense,
}

class TransactionFilter {
  final Set<TransactionType> types;
  final Set<String> categories;
  final SortBy sortBy;
  final bool isBankTransaction;

  const TransactionFilter({
    this.types = const {},
    this.categories = const {},
    this.sortBy = SortBy.newest,
    this.isBankTransaction = false,
  });

  TransactionFilter copyWith({
    Set<TransactionType>? types,
    Set<String>? categories,
    SortBy? sortBy,
    bool? isBankTransaction,
  }) {
    return TransactionFilter(
      types: types ?? Set<TransactionType>.from(this.types),
      categories: categories ?? Set<String>.from(this.categories),
      sortBy: sortBy ?? this.sortBy,
      isBankTransaction: isBankTransaction ?? this.isBankTransaction,
    );
  }

  factory TransactionFilter.fromJson(Map<String, dynamic> json) {
    return TransactionFilter(
      types: (json['types'] as List?)
              ?.map((e) => TransactionType.values.firstWhere(
                    (type) => type.toString() == e,
                    orElse: () => TransactionType.expense,
                  ))
              .toSet() ??
          Set<TransactionType>(),
      categories: (json['categories'] as List?)?.cast<String>().toSet() ??
          Set<String>(),
      sortBy: SortBy.values.firstWhere(
        (sort) => sort.toString() == json['sortBy'],
        orElse: () => SortBy.newest,
      ),
      isBankTransaction: json['isBankTransaction'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'types': types.map((e) => e.toString()).toList(),
        'categories': categories.toList(),
        'sortBy': sortBy.toString(),
        'isBankTransaction': isBankTransaction,
      };
}

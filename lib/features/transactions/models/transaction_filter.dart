import 'transaction_model.dart';

enum SortBy {
  newest,
  oldest,
  highest,
  lowest,
}

class TransactionFilter {
  final List<TransactionType> types;
  final List<String> categories;
  final SortBy sortBy;

  static const List<TransactionType> _emptyTypes = [];
  static const List<String> _emptyCategories = [];

  const TransactionFilter({
    this.types = _emptyTypes,
    this.categories = _emptyCategories,
    this.sortBy = SortBy.newest,
  });

  TransactionFilter copyWith({
    List<TransactionType>? types,
    List<String>? categories,
    SortBy? sortBy,
  }) {
    return TransactionFilter(
      types: types ?? List<TransactionType>.from(this.types),
      categories: categories ?? List<String>.from(this.categories),
      sortBy: sortBy ?? this.sortBy,
    );
  }

  factory TransactionFilter.fromJson(Map<String, dynamic> json) {
    return TransactionFilter(
      types: (json['types'] as List?)?.map((e) => 
        TransactionType.values.firstWhere(
          (type) => type.toString() == e,
          orElse: () => TransactionType.expense,
        )
      ).toList() ?? _emptyTypes,
      categories: (json['categories'] as List?)?.cast<String>().toList() ?? _emptyCategories,
      sortBy: SortBy.values.firstWhere(
        (sort) => sort.toString() == json['sortBy'],
        orElse: () => SortBy.newest,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'types': types.map((e) => e.toString()).toList(),
    'categories': categories,
    'sortBy': sortBy.toString(),
  };
} 
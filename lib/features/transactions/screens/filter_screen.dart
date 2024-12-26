import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/haptic_service.dart';
import '../models/transaction_filter.dart';
import '../models/transaction_model.dart';
import '../widgets/category_selection_sheet.dart';
import '../../categories/providers/categories_provider.dart';
import '../../categories/models/category_model.dart';
import '../providers/transaction_filter_provider.dart';
import 'package:flutter/material.dart' show Material, Colors;

class FilterScreen extends ConsumerStatefulWidget {
  final TransactionFilter initialFilter;
  final Function(TransactionFilter) onApply;

  const FilterScreen({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  @override
  ConsumerState<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends ConsumerState<FilterScreen> {
  late TransactionFilter _filter;
  late List<Category> _selectedCategories;
  late Set<TransactionType> _selectedTypes;
  late TransactionFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    _tempFilter = widget.initialFilter;
    _selectedCategories = ref
        .read(categoriesProvider)
        .where((c) => _filter.categories.contains(c.id))
        .toList();
    _selectedTypes = Set<TransactionType>.from(_filter.types);
  }

  void _resetFilter() {
    // Create a fresh filter
    final resetFilter = const TransactionFilter(
      isBankTransaction: false,
      types: {},
      categories: {},
      sortBy: SortBy.newest,
    );

    // Update everything synchronously before popping
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Update provider and notify listeners
      ref.read(transactionFilterProvider.notifier).resetFilter();

      // Update parent widget
      widget.onApply(resetFilter);

      // Update local state
      if (mounted) {
        setState(() {
          _selectedCategories = [];
          _selectedTypes = {};
          _tempFilter = resetFilter;
        });

        // Pop the screen
        Navigator.pop(context);
      }
    });
  }

  void _handleCancel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Update parent widget
      widget.onApply(widget.initialFilter);

      // Update local state
      if (mounted) {
        setState(() {
          _tempFilter = widget.initialFilter;
          _selectedCategories = ref
              .read(categoriesProvider)
              .where((c) => widget.initialFilter.categories.contains(c.id))
              .toList();
          _selectedTypes =
              Set<TransactionType>.from(widget.initialFilter.types);
        });

        // Pop the screen
        Navigator.pop(context);
      }
    });
  }

  void _handleApply() {
    if (mounted) {
      widget.onApply(_tempFilter);
      Navigator.of(context).pop();
    }
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDarkMode = ref.watch(themeProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? CupertinoColors.systemPurple.withOpacity(0.2)
              : isDarkMode
                  ? AppTheme.cardDark
                  : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? CupertinoColors.systemPurple
                : isDarkMode
                    ? const Color(0xFF2C2C2E)
                    : const Color(0xFFE5E5EA),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? CupertinoColors.systemPurple
                : isDarkMode
                    ? CupertinoColors.white
                    : CupertinoColors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(bool isDarkMode) {
    final categories = ref.watch(categoriesProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
        ),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(16),
        onPressed: () async {
          await HapticService.lightImpact(ref);
          final result = await showCupertinoModalPopup<Category>(
            context: context,
            builder: (context) => CategorySelectionSheet(
              categories: categories,
              selectedCategory: _selectedCategories.isNotEmpty
                  ? _selectedCategories.first
                  : null,
              onCategorySelected: (category) {
                setState(() {
                  if (_selectedCategories.contains(category)) {
                    _selectedCategories.remove(category);
                  } else {
                    _selectedCategories.add(category);
                  }
                  _tempFilter = _tempFilter.copyWith(
                    categories: _selectedCategories.map((c) => c.id).toSet(),
                  );
                });
              },
            ),
          );
          if (result != null) {
            setState(() {
              if (_selectedCategories.contains(result)) {
                _selectedCategories.remove(result);
              } else {
                _selectedCategories.add(result);
              }
              _tempFilter = _tempFilter.copyWith(
                categories: _selectedCategories.map((c) => c.id).toSet(),
              );
            });
          }
        },
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 17,
                    color: isDarkMode
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                  ),
                ),
                if (_selectedCategories.isNotEmpty)
                  Text(
                    _selectedCategories.map((c) => c.name).join(', '),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey2,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Icon(
              CupertinoIcons.chevron_right,
              color: isDarkMode
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey2,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TransactionType.values.map((type) {
            final isSelected = _selectedTypes.contains(type);
            return _buildFilterChip(
              label: type.name.substring(0, 1).toUpperCase() +
                  type.name.substring(1),
              isSelected: isSelected,
              onTap: () async {
                await HapticService.lightImpact(ref);
                setState(() {
                  if (isSelected) {
                    _selectedTypes.remove(type);
                  } else {
                    _selectedTypes.add(type);
                  }
                  _tempFilter = _tempFilter.copyWith(types: _selectedTypes);
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildFilterChip(
          label: 'Bank Transactions',
          isSelected: _tempFilter.isBankTransaction,
          onTap: () async {
            await HapticService.lightImpact(ref);
            setState(() {
              _tempFilter = _tempFilter.copyWith(
                isBankTransaction: !_tempFilter.isBankTransaction,
              );
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final backgroundColor =
        isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight;

    return WillPopScope(
      onWillPop: () async {
        _handleCancel();
        return false;
      },
      child: CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        HapticService.lightImpact(ref);
                        _handleCancel();
                      },
                      child: const Text('Cancel'),
                    ),
                    const Text(
                      'Filter Transaction',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          color: CupertinoColors.systemPurple,
                        ),
                      ),
                      onPressed: () {
                        HapticService.lightImpact(ref);
                        _resetFilter();
                      },
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter By',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTransactionTypeFilters(),
                      const SizedBox(height: 24),
                      Text(
                        'Sort By',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: SortBy.values.map((sort) {
                          return _buildFilterChip(
                            label: sort.name.substring(0, 1).toUpperCase() +
                                sort.name.substring(1),
                            isSelected: _tempFilter.sortBy == sort,
                            onTap: () async {
                              await HapticService.lightImpact(ref);
                              setState(() {
                                _tempFilter =
                                    _tempFilter.copyWith(sortBy: sort);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? CupertinoColors.white
                                  : CupertinoColors.black,
                            ),
                          ),
                          Text(
                            '${_tempFilter.categories.length} Selected',
                            style: TextStyle(
                              color: isDarkMode
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.systemGrey2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildCategorySelector(isDarkMode),
                    ],
                  ),
                ),
              ),
              // Apply Button
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  MediaQuery.of(context).padding.bottom + 16,
                ),
                child: CupertinoButton.filled(
                  onPressed: () {
                    HapticService.lightImpact(ref);
                    _handleApply();
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: const Center(
                    child: Text(
                      'Apply',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/haptic_service.dart';
import '../models/transaction_filter.dart';
import '../models/transaction_type.dart';
import '../widgets/category_selection_sheet.dart';
import '../../categories/providers/categories_provider.dart';
import '../../categories/models/category_model.dart';

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

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    _selectedCategories = ref
        .read(categoriesProvider)
        .where((category) => _filter.categories.contains(category.id))
        .toList();
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
          color: isDarkMode 
              ? const Color(0xFF2C2C2E) 
              : const Color(0xFFE5E5EA),
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
                  _filter = _filter.copyWith(
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
              _filter = _filter.copyWith(
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return Container(
      height: 600,
      padding: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
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
                    setState(() {
                      _filter = const TransactionFilter();
                    });
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
                      color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TransactionType.values.map((type) {
                      return _buildFilterChip(
                        label: type.name.substring(0, 1).toUpperCase() + 
                              type.name.substring(1),
                        isSelected: _filter.types.contains(type),
                        onTap: () async {
                          await HapticService.lightImpact(ref);
                          setState(() {
                            final newTypes = Set<TransactionType>.from(_filter.types);
                            if (newTypes.contains(type)) {
                              newTypes.remove(type);
                            } else {
                              newTypes.add(type);
                            }
                            _filter = _filter.copyWith(types: newTypes);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
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
                        isSelected: _filter.sortBy == sort,
                        onTap: () async {
                          await HapticService.lightImpact(ref);
                          setState(() {
                            _filter = _filter.copyWith(sortBy: sort);
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
                          color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                        ),
                      ),
                      Text(
                        '${_filter.categories.length} Selected',
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
            padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
            child: CupertinoButton.filled(
              onPressed: () {
                widget.onApply(_filter);
                Navigator.pop(context);
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
    );
  }
} 
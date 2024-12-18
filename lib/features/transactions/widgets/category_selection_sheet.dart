import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../categories/providers/categories_provider.dart';
import '../../categories/models/category_model.dart';
import '../models/transaction_type.dart';

class CategorySelectionSheet extends ConsumerStatefulWidget {
  final List<String> selectedCategories;
  final List<TransactionType> transactionTypes;

  const CategorySelectionSheet({
    super.key,
    required this.selectedCategories,
    required this.transactionTypes,
  });

  @override
  ConsumerState<CategorySelectionSheet> createState() => _CategorySelectionSheetState();
}

class _CategorySelectionSheetState extends ConsumerState<CategorySelectionSheet> {
  late Set<String> _selectedCategories;

  @override
  void initState() {
    super.initState();
    _selectedCategories = widget.selectedCategories.toSet();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final categories = ref.watch(categoriesProvider).where((category) {
      if (widget.transactionTypes.isEmpty) return true;
      return widget.transactionTypes.contains(
        switch (category.type) {
          CategoryType.income => TransactionType.income,
          CategoryType.expense => TransactionType.expense,
          CategoryType.transfer => TransactionType.transfer,
        }
      );
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      color: isDarkMode 
                          ? CupertinoColors.systemGrey 
                          : CupertinoColors.systemGrey2,
                    ),
                  ),
                  onPressed: () {
                    setState(() => _selectedCategories.clear());
                  },
                ),
                const Text(
                  'Select Categories',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('Done'),
                  onPressed: () {
                    Navigator.pop(context, _selectedCategories.toList());
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategories.contains(category.id);

                return CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isSelected) {
                        _selectedCategories.remove(category.id);
                      } else {
                        _selectedCategories.add(category.id);
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          category.icon,
                          color: category.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 17,
                          color: isDarkMode 
                              ? CupertinoColors.white 
                              : CupertinoColors.black,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(
                          CupertinoIcons.checkmark_alt,
                          color: CupertinoColors.systemBlue,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 
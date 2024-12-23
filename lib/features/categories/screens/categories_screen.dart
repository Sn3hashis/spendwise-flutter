import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise/features/categories/screens/add_category_screen.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../models/category_model.dart';
import '../providers/categories_provider.dart';


class CategoriesScreen extends ConsumerStatefulWidget {
  final CategoryType? filterType;

  const CategoriesScreen({
    super.key,
    this.filterType,
  });

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  int _selectedSegment = 0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final categories = ref.watch(categoriesProvider);

    // Sort and filter categories
    final incomeCategories = categories
        .where((cat) => cat.type == CategoryType.income)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    
    final expenseCategories = categories
        .where((cat) => cat.type == CategoryType.expense)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        middle: const Text('Categories'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => AddCategoryScreen(
                  category: Category(
                    id: const Uuid().v4(),
                    name: '',
                    description: '',
                    icon: CupertinoIcons.money_dollar,
                    color: CupertinoColors.systemBlue,
                    type: _selectedSegment == 0 
                        ? CategoryType.income 
                        : CategoryType.expense,
                    isDefault: false,
                  ),
                  isEditingCategory: true,
                ),
              ),
            );
          },
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Segmented Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<int>(
                  backgroundColor: isDarkMode 
                      ? AppTheme.cardDark 
                      : AppTheme.cardLight,
                  thumbColor: isDarkMode 
                      ? const Color(0xFF2C2C2E) 
                      : CupertinoColors.white,
                  groupValue: _selectedSegment,
                  onValueChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedSegment = value);
                    }
                  },
                  children: {
                    0: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        'Income',
                        style: TextStyle(
                          color: isDarkMode 
                              ? CupertinoColors.white 
                              : CupertinoColors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    1: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        'Expense',
                        style: TextStyle(
                          color: isDarkMode 
                              ? CupertinoColors.white 
                              : CupertinoColors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Categories List
            Expanded(
              child: ListView.builder(
                itemCount: _selectedSegment == 0 
                    ? incomeCategories.length 
                    : expenseCategories.length,
                itemBuilder: (context, index) {
                  final category = _selectedSegment == 0 
                      ? incomeCategories[index] 
                      : expenseCategories[index];
                  return _buildCategoryTile(context, category, isDarkMode, ref);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, Category category, bool isDarkMode, WidgetRef ref) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        if (widget.filterType != null) {
          Navigator.pop(context, category);
        } else if (category.isCustom) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => AddCategoryScreen(
                category: category,
                isEditingCategory: true,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDarkMode 
                  ? const Color(0xFF2C2C2E) 
                  : const Color(0xFFE5E5EA),
            ),
          ),
        ),
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                    ),
                  ),
                  Text(
                    category.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDarkMode 
                          ? CupertinoColors.systemGrey 
                          : CupertinoColors.systemGrey2,
                    ),
                  ),
                ],
              ),
            ),
            if (category.isCustom)
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  CupertinoIcons.delete,
                  color: CupertinoColors.systemRed,
                  size: 20,
                ),
                onPressed: () async {
                  await _handleCategoryDeletion(category);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> _handleCategoryDeletion(Category category) async {
    if (category.isDefault) {
      // Show error message for default category
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Cannot Delete'),
          content: const Text('Default categories cannot be deleted'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return false;
    }

    // Show delete confirmation for non-default categories
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete ${category.name}?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await ref.read(categoriesProvider.notifier).deleteCategory(category.id);
        return true;
      } catch (e) {
        if (!mounted) return false;
        // Show error message
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        return false;
      }
    }
    return false;
  }
}
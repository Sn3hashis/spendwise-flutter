import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../models/category_model.dart';
import '../providers/categories_provider.dart';
import 'add_category_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  final CategoryType? filterType;

  const CategoriesScreen({
    super.key,
    this.filterType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final categories = ref.watch(categoriesProvider);
    
    List<Category> sortCategories(List<Category> cats) {
      return [...cats]..sort((a, b) {
        if (a.isCustom && !b.isCustom) return -1;
        if (!a.isCustom && b.isCustom) return 1;
        return a.name.compareTo(b.name);
      });
    }
    
    final filteredCategories = filterType != null
        ? sortCategories(categories.where((cat) => cat.type == filterType!).toList())
        : categories;
    
    final incomeCategories = filterType == null
        ? sortCategories(categories.where((cat) => cat.type == CategoryType.income).toList())
        : <Category>[];
    final expenseCategories = filterType == null
        ? sortCategories(categories.where((cat) => cat.type == CategoryType.expense).toList())
        : <Category>[];

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        middle: Text(filterType != null 
            ? '${filterType == CategoryType.income ? 'Income' : 'Expense'} Categories'
            : 'Categories'
        ),
        trailing: filterType == null ? CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const AddCategoryScreen(),
              ),
            );
          },
        ) : null,
      ),
      child: SafeArea(
        child: ListView(
          children: [
            if (filterType == null) ...[
              _buildSection(
                'Income Categories',
                incomeCategories,
                isDarkMode,
                ref,
              ),
              _buildSection(
                'Expense Categories',
                expenseCategories,
                isDarkMode,
                ref,
              ),
            ] else
              _buildSection(
                '',
                filteredCategories,
                isDarkMode,
                ref,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<Category> categories,
    bool isDarkMode,
    WidgetRef ref,
  ) {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                ),
              ),
            ),
          ...categories.map((category) => _buildCategoryTile(context, category, isDarkMode, ref)),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, Category category, bool isDarkMode, WidgetRef ref) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        if (filterType != null) {
          Navigator.pop(context, category);
        } else if (category.isCustom) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => AddCategoryScreen(category: category),
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
                onPressed: () {
                  ref.read(categoriesProvider.notifier).deleteCategory(category.id);
                },
              ),
          ],
        ),
      ),
    );
  }
} 
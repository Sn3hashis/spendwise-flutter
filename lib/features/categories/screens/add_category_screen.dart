import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/haptic_service.dart';
import '../models/category_model.dart';
import '../providers/categories_provider.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  final Category? category;
  final bool isEditingCategory;

  const AddCategoryScreen({
    super.key,
    this.category,
    this.isEditingCategory = false,
  });

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late CategoryType _selectedType;
  late IconData _selectedIcon;
  late Color _selectedColor;

  final List<IconData> _icons = [
    CupertinoIcons.money_dollar,
    CupertinoIcons.cart_fill,
    CupertinoIcons.car_detailed,
    CupertinoIcons.house_fill,
    CupertinoIcons.gift_fill,
    CupertinoIcons.gamecontroller_fill,
    CupertinoIcons.heart_fill,
    CupertinoIcons.book_fill,
    CupertinoIcons.bus,
    CupertinoIcons.airplane,
    CupertinoIcons.paw_solid,
    CupertinoIcons.bag_fill,
    CupertinoIcons.creditcard_fill,
    CupertinoIcons.ticket_fill,
    CupertinoIcons.cart_badge_plus,
    CupertinoIcons.phone_fill,
    CupertinoIcons.tv_fill,
    CupertinoIcons.cloud_fill,
    CupertinoIcons.music_note,
    CupertinoIcons.scissors,
    CupertinoIcons.briefcase_fill,
    CupertinoIcons.building_2_fill,
    CupertinoIcons.bed_double_fill,
    CupertinoIcons.hammer_fill,
  ];

  final List<Color> _colors = [
    CupertinoColors.systemRed,
    CupertinoColors.systemOrange,
    CupertinoColors.systemYellow,
    CupertinoColors.systemGreen,
    CupertinoColors.systemBlue,
    CupertinoColors.systemPurple,
    CupertinoColors.systemPink,
    CupertinoColors.systemTeal,
    CupertinoColors.systemIndigo,
  ];

  @override
  void initState() {
    super.initState();
    // Don't allow editing default categories
    if (widget.category != null && widget.category!.isDefault == true) {
      Navigator.pop(context);
    }
    _nameController = TextEditingController(text: widget.category?.name);
    _descriptionController = TextEditingController(text: widget.category?.description);
    _selectedType = widget.category?.type ?? CategoryType.expense;
    _selectedIcon = widget.category?.icon ?? _icons.first;
    _selectedColor = widget.category?.color ?? _colors.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAlert(String message, {bool isError = false}) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(isError ? 'Error' : 'Success'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showAlert('Please enter a category name', isError: true);
      return;
    }

    try {
      final newCategory = Category(
        id: '', // Will be set by the provider
        name: name,
        description: _descriptionController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
        type: _selectedType,
        isDefault: false,
      );

      await ref.read(categoriesProvider.notifier).addCategory(newCategory);
      
      if (mounted) {
        Navigator.of(context).pop();
        _showAlert('Category added successfully');
      }
    } catch (e) {
      if (mounted) {
        _showAlert(
          e.toString().replaceAll('Exception: ', ''),
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        middle: Text(widget.category != null ? 'Edit Category' : 'Add Category'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Save'),
          onPressed: _saveCategory,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Type Selector
            Text(
              'Type',
              style: TextStyle(
                fontSize: 17,
                color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            CupertinoSlidingSegmentedControl<CategoryType>(
              groupValue: _selectedType,
              children: const {
                CategoryType.expense: Text('Expense'),
                CategoryType.income: Text('Income'),
              },
              onValueChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 24),

            // Name Input
            CupertinoTextField(
              controller: _nameController,
              placeholder: 'Category Name',
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),

            // Description Input
            CupertinoTextField(
              controller: _descriptionController,
              placeholder: 'Description',
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 24),

            // Icon Selector
            Text(
              'Icon',
              style: TextStyle(
                fontSize: 17,
                color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - (4 * 16)) / 5; // 5 items per row, 4 gaps
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: _icons.map((icon) {
                      final isSelected = _selectedIcon == icon;
                      return SizedBox(
                        width: itemWidth,
                        height: itemWidth,
                        child: GestureDetector(
                          onTap: () async {
                            await HapticService.lightImpact(ref);
                            setState(() => _selectedIcon = icon);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? _selectedColor.withOpacity(0.2) : null,
                              border: Border.all(
                                color: isSelected ? _selectedColor : Colors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              icon,
                              color: isSelected 
                                  ? _selectedColor 
                                  : (isDarkMode ? CupertinoColors.white : CupertinoColors.black),
                              size: 24,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Color Selector
            Text(
              'Color',
              style: TextStyle(
                fontSize: 17,
                color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _colors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () async {
                      await HapticService.lightImpact(ref);
                      setState(() => _selectedColor = color);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                                width: 2,
                              )
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
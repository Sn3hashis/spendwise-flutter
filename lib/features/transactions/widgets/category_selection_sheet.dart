import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' show PathMetric;
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../categories/models/category_model.dart';

class CategorySelectionSheet extends ConsumerStatefulWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final Function(Category) onCategorySelected;

  const CategorySelectionSheet({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  ConsumerState<CategorySelectionSheet> createState() => _CategorySelectionSheetState();
}

class _CategorySelectionSheetState extends ConsumerState<CategorySelectionSheet> {
  late TextEditingController _searchController;
  late List<Category> _filteredCategories;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCategories = widget.categories;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories(String query) {
    setState(() {
      _filteredCategories = widget.categories
          .where((category) => 
              category.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Select Category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
              ),
            ),
          ),

          // Search Box with dotted border
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4), // Reduced bottom padding
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkMode 
                      ? CupertinoColors.systemGrey 
                      : CupertinoColors.systemGrey2,
                  width: 1,
                  style: BorderStyle.none,
                ),
              ),
              child: Stack(
                children: [
                  // Dotted border
                  CustomPaint(
                    painter: DottedBorderPainter(
                      color: isDarkMode 
                          ? CupertinoColors.systemGrey 
                          : CupertinoColors.systemGrey2,
                      borderRadius: 8,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 36, // Match CupertinoSearchTextField height
                    ),
                  ),
                  CupertinoSearchTextField(
                    controller: _searchController,
                    placeholder: 'Search categories',
                    onChanged: _filterCategories,
                    style: TextStyle(
                      color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                    ),
                    backgroundColor: isDarkMode 
                        ? CupertinoColors.systemGrey6.darkColor 
                        : CupertinoColors.systemGrey6,
                  ),
                ],
              ),
            ),
          ),
          
          // Categories List
          Expanded(
            child: _filteredCategories.isEmpty
                ? Center(
                    child: Text(
                      'No categories found',
                      style: TextStyle(
                        color: isDarkMode 
                            ? CupertinoColors.systemGrey 
                            : CupertinoColors.systemGrey2,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero, // Remove default padding
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = _filteredCategories[index];
                      final isSelected = widget.selectedCategory?.id == category.id;
                      
                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          widget.onCategorySelected(category);
                          if (context.mounted) {
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: CupertinoColors.systemGrey.withOpacity(0.2),
                                width: 0.5,
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
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: isDarkMode 
                                        ? CupertinoColors.white 
                                        : CupertinoColors.black,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  CupertinoIcons.checkmark_alt,
                                  color: CupertinoColors.systemBlue,
                                  size: 20,
                                ),
                            ],
                          ),
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

// Add this custom painter for the dotted border
class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  DottedBorderPainter({
    required this.color,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 4;
    const dashSpace = 4;
    final width = size.width;
    final height = size.height;

    // Top line
    double x = 0;
    while (x < width) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + dashWidth, 0),
        paint,
      );
      x += dashWidth + dashSpace;
    }

    // Right line
    double y = 0;
    while (y < height) {
      canvas.drawLine(
        Offset(width, y),
        Offset(width, y + dashWidth),
        paint,
      );
      y += dashWidth + dashSpace;
    }

    // Bottom line
    x = width;
    while (x > 0) {
      canvas.drawLine(
        Offset(x, height),
        Offset(x - dashWidth, height),
        paint,
      );
      x -= dashWidth + dashSpace;
    }

    // Left line
    y = height;
    while (y > 0) {
      canvas.drawLine(
        Offset(0, y),
        Offset(0, y - dashWidth),
        paint,
      );
      y -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DottedBorderPainter oldDelegate) => false;
} 
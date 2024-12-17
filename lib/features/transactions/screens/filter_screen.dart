import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/haptic_service.dart';
import '../models/transaction_filter.dart';

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

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
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
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // TODO: Show category selector
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode 
                              ? const Color(0xFF2C2C2E) 
                              : const Color(0xFFE5E5EA),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Choose Category',
                            style: TextStyle(
                              color: isDarkMode 
                                  ? CupertinoColors.white 
                                  : CupertinoColors.black,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            CupertinoIcons.chevron_right,
                            color: isDarkMode 
                                ? CupertinoColors.systemGrey 
                                : CupertinoColors.systemGrey2,
                          ),
                        ],
                      ),
                    ),
                  ),
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
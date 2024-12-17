import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/haptic_service.dart';

enum DateRangeType {
  week,
  month,
  year,
  custom,
}

class DateRange {
  final DateTime startDate;
  final DateTime endDate;
  final DateRangeType type;

  DateRange({
    required this.startDate,
    required this.endDate,
    required this.type,
  });

  String get displayText {
    switch (type) {
      case DateRangeType.week:
        return 'This Week';
      case DateRangeType.month:
        return '${_getMonthName(startDate.month)} ${startDate.year}';
      case DateRangeType.year:
        return startDate.year.toString();
      case DateRangeType.custom:
        return 'Custom Range\n${startDate.day} ${_getMonthName(startDate.month)} - ${endDate.day} ${_getMonthName(endDate.month)}';
    }
  }

  static String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

class DateRangeSelector extends ConsumerStatefulWidget {
  final DateRange selectedRange;
  final Function(DateRange) onRangeSelected;

  const DateRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeSelected,
  });

  @override
  ConsumerState<DateRangeSelector> createState() => _DateRangeSelectorState();
}

class _DateRangeSelectorState extends ConsumerState<DateRangeSelector> {
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  void _showRangeSelector() {
    final isDarkMode = ref.read(themeProvider);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const Text(
                    'Select Date Range',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildRangeOption(
                      'This Week',
                      DateRangeType.week,
                      _getWeekRange(),
                    ),
                    _buildRangeOption(
                      'This Month',
                      DateRangeType.month,
                      _getMonthRange(),
                    ),
                    _buildRangeOption(
                      'Last 3 Months',
                      DateRangeType.custom,
                      _getLastThreeMonthsRange(),
                    ),
                    _buildRangeOption(
                      'Last 6 Months',
                      DateRangeType.custom,
                      _getLastSixMonthsRange(),
                    ),
                    _buildRangeOption(
                      'This Year',
                      DateRangeType.year,
                      _getYearRange(),
                    ),
                    _buildRangeOption(
                      'Custom Range',
                      DateRangeType.custom,
                      null,
                      showCustomPicker: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeOption(
    String title,
    DateRangeType type,
    DateRange? range, {
    bool showCustomPicker = false,
  }) {
    final isDarkMode = ref.watch(themeProvider);
    final isCustomSelected = widget.selectedRange.type == DateRangeType.custom && title == 'Custom Range';

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () async {
        await HapticService.lightImpact(ref);
        if (showCustomPicker) {
          _showCustomRangePicker();
        } else if (range != null) {
          widget.onRangeSelected(range);
          Navigator.pop(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                    ),
                  ),
                  if (isCustomSelected)
                    Text(
                      '${widget.selectedRange.startDate.day} ${_getMonthName(widget.selectedRange.startDate.month)} ${widget.selectedRange.startDate.year} - ${widget.selectedRange.endDate.day} ${_getMonthName(widget.selectedRange.endDate.month)} ${widget.selectedRange.endDate.year}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode 
                            ? CupertinoColors.systemGrey 
                            : CupertinoColors.systemGrey2,
                      ),
                    ),
                ],
              ),
            ),
            if (showCustomPicker)
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

  void _showCustomRangePicker() {
    final isDarkMode = ref.read(themeProvider);
    DateTime startDate = widget.selectedRange.startDate;
    DateTime endDate = widget.selectedRange.endDate;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 500,
        padding: const EdgeInsets.only(top: 6),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          children: [
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
                    'Custom Range',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      widget.onRangeSelected(DateRange(
                        startDate: startDate,
                        endDate: endDate,
                        type: DateRangeType.custom,
                      ));
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Start Date',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDarkMode 
                                ? CupertinoColors.systemGrey 
                                : CupertinoColors.systemGrey2,
                          ),
                        ),
                      ),
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isDarkMode 
                                  ? const Color(0xFF2C2C2E) 
                                  : const Color(0xFFE5E5EA),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: startDate,
                          maximumDate: DateTime.now(),
                          minimumYear: 2000,
                          maximumYear: DateTime.now().year,
                          onDateTimeChanged: (date) async {
                            await HapticService.selectionClick(ref);
                            startDate = date;
                          },
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'End Date',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDarkMode 
                                ? CupertinoColors.systemGrey 
                                : CupertinoColors.systemGrey2,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 180,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: endDate,
                          maximumDate: DateTime.now(),
                          minimumYear: 2000,
                          maximumYear: DateTime.now().year,
                          onDateTimeChanged: (date) async {
                            await HapticService.selectionClick(ref);
                            endDate = date;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  DateRange _getWeekRange() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return DateRange(
      startDate: startOfWeek,
      endDate: now,
      type: DateRangeType.week,
    );
  }

  DateRange _getMonthRange() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return DateRange(
      startDate: startOfMonth,
      endDate: now,
      type: DateRangeType.month,
    );
  }

  DateRange _getYearRange() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    return DateRange(
      startDate: startOfYear,
      endDate: now,
      type: DateRangeType.year,
    );
  }

  DateRange _getLastThreeMonthsRange() {
    final now = DateTime.now();
    final startOfRange = DateTime(now.year, now.month - 2, 1); // Goes back 3 months
    return DateRange(
      startDate: startOfRange,
      endDate: now,
      type: DateRangeType.custom,
    );
  }

  DateRange _getLastSixMonthsRange() {
    final now = DateTime.now();
    final startOfRange = DateTime(now.year, now.month - 5, 1); // Goes back 6 months
    return DateRange(
      startDate: startOfRange,
      endDate: now,
      type: DateRangeType.custom,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final displayText = widget.selectedRange.displayText;
    final isCustomRange = widget.selectedRange.type == DateRangeType.custom;

    return GestureDetector(
      onTap: () async {
        await HapticService.lightImpact(ref);
        _showRangeSelector();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCustomRange) ...[
                  Text(
                    'Custom Range',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                    ),
                  ),
                  Text(
                    '${widget.selectedRange.startDate.day} ${_getMonthName(widget.selectedRange.startDate.month)} - ${widget.selectedRange.endDate.day} ${_getMonthName(widget.selectedRange.endDate.month)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode 
                          ? CupertinoColors.systemGrey 
                          : CupertinoColors.systemGrey2,
                    ),
                  ),
                ] else
                  Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            CupertinoIcons.chevron_down,
            size: 20,
          ),
        ],
      ),
    );
  }
} 
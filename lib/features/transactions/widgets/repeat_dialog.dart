import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/haptic_service.dart';

enum RepeatFrequency {
  daily,
  weekly,
  monthly,
  yearly,
}

class RepeatDialog extends ConsumerStatefulWidget {
  final RepeatFrequency frequency;
  final DateTime? endDate;
  final Function(RepeatFrequency, DateTime?) onSave;

  const RepeatDialog({
    super.key,
    required this.frequency,
    this.endDate,
    required this.onSave,
  });

  @override
  ConsumerState<RepeatDialog> createState() => _RepeatDialogState();
}

class _RepeatDialogState extends ConsumerState<RepeatDialog> {
  late RepeatFrequency selectedFrequency;
  DateTime? selectedEndDate;

  @override
  void initState() {
    super.initState();
    selectedFrequency = widget.frequency;
    selectedEndDate = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Frequency Selector
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    await HapticService.lightImpact(ref);
                    
                    RepeatFrequency tempFrequency = selectedFrequency;
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 250,
                          color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
                          child: Column(
                            children: [
                              Container(
                                height: 50,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
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
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () async {
                                        await HapticService.lightImpact(ref);
                                        setState(() {
                                          selectedFrequency = tempFrequency;
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Save'),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: CupertinoPicker(
                                  itemExtent: 45,
                                  scrollController: FixedExtentScrollController(
                                    initialItem: RepeatFrequency.values.indexOf(selectedFrequency),
                                  ),
                                  onSelectedItemChanged: (index) async {
                                    await HapticService.selectionClick(ref);
                                    tempFrequency = RepeatFrequency.values[index];
                                  },
                                  children: RepeatFrequency.values.map((freq) {
                                    return Text(
                                      freq.name.substring(0, 1).toUpperCase() + freq.name.substring(1),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Text(
                          'Frequency',
                          style: TextStyle(
                            color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          selectedFrequency.name.substring(0, 1).toUpperCase() +
                          selectedFrequency.name.substring(1),
                          style: TextStyle(
                            color: isDarkMode 
                                ? CupertinoColors.systemGrey 
                                : CupertinoColors.systemGrey2,
                          ),
                        ),
                        Icon(
                          CupertinoIcons.chevron_down,
                          size: 16,
                          color: isDarkMode 
                              ? CupertinoColors.systemGrey 
                              : CupertinoColors.systemGrey2,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: isDarkMode 
                      ? const Color(0xFF2C2C2E) 
                      : const Color(0xFFE5E5EA),
                ),
                // End Date Selector
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    await HapticService.lightImpact(ref);
                    
                    final now = DateTime.now();
                    final currentDate = DateTime(now.year, now.month, now.day);
                    DateTime tempEndDate = selectedEndDate ?? currentDate;

                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 250,
                          color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
                          child: Column(
                            children: [
                              Container(
                                height: 50,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
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
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () async {
                                        await HapticService.lightImpact(ref);
                                        setState(() {
                                          selectedEndDate = tempEndDate;
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Save'),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.date,
                                  minimumDate: currentDate,
                                  initialDateTime: tempEndDate,
                                  onDateTimeChanged: (date) async {
                                    await HapticService.selectionClick(ref);
                                    tempEndDate = date;
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Text(
                          'End After',
                          style: TextStyle(
                            color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          selectedEndDate?.toString().split(' ')[0] ?? 'Select Date',
                          style: TextStyle(
                            color: isDarkMode 
                                ? CupertinoColors.systemGrey 
                                : CupertinoColors.systemGrey2,
                          ),
                        ),
                        Icon(
                          CupertinoIcons.chevron_down,
                          size: 16,
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
          CupertinoButton(
            onPressed: () => widget.onSave(selectedFrequency, selectedEndDate),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
} 
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../models/payee_model.dart';
import '../providers/payees_provider.dart';

class AddPayeeScreen extends ConsumerStatefulWidget {
  final Payee? payee;

  const AddPayeeScreen({super.key, this.payee});

  @override
  ConsumerState<AddPayeeScreen> createState() => _AddPayeeScreenState();
}

class _AddPayeeScreenState extends ConsumerState<AddPayeeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _imagePath;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    if (widget.payee != null) {
      _nameController.text = widget.payee!.name;
      _phoneController.text = widget.payee!.phone ?? '';
      _emailController.text = widget.payee!.email ?? '';
      _imagePath = widget.payee!.imageUrl;
    }
    _validateInputs();
    _nameController.addListener(_validateInputs);
  }

  void _validateInputs() {
    setState(() {
      _isValid = _nameController.text.isNotEmpty;
    });
  }

  Future<void> _pickContact() async {
    try {
      if (!await FlutterContacts.requestPermission()) {
        if (!mounted) return;
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Permission Required'),
            content: const Text('Please enable contacts permission to use this feature.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        return;
      }

      // Get contact with full details directly
      final contact = await FlutterContacts.openExternalPick();
      if (contact == null || !mounted) return;

      // Get full contact details
      final fullContact = await FlutterContacts.getContact(contact.id);
      if (fullContact == null || !mounted) return;

      // Update form fields
      setState(() {
        // Name
        _nameController.text = fullContact.displayName;

        // Phone
        if (fullContact.phones.isNotEmpty) {
          _phoneController.text = fullContact.phones.first.number.replaceAll(RegExp(r'[^\d+]'), '');
        }

        // Email
        if (fullContact.emails.isNotEmpty) {
          _emailController.text = fullContact.emails.first.address;
        }
      });

      // Validate inputs
      _validateInputs();

    } catch (e) {
      debugPrint('Error picking contact: $e');
      if (!mounted) return;
      
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to pick contact. Please try again.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Select Image Source'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.camera);
              
              if (image != null) {
                setState(() {
                  _imagePath = image.path;
                });
              }
            },
            child: const Text('Camera'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              
              if (image != null) {
                setState(() {
                  _imagePath = image.path;
                });
              }
            },
            child: const Text('Gallery'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        middle: Text(widget.payee != null ? 'Edit Payee' : 'Add Payee'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Lottie Animation
                Container(
                  height: screenWidth * 0.4,
                  width: screenWidth * 1.2,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Lottie.asset(
                    'assets/animations/add_payee.json',
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
                // Profile Image
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDarkMode 
                          ? CupertinoColors.systemGrey6.darkColor 
                          : CupertinoColors.systemGrey6,
                      border: Border.all(
                        color: isDarkMode 
                            ? const Color(0xFF2C2C2E) 
                            : const Color(0xFFE5E5EA),
                        width: 1,
                      ),
                      image: _imagePath != null
                          ? DecorationImage(
                              image: FileImage(File(_imagePath!)),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                debugPrint('Error loading image: $exception');
                                setState(() {
                                  _imagePath = null;
                                });
                              },
                            )
                          : null,
                    ),
                    child: _imagePath == null
                        ? Icon(
                            CupertinoIcons.camera,
                            size: 40,
                            color: isDarkMode 
                                ? CupertinoColors.systemGrey 
                                : CupertinoColors.systemGrey2,
                          )
                        : null,
                  ),
                ),
                // Form Fields
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CupertinoTextField(
                      controller: _nameController,
                      placeholder: 'Name',
                      placeholderStyle: TextStyle(
                        color: isDarkMode 
                            ? CupertinoColors.systemGrey 
                            : CupertinoColors.systemGrey2,
                      ),
                      style: TextStyle(
                        color: isDarkMode 
                            ? CupertinoColors.white 
                            : CupertinoColors.black,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDarkMode 
                              ? const Color(0xFF2C2C2E) 
                              : const Color(0xFFE5E5EA),
                          width: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CupertinoTextField(
                      controller: _phoneController,
                      placeholder: 'Phone',
                      placeholderStyle: TextStyle(
                        color: isDarkMode 
                            ? CupertinoColors.systemGrey 
                            : CupertinoColors.systemGrey2,
                      ),
                      style: TextStyle(
                        color: isDarkMode 
                            ? CupertinoColors.white 
                            : CupertinoColors.black,
                      ),
                      keyboardType: TextInputType.phone,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDarkMode 
                              ? const Color(0xFF2C2C2E) 
                              : const Color(0xFFE5E5EA),
                          width: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CupertinoTextField(
                      controller: _emailController,
                      placeholder: 'Email',
                      placeholderStyle: TextStyle(
                        color: isDarkMode 
                            ? CupertinoColors.systemGrey 
                            : CupertinoColors.systemGrey2,
                      ),
                      style: TextStyle(
                        color: isDarkMode 
                            ? CupertinoColors.white 
                            : CupertinoColors.black,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDarkMode 
                              ? const Color(0xFF2C2C2E) 
                              : const Color(0xFFE5E5EA),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Action Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: CupertinoColors.systemBlue,
                        borderRadius: BorderRadius.circular(8),
                        onPressed: _pickContact,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons.person_crop_circle_badge_plus,
                              color: CupertinoColors.white,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Select Contact',
                              style: TextStyle(
                                color: CupertinoColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: CupertinoColors.systemGreen,
                        borderRadius: BorderRadius.circular(8),
                        onPressed: _pickImage,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons.cloud_upload,
                              color: CupertinoColors.white,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Upload DP',
                              style: TextStyle(
                                color: CupertinoColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    borderRadius: BorderRadius.circular(8),
                    color: _isValid ? CupertinoColors.activeBlue : CupertinoColors.systemGrey3,
                    onPressed: _isValid ? () async {
                      String? permanentImagePath = _imagePath;
                      if (_imagePath != null && _imagePath != widget.payee?.imageUrl) {
                        try {
                          final Directory appDir = await getApplicationDocumentsDirectory();
                          final String fileName = 'payee_${DateTime.now().millisecondsSinceEpoch}.jpg';
                          final String filePath = '${appDir.path}/$fileName';
                          
                          // Create a copy of the image file
                          final File originalFile = File(_imagePath!);
                          if (await originalFile.exists()) {
                            await originalFile.copy(filePath);
                            permanentImagePath = filePath;
                          } else {
                            debugPrint('Original image file does not exist: $_imagePath');
                            permanentImagePath = _imagePath;
                          }
                        } catch (e) {
                          debugPrint('Error copying image: $e');
                          permanentImagePath = _imagePath;
                        }
                      }

                      final payee = Payee(
                        id: widget.payee?.id ?? const Uuid().v4(),
                        name: _nameController.text,
                        email: _emailController.text.isEmpty ? null : _emailController.text,
                        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
                        imageUrl: _imagePath,
                        createdAt: widget.payee?.createdAt ?? DateTime.now(), // Add timestamp
                        updatedAt: DateTime.now(), // Always update timestamp
                      );

                      if (widget.payee != null) {
                        ref.read(payeesProvider.notifier).updatePayee(payee);
                      } else {
                        ref.read(payeesProvider.notifier).addPayee(payee);
                      }

                      Navigator.pop(context);
                    } : null,
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
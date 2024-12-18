import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';

class AttachmentService {
  static final ImagePicker _picker = ImagePicker();
  
  static Future<void> showAttachmentOptions(
    BuildContext context, {
    required Function(List<String>) onAttachmentsSelected,
  }) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              final photo = await _takePhoto();
              if (photo != null) {
                onAttachmentsSelected([photo]);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.camera_fill,
                  color: CupertinoColors.systemPurple,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Camera',
                  style: TextStyle(
                    color: CupertinoColors.systemPurple,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              final images = await _pickImages();
              if (images.isNotEmpty) {
                onAttachmentsSelected(images);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.photo_fill,
                  color: CupertinoColors.systemPurple,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Image',
                  style: TextStyle(
                    color: CupertinoColors.systemPurple,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              final document = await _pickDocument();
              if (document != null) {
                onAttachmentsSelected([document]);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.doc_fill,
                  color: CupertinoColors.systemPurple,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Document',
                  style: TextStyle(
                    color: CupertinoColors.systemPurple,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  static Future<String?> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      return photo?.path;
    } catch (e) {
      return null;
    }
  }

  static Future<List<String>> _pickImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        imageQuality: 80,
      );
      if (images != null && images.length > 2) {
        return images.take(2).map((image) => image.path).toList();
      }
      return images?.map((image) => image.path).toList() ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<String?> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );
      
      return result?.files.single.path;
    } catch (e) {
      return null;
    }
  }
} 
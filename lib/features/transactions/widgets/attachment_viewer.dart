import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../core/providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttachmentViewer extends ConsumerWidget {
  final String filePath;

  const AttachmentViewer({
    super.key,
    required this.filePath,
  });

  bool get isPDF => path.extension(filePath).toLowerCase() == '.pdf';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        children: [
          // Content
          Center(
            child: isPDF
                ? SfPdfViewer.file(
                    File(filePath),
                    canShowScrollHead: false,
                    enableDoubleTapZooming: true,
                    pageSpacing: 0,
                  )
                : InteractiveViewer(
                    child: Image.file(
                      File(filePath),
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
          // Close Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CupertinoColors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.xmark,
                  color: CupertinoColors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
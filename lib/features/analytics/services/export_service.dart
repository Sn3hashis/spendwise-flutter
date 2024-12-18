import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as spdf;
import '../../transactions/models/transaction_model.dart';
import '../../../core/utils/date_helper.dart';

class ExportService {
  static Future<void> exportToPDF({
    required List<Transaction> transactions,
    required String period,
    required BuildContext context,
    required List<int>? trendChartImage,
    required List<int>? categoryChartImage,
    required List<int>? patternChartImage,
  }) async {
    final pdf = pw.Document();
    
    // Add title
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Transaction Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Period: $period'),
            pw.SizedBox(height: 20),
            
            // Add charts if available
            if (trendChartImage != null)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Transaction Trends',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Image(
                    pw.MemoryImage(Uint8List.fromList(trendChartImage)),
                    height: 200,
                  ),
                  pw.SizedBox(height: 20),
                ],
              ),

            if (categoryChartImage != null)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Category Analysis',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Image(
                    pw.MemoryImage(Uint8List.fromList(categoryChartImage)),
                    height: 200,
                  ),
                  pw.SizedBox(height: 20),
                ],
              ),

            if (patternChartImage != null)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Payment Patterns',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Image(
                    pw.MemoryImage(Uint8List.fromList(patternChartImage)),
                    height: 200,
                  ),
                ],
              ),

            pw.SizedBox(height: 20),
            pw.Text(
              'Transaction Details',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            
            // Add transaction table
            pw.Table.fromTextArray(
              headers: ['Date', 'Description', 'Category', 'Amount'],
              data: transactions.map((transaction) => [
                formatDateTime(transaction.date),
                transaction.description,
                transaction.category.name,
                '₹${transaction.amount.abs()}',
              ]).toList(),
            ),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/transactions_report.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Transaction Report',
    );
  }

  static Future<void> exportToExcel(List<Transaction> transactions) async {
    final excel = Excel.createExcel();
    final sheet = excel['Transactions'];

    // Add headers
    final headers = [
      'Date',
      'Description',
      'Category',
      'Amount',
      'Type',
    ];

    sheet.appendRow(headers.map((header) => TextCellValue(header)).toList());

    // Add data
    for (var transaction in transactions) {
      sheet.appendRow([
        TextCellValue(formatDateTime(transaction.date)),
        TextCellValue(transaction.description),
        TextCellValue(transaction.category.name),
        TextCellValue(transaction.amount.toString()),
        TextCellValue(transaction.type.toString()),
      ]);
    }

    // Auto-fit columns
    for (var i = 0; i < sheet.maxColumns; i++) {
      sheet.setColumnWidth(i, 15);
    }

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/transactions.xlsx');
    await file.writeAsBytes(excel.encode()!);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Transaction Data',
    );
  }
} 
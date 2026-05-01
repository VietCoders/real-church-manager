// PDF builder cho báo cáo — table-based + bar/pie chart, dùng chung cho 6 report.
import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

enum ReportChartType { none, bar, pie }

class RealCmReportPdfBuilder {
  RealCmReportPdfBuilder._();

  static final _df = DateFormat('dd/MM/yyyy HH:mm', 'vi');

  /// Báo cáo dạng table đơn giản: title + caption + bảng 2 cột (label/value).
  /// chartType: bar/pie sẽ render biểu đồ phía trên bảng (skip rows có value không phải số).
  static Future<pw.Document> simpleTable({
    required String parishName,
    required String title,
    String? caption,
    required List<MapEntry<String, String>> rows,
    ReportChartType chartType = ReportChartType.none,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => [
          pw.Center(
            child: pw.Text(parishName.toUpperCase(),
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 16),
          pw.Center(
            child: pw.Text(title,
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ),
          if (caption != null) ...[
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(caption,
                  style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic)),
            ),
          ],
          pw.SizedBox(height: 16),
          if (chartType != ReportChartType.none) ...[
            _buildChart(rows, chartType),
            pw.SizedBox(height: 20),
          ],
          pw.Table(
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey400),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _cell('Chỉ tiêu', bold: true),
                  _cell('Giá trị', bold: true, align: pw.TextAlign.right),
                ],
              ),
              for (final r in rows)
                pw.TableRow(children: [
                  _cell(r.key),
                  _cell(r.value, align: pw.TextAlign.right),
                ]),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text('Xuất ngày ${_df.format(DateTime.now())}',
                style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
          ),
        ],
      ),
    );
    return pdf;
  }

  static pw.Widget _buildChart(List<MapEntry<String, String>> rows, ReportChartType type) {
    final palette = [
      PdfColors.blue700, PdfColors.green700, PdfColors.orange700,
      PdfColors.purple700, PdfColors.red700, PdfColors.teal700,
      PdfColors.indigo700, PdfColors.pink700,
    ];
    // Parse số từ "1.234.567 đ" hoặc "12" → 1234567 / 12. Skip row không phải số.
    final numeric = <MapEntry<String, double>>[];
    for (final r in rows) {
      final cleaned = r.value.replaceAll(RegExp(r'[^\d\-]'), '');
      final v = double.tryParse(cleaned);
      if (v != null && v > 0) numeric.add(MapEntry(r.key, v));
    }
    if (numeric.isEmpty) return pw.SizedBox();

    if (type == ReportChartType.pie) {
      final total = numeric.fold<double>(0, (s, e) => s + e.value);
      return pw.Container(
        height: 220,
        child: pw.Row(
          children: [
            pw.Expanded(
              child: pw.SizedBox(
                height: 200,
                child: _PieChart(
                  values: numeric.map((e) => e.value).toList(),
                  colors: List.generate(numeric.length, (i) => palette[i % palette.length]),
                ),
              ),
            ),
            pw.SizedBox(width: 16),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < numeric.length; i++)
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 3),
                      child: pw.Row(children: [
                        pw.Container(width: 12, height: 12, color: palette[i % palette.length]),
                        pw.SizedBox(width: 6),
                        pw.Expanded(
                          child: pw.Text(
                            '${numeric[i].key} (${(numeric[i].value / total * 100).toStringAsFixed(0)}%)',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ),
                      ]),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Bar
    final maxV = numeric.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return pw.Container(
      height: 200,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < numeric.length; i++)
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 4),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(numeric[i].value.toStringAsFixed(0),
                        style: const pw.TextStyle(fontSize: 9)),
                    pw.SizedBox(height: 2),
                    pw.Container(
                      height: (numeric[i].value / maxV) * 140,
                      color: palette[i % palette.length],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(numeric[i].key,
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 9), maxLines: 2),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _cell(String text, {bool bold = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(fontSize: 11, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
      ),
    );
  }

  static Future<void> print(pw.Document doc, {String? jobName}) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: jobName ?? 'Real Church Manager Report',
    );
  }
}

// PDF builder cho báo cáo — table-based, dùng chung cho 6 report.
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class RealCmReportPdfBuilder {
  RealCmReportPdfBuilder._();

  static final _df = DateFormat('dd/MM/yyyy HH:mm', 'vi');

  /// Báo cáo dạng table đơn giản: title + caption + bảng 2 cột (label/value).
  static Future<pw.Document> simpleTable({
    required String parishName,
    required String title,
    String? caption,
    required List<MapEntry<String, String>> rows,
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

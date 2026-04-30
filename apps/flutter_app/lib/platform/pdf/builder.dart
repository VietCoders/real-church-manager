// PDF builder — sinh chứng chỉ Bí Tích layout VN chuẩn.
// Layout: logo giáo xứ + tên giáo xứ + tiêu đề bí tích + thông tin người + cha cử hành + dấu/chữ ký.
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class RealCmCertificateBuilder {
  RealCmCertificateBuilder._();

  /// Sinh chứng chỉ Rửa Tội. Tham số tối thiểu — extension cho 4 sổ còn lại theo cùng pattern.
  static Future<pw.Document> baptism({
    required String parishName,
    required String parishAddress,
    required String memberSaintName,
    required String memberFullName,
    required DateTime memberBirthDate,
    required String fatherName,
    required String motherName,
    required String godfatherName,
    required String godmotherName,
    required DateTime baptismDate,
    required String baptismPlace,
    required String priestName,
    required String bookNumber,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.notoSerifRegular();
    final fontBold = await PdfGoogleFonts.notoSerifBold();
    final df = DateFormat('dd/MM/yyyy', 'vi');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (ctx) => pw.Padding(
          padding: const pw.EdgeInsets.all(48),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(parishName.toUpperCase(),
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text(parishAddress, style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 32),
              pw.Text('CHỨNG CHỈ RỬA TỘI',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Text('(Certificatum Baptismi)',
                  style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic)),
              pw.SizedBox(height: 8),
              pw.Text('Số sổ: $bookNumber', style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 24),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 24),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _row('Tên Thánh:', memberSaintName, fontBold),
                    _row('Họ và tên:', memberFullName, fontBold),
                    _row('Sinh ngày:', df.format(memberBirthDate), fontBold),
                    _row('Cha:', fatherName, fontBold),
                    _row('Mẹ:', motherName, fontBold),
                    pw.Divider(),
                    _row('Cha đỡ đầu:', godfatherName, fontBold),
                    _row('Mẹ đỡ đầu:', godmotherName, fontBold),
                    pw.Divider(),
                    _row('Đã được rửa tội ngày:', df.format(baptismDate), fontBold),
                    _row('Tại:', baptismPlace, fontBold),
                    _row('Cha cử hành:', priestName, fontBold),
                  ],
                ),
              ),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('(Dấu giáo xứ)', style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 64),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Cha xứ', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Text('(Ký và ghi rõ họ tên)', style: const pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
                      pw.SizedBox(height: 56),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Text('Cấp ngày ${df.format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
            ],
          ),
        ),
      ),
    );

    return pdf;
  }

  static pw.Widget _row(String label, String value, pw.Font bold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(fontSize: 12, font: bold, fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// Print/preview qua printing package — hoạt động trên Win/Mac/Android/Linux.
  static Future<void> printDocument(pw.Document doc, {String? jobName}) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: jobName ?? 'Real Church Manager Certificate',
    );
  }

  static Future<Uint8List> toBytes(pw.Document doc) => doc.save();
}

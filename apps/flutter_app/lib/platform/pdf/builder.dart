// PDF builder — sinh chứng chỉ Bí Tích layout VN chuẩn.
// 5 sổ: Rửa Tội · Thêm Sức · Hôn Phối · Xức Dầu · An Táng.
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class RealCmCertificateBuilder {
  RealCmCertificateBuilder._();

  static final _df = DateFormat('dd/MM/yyyy', 'vi');

  // ─── Rửa Tội ──────────────────────────────────────────────
  static Future<pw.Document> baptism({
    required String parishName,
    required String parishAddress,
    required Map<String, dynamic> data,
    required String memberFullName,
    required String memberSaintName,
    DateTime? memberBirthDate,
  }) async {
    return _build(
      parishName: parishName,
      parishAddress: parishAddress,
      titleVi: 'CHỨNG CHỈ RỬA TỘI',
      titleLatin: '(Certificatum Baptismi)',
      bookNumber: data['book_number']?.toString() ?? '',
      rows: [
        ('Tên Thánh', memberSaintName),
        ('Họ và tên', memberFullName),
        if (memberBirthDate != null) ('Sinh ngày', _df.format(memberBirthDate)),
        ('Cha', data['father_name']?.toString() ?? ''),
        ('Mẹ', data['mother_name']?.toString() ?? ''),
        _divider,
        ('Cha đỡ đầu', data['godfather_name']?.toString() ?? ''),
        ('Mẹ đỡ đầu', data['godmother_name']?.toString() ?? ''),
        _divider,
        ('Đã được rửa tội ngày', _date(data['baptism_date'])),
        ('Tại', data['baptism_place']?.toString() ?? ''),
        ('Cha cử hành', data['priest_name']?.toString() ?? ''),
      ],
    );
  }

  // ─── Thêm Sức ─────────────────────────────────────────────
  static Future<pw.Document> confirmation({
    required String parishName,
    required String parishAddress,
    required Map<String, dynamic> data,
    required String memberFullName,
  }) async {
    return _build(
      parishName: parishName,
      parishAddress: parishAddress,
      titleVi: 'CHỨNG CHỈ THÊM SỨC',
      titleLatin: '(Certificatum Confirmationis)',
      bookNumber: data['book_number']?.toString() ?? '',
      rows: [
        ('Họ và tên', memberFullName),
        ('Tên Thánh Thêm Sức', data['confirmation_saint_name']?.toString() ?? ''),
        _divider,
        ('Người đỡ đầu', data['sponsor_name']?.toString() ?? ''),
        _divider,
        ('Đã được Thêm Sức ngày', _date(data['confirmation_date'])),
        ('Tại', data['confirmation_place']?.toString() ?? ''),
        ('Đức Giám mục cử hành', data['bishop_name']?.toString() ?? ''),
      ],
    );
  }

  // ─── Hôn Phối ─────────────────────────────────────────────
  static Future<pw.Document> marriage({
    required String parishName,
    required String parishAddress,
    required Map<String, dynamic> data,
    required String groomFullName,
    required String brideFullName,
  }) async {
    return _build(
      parishName: parishName,
      parishAddress: parishAddress,
      titleVi: 'CHỨNG CHỈ HÔN PHỐI',
      titleLatin: '(Certificatum Matrimonii)',
      bookNumber: data['book_number']?.toString() ?? '',
      rows: [
        ('Chú rể', groomFullName),
        ('Cha chú rể', data['groom_father_name']?.toString() ?? ''),
        ('Mẹ chú rể', data['groom_mother_name']?.toString() ?? ''),
        _divider,
        ('Cô dâu', brideFullName),
        ('Cha cô dâu', data['bride_father_name']?.toString() ?? ''),
        ('Mẹ cô dâu', data['bride_mother_name']?.toString() ?? ''),
        _divider,
        ('Người chứng 1', data['witness_1_name']?.toString() ?? ''),
        ('Người chứng 2', data['witness_2_name']?.toString() ?? ''),
        if ((data['dispensation']?.toString() ?? '').isNotEmpty)
          ('Miễn chuẩn', data['dispensation']?.toString() ?? ''),
        _divider,
        ('Đã kết hôn ngày', _date(data['marriage_date'])),
        ('Tại', data['marriage_place']?.toString() ?? ''),
        ('Cha chủ sự', data['priest_name']?.toString() ?? ''),
      ],
    );
  }

  // ─── Xức Dầu ──────────────────────────────────────────────
  static Future<pw.Document> anointing({
    required String parishName,
    required String parishAddress,
    required Map<String, dynamic> data,
    required String memberFullName,
  }) async {
    return _build(
      parishName: parishName,
      parishAddress: parishAddress,
      titleVi: 'CHỨNG CHỈ XỨC DẦU BỆNH NHÂN',
      titleLatin: '(Unctio Infirmorum)',
      bookNumber: data['book_number']?.toString() ?? '',
      rows: [
        ('Họ và tên bệnh nhân', memberFullName),
        if ((data['condition']?.toString() ?? '').isNotEmpty)
          ('Tình trạng', data['condition']?.toString() ?? ''),
        _divider,
        ('Đã được xức dầu ngày', _date(data['anointing_date'])),
        ('Tại', data['anointing_place']?.toString() ?? ''),
        ('Cha cử hành', data['priest_name']?.toString() ?? ''),
      ],
    );
  }

  // ─── An Táng ──────────────────────────────────────────────
  static Future<pw.Document> funeral({
    required String parishName,
    required String parishAddress,
    required Map<String, dynamic> data,
    required String memberFullName,
  }) async {
    return _build(
      parishName: parishName,
      parishAddress: parishAddress,
      titleVi: 'CHỨNG CHỈ AN TÁNG',
      titleLatin: '(Certificatum Funeris)',
      bookNumber: data['book_number']?.toString() ?? '',
      rows: [
        ('Họ và tên người quá cố', memberFullName),
        ('Ngày qua đời', _date(data['death_date'])),
        ('Nguyên nhân', data['death_cause']?.toString() ?? ''),
        _divider,
        ('Ngày an táng', _date(data['funeral_date'])),
        ('Nơi an táng', data['burial_place']?.toString() ?? ''),
        ('Cha chủ tế', data['priest_name']?.toString() ?? ''),
      ],
    );
  }

  // ─── Helper internal ──────────────────────────────────────
  static const _divider = ('__divider__', '');

  static Future<pw.Document> _build({
    required String parishName,
    required String parishAddress,
    required String titleVi,
    required String titleLatin,
    required String bookNumber,
    required List<(String, String)> rows,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.notoSerifRegular();
    final fontBold = await PdfGoogleFonts.notoSerifBold();

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
              pw.Text(titleVi,
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.Text(titleLatin,
                  style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic)),
              pw.SizedBox(height: 8),
              if (bookNumber.isNotEmpty)
                pw.Text('Số sổ: $bookNumber', style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 24),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 24),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    for (final r in rows)
                      if (r.$1 == '__divider__')
                        pw.Divider()
                      else
                        _row(r.$1, r.$2, fontBold),
                  ],
                ),
              ),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(children: [
                    pw.Text('(Dấu giáo xứ)', style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 64),
                  ]),
                  pw.Column(children: [
                    pw.Text('Cha xứ', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Text('(Ký và ghi rõ họ tên)', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
                    pw.SizedBox(height: 56),
                  ]),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Text('Cấp ngày ${_df.format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
            ],
          ),
        ),
      ),
    );

    return pdf;
  }

  static String _date(dynamic v) {
    if (v == null || v.toString().isEmpty) return '';
    final d = DateTime.tryParse(v.toString());
    if (d == null) return v.toString();
    return _df.format(d);
  }

  static pw.Widget _row(String label, String value, pw.Font bold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 160,
            child: pw.Text('$label:', style: const pw.TextStyle(fontSize: 12)),
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

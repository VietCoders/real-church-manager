// PDF preview screen — full-screen wrapper quanh package:printing PdfPreview với toolbar
// Print/Save/Share. Dùng cho chứng chỉ Bí Tích + báo cáo PDF trước khi gửi máy in.
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RealCmPdfPreviewScreen extends StatelessWidget {
  const RealCmPdfPreviewScreen({super.key, required this.title, required this.document, this.fileName});

  final String title;
  final pw.Document document;
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PdfPreview(
        canDebug: false,
        canChangeOrientation: false,
        canChangePageFormat: false,
        pdfFileName: fileName ?? '${title.replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_')}.pdf',
        build: (PdfPageFormat format) async => document.save(),
        loadingWidget: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

/// Helper: mở preview screen từ bất kỳ Navigator nào.
Future<void> realCmShowPdfPreview(
  BuildContext context, {
  required String title,
  required pw.Document document,
  String? fileName,
}) async {
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => RealCmPdfPreviewScreen(title: title, document: document, fileName: fileName),
      fullscreenDialog: true,
    ),
  );
}

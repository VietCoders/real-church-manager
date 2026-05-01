// Excel exporter cho báo cáo — sinh .xlsx file rồi mở qua OS default app.
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class RealCmExcelExporter {
  RealCmExcelExporter._();

  /// Tạo file .xlsx với 1 sheet "Báo cáo": title row + header + data rows.
  /// Trả về path file đã save trong thư mục Documents/temp.
  static Future<String> exportSimpleTable({
    required String parishName,
    required String title,
    String? caption,
    required List<MapEntry<String, String>> rows,
  }) async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    final sheet = excel['Báo cáo'];

    // Title
    sheet.appendRow([TextCellValue(parishName)]);
    sheet.appendRow([TextCellValue(title)]);
    if (caption != null) sheet.appendRow([TextCellValue(caption)]);
    sheet.appendRow([]);

    // Header
    sheet.appendRow([
      TextCellValue('Chỉ tiêu'),
      TextCellValue('Giá trị'),
    ]);

    // Data
    for (final r in rows) {
      sheet.appendRow([
        TextCellValue(r.key),
        TextCellValue(r.value),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) throw StateError('Excel encode trả về null');

    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:\.]'), '-');
    final safeTitle = title.replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
    final path = '${dir.path}/report_${safeTitle}_$ts.xlsx';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return path;
  }
}

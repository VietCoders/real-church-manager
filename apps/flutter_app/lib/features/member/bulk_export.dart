// Bulk export giáo dân ra Excel — toàn bộ active members.
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../platform/pocketbase/client.dart';
import '../../ui/toast/service.dart';

Future<void> exportMembersToExcel(BuildContext ctx) async {
  try {
    final pb = RealCmPocketBase.instance();
    final all = <RecordModel>[];
    int page = 1;
    while (true) {
      final res = await pb.collection('members').getList(
        page: page,
        perPage: 200,
        filter: 'deleted_at = null',
        expand: 'district_id',
        sort: 'full_name',
      );
      all.addAll(res.items);
      if (page >= res.totalPages) break;
      page++;
    }
    if (!ctx.mounted) return;

    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    final sheet = excel['Giáo dân'];
    final df = DateFormat('dd/MM/yyyy', 'vi');

    sheet.appendRow([
      TextCellValue('STT'),
      TextCellValue('Tên Thánh'),
      TextCellValue('Họ và tên'),
      TextCellValue('Giới tính'),
      TextCellValue('Ngày sinh'),
      TextCellValue('Nơi sinh'),
      TextCellValue('SĐT'),
      TextCellValue('Email'),
      TextCellValue('Địa chỉ'),
      TextCellValue('Giáo họ'),
      TextCellValue('Cha'),
      TextCellValue('Mẹ'),
      TextCellValue('Trạng thái'),
    ]);

    for (var i = 0; i < all.length; i++) {
      final r = all[i];
      final exp = r.expand['district_id'];
      final districtName = (exp != null && exp.isNotEmpty) ? exp.first.data['name']?.toString() ?? '' : '';
      final birth = DateTime.tryParse(r.data['birth_date']?.toString() ?? '');
      final gender = r.data['gender']?.toString() ?? '';
      final genderLabel = gender == 'male' ? 'Nam' : gender == 'female' ? 'Nữ' : gender == 'other' ? 'Khác' : '';
      final status = r.data['status']?.toString() ?? '';
      final statusLabel = {
        'active': 'Đang sinh hoạt',
        'moved_out': 'Đã chuyển',
        'deceased': 'Đã qua đời',
        'excommunicated': 'Vạ tuyệt thông',
      }[status] ?? status;

      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(r.data['saint_name']?.toString() ?? ''),
        TextCellValue(r.data['full_name']?.toString() ?? ''),
        TextCellValue(genderLabel),
        TextCellValue(birth != null ? df.format(birth) : ''),
        TextCellValue(r.data['birth_place']?.toString() ?? ''),
        TextCellValue(r.data['phone']?.toString() ?? ''),
        TextCellValue(r.data['email']?.toString() ?? ''),
        TextCellValue(r.data['address']?.toString() ?? ''),
        TextCellValue(districtName),
        TextCellValue(r.data['father_name_text']?.toString() ?? ''),
        TextCellValue(r.data['mother_name_text']?.toString() ?? ''),
        TextCellValue(statusLabel),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) throw StateError('Excel encode null');
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:\.]'), '-');
    final path = '${dir.path}/members_export_$ts.xlsx';
    await File(path).writeAsBytes(bytes, flush: true);
    if (!ctx.mounted) return;
    realCmToast(ctx, 'Đã xuất ${all.length} giáo dân: $path', type: RealCmToastType.success);
    await OpenFilex.open(path);
  } catch (e) {
    if (ctx.mounted) realCmToast(ctx, 'Lỗi xuất Excel: $e', type: RealCmToastType.error);
  }
}

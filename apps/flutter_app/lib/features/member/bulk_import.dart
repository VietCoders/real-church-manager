// Bulk import giáo dân từ Excel (.xlsx) hoặc CSV (.csv).
// Cột yêu cầu: Tên Thánh, Họ và tên, Giới tính (Nam/Nữ/Khác), Ngày sinh (dd/MM/yyyy),
// SĐT, Email, Địa chỉ, Cha, Mẹ, Giáo họ. Cột thiếu OK → bỏ qua.
import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/member/repository.dart';
import 'member_form.dart' show memberRepoProvider;
import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../platform/pocketbase/auth.dart';
import '../../platform/pocketbase/client.dart';
import '../../ui/scaffold/app_shell.dart';
import '../../ui/toast/service.dart';

class _ImportRow {
  _ImportRow({required this.raw, this.error, this.skipReason});
  final Map<String, String> raw;
  String? error;
  String? skipReason;
  bool selected = true;

  String get fullName => raw['full_name'] ?? '';
  String get saintName => raw['saint_name'] ?? '';
  String get displayName => saintName.isEmpty ? fullName : '$saintName $fullName';
}

class MemberBulkImportScreen extends ConsumerStatefulWidget {
  const MemberBulkImportScreen({super.key});
  @override
  ConsumerState<MemberBulkImportScreen> createState() => _MemberBulkImportScreenState();
}

class _MemberBulkImportScreenState extends ConsumerState<MemberBulkImportScreen> {
  List<_ImportRow> _rows = [];
  String? _fileName;
  bool _importing = false;
  int _imported = 0;
  int _skipped = 0;
  Map<String, String> _districtNameToId = {};

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      Uint8List? bytes = file.bytes;
      if (bytes == null && file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }
      if (bytes == null) {
        if (mounted) realCmToast(context, 'Không đọc được file', type: RealCmToastType.error);
        return;
      }
      // Load district map để tra cứu
      try {
        final pb = RealCmPocketBase.instance();
        final districts = await pb.collection('districts').getFullList();
        _districtNameToId = {
          for (final d in districts) (d.data['name']?.toString() ?? '').toLowerCase(): d.id,
        };
      } catch (_) {}
      // Parse
      final rows = file.extension == 'csv'
          ? _parseCsv(String.fromCharCodes(bytes))
          : _parseExcel(bytes);
      setState(() {
        _rows = rows;
        _fileName = file.name;
        _imported = 0;
        _skipped = 0;
      });
    } catch (e) {
      if (mounted) realCmToast(context, 'Lỗi đọc file: $e', type: RealCmToastType.error);
    }
  }

  List<_ImportRow> _parseCsv(String content) {
    final lines = content.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return [];
    final headers = _splitCsvLine(lines.first).map((h) => h.trim()).toList();
    final result = <_ImportRow>[];
    for (var i = 1; i < lines.length; i++) {
      final cells = _splitCsvLine(lines[i]);
      final raw = <String, String>{};
      for (var j = 0; j < headers.length && j < cells.length; j++) {
        raw[_normalizeHeader(headers[j])] = cells[j].trim();
      }
      if ((raw['full_name'] ?? '').isEmpty) continue;
      result.add(_ImportRow(raw: raw));
    }
    return result;
  }

  List<String> _splitCsvLine(String line) {
    final out = <String>[];
    var buf = StringBuffer();
    var quoted = false;
    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (c == '"') {
        quoted = !quoted;
        continue;
      }
      if (c == ',' && !quoted) {
        out.add(buf.toString());
        buf = StringBuffer();
      } else {
        buf.write(c);
      }
    }
    out.add(buf.toString());
    return out;
  }

  List<_ImportRow> _parseExcel(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    if (excel.tables.isEmpty) return [];
    final sheet = excel.tables.values.first;
    if (sheet.maxRows < 2) return [];
    final headerRow = sheet.row(0);
    final headers = headerRow.map((c) => (c?.value?.toString() ?? '').trim()).toList();
    final result = <_ImportRow>[];
    for (var r = 1; r < sheet.maxRows; r++) {
      final cells = sheet.row(r);
      final raw = <String, String>{};
      for (var j = 0; j < headers.length && j < cells.length; j++) {
        final v = cells[j]?.value;
        if (v == null) continue;
        final s = v is DateTime ? DateFormat('dd/MM/yyyy').format(v) : v.toString();
        raw[_normalizeHeader(headers[j])] = s.trim();
      }
      if ((raw['full_name'] ?? '').isEmpty) continue;
      result.add(_ImportRow(raw: raw));
    }
    return result;
  }

  String _normalizeHeader(String h) {
    final lower = h.toLowerCase().trim();
    return {
      'tên thánh': 'saint_name',
      'ten thanh': 'saint_name',
      'họ và tên': 'full_name',
      'họ tên': 'full_name',
      'ho va ten': 'full_name',
      'ho ten': 'full_name',
      'giới tính': 'gender',
      'gioi tinh': 'gender',
      'ngày sinh': 'birth_date',
      'ngay sinh': 'birth_date',
      'sđt': 'phone',
      'điện thoại': 'phone',
      'dien thoai': 'phone',
      'phone': 'phone',
      'email': 'email',
      'địa chỉ': 'address',
      'dia chi': 'address',
      'address': 'address',
      'cha': 'father_name_text',
      'cha (text)': 'father_name_text',
      'mẹ': 'mother_name_text',
      'me': 'mother_name_text',
      'giáo họ': 'district_name',
      'giao ho': 'district_name',
      'district': 'district_name',
    }[lower] ?? lower;
  }

  String? _parseGender(String? s) {
    if (s == null || s.isEmpty) return null;
    final l = s.toLowerCase().trim();
    if (l == 'nam' || l == 'male' || l == 'm') return 'male';
    if (l == 'nữ' || l == 'nu' || l == 'female' || l == 'f') return 'female';
    return 'other';
  }

  DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    for (final fmt in ['dd/MM/yyyy', 'yyyy-MM-dd', 'd/M/yyyy', 'dd-MM-yyyy']) {
      try {
        return DateFormat(fmt).parseStrict(s);
      } catch (_) {}
    }
    return DateTime.tryParse(s);
  }

  Future<void> _runImport() async {
    setState(() {
      _importing = true;
      _imported = 0;
      _skipped = 0;
    });
    final repo = ref.read(memberRepoProvider);
    for (final row in _rows.where((r) => r.selected && r.error == null)) {
      try {
        final birth = _parseDate(row.raw['birth_date']);
        // Dedup check
        final dups = await repo.findDuplicates(
          fullName: row.fullName,
          birthDate: birth,
          saintName: row.saintName,
        );
        if (dups.isNotEmpty) {
          row.skipReason = 'Trùng với ${dups.first.displayName}';
          row.selected = false;
          _skipped++;
          if (mounted) setState(() {});
          continue;
        }
        final body = <String, dynamic>{
          if (row.saintName.isNotEmpty) 'saint_name': row.saintName,
          'full_name': row.fullName,
          if (_parseGender(row.raw['gender']) != null) 'gender': _parseGender(row.raw['gender']),
          if (birth != null) 'birth_date': birth.toIso8601String(),
          if ((row.raw['phone'] ?? '').isNotEmpty) 'phone': row.raw['phone'],
          if ((row.raw['email'] ?? '').isNotEmpty) 'email': row.raw['email'],
          if ((row.raw['address'] ?? '').isNotEmpty) 'address': row.raw['address'],
          if ((row.raw['father_name_text'] ?? '').isNotEmpty) 'father_name_text': row.raw['father_name_text'],
          if ((row.raw['mother_name_text'] ?? '').isNotEmpty) 'mother_name_text': row.raw['mother_name_text'],
          'status': 'active',
        };
        final dn = (row.raw['district_name'] ?? '').toLowerCase();
        if (dn.isNotEmpty && _districtNameToId[dn] != null) {
          body['district_id'] = _districtNameToId[dn];
        }
        await repo.create(body);
        _imported++;
        if (mounted) setState(() {});
      } catch (e) {
        row.error = e.toString();
        if (mounted) setState(() {});
      }
    }
    if (mounted) {
      setState(() => _importing = false);
      realCmToast(context, 'Đã import $_imported giáo dân (bỏ qua $_skipped trùng)',
          type: RealCmToastType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(realCmAuthProvider);
    if (!auth.canEditMembers) {
      return RealCmAppShell(title: 'Import giáo dân', body: const Center(child: Text('Không có quyền')));
    }
    return RealCmAppShell(
      title: 'Import giáo dân từ Excel/CSV',
      body: Padding(
        padding: const EdgeInsets.all(RealCmSpacing.s4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.all(RealCmSpacing.s3),
            decoration: BoxDecoration(
              color: RealCmColors.info.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(RealCmRadius.md),
            ),
            child: const Row(children: [
              Icon(Icons.info_outline, color: RealCmColors.info, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text(
                'Cột nhận biết: Tên Thánh, Họ và tên (BẮT BUỘC), Giới tính, Ngày sinh, SĐT, Email, Địa chỉ, Cha, Mẹ, Giáo họ. '
                'Có dedup tự động — bỏ qua nếu trùng tên + ngày sinh.',
                style: TextStyle(fontSize: 13),
              )),
            ]),
          ),
          const SizedBox(height: RealCmSpacing.s3),
          Row(children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.file_upload_outlined),
              label: const Text('Chọn file Excel / CSV'),
              onPressed: _importing ? null : _pickFile,
            ),
            const SizedBox(width: 12),
            if (_fileName != null) Expanded(child: Text(_fileName!, style: const TextStyle(color: RealCmColors.textMuted))),
          ]),
          if (_rows.isNotEmpty) ...[
            const SizedBox(height: RealCmSpacing.s3),
            Row(children: [
              Text('Tổng: ${_rows.length} hàng', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              if (_imported > 0) Text('✓ $_imported đã import', style: const TextStyle(color: RealCmColors.success)),
              const SizedBox(width: 16),
              if (_skipped > 0) Text('⚠ $_skipped trùng', style: const TextStyle(color: RealCmColors.warning)),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(RealCmIcons.add, size: 18),
                label: Text(_importing ? 'Đang import...' : 'Import'),
                onPressed: _importing ? null : _runImport,
              ),
            ]),
            const SizedBox(height: RealCmSpacing.s2),
            Expanded(
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.outlineVariant), borderRadius: BorderRadius.circular(RealCmRadius.md)),
                child: ListView.separated(
                  itemCount: _rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final row = _rows[i];
                    return CheckboxListTile(
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: row.selected,
                      onChanged: row.error != null ? null : (v) => setState(() => row.selected = v ?? false),
                      title: Text(row.displayName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text([
                        if (row.raw['gender'] != null) row.raw['gender']!,
                        if (row.raw['birth_date'] != null) row.raw['birth_date']!,
                        if (row.raw['phone'] != null) row.raw['phone']!,
                        if (row.raw['district_name'] != null) row.raw['district_name']!,
                      ].where((s) => s.isNotEmpty).join(' · '),
                          style: const TextStyle(fontSize: 12)),
                      secondary: row.error != null
                          ? Tooltip(message: row.error!, child: const Icon(Icons.error_outline, color: RealCmColors.danger, size: 18))
                          : row.skipReason != null
                              ? Tooltip(message: row.skipReason!, child: const Icon(Icons.warning_amber_outlined, color: RealCmColors.warning, size: 18))
                              : null,
                    );
                  },
                ),
              ),
            ),
          ] else ...[
            const Spacer(),
            const Center(child: Text('Chọn file để bắt đầu', style: TextStyle(color: RealCmColors.textMuted))),
            const Spacer(),
          ],
        ]),
      ),
    );
  }
}

// Activity log screen — chỉ priest_pastor xem được. Hiển thị log create/update/delete
// trên các collection quan trọng (members, sacraments, donations) với info user + timestamp.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../platform/pocketbase/auth.dart';
import '../../platform/pocketbase/client.dart';
import '../../ui/scaffold/app_shell.dart';

final _logsProvider = FutureProvider.autoDispose.family<List<RecordModel>, String?>((ref, filter) async {
  final pb = RealCmPocketBase.instance();
  try {
    final res = await pb.collection('activity_logs').getList(
      page: 1,
      perPage: 200,
      sort: '-created',
      filter: filter,
      expand: 'user_id',
    );
    return res.items;
  } catch (_) {
    return <RecordModel>[];
  }
});

class ActivityLogScreen extends ConsumerStatefulWidget {
  const ActivityLogScreen({super.key});
  @override
  ConsumerState<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends ConsumerState<ActivityLogScreen> {
  String? _opFilter; // create/update/delete
  String? _collectionFilter;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(realCmAuthProvider);
    if (!auth.isPriestPastor) {
      return RealCmAppShell(
        title: 'Nhật ký hoạt động',
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(RealCmSpacing.s5),
            child: Column(mainAxisSize: MainAxisSize.min, children: const [
              Icon(RealCmIcons.lock, size: 56, color: RealCmColors.warning),
              SizedBox(height: RealCmSpacing.s3),
              Text('Chỉ Cha xứ xem được', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      );
    }

    final filters = <String>[];
    if (_opFilter != null) filters.add('op = "$_opFilter"');
    if (_collectionFilter != null) filters.add('collection = "$_collectionFilter"');
    final filter = filters.isEmpty ? null : filters.join(' && ');
    final async = ref.watch(_logsProvider(filter));
    final df = DateFormat('dd/MM/yyyy HH:mm:ss', 'vi');

    return RealCmAppShell(
      title: 'Nhật ký hoạt động',
      actions: [
        IconButton(
          icon: const Icon(RealCmIcons.refresh),
          onPressed: () => ref.invalidate(_logsProvider(filter)),
        ),
      ],
      body: Column(children: [
        Container(
          padding: const EdgeInsets.all(RealCmSpacing.s3),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              const Text('Hành động:', style: TextStyle(color: RealCmColors.textMuted, fontSize: 13)),
              const SizedBox(width: 8),
              _chip(label: 'Tất cả', value: null, current: _opFilter, onSelect: (v) => setState(() => _opFilter = v)),
              _chip(label: 'Thêm', value: 'create', current: _opFilter, onSelect: (v) => setState(() => _opFilter = v)),
              _chip(label: 'Sửa', value: 'update', current: _opFilter, onSelect: (v) => setState(() => _opFilter = v)),
              _chip(label: 'Xoá', value: 'delete', current: _opFilter, onSelect: (v) => setState(() => _opFilter = v)),
              const SizedBox(width: 16),
              const Text('Module:', style: TextStyle(color: RealCmColors.textMuted, fontSize: 13)),
              const SizedBox(width: 8),
              _chip(label: 'Tất cả', value: null, current: _collectionFilter, onSelect: (v) => setState(() => _collectionFilter = v)),
              _chip(label: 'Giáo dân', value: 'members', current: _collectionFilter, onSelect: (v) => setState(() => _collectionFilter = v)),
              _chip(label: 'Gia đình', value: 'families', current: _collectionFilter, onSelect: (v) => setState(() => _collectionFilter = v)),
              _chip(label: 'Bí Tích', value: 'sacrament_baptism', current: _collectionFilter, onSelect: (v) => setState(() => _collectionFilter = v)),
              _chip(label: 'Thu chi', value: 'donations', current: _collectionFilter, onSelect: (v) => setState(() => _collectionFilter = v)),
            ]),
          ),
        ),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Padding(
              padding: const EdgeInsets.all(RealCmSpacing.s4),
              child: Text('Lỗi: $e', style: const TextStyle(color: RealCmColors.danger)),
            )),
            data: (logs) {
              if (logs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Chưa có nhật ký nào.\nNhật ký sẽ tự động ghi khi có thay đổi dữ liệu.',
                        style: TextStyle(color: RealCmColors.textMuted), textAlign: TextAlign.center),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: RealCmSpacing.s2),
                itemCount: logs.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 60),
                itemBuilder: (_, i) {
                  final log = logs[i];
                  final op = log.data['op']?.toString() ?? '';
                  final col = log.data['collection']?.toString() ?? '';
                  final summary = log.data['summary']?.toString() ?? '';
                  final created = DateTime.tryParse(log.data['created']?.toString() ?? log.created);
                  final exp = log.expand['user_id'];
                  final userName = (exp != null && exp.isNotEmpty)
                      ? (exp.first.data['name']?.toString() ?? exp.first.data['username']?.toString() ?? 'Không rõ')
                      : 'Không rõ';
                  final meta = log.data['meta'];
                  final changes = (meta is Map ? meta['changes'] : null) as Map?;
                  return ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: RealCmSpacing.s4, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: _opColor(op).withValues(alpha: 0.15),
                      child: Icon(_opIcon(op), color: _opColor(op), size: 18),
                    ),
                    title: Text(summary, style: const TextStyle(fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '$userName · ${_collectionLabel(col)} · ${created != null ? df.format(created) : ''}',
                        style: const TextStyle(fontSize: 12, color: RealCmColors.textMuted),
                      ),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(72, 0, 16, 12),
                    children: [
                      if (changes != null && changes.isNotEmpty)
                        for (final entry in changes.entries)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              SizedBox(
                                width: 140,
                                child: Text(_fieldLabel(entry.key.toString()),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: RealCmColors.textMuted)),
                              ),
                              Expanded(
                                child: Wrap(spacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: RealCmColors.danger.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(_fmtVal((entry.value as Map)['from']),
                                        style: const TextStyle(fontSize: 12, color: RealCmColors.danger)),
                                  ),
                                  const Icon(Icons.arrow_forward, size: 12, color: RealCmColors.textMuted),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: RealCmColors.success.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(_fmtVal((entry.value as Map)['to']),
                                        style: const TextStyle(fontSize: 12, color: RealCmColors.success)),
                                  ),
                                ]),
                              ),
                            ]),
                          )
                      else
                        const Text('(Không có thay đổi field nào ghi nhận được)',
                            style: TextStyle(fontSize: 12, color: RealCmColors.textMuted)),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _chip({required String label, required String? value, required String? current, required ValueChanged<String?> onSelect}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: current == value,
        onSelected: (_) => onSelect(value),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Color _opColor(String op) {
    switch (op) {
      case 'create': return RealCmColors.success;
      case 'update': return RealCmColors.info;
      case 'delete': return RealCmColors.danger;
      default: return RealCmColors.textMuted;
    }
  }

  IconData _opIcon(String op) {
    switch (op) {
      case 'create': return Icons.add_circle_outline;
      case 'update': return Icons.edit_outlined;
      case 'delete': return Icons.delete_outline;
      default: return Icons.history;
    }
  }

  String _fieldLabel(String f) {
    return {
      'full_name': 'Họ tên',
      'saint_name': 'Tên Thánh',
      'gender': 'Giới tính',
      'birth_date': 'Ngày sinh',
      'phone': 'Điện thoại',
      'email': 'Email',
      'address': 'Địa chỉ',
      'district_id': 'Giáo họ',
      'family_id': 'Gia đình',
      'status': 'Trạng thái',
      'photo': 'Ảnh',
      'family_name': 'Tên gia đình',
      'head_id': 'Gia trưởng',
      'name': 'Tên',
      'role': 'Vai trò',
      'priest_name': 'Cha cử hành',
      'baptism_date': 'Ngày Rửa Tội',
      'confirmation_date': 'Ngày Thêm Sức',
      'marriage_date': 'Ngày Hôn Phối',
      'amount': 'Số tiền',
      'donor_name': 'Người dâng',
      'description': 'Mô tả',
      'notes': 'Ghi chú',
      'deleted_at': 'Đã xoá',
    }[f] ?? f;
  }

  String _fmtVal(dynamic v) {
    if (v == null || v.toString().isEmpty) return '∅';
    final s = v.toString();
    if (s.length > 60) return '${s.substring(0, 60)}…';
    return s;
  }

  String _collectionLabel(String col) {
    return {
      'members': 'Giáo dân',
      'families': 'Gia đình',
      'districts': 'Giáo họ',
      'sacrament_baptism': 'Sổ Rửa Tội',
      'sacrament_confirmation': 'Sổ Thêm Sức',
      'sacrament_marriage': 'Sổ Hôn Phối',
      'sacrament_anointing': 'Sổ Xức Dầu',
      'sacrament_funeral': 'Sổ An Táng',
      'donations': 'Sổ thu chi',
      'mass_intentions': 'Lễ ý',
      'groups': 'Đoàn thể',
      'liturgical_events': 'Lịch phụng vụ',
      'parish_settings': 'Cấu hình giáo xứ',
      'users': 'Người dùng',
    }[col] ?? col;
  }
}

// Parish settings — single record edit cho cấu hình giáo xứ.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../core/logging/logger.dart';
import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../platform/pocketbase/auth.dart';
import '../../platform/pocketbase/client.dart';
import '../../ui/scaffold/app_shell.dart';
import '../../ui/toast/service.dart';

class ParishSettingsRepository {
  ParishSettingsRepository();
  final _log = RealCmLogger.of('parish.repo');

  Future<RecordModel?> getOrNull() async {
    final pb = RealCmPocketBase.instance();
    try {
      final res = await pb.collection('parish_settings').getList(page: 1, perPage: 1);
      if (res.items.isEmpty) return null;
      return res.items.first;
    } catch (e) {
      _log.warning('Lỗi tải parish_settings: $e');
      return null;
    }
  }

  Future<RecordModel> save(String? id, Map<String, dynamic> data) async {
    final pb = RealCmPocketBase.instance();
    if (id == null) {
      return await pb.collection('parish_settings').create(body: data);
    }
    return await pb.collection('parish_settings').update(id, body: data);
  }
}

final parishRepoProvider = Provider((_) => ParishSettingsRepository());
final _parishProvider = FutureProvider.autoDispose<RecordModel?>(
  (ref) => ref.read(parishRepoProvider).getOrNull(),
);

class ParishSettingsScreen extends ConsumerStatefulWidget {
  const ParishSettingsScreen({super.key});

  @override
  ConsumerState<ParishSettingsScreen> createState() => _ParishSettingsScreenState();
}

class _ParishSettingsScreenState extends ConsumerState<ParishSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _dioceseCtrl = TextEditingController();
  final _pastorCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _foundingYearCtrl = TextEditingController();
  final _patronSaintCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _feastDay;
  String? _existingId;
  bool _initialized = false;
  bool _saving = false;

  void _populate(RecordModel rec) {
    _existingId = rec.id;
    _nameCtrl.text = rec.data['name']?.toString() ?? '';
    _addressCtrl.text = rec.data['address']?.toString() ?? '';
    _dioceseCtrl.text = rec.data['diocese']?.toString() ?? '';
    _pastorCtrl.text = rec.data['pastor_name']?.toString() ?? '';
    _phoneCtrl.text = rec.data['phone']?.toString() ?? '';
    _emailCtrl.text = rec.data['email']?.toString() ?? '';
    _foundingYearCtrl.text = rec.data['founding_year']?.toString() ?? '';
    _patronSaintCtrl.text = rec.data['patron_saint']?.toString() ?? '';
    _notesCtrl.text = rec.data['notes']?.toString() ?? '';
    final fd = rec.data['feast_day']?.toString();
    _feastDay = (fd != null && fd.isNotEmpty) ? DateTime.tryParse(fd) : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final data = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'diocese': _dioceseCtrl.text.trim(),
        'pastor_name': _pastorCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'founding_year': int.tryParse(_foundingYearCtrl.text.trim()),
        'patron_saint': _patronSaintCtrl.text.trim(),
        'feast_day': _feastDay?.toIso8601String(),
        'notes': _notesCtrl.text.trim(),
      }..removeWhere((_, v) => v == null || (v is String && v.isEmpty));
      final saved = await ref.read(parishRepoProvider).save(_existingId, data);
      _existingId = saved.id;
      if (mounted) realCmToast(context, 'Đã lưu cấu hình giáo xứ', type: RealCmToastType.success);
      ref.invalidate(_parishProvider);
    } catch (e) {
      if (mounted) realCmToast(context, 'Lưu thất bại: $e', type: RealCmToastType.error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(realCmAuthProvider);
    final canEdit = auth.isPriest;
    final df = DateFormat('dd/MM', 'vi');

    return RealCmAppShell(
      title: 'Cấu hình giáo xứ',
      body: ref.watch(_parishProvider).when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (rec) {
          if (!_initialized) {
            if (rec != null) _populate(rec);
            _initialized = true;
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(RealCmSpacing.s5),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(RealCmSpacing.s4),
                        decoration: BoxDecoration(
                          color: RealCmColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(RealCmRadius.lg),
                        ),
                        child: Row(
                          children: [
                            const Icon(RealCmIcons.parish, color: RealCmColors.primary, size: 36),
                            const SizedBox(width: RealCmSpacing.s3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _nameCtrl.text.isEmpty ? 'Giáo xứ chưa cấu hình' : _nameCtrl.text,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                  ),
                                  if (_pastorCtrl.text.isNotEmpty)
                                    Text('Cha xứ: ${_pastorCtrl.text}',
                                        style: const TextStyle(color: RealCmColors.textMuted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: RealCmSpacing.s5),
                      _section('Thông tin cơ bản'),
                      TextFormField(
                        controller: _nameCtrl,
                        enabled: canEdit,
                        decoration: const InputDecoration(labelText: 'Tên giáo xứ *'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: RealCmSpacing.s3),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dioceseCtrl,
                              enabled: canEdit,
                              decoration: const InputDecoration(labelText: 'Giáo phận'),
                            ),
                          ),
                          const SizedBox(width: RealCmSpacing.s3),
                          Expanded(
                            child: TextFormField(
                              controller: _pastorCtrl,
                              enabled: canEdit,
                              decoration: const InputDecoration(labelText: 'Cha xứ'),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: RealCmSpacing.s3),
                      TextFormField(
                        controller: _addressCtrl,
                        enabled: canEdit,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Địa chỉ'),
                      ),
                      const SizedBox(height: RealCmSpacing.s4),
                      _section('Liên hệ'),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneCtrl,
                              enabled: canEdit,
                              decoration: const InputDecoration(labelText: 'Điện thoại'),
                            ),
                          ),
                          const SizedBox(width: RealCmSpacing.s3),
                          Expanded(
                            child: TextFormField(
                              controller: _emailCtrl,
                              enabled: canEdit,
                              decoration: const InputDecoration(labelText: 'Email'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: RealCmSpacing.s4),
                      _section('Lịch sử & Bổn mạng'),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _foundingYearCtrl,
                              enabled: canEdit,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Năm thành lập'),
                            ),
                          ),
                          const SizedBox(width: RealCmSpacing.s3),
                          Expanded(
                            child: TextFormField(
                              controller: _patronSaintCtrl,
                              enabled: canEdit,
                              decoration: const InputDecoration(labelText: 'Thánh bổn mạng'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: RealCmSpacing.s3),
                      InkWell(
                        onTap: !canEdit
                            ? null
                            : () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _feastDay ?? DateTime(DateTime.now().year, 1, 1),
                                  firstDate: DateTime(2000, 1, 1),
                                  lastDate: DateTime(2100, 12, 31),
                                  locale: const Locale('vi'),
                                );
                                if (picked != null) setState(() => _feastDay = picked);
                              },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Ngày lễ bổn mạng',
                            suffixIcon: const Icon(RealCmIcons.calendar),
                            enabled: canEdit,
                          ),
                          child: Text(_feastDay == null ? 'Chọn ngày...' : df.format(_feastDay!)),
                        ),
                      ),
                      const SizedBox(height: RealCmSpacing.s4),
                      _section('Ghi chú'),
                      TextFormField(
                        controller: _notesCtrl,
                        enabled: canEdit,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Ghi chú',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: RealCmSpacing.s5),
                      if (canEdit)
                        ElevatedButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: _saving
                              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(RealCmIcons.save, size: 18),
                          label: const Text('Lưu cấu hình'),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(RealCmSpacing.s3),
                          decoration: BoxDecoration(
                            color: RealCmColors.warning.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(RealCmRadius.md),
                          ),
                          child: const Row(
                            children: [
                              Icon(RealCmIcons.info, color: RealCmColors.warning, size: 18),
                              SizedBox(width: RealCmSpacing.s2),
                              Expanded(
                                child: Text('Chỉ Cha xứ / Cha phó được phép sửa cấu hình giáo xứ.'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.only(bottom: RealCmSpacing.s2),
        child: Row(
          children: [
            Container(width: 4, height: 16, decoration: BoxDecoration(color: RealCmColors.primary, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: RealCmSpacing.s2),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: RealCmColors.textMuted)),
          ],
        ),
      );

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _dioceseCtrl.dispose();
    _pastorCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _foundingYearCtrl.dispose();
    _patronSaintCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }
}

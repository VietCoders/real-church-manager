// Member form — modal đầy đủ thêm/sửa giáo dân.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../data/member/repository.dart';
import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../domain/member/entity.dart';
import '../../platform/pocketbase/client.dart';
import '../../ui/modal/service.dart';
import '../../ui/toast/service.dart';

final memberRepoProvider = Provider((_) => MemberRepository());

/// Show form modal. `existing == null` = thêm mới, ngược lại = sửa.
/// Returns saved Member nếu OK, null nếu cancel.
Future<Member?> showMemberFormModal(BuildContext context, WidgetRef ref, {Member? existing}) {
  return showDialog<Member>(
    context: context,
    barrierDismissible: false,
    builder: (_) => MemberFormDialog(existing: existing),
  );
}

class MemberFormDialog extends ConsumerStatefulWidget {
  const MemberFormDialog({super.key, this.existing});
  final Member? existing;

  @override
  ConsumerState<MemberFormDialog> createState() => _MemberFormDialogState();
}

class _MemberFormDialogState extends ConsumerState<MemberFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _saintCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _birthPlaceCtrl;
  late final TextEditingController _idNumberCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _fatherNameCtrl;
  late final TextEditingController _motherNameCtrl;
  RealCmGender? _gender;
  DateTime? _birthDate;
  RealCmMemberStatus _status = RealCmMemberStatus.active;
  bool _saving = false;
  File? _pendingPhoto; // ảnh chọn nhưng chưa upload (dùng cho create)
  String? _photoFilename; // filename hiện trong DB (existing member)
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    final m = widget.existing;
    _saintCtrl = TextEditingController(text: m?.saintName ?? '');
    _nameCtrl = TextEditingController(text: m?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: m?.phone ?? '');
    _emailCtrl = TextEditingController(text: m?.email ?? '');
    _addressCtrl = TextEditingController(text: m?.address ?? '');
    _birthPlaceCtrl = TextEditingController(text: m?.birthPlace ?? '');
    _idNumberCtrl = TextEditingController(text: m?.idNumber ?? '');
    _notesCtrl = TextEditingController(text: m?.notes ?? '');
    _fatherNameCtrl = TextEditingController(text: m?.fatherNameText ?? '');
    _motherNameCtrl = TextEditingController(text: m?.motherNameText ?? '');
    _gender = m?.gender;
    _birthDate = m?.birthDate;
    _status = m?.status ?? RealCmMemberStatus.active;
    _photoFilename = m?.photo;
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;
      final file = File(picked.path);
      // Nếu đang sửa member existing → upload luôn để có thumbnail ngay
      if (widget.existing != null) {
        setState(() => _uploadingPhoto = true);
        try {
          final updated = await ref.read(memberRepoProvider).uploadPhoto(widget.existing!.id, file);
          setState(() {
            _photoFilename = updated.photo;
            _pendingPhoto = null;
          });
          if (mounted) realCmToast(context, 'Đã cập nhật ảnh', type: RealCmToastType.success);
        } catch (e) {
          if (mounted) realCmToast(context, 'Tải ảnh thất bại: $e', type: RealCmToastType.error);
        } finally {
          if (mounted) setState(() => _uploadingPhoto = false);
        }
      } else {
        // Member chưa tạo — giữ file pending, upload sau khi create
        setState(() => _pendingPhoto = file);
      }
    } catch (e) {
      if (mounted) realCmToast(context, 'Không thể chọn ảnh: $e', type: RealCmToastType.error);
    }
  }

  Future<void> _removePhoto() async {
    if (widget.existing == null) {
      setState(() => _pendingPhoto = null);
      return;
    }
    final ok = await realCmConfirm(context,
        title: 'Xoá ảnh', body: 'Xác nhận xoá ảnh giáo dân này?', danger: true);
    if (!ok) return;
    try {
      final updated = await ref.read(memberRepoProvider).removePhoto(widget.existing!.id);
      setState(() => _photoFilename = updated.photo);
      if (mounted) realCmToast(context, 'Đã xoá ảnh', type: RealCmToastType.success);
    } catch (e) {
      if (mounted) realCmToast(context, 'Lỗi xoá ảnh: $e', type: RealCmToastType.error);
    }
  }

  @override
  void dispose() {
    _saintCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _birthPlaceCtrl.dispose();
    _idNumberCtrl.dispose();
    _notesCtrl.dispose();
    _fatherNameCtrl.dispose();
    _motherNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('vi'),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    // Duplicate detection — chỉ check khi tạo mới
    if (widget.existing == null) {
      try {
        final dups = await ref.read(memberRepoProvider).findDuplicates(
              fullName: _nameCtrl.text.trim(),
              birthDate: _birthDate,
              saintName: _saintCtrl.text.trim(),
            );
        if (dups.isNotEmpty && mounted) {
          final proceed = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              icon: const Icon(RealCmIcons.warning, color: RealCmColors.warning, size: 40),
              title: const Text('Có thể trùng giáo dân'),
              content: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phát hiện ${dups.length} giáo dân tên gần giống — kiểm tra xem có phải đã có sẵn?',
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: RealCmSpacing.s3),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 240),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(ctx).colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(RealCmRadius.md),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: dups.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final d = dups[i];
                          final birth = d.birthDate;
                          return ListTile(
                            dense: true,
                            leading: const Icon(RealCmIcons.member, size: 18),
                            title: Text(d.displayName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              [
                                if (birth != null) DateFormat('dd/MM/yyyy', 'vi').format(birth),
                                if (d.fatherNameText != null) 'Cha: ${d.fatherNameText}',
                              ].join(' · '),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Huỷ — sửa lại')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: RealCmColors.warning, foregroundColor: Colors.white),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Vẫn tạo mới'),
                ),
              ],
            ),
          );
          if (proceed != true) {
            setState(() => _saving = false);
            return;
          }
        }
      } catch (_) {
        // Duplicate check không bắt buộc — bỏ qua nếu lỗi
      }
    }

    try {
      final data = <String, dynamic>{
        'saint_name': _saintCtrl.text.trim(),
        'full_name': _nameCtrl.text.trim(),
        'gender': _gender?.name,
        'birth_date': _birthDate?.toIso8601String(),
        'birth_place': _birthPlaceCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'id_number': _idNumberCtrl.text.trim(),
        'father_name_text': _fatherNameCtrl.text.trim(),
        'mother_name_text': _motherNameCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
        'status': _status == RealCmMemberStatus.movedOut ? 'moved_out' : _status.name,
      }..removeWhere((_, v) => v == null || (v is String && v.isEmpty));

      final repo = ref.read(memberRepoProvider);
      var result = widget.existing == null
          ? await repo.create(data)
          : await repo.update(widget.existing!.id, data);
      // Upload pending photo nếu vừa create
      if (_pendingPhoto != null) {
        try {
          result = await repo.uploadPhoto(result.id, _pendingPhoto!);
        } catch (e) {
          if (mounted) realCmToast(context, 'Đã lưu giáo dân nhưng upload ảnh thất bại: $e', type: RealCmToastType.warning);
        }
      }
      if (mounted) {
        realCmToast(context,
            widget.existing == null ? 'Đã thêm giáo dân ${result.displayName}' : 'Đã cập nhật ${result.displayName}',
            type: RealCmToastType.success);
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) realCmToast(context, 'Lưu thất bại: $e', type: RealCmToastType.error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy', 'vi');
    final isEdit = widget.existing != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RealCmRadius.lg)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(RealCmSpacing.s4),
              decoration: BoxDecoration(
                color: RealCmColors.primary.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(RealCmRadius.lg)),
              ),
              child: Row(
                children: [
                  const Icon(RealCmIcons.member, color: RealCmColors.primary),
                  const SizedBox(width: RealCmSpacing.s3),
                  Expanded(
                    child: Text(
                      isEdit ? 'Sửa giáo dân' : 'Thêm giáo dân',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(RealCmIcons.close),
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(RealCmSpacing.s4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _section('Thông tin cá nhân'),
                      _PhotoSection(
                        memberId: widget.existing?.id,
                        photoFilename: _photoFilename,
                        pendingPhoto: _pendingPhoto,
                        uploading: _uploadingPhoto,
                        onPickGallery: () => _pickPhoto(ImageSource.gallery),
                        onPickCamera: () => _pickPhoto(ImageSource.camera),
                        onRemove: _removePhoto,
                      ),
                      const SizedBox(height: RealCmSpacing.s4),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _saintCtrl,
                              decoration: const InputDecoration(labelText: 'Tên Thánh', hintText: 'Phêrô, Maria...'),
                            ),
                          ),
                          const SizedBox(width: RealCmSpacing.s3),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _nameCtrl,
                              decoration: const InputDecoration(labelText: 'Họ và tên *'),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: RealCmSpacing.s3),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<RealCmGender>(
                              value: _gender,
                              decoration: const InputDecoration(labelText: 'Giới tính'),
                              items: const [
                                DropdownMenuItem(value: RealCmGender.male, child: Text('Nam')),
                                DropdownMenuItem(value: RealCmGender.female, child: Text('Nữ')),
                                DropdownMenuItem(value: RealCmGender.other, child: Text('Khác')),
                              ],
                              onChanged: (v) => setState(() => _gender = v),
                            ),
                          ),
                          const SizedBox(width: RealCmSpacing.s3),
                          Expanded(
                            child: InkWell(
                              onTap: _pickBirthDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(labelText: 'Ngày sinh', suffixIcon: Icon(RealCmIcons.calendar)),
                                child: Text(_birthDate == null ? 'Chọn...' : df.format(_birthDate!)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: RealCmSpacing.s3),
                      TextFormField(controller: _birthPlaceCtrl, decoration: const InputDecoration(labelText: 'Nơi sinh')),
                      const SizedBox(height: RealCmSpacing.s3),
                      TextFormField(controller: _idNumberCtrl, decoration: const InputDecoration(labelText: 'Số CCCD/CMND')),

                      const SizedBox(height: RealCmSpacing.s4),
                      _section('Liên hệ'),
                      TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Điện thoại')),
                      const SizedBox(height: RealCmSpacing.s3),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) return 'Email không hợp lệ';
                          return null;
                        },
                      ),
                      const SizedBox(height: RealCmSpacing.s3),
                      TextFormField(controller: _addressCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Địa chỉ')),

                      const SizedBox(height: RealCmSpacing.s4),
                      _section('Cha mẹ (nếu không trong hệ thống)'),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _fatherNameCtrl, decoration: const InputDecoration(labelText: 'Tên cha'))),
                          const SizedBox(width: RealCmSpacing.s3),
                          Expanded(child: TextFormField(controller: _motherNameCtrl, decoration: const InputDecoration(labelText: 'Tên mẹ'))),
                        ],
                      ),

                      const SizedBox(height: RealCmSpacing.s4),
                      _section('Tình trạng & Ghi chú'),
                      DropdownButtonFormField<RealCmMemberStatus>(
                        value: _status,
                        decoration: const InputDecoration(labelText: 'Tình trạng'),
                        items: const [
                          DropdownMenuItem(value: RealCmMemberStatus.active, child: Text('Đang hoạt động')),
                          DropdownMenuItem(value: RealCmMemberStatus.movedOut, child: Text('Đã chuyển xứ')),
                          DropdownMenuItem(value: RealCmMemberStatus.deceased, child: Text('Đã qua đời')),
                          DropdownMenuItem(value: RealCmMemberStatus.excommunicated, child: Text('Vạ tuyệt thông')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _status = v);
                        },
                      ),
                      const SizedBox(height: RealCmSpacing.s3),
                      TextFormField(
                        controller: _notesCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Ghi chú', alignLabelWithHint: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(RealCmSpacing.s3),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Huỷ'),
                  ),
                  const SizedBox(width: RealCmSpacing.s2),
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(RealCmIcons.save, size: 18),
                    label: Text(isEdit ? 'Lưu thay đổi' : 'Thêm giáo dân'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.only(bottom: RealCmSpacing.s2, top: RealCmSpacing.s2),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(color: RealCmColors.primary, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: RealCmSpacing.s2),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: RealCmColors.textMuted)),
          ],
        ),
      );
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.memberId,
    required this.photoFilename,
    required this.pendingPhoto,
    required this.uploading,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onRemove,
  });

  final String? memberId;
  final String? photoFilename;
  final File? pendingPhoto;
  final bool uploading;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = pendingPhoto != null || (photoFilename != null && photoFilename!.isNotEmpty);
    final url = (pendingPhoto == null && memberId != null && photoFilename != null && photoFilename!.isNotEmpty)
        ? RealCmPocketBase.fileUrl(collection: 'members', recordId: memberId!, filename: photoFilename, thumb: '300x300')
        : null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: RealCmColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(RealCmRadius.lg),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: uploading
              ? const Center(child: CircularProgressIndicator())
              : pendingPhoto != null
                  ? Image.file(pendingPhoto!, fit: BoxFit.cover)
                  : url != null
                      ? Image.network(url, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(RealCmIcons.member, size: 40, color: RealCmColors.textMuted))
                      : const Icon(RealCmIcons.member, size: 40, color: RealCmColors.textMuted),
        ),
        const SizedBox(width: RealCmSpacing.s4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ảnh đại diện', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text('JPG/PNG/WEBP, tối đa 5MB. Sẽ tự resize thumbnail.',
                  style: TextStyle(fontSize: 12, color: RealCmColors.textMuted)),
              const SizedBox(height: RealCmSpacing.s2),
              Wrap(
                spacing: RealCmSpacing.s2,
                runSpacing: RealCmSpacing.s2,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library_outlined, size: 16),
                    label: const Text('Chọn ảnh'),
                    onPressed: uploading ? null : onPickGallery,
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.photo_camera_outlined, size: 16),
                    label: const Text('Chụp ảnh'),
                    onPressed: uploading ? null : onPickCamera,
                  ),
                  if (hasPhoto)
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline, size: 16, color: RealCmColors.danger),
                      label: const Text('Xoá ảnh', style: TextStyle(color: RealCmColors.danger)),
                      onPressed: uploading ? null : onRemove,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

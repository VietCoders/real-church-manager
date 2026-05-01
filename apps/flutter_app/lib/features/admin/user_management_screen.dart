// User management — chỉ cha xứ (priest_pastor) truy cập được. Tạo/sửa/reset password
// cho cha phó, thư ký, hội đồng mục vụ.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../platform/pocketbase/auth.dart';
import '../../platform/pocketbase/client.dart';
import '../../ui/crud/crud_scaffold.dart';
import '../../ui/modal/service.dart';
import '../../ui/scaffold/app_shell.dart';
import '../../ui/toast/service.dart';

final _userListProvider = FutureProvider.autoDispose<List<RecordModel>>((ref) async {
  final pb = RealCmPocketBase.instance();
  final res = await pb.collection('users').getList(page: 1, perPage: 100, sort: 'role,name');
  return res.items;
});

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(realCmAuthProvider);
    final isPastor = auth.role == 'priest_pastor';
    final async = ref.watch(_userListProvider);

    if (!isPastor) {
      return RealCmAppShell(
        title: 'Quản lý người dùng',
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(RealCmSpacing.s5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(RealCmIcons.lock, size: 56, color: RealCmColors.warning),
                const SizedBox(height: RealCmSpacing.s3),
                const Text('Chỉ Cha xứ được phép', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: RealCmSpacing.s2),
                const Text('Quản lý người dùng yêu cầu role priest_pastor.',
                    style: TextStyle(color: RealCmColors.textMuted), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }

    return RealCmAppShell(
      title: 'Quản lý người dùng',
      actions: [
        IconButton(icon: const Icon(RealCmIcons.refresh), onPressed: () => ref.invalidate(_userListProvider)),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, ref),
        icon: const Icon(RealCmIcons.add),
        label: const Text('Thêm người dùng'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => CrudErrorState(error: e, onRetry: () => ref.invalidate(_userListProvider)),
        data: (users) {
          if (users.isEmpty) {
            return CrudEmptyState(
              icon: RealCmIcons.user,
              title: 'Chưa có user',
              hint: 'Thêm cha phó, thư ký, hội đồng mục vụ.',
              canAdd: true,
              addLabel: 'Thêm user',
              onAdd: () => _showForm(context, ref),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: RealCmSpacing.s2),
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (_, i) {
              final u = users[i];
              final role = u.data['role']?.toString() ?? '';
              final isCurrentUser = u.id == auth.user?.id;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: RealCmSpacing.s4, vertical: RealCmSpacing.s2),
                leading: CircleAvatar(
                  backgroundColor: _roleColor(role).withValues(alpha: 0.15),
                  child: Icon(_roleIcon(role), color: _roleColor(role), size: 20),
                ),
                title: Row(children: [
                  Text(u.data['name']?.toString() ?? u.data['username']?.toString() ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (isCurrentUser) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: RealCmColors.info.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(RealCmRadius.sm),
                      ),
                      child: const Text('Bạn', style: TextStyle(fontSize: 10, color: RealCmColors.info, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ]),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Wrap(spacing: RealCmSpacing.s2, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _roleColor(role).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(RealCmRadius.full),
                      ),
                      child: Text(_roleLabel(role), style: TextStyle(fontSize: 11, color: _roleColor(role), fontWeight: FontWeight.w600)),
                    ),
                    if (u.data['username']?.toString().isNotEmpty == true)
                      Text('@${u.data['username']}', style: const TextStyle(fontSize: 12, color: RealCmColors.textMuted)),
                    if (u.data['email']?.toString().isNotEmpty == true)
                      Text(u.data['email'], style: const TextStyle(fontSize: 12, color: RealCmColors.textMuted)),
                    if (u.data['must_change_password'] == true)
                      const Text('⚠ Phải đổi mật khẩu', style: TextStyle(fontSize: 11, color: RealCmColors.warning)),
                  ]),
                ),
                trailing: isCurrentUser
                    ? null
                    : PopupMenuButton<String>(
                        icon: const Icon(RealCmIcons.more),
                        onSelected: (v) async {
                          if (v == 'edit') _showForm(context, ref, existing: u);
                          if (v == 'reset') _resetPassword(context, ref, u);
                          if (v == 'delete') _delete(context, ref, u);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Sửa thông tin')),
                          PopupMenuItem(value: 'reset', child: Text('Đặt lại mật khẩu')),
                          PopupMenuItem(value: 'delete', child: Text('Xoá user', style: TextStyle(color: RealCmColors.danger))),
                        ],
                      ),
                onTap: isCurrentUser ? null : () => _showForm(context, ref, existing: u),
              );
            },
          );
        },
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'priest_pastor': return RealCmColors.danger;
      case 'priest_assistant': return RealCmColors.primary;
      case 'secretary': return RealCmColors.info;
      case 'council_member': return RealCmColors.success;
      default: return RealCmColors.textMuted;
    }
  }

  IconData _roleIcon(String role) {
    if (role.startsWith('priest_')) return RealCmIcons.parish;
    return RealCmIcons.user;
  }

  String _roleLabel(String role) {
    return {
      'priest_pastor': 'Cha xứ',
      'priest_assistant': 'Cha phó',
      'secretary': 'Thư ký',
      'council_member': 'Hội đồng mục vụ',
      'guest': 'Khách',
    }[role] ?? role;
  }

  Future<void> _showForm(BuildContext context, WidgetRef ref, {RecordModel? existing}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _UserFormDialog(existing: existing),
    );
    if (result == true) {
      ref.invalidate(_userListProvider);
    }
  }

  Future<void> _resetPassword(BuildContext context, WidgetRef ref, RecordModel u) async {
    final newPassCtrl = TextEditingController(text: 'admin123');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đặt lại mật khẩu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Đặt lại mật khẩu cho user ${u.data['name'] ?? u.data['username']}?'),
            const SizedBox(height: RealCmSpacing.s3),
            TextField(
              controller: newPassCtrl,
              decoration: const InputDecoration(labelText: 'Mật khẩu mới', helperText: 'User sẽ buộc đổi mật khẩu khi đăng nhập'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Huỷ')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Đặt lại')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await RealCmPocketBase.instance().collection('users').update(u.id, body: {
        'password': newPassCtrl.text,
        'passwordConfirm': newPassCtrl.text,
        'must_change_password': true,
      });
      if (context.mounted) {
        realCmToast(context, 'Đã đặt lại mật khẩu (user phải đổi khi đăng nhập)', type: RealCmToastType.success);
      }
    } catch (e) {
      if (context.mounted) realCmToast(context, 'Lỗi: $e', type: RealCmToastType.error);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, RecordModel u) async {
    final ok = await realCmConfirm(
      context,
      title: 'Xoá user',
      body: 'Xoá user "${u.data['name'] ?? u.data['username']}" khỏi hệ thống?\nLưu ý: hành động không thể khôi phục.',
      confirmLabel: 'Xoá',
      danger: true,
    );
    if (!ok) return;
    try {
      await RealCmPocketBase.instance().collection('users').delete(u.id);
      if (context.mounted) {
        realCmToast(context, 'Đã xoá user', type: RealCmToastType.success);
        ref.invalidate(_userListProvider);
      }
    } catch (e) {
      if (context.mounted) realCmToast(context, 'Lỗi: $e', type: RealCmToastType.error);
    }
  }
}

class _UserFormDialog extends ConsumerStatefulWidget {
  const _UserFormDialog({this.existing});
  final RecordModel? existing;

  @override
  ConsumerState<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;
  String _role = 'secretary';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.existing?.data ?? {};
    _usernameCtrl = TextEditingController(text: d['username']?.toString() ?? '');
    _nameCtrl = TextEditingController(text: d['name']?.toString() ?? '');
    _emailCtrl = TextEditingController(text: d['email']?.toString() ?? '');
    _passwordCtrl = TextEditingController(text: '');
    _role = d['role']?.toString() ?? 'secretary';
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final body = <String, dynamic>{
        'username': _usernameCtrl.text.trim(),
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'role': _role,
        'verified': true,
      };
      final pb = RealCmPocketBase.instance();
      if (widget.existing == null) {
        body['password'] = _passwordCtrl.text;
        body['passwordConfirm'] = _passwordCtrl.text;
        body['must_change_password'] = true;
        await pb.collection('users').create(body: body);
      } else {
        await pb.collection('users').update(widget.existing!.id, body: body);
      }
      if (mounted) {
        realCmToast(context, widget.existing == null ? 'Đã tạo user' : 'Đã cập nhật', type: RealCmToastType.success);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) realCmToast(context, 'Lỗi: $e', type: RealCmToastType.error);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return CrudFormScaffold(
      title: isEdit ? 'Sửa user' : 'Thêm user',
      icon: RealCmIcons.user,
      isEdit: isEdit,
      saving: _saving,
      onCancel: () => Navigator.of(context).pop(false),
      onSave: _save,
      body: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const CrudFormSection(label: 'Thông tin'),
          TextFormField(
            controller: _usernameCtrl,
            decoration: const InputDecoration(labelText: 'Tên đăng nhập *', helperText: 'Vd: chaphoa, thuky01'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
          ),
          const SizedBox(height: RealCmSpacing.s3),
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Họ tên hiển thị *'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
          ),
          const SizedBox(height: RealCmSpacing.s3),
          TextFormField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: 'Email (tuỳ chọn)'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: RealCmSpacing.s4),
          const CrudFormSection(label: 'Phân quyền'),
          DropdownButtonFormField<String>(
            initialValue: _role,
            decoration: const InputDecoration(labelText: 'Vai trò *'),
            items: const [
              DropdownMenuItem(value: 'priest_pastor', child: Text('Cha xứ (toàn quyền)')),
              DropdownMenuItem(value: 'priest_assistant', child: Text('Cha phó (gần như toàn quyền)')),
              DropdownMenuItem(value: 'secretary', child: Text('Thư ký (CRUD ngoại trừ xoá)')),
              DropdownMenuItem(value: 'council_member', child: Text('Hội đồng mục vụ (đoàn thể + thu chi)')),
              DropdownMenuItem(value: 'guest', child: Text('Khách (chỉ đọc)')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _role = v);
            },
          ),
          if (!isEdit) ...[
            const SizedBox(height: RealCmSpacing.s4),
            const CrudFormSection(label: 'Mật khẩu ban đầu'),
            TextFormField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(labelText: 'Mật khẩu *', helperText: 'Tối thiểu 6 ký tự. User sẽ buộc đổi khi đăng nhập đầu.'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Bắt buộc';
                if (v.length < 6) return 'Tối thiểu 6 ký tự';
                return null;
              },
            ),
          ],
        ]),
      ),
    );
  }
}

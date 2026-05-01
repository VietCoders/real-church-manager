// Preferences — Theme + Language toggle + Backup tools.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../platform/pocketbase/auth.dart';
import '../../platform/pocketbase/client.dart';
import '../../platform/storage/preferences.dart';
import '../../ui/modal/service.dart';
import '../../ui/scaffold/app_shell.dart';
import '../../ui/toast/service.dart';

class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(realCmAuthProvider);
    final theme = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final isPriest = auth.isPriest;

    return RealCmAppShell(
      title: 'Tuỳ chọn',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(RealCmSpacing.s5),
            children: [
              _Section(
                icon: Icons.palette_outlined,
                title: 'Giao diện',
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Chế độ màu'),
                    subtitle: const Text('Sáng / Tối / Theo hệ thống'),
                    trailing: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined), label: Text('Sáng')),
                        ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined), label: Text('Tối')),
                        ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto_outlined), label: Text('Tự động')),
                      ],
                      selected: {theme},
                      onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).set(s.first),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: RealCmSpacing.s4),
              _Section(
                icon: Icons.language,
                title: 'Ngôn ngữ',
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Ngôn ngữ hiển thị'),
                    subtitle: const Text('Vietnamese / English'),
                    trailing: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'vi', label: Text('🇻🇳 Tiếng Việt')),
                        ButtonSegment(value: 'en', label: Text('🇬🇧 English')),
                      ],
                      selected: {locale.languageCode},
                      onSelectionChanged: (s) => ref.read(localeProvider.notifier).set(Locale(s.first)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: RealCmSpacing.s4),
              _Section(
                icon: Icons.account_circle_outlined,
                title: 'Tài khoản hiện tại',
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: RealCmColors.primary.withValues(alpha: 0.15),
                      child: const Icon(RealCmIcons.user, color: RealCmColors.primary),
                    ),
                    title: Text(auth.user?.data['name']?.toString() ?? 'Người dùng'),
                    subtitle: Text('@${auth.user?.data['username'] ?? ''} · ${_roleLabel(auth.role ?? '')}'),
                  ),
                  const SizedBox(height: RealCmSpacing.s2),
                  Wrap(
                    spacing: RealCmSpacing.s2,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(RealCmIcons.lock, size: 18),
                        label: const Text('Đổi mật khẩu'),
                        onPressed: () async {
                          await Navigator.of(context).pushNamed('/change-password');
                        },
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(RealCmIcons.logout, size: 18, color: RealCmColors.danger),
                        label: const Text('Đăng xuất', style: TextStyle(color: RealCmColors.danger)),
                        onPressed: () async {
                          final ok = await realCmConfirm(context,
                              title: 'Đăng xuất',
                              body: 'Bạn có chắc muốn đăng xuất?',
                              confirmLabel: 'Đăng xuất');
                          if (ok) await ref.read(realCmAuthProvider.notifier).logout();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              if (isPriest) ...[
                const SizedBox(height: RealCmSpacing.s4),
                _Section(
                  icon: Icons.backup_outlined,
                  title: 'Sao lưu / Khôi phục',
                  children: [
                    const Text(
                      'Tạo bản sao lưu toàn bộ dữ liệu (giáo dân, sổ Bí Tích, đoàn thể, ...). '
                      'File backup có thể tải về và khôi phục khi cần.',
                      style: TextStyle(color: RealCmColors.textMuted),
                    ),
                    const SizedBox(height: RealCmSpacing.s3),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.backup_outlined, size: 18),
                      label: const Text('Tạo bản sao lưu mới'),
                      onPressed: () => _createBackup(context),
                    ),
                    const SizedBox(height: RealCmSpacing.s2),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.list_outlined, size: 18),
                      label: const Text('Xem danh sách backup'),
                      onPressed: () => _listBackups(context),
                    ),
                    const SizedBox(height: RealCmSpacing.s3),
                    Container(
                      padding: const EdgeInsets.all(RealCmSpacing.s3),
                      decoration: BoxDecoration(
                        color: RealCmColors.success.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(RealCmRadius.md),
                      ),
                      child: const Row(children: [
                        Icon(Icons.schedule, color: RealCmColors.success, size: 18),
                        SizedBox(width: RealCmSpacing.s2),
                        Expanded(child: Text(
                          'Tự động sao lưu hàng ngày lúc 03:00 UTC (10:00 sáng VN). '
                          'Tên file: real-cm-auto-YYYYMMDD-HHMMSS.zip.',
                          style: TextStyle(fontSize: 13),
                        )),
                      ]),
                    ),
                    const SizedBox(height: RealCmSpacing.s2),
                    Container(
                      padding: const EdgeInsets.all(RealCmSpacing.s3),
                      decoration: BoxDecoration(
                        color: RealCmColors.warning.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(RealCmRadius.md),
                      ),
                      child: const Row(children: [
                        Icon(RealCmIcons.warning, color: RealCmColors.warning, size: 18),
                        SizedBox(width: RealCmSpacing.s2),
                        Expanded(child: Text(
                          'Backup được lưu trên server PocketBase tại pb_data/backups/. '
                          'Nên sao chép định kỳ ra ổ cứng riêng để an toàn.',
                          style: TextStyle(fontSize: 13),
                        )),
                      ]),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: RealCmSpacing.s4),
              _Section(
                icon: Icons.info_outline,
                title: 'Về Real Church Manager',
                children: const [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Phiên bản'),
                    trailing: Text('1.0.0'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('License'),
                    trailing: Text('MIT'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Tác giả'),
                    trailing: Text('Đạo Trần · VietCoders'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Repository'),
                    subtitle: Text('github.com/VietCoders/real-church-manager'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createBackup(BuildContext context) async {
    final nameCtrl = TextEditingController(text: 'backup-${DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 19)}.zip');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo bản sao lưu'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Tên file backup'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Huỷ')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Tạo')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final pb = RealCmPocketBase.instance();
      await pb.backups.create(nameCtrl.text);
      if (context.mounted) realCmToast(context, 'Đã tạo backup ${nameCtrl.text}', type: RealCmToastType.success);
    } catch (e) {
      if (context.mounted) realCmToast(context, 'Lỗi: $e (cần quyền PB admin)', type: RealCmToastType.error);
    }
  }

  Future<void> _listBackups(BuildContext context) async {
    try {
      final pb = RealCmPocketBase.instance();
      final list = await pb.backups.getFullList();
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: const Text('Danh sách backup'),
            content: SizedBox(
              width: 640,
              height: 480,
              child: list.isEmpty
                  ? const Center(child: Text('Chưa có backup nào', style: TextStyle(color: RealCmColors.textMuted)))
                  : ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final b = list[i];
                        final size = (b.size / 1024 / 1024).toStringAsFixed(2);
                        return ListTile(
                          leading: const Icon(Icons.archive_outlined),
                          title: Text(b.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('$size MB · ${b.modified}'),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (v) async {
                              if (v == 'download') {
                                await _downloadBackup(context, b.key);
                              } else if (v == 'restore') {
                                await _restoreBackup(context, b.key);
                              } else if (v == 'delete') {
                                await _deleteBackup(context, b.key);
                                if (context.mounted) {
                                  Navigator.of(ctx).pop();
                                  await _listBackups(context);
                                }
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'download', child: Row(children: [Icon(Icons.download, size: 18), SizedBox(width: 8), Text('Tải về')])),
                              PopupMenuItem(value: 'restore', child: Row(children: [Icon(Icons.restore, size: 18, color: RealCmColors.warning), SizedBox(width: 8), Text('Khôi phục từ backup này')])),
                              PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: RealCmColors.danger), SizedBox(width: 8), Text('Xoá', style: TextStyle(color: RealCmColors.danger))])),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Đóng'))],
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) realCmToast(context, 'Lỗi: $e (cần quyền PB admin)', type: RealCmToastType.error);
    }
  }

  Future<void> _downloadBackup(BuildContext context, String key) async {
    try {
      final pb = RealCmPocketBase.instance();
      // PB cần admin token cho file token
      final token = await pb.files.getToken();
      final url = pb.backups.getDownloadURL(token, key);
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);
        if (context.mounted) realCmToast(context, 'Mở link tải về trên trình duyệt', type: RealCmToastType.info);
      } else {
        if (context.mounted) realCmToast(context, 'Không thể mở URL', type: RealCmToastType.error);
      }
    } catch (e) {
      if (context.mounted) realCmToast(context, 'Lỗi tải: $e', type: RealCmToastType.error);
    }
  }

  Future<void> _restoreBackup(BuildContext context, String key) async {
    final ok = await realCmConfirm(
      context,
      title: 'Khôi phục từ backup',
      body: 'CẢNH BÁO: toàn bộ dữ liệu hiện tại sẽ bị thay thế bằng nội dung trong backup "$key". Server sẽ restart và bạn cần đăng nhập lại.\n\nXác nhận khôi phục?',
      confirmLabel: 'Khôi phục',
      danger: true,
    );
    if (!ok) return;
    try {
      final pb = RealCmPocketBase.instance();
      await pb.backups.restore(key);
      if (context.mounted) {
        realCmToast(context, 'Đã yêu cầu khôi phục. Server đang restart, vui lòng đăng nhập lại.', type: RealCmToastType.warning);
      }
    } catch (e) {
      if (context.mounted) realCmToast(context, 'Lỗi khôi phục: $e', type: RealCmToastType.error);
    }
  }

  Future<void> _deleteBackup(BuildContext context, String key) async {
    final ok = await realCmConfirm(
      context,
      title: 'Xoá backup',
      body: 'Xác nhận xoá file backup "$key"?',
      confirmLabel: 'Xoá',
      danger: true,
    );
    if (!ok) return;
    try {
      final pb = RealCmPocketBase.instance();
      await pb.backups.delete(key);
      if (context.mounted) realCmToast(context, 'Đã xoá', type: RealCmToastType.success);
    } catch (e) {
      if (context.mounted) realCmToast(context, 'Lỗi: $e', type: RealCmToastType.error);
    }
  }

  String _roleLabel(String role) => {
    'priest_pastor': 'Cha xứ',
    'priest_assistant': 'Cha phó',
    'secretary': 'Thư ký',
    'council_member': 'Hội đồng mục vụ',
    'guest': 'Khách',
  }[role] ?? role;
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.children});
  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RealCmSpacing.s4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(RealCmRadius.lg),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: RealCmColors.primary),
          const SizedBox(width: RealCmSpacing.s2),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: RealCmSpacing.s3),
        ...children,
      ]),
    );
  }
}

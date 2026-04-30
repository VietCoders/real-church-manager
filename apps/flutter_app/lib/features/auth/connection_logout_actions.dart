// Shared logout helper với confirm modal — dùng chung mọi screen.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../platform/pocketbase/auth.dart';
import '../../ui/modal/service.dart';

Future<void> realCmLogoutWithConfirm(BuildContext context, WidgetRef ref) async {
  final ok = await realCmConfirm(
    context,
    title: 'Đăng xuất',
    body: 'Bạn có chắc muốn đăng xuất khỏi giáo xứ?',
    confirmLabel: 'Đăng xuất',
    cancelLabel: 'Huỷ',
    danger: false,
  );
  if (!ok) return;
  await ref.read(realCmAuthProvider.notifier).logout();
}

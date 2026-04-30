// Toast service — abstraction wrap SnackBar / overlay.
// Usage: realCmToast(context, 'Đã lưu', RealCmToastType.success)
import 'package:flutter/material.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';

enum RealCmToastType { success, error, warning, info }

void realCmToast(
  BuildContext context,
  String message, {
  RealCmToastType type = RealCmToastType.info,
  Duration duration = const Duration(seconds: 4),
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      duration: duration,
      backgroundColor: _bgColor(type),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RealCmRadius.md)),
      content: Row(
        children: [
          Icon(_icon(type), color: Colors.white, size: 20),
          const SizedBox(width: RealCmSpacing.s3),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
        ],
      ),
    ),
  );
}

Color _bgColor(RealCmToastType type) {
  switch (type) {
    case RealCmToastType.success: return RealCmColors.success;
    case RealCmToastType.error: return RealCmColors.danger;
    case RealCmToastType.warning: return RealCmColors.warning;
    case RealCmToastType.info: return RealCmColors.info;
  }
}

IconData _icon(RealCmToastType type) {
  switch (type) {
    case RealCmToastType.success: return RealCmIcons.success;
    case RealCmToastType.error: return RealCmIcons.error;
    case RealCmToastType.warning: return RealCmIcons.warning;
    case RealCmToastType.info: return RealCmIcons.info;
  }
}

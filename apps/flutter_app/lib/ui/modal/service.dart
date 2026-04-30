// Modal service — abstraction wrap showDialog với focus trap + Esc close.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/tokens.dart';

enum RealCmModalType { info, warning, danger }
enum RealCmModalSize { sm, md, lg, fullscreen }

class RealCmModalButton {
  RealCmModalButton({
    required this.label,
    required this.action,
    this.style = RealCmModalButtonStyle.ghost,
  });

  final String label;
  final String action;
  final RealCmModalButtonStyle style;
}

enum RealCmModalButtonStyle { primary, secondary, ghost, danger }

/// Show modal. Returns action id của button user nhấn (hoặc null nếu đóng bằng Esc/backdrop).
Future<String?> realCmModal(
  BuildContext context, {
  required String title,
  required Widget body,
  RealCmModalType type = RealCmModalType.info,
  RealCmModalSize size = RealCmModalSize.md,
  List<RealCmModalButton>? buttons,
  bool dismissible = true,
}) {
  final maxWidth = _maxWidth(size);
  return showDialog<String>(
    context: context,
    barrierDismissible: dismissible,
    barrierColor: RealCmColors.overlay,
    builder: (ctx) => Dialog(
      backgroundColor: Theme.of(ctx).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RealCmRadius.lg)),
      child: Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.escape): _DismissIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            _DismissIntent: CallbackAction<_DismissIntent>(
              onInvoke: (_) {
                if (dismissible) Navigator.of(ctx).pop();
                return null;
              },
            ),
          },
          child: Focus(
            autofocus: true,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: const EdgeInsets.all(RealCmSpacing.s5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(ctx).textTheme.titleLarge),
                    const SizedBox(height: RealCmSpacing.s4),
                    Flexible(child: SingleChildScrollView(child: body)),
                    if (buttons != null && buttons.isNotEmpty) ...[
                      const SizedBox(height: RealCmSpacing.s5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          for (final btn in buttons) ...[
                            _buildButton(ctx, btn),
                            const SizedBox(width: RealCmSpacing.s2),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

double _maxWidth(RealCmModalSize size) {
  switch (size) {
    case RealCmModalSize.sm: return 400;
    case RealCmModalSize.md: return 600;
    case RealCmModalSize.lg: return 900;
    case RealCmModalSize.fullscreen: return double.infinity;
  }
}

Widget _buildButton(BuildContext ctx, RealCmModalButton btn) {
  void onPressed() => Navigator.of(ctx).pop(btn.action);
  switch (btn.style) {
    case RealCmModalButtonStyle.primary:
      return ElevatedButton(onPressed: onPressed, child: Text(btn.label));
    case RealCmModalButtonStyle.secondary:
      return OutlinedButton(onPressed: onPressed, child: Text(btn.label));
    case RealCmModalButtonStyle.danger:
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: RealCmColors.danger, foregroundColor: Colors.white),
        child: Text(btn.label),
      );
    case RealCmModalButtonStyle.ghost:
      return TextButton(onPressed: onPressed, child: Text(btn.label));
  }
}

class _DismissIntent extends Intent {
  const _DismissIntent();
}

/// Confirm dialog ngắn gọn.
Future<bool> realCmConfirm(
  BuildContext context, {
  required String title,
  required String body,
  String? confirmLabel,
  String? cancelLabel,
  bool danger = false,
}) async {
  final result = await realCmModal(
    context,
    title: title,
    body: Text(body),
    type: danger ? RealCmModalType.danger : RealCmModalType.warning,
    buttons: [
      RealCmModalButton(label: cancelLabel ?? 'Huỷ', action: 'cancel', style: RealCmModalButtonStyle.ghost),
      RealCmModalButton(
        label: confirmLabel ?? 'Xác nhận',
        action: 'confirm',
        style: danger ? RealCmModalButtonStyle.danger : RealCmModalButtonStyle.primary,
      ),
    ],
  );
  return result == 'confirm';
}

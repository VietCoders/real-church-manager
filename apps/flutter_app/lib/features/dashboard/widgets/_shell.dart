// Shared dashboard widget shell — tất cả widget dùng common shell này để consistency.
import 'package:flutter/material.dart';

import '../../../design/icons.dart';
import '../../../design/tokens.dart';

class DashboardWidgetShell extends StatelessWidget {
  const DashboardWidgetShell({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.iconColor,
    this.actions,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Color? iconColor;
  final List<Widget>? actions;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(RealCmRadius.lg),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(RealCmRadius.lg),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant, width: 1),
            borderRadius: BorderRadius.circular(RealCmRadius.lg),
          ),
          padding: const EdgeInsets.all(RealCmSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(RealCmSpacing.s2),
                    decoration: BoxDecoration(
                      color: (iconColor ?? RealCmColors.primary).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(RealCmRadius.md),
                    ),
                    child: Icon(icon, size: 18, color: iconColor ?? RealCmColors.primary),
                  ),
                  const SizedBox(width: RealCmSpacing.s3),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (actions != null) ...actions!,
                ],
              ),
              const SizedBox(height: RealCmSpacing.s4),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shell cho stats card kích thước nhỏ — 1 con số to + label.
class DashboardStatsShell extends StatelessWidget {
  const DashboardStatsShell({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    this.subtitle,
    this.iconColor,
    this.loading = false,
    this.error,
  });

  final String title;
  final IconData icon;
  final String value;
  final String? subtitle;
  final Color? iconColor;
  final bool loading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return DashboardWidgetShell(
      title: title,
      icon: icon,
      iconColor: iconColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading)
            const SizedBox(
              height: 36,
              width: 36,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (error != null)
            Row(
              children: [
                const Icon(RealCmIcons.error, color: RealCmColors.danger, size: 20),
                const SizedBox(width: RealCmSpacing.s2),
                Expanded(child: Text(error!, style: const TextStyle(color: RealCmColors.danger))),
              ],
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: iconColor ?? RealCmColors.primary,
                height: 1,
              ),
            ),
          if (subtitle != null && !loading && error == null) ...[
            const SizedBox(height: RealCmSpacing.s2),
            Text(subtitle!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: RealCmColors.textMuted)),
          ],
        ],
      ),
    );
  }
}

// AppShell — responsive scaffold dùng chung mọi screen sau login.
// Desktop ≥1200px: permanent sidebar 240px.
// Tablet 800-1200px: collapsed rail 72px (icons + tooltip).
// Mobile <800px: classic drawer overlay.
//
// Mọi feature screen MUST wrap content qua RealCmAppShell để consistency.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../features/auth/connection_logout_actions.dart';
import '../../platform/pocketbase/auth.dart';
import '../../platform/sync/queue.dart';
import '../toast/service.dart';
import 'nav_destinations.dart';

const double _breakpointDesktop = 1200;
const double _breakpointTablet = 800;
const double _sidebarWidth = 240;
const double _railWidth = 72;

class RealCmAppShell extends ConsumerWidget {
  const RealCmAppShell({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(realCmAuthProvider);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= _breakpointDesktop;
    final isTablet = width >= _breakpointTablet && width < _breakpointDesktop;
    final currentRoute = GoRouterState.of(context).matchedLocation;

    final appBar = AppBar(
      automaticallyImplyLeading: !isDesktop && !isTablet,
      title: Text(title),
      actions: [
        if (actions != null) ...actions!,
        IconButton(
          icon: const Icon(RealCmIcons.logout),
          tooltip: 'Đăng xuất',
          onPressed: () => realCmLogoutWithConfirm(context, ref),
        ),
        const SizedBox(width: RealCmSpacing.s2),
      ],
    );

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(currentRoute: currentRoute, role: auth.role ?? 'guest', expanded: true),
            VerticalDivider(width: 1, color: Theme.of(context).colorScheme.outlineVariant),
            Expanded(
              child: Scaffold(
                appBar: appBar,
                body: body,
                floatingActionButton: floatingActionButton,
              ),
            ),
          ],
        ),
      );
    }
    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(currentRoute: currentRoute, role: auth.role ?? 'guest', expanded: false),
            VerticalDivider(width: 1, color: Theme.of(context).colorScheme.outlineVariant),
            Expanded(
              child: Scaffold(
                appBar: appBar,
                body: body,
                floatingActionButton: floatingActionButton,
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: appBar,
      drawer: _MobileDrawer(currentRoute: currentRoute, role: auth.role ?? 'guest'),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.currentRoute, required this.role, required this.expanded});
  final String currentRoute;
  final String role;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = expanded ? _sidebarWidth : _railWidth;
    return Container(
      width: width,
      color: scheme.surface,
      child: Column(
        children: [
          _Header(expanded: expanded, role: role),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: RealCmSpacing.s2),
              children: _buildItems(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    final items = <Widget>[];
    String? lastSection;
    for (final dest in realCmDestinationsFor(role)) {
      if (dest.section != null && dest.section != lastSection) {
        if (expanded) {
          items.add(Padding(
            padding: const EdgeInsets.only(
              left: RealCmSpacing.s4,
              top: RealCmSpacing.s4,
              bottom: RealCmSpacing.s2,
            ),
            child: Text(
              dest.section!.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: RealCmColors.textMuted,
              ),
            ),
          ));
        } else {
          items.add(const Padding(
            padding: EdgeInsets.symmetric(vertical: RealCmSpacing.s2),
            child: Divider(indent: 12, endIndent: 12),
          ));
        }
        lastSection = dest.section;
      }
      items.add(_NavItem(
        dest: dest,
        active: _isActive(currentRoute, dest.route),
        expanded: expanded,
      ));
    }
    return items;
  }

  bool _isActive(String current, String target) {
    if (target == '/') return current == '/';
    return current.startsWith(target);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.expanded, required this.role});
  final bool expanded;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: expanded ? RealCmSpacing.s4 : RealCmSpacing.s3,
        vertical: RealCmSpacing.s4,
      ),
      decoration: const BoxDecoration(color: RealCmColors.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(RealCmIcons.parish, color: Colors.white, size: 32),
          if (expanded) ...[
            const SizedBox(height: RealCmSpacing.s2),
            const Text(
              'Quản lý Giáo xứ',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(_roleLabel(role),
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.dest, required this.active, required this.expanded});
  final RealCmNavDestination dest;
  final bool active;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final activeColor = RealCmColors.primary;
    final activeBg = activeColor.withValues(alpha: 0.10);

    final tile = Container(
      margin: EdgeInsets.symmetric(
        horizontal: expanded ? RealCmSpacing.s2 : RealCmSpacing.s2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: active ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(RealCmRadius.md),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(RealCmRadius.md),
        onTap: () => context.go(dest.route),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: expanded ? RealCmSpacing.s3 : 0,
            vertical: RealCmSpacing.s3,
          ),
          child: expanded
              ? Row(
                  children: [
                    Icon(dest.icon, size: 20, color: active ? activeColor : RealCmColors.textMuted),
                    const SizedBox(width: RealCmSpacing.s3),
                    Expanded(
                      child: Text(
                        dest.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                          color: active ? activeColor : RealCmColors.text,
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Icon(dest.icon, size: 22, color: active ? activeColor : RealCmColors.textMuted),
                ),
        ),
      ),
    );

    if (!expanded) {
      return Tooltip(message: dest.label, child: tile);
    }
    return tile;
  }
}

class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer({required this.currentRoute, required this.role});
  final String currentRoute;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _Header(expanded: true, role: role),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: realCmDestinationsFor(role).map((dest) {
                final active = _isActive(currentRoute, dest.route);
                return ListTile(
                  leading: Icon(dest.icon, color: active ? RealCmColors.primary : null),
                  title: Text(
                    dest.label,
                    style: TextStyle(
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? RealCmColors.primary : null,
                    ),
                  ),
                  selected: active,
                  selectedTileColor: RealCmColors.primary.withValues(alpha: 0.10),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go(dest.route);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  bool _isActive(String current, String target) {
    if (target == '/') return current == '/';
    return current.startsWith(target);
  }
}

String _roleLabel(String role) {
  switch (role) {
    case 'priest_pastor':
      return 'Cha xứ';
    case 'priest_assistant':
      return 'Cha phó';
    case 'secretary':
      return 'Thư ký';
    case 'council_member':
      return 'Hội đồng mục vụ';
    default:
      return 'Khách';
  }
}

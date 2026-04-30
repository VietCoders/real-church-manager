// Member list — danh sách giáo dân + search + nav drawer.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/member/repository.dart';
import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../domain/member/entity.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../platform/pocketbase/auth.dart';
import '../../ui/toast/service.dart';

final _memberRepoProvider = Provider<MemberRepository>((ref) => MemberRepository());

final _memberListProvider = FutureProvider.autoDispose.family<List<Member>, String?>((ref, search) {
  return ref.read(_memberRepoProvider).list(search: search);
});

class MemberListScreen extends ConsumerStatefulWidget {
  const MemberListScreen({super.key});

  @override
  ConsumerState<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends ConsumerState<MemberListScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final auth = ref.watch(realCmAuthProvider);
    final asyncList = ref.watch(_memberListProvider(_search.isEmpty ? null : _search));

    return Scaffold(
      appBar: AppBar(
        title: Text(t.memberListTitle),
        actions: [
          IconButton(
            icon: const Icon(RealCmIcons.refresh),
            onPressed: () => ref.invalidate(_memberListProvider),
          ),
          IconButton(
            icon: const Icon(RealCmIcons.logout),
            tooltip: t.authLogoutButton,
            onPressed: () async {
              await ref.read(realCmAuthProvider.notifier).logout();
            },
          ),
        ],
      ),
      drawer: _NavDrawer(role: auth.role ?? 'guest'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(RealCmSpacing.s4),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(RealCmIcons.search),
                hintText: t.memberSearchHint,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: asyncList.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(RealCmSpacing.s5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(RealCmIcons.error, size: 48, color: RealCmColors.danger),
                      const SizedBox(height: RealCmSpacing.s3),
                      Text(t.commonError, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: RealCmSpacing.s2),
                      Text('$e', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              data: (members) {
                if (members.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(RealCmIcons.member, size: 48, color: RealCmColors.textDisabled),
                        const SizedBox(height: RealCmSpacing.s3),
                        Text(t.commonEmpty, style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final m = members[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: RealCmColors.surfaceVariant,
                        child: Text(_initials(m.displayName), style: const TextStyle(color: RealCmColors.text)),
                      ),
                      title: Text(m.displayName),
                      subtitle: Text(_subtitle(m)),
                      trailing: m.gender == RealCmGender.female
                          ? const Icon(Icons.female, color: RealCmColors.primaryLight)
                          : m.gender == RealCmGender.male
                              ? const Icon(Icons.male, color: RealCmColors.info)
                              : null,
                      onTap: () {
                        // TODO Phase 4: navigate detail
                        realCmToast(context, 'Chi tiết: ${m.displayName} (sẽ làm Phase 4)',
                            type: RealCmToastType.info);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: auth.canEditMembers
          ? FloatingActionButton(
              onPressed: () {
                realCmToast(context, 'Thêm giáo dân (sẽ làm Phase 4)', type: RealCmToastType.info);
              },
              tooltip: t.memberAddTitle,
              child: const Icon(RealCmIcons.add),
            )
          : null,
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  static String _subtitle(Member m) {
    final parts = <String>[];
    if (m.phone != null && m.phone!.isNotEmpty) parts.add(m.phone!);
    if (m.address != null && m.address!.isNotEmpty) parts.add(m.address!);
    return parts.join(' · ');
  }
}

class _NavDrawer extends StatelessWidget {
  const _NavDrawer({required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: RealCmColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(RealCmIcons.parish, color: Colors.white, size: 36),
                const SizedBox(height: RealCmSpacing.s2),
                Text(t.appTitle, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: RealCmSpacing.s1),
                Text(_roleLabel(role), style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          _navItem(context, RealCmIcons.member, t.navMembers, '/'),
          _navItem(context, RealCmIcons.family, t.navFamilies, '/families'),
          _navItem(context, RealCmIcons.district, t.navDistricts, '/districts'),
          const Divider(),
          _navItem(context, RealCmIcons.baptism, t.sacramentBaptism, '/sacrament/baptism'),
          _navItem(context, RealCmIcons.confirmation, t.sacramentConfirmation, '/sacrament/confirmation'),
          _navItem(context, RealCmIcons.marriage, t.sacramentMarriage, '/sacrament/marriage'),
          _navItem(context, RealCmIcons.anointing, t.sacramentAnointing, '/sacrament/anointing'),
          _navItem(context, RealCmIcons.funeral, t.sacramentFuneral, '/sacrament/funeral'),
          const Divider(),
          _navItem(context, RealCmIcons.group, t.navGroups, '/groups'),
          _navItem(context, RealCmIcons.mass, t.navMass, '/mass'),
          _navItem(context, RealCmIcons.calendar, t.navCalendar, '/calendar'),
          _navItem(context, RealCmIcons.donation, t.navDonations, '/donations'),
          _navItem(context, RealCmIcons.report, t.navReports, '/reports'),
          const Divider(),
          _navItem(context, RealCmIcons.settings, t.navSettings, '/settings'),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext ctx, IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.of(ctx).pop();
        // TODO Phase 4-6: navigate qua go_router
      },
    );
  }

  static String _roleLabel(String role) {
    switch (role) {
      case 'priest_pastor': return 'Cha xứ';
      case 'priest_assistant': return 'Cha phó';
      case 'secretary': return 'Thư ký';
      case 'council_member': return 'Hội đồng mục vụ';
      default: return 'Khách';
    }
  }
}

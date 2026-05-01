// Real Church Manager — App root
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'design/theme.dart';
import 'features/admin/activity_log_screen.dart';
import 'features/admin/user_management_screen.dart';
import 'features/auth/change_password_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/calendar/calendar_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/district/list_screen.dart';
import 'features/family/detail_screen.dart';
import 'features/member/detail_screen.dart';
import 'features/member/list_screen.dart';
import 'features/modules/configs.dart' as cfg;
import 'features/reports/reports_screen.dart';
import 'features/settings/connection_screen.dart';
import 'features/settings/parish_settings_screen.dart';
import 'features/settings/preferences_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'platform/pocketbase/auth.dart';
import 'platform/storage/preferences.dart';
import 'ui/crud/collection_crud.dart';
import 'ui/scaffold/nav_destinations.dart';

final realCmRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(realCmAuthProvider);
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final connecting = loc == '/setup';
      final loggingIn = loc == '/login';
      final changing = loc == '/change-password';
      if (!auth.hasBackend) return connecting ? null : '/setup';
      if (!auth.isAuthenticated) return loggingIn ? null : '/login';
      if (auth.mustChangePassword) return changing ? null : '/change-password';
      if (loggingIn || connecting || changing) return '/';
      // Permission guard: route nào yêu cầu role cụ thể, redirect về / nếu role không khớp.
      final dest = realCmDestinations.where((d) => loc == d.route || (d.route != '/' && loc.startsWith(d.route))).firstOrNull;
      if (dest != null && !dest.isVisibleFor(auth.role ?? 'guest')) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/setup', builder: (_, __) => const ConnectionScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/change-password', builder: (_, __) => const ChangePasswordScreen()),
      GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),

      GoRoute(path: '/members', builder: (_, __) => const MemberListScreen()),
      GoRoute(path: '/members/:id', builder: (_, state) => MemberDetailScreen(memberId: state.pathParameters['id']!)),
      GoRoute(path: '/districts', builder: (_, __) => const DistrictListScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const ParishSettingsScreen()),
      GoRoute(path: '/preferences', builder: (_, __) => const PreferencesScreen()),
      GoRoute(path: '/users', builder: (_, __) => const UserManagementScreen()),
      GoRoute(path: '/calendar', builder: (_, __) => const LiturgicalCalendarScreen()),
      GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),

      GoRoute(path: '/families', builder: (_, __) => CollectionCrudScreen(config: cfg.familyConfig)),
      GoRoute(path: '/families/:id', builder: (_, state) => FamilyDetailScreen(familyId: state.pathParameters['id']!)),
      GoRoute(path: '/sacrament/baptism', builder: (_, __) => CollectionCrudScreen(config: cfg.baptismConfig)),
      GoRoute(path: '/sacrament/confirmation', builder: (_, __) => CollectionCrudScreen(config: cfg.confirmationConfig)),
      GoRoute(path: '/sacrament/marriage', builder: (_, __) => CollectionCrudScreen(config: cfg.marriageConfig)),
      GoRoute(path: '/sacrament/anointing', builder: (_, __) => CollectionCrudScreen(config: cfg.anointingConfig)),
      GoRoute(path: '/sacrament/funeral', builder: (_, __) => CollectionCrudScreen(config: cfg.funeralConfig)),
      GoRoute(path: '/groups', builder: (_, __) => CollectionCrudScreen(config: cfg.groupConfig)),
      GoRoute(path: '/mass', builder: (_, __) => CollectionCrudScreen(config: cfg.massIntentionConfig)),
      GoRoute(path: '/donations', builder: (_, __) => CollectionCrudScreen(config: cfg.donationConfig)),
    ],
  );
});

class RealCmApp extends ConsumerWidget {
  const RealCmApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(realCmRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
      theme: RealCmTheme.light(),
      darkTheme: RealCmTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      debugShowCheckedModeBanner: false,
    );
  }
}

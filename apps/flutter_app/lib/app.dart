// Real Church Manager — App root
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'design/icons.dart';
import 'design/theme.dart';
import 'features/auth/change_password_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/coming_soon/coming_soon_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/district/list_screen.dart';
import 'features/member/list_screen.dart';
import 'features/modules/configs.dart' as cfg;
import 'features/settings/connection_screen.dart';
import 'features/settings/parish_settings_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'platform/pocketbase/auth.dart';
import 'ui/crud/collection_crud.dart';

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
      return null;
    },
    routes: [
      GoRoute(path: '/setup', builder: (_, __) => const ConnectionScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/change-password', builder: (_, __) => const ChangePasswordScreen()),
      GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),

      // Module có CRUD UI riêng
      GoRoute(path: '/members', builder: (_, __) => const MemberListScreen()),
      GoRoute(path: '/districts', builder: (_, __) => const DistrictListScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const ParishSettingsScreen()),

      // Module dùng generic CollectionCrudScreen với config
      GoRoute(path: '/sacrament/baptism', builder: (_, __) => CollectionCrudScreen(config: cfg.baptismConfig)),
      GoRoute(path: '/sacrament/confirmation', builder: (_, __) => CollectionCrudScreen(config: cfg.confirmationConfig)),
      GoRoute(path: '/sacrament/marriage', builder: (_, __) => CollectionCrudScreen(config: cfg.marriageConfig)),
      GoRoute(path: '/sacrament/anointing', builder: (_, __) => CollectionCrudScreen(config: cfg.anointingConfig)),
      GoRoute(path: '/sacrament/funeral', builder: (_, __) => CollectionCrudScreen(config: cfg.funeralConfig)),
      GoRoute(path: '/groups', builder: (_, __) => CollectionCrudScreen(config: cfg.groupConfig)),
      GoRoute(path: '/mass', builder: (_, __) => CollectionCrudScreen(config: cfg.massIntentionConfig)),
      GoRoute(path: '/donations', builder: (_, __) => CollectionCrudScreen(config: cfg.donationConfig)),

      // Module còn placeholder (Family / Calendar / Reports — sẽ làm v1.0.x)
      GoRoute(path: '/families', builder: (_, __) => _placeholder('/families')),
      GoRoute(path: '/calendar', builder: (_, __) => _placeholder('/calendar')),
      GoRoute(path: '/reports', builder: (_, __) => _placeholder('/reports')),
    ],
  );
});

Widget _placeholder(String route) {
  final c = ComingSoonCatalog.all[route];
  if (c == null) {
    return ComingSoonScreen(
      appBarTitle: 'Đang phát triển',
      icon: RealCmIcons.info,
      heading: 'Module sắp ra mắt',
      description: 'Module này đang được phát triển.',
      features: const ['Sẽ có ở các phase tiếp theo'],
    );
  }
  return ComingSoonScreen(
    appBarTitle: c.title,
    icon: c.icon,
    heading: c.heading,
    description: c.description,
    features: c.features,
    targetVersion: c.targetVersion,
  );
}

class RealCmApp extends ConsumerWidget {
  const RealCmApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(realCmRouterProvider);
    return MaterialApp.router(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
      theme: RealCmTheme.light(),
      darkTheme: RealCmTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('vi'),
      debugShowCheckedModeBanner: false,
    );
  }
}

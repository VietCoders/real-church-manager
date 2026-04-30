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
import 'features/settings/connection_screen.dart';
import 'features/settings/parish_settings_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'platform/pocketbase/auth.dart';

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

      // Module đã có full CRUD
      GoRoute(path: '/members', builder: (_, __) => const MemberListScreen()),
      GoRoute(path: '/districts', builder: (_, __) => const DistrictListScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const ParishSettingsScreen()),

      // Module placeholder — full UI sẽ scaffold trong các turn tiếp.
      GoRoute(path: '/families', builder: (_, __) => _placeholder('/families')),
      GoRoute(path: '/sacrament/baptism', builder: (_, __) => _placeholder('/sacrament/baptism', custom: const ComingSoonConfig(
        title: 'Sổ Rửa Tội',
        icon: RealCmIcons.baptism,
        heading: 'Sổ Rửa Tội (Baptism)',
        description: 'Quản lý sổ Bí Tích Rửa Tội với cha mẹ đỡ đầu, cha rửa tội, in chứng chỉ.',
        features: [
          'CRUD record Rửa Tội với số sổ tự động (RT-YYYY-NNNN)',
          'Liên kết giáo dân + cha mẹ đỡ đầu',
          'Tự động cập nhật Member.baptism_date',
          'In chứng chỉ Rửa Tội PDF A4 layout chuẩn VN (đã có pdf builder canonical)',
          'Tìm kiếm theo số sổ, năm, tên người',
          'Backend: data layer đã có entity + repository sẵn sàng',
        ],
      ))),
      GoRoute(path: '/sacrament/confirmation', builder: (_, __) => _placeholder('/sacrament/confirmation')),
      GoRoute(path: '/sacrament/marriage', builder: (_, __) => _placeholder('/sacrament/marriage')),
      GoRoute(path: '/sacrament/anointing', builder: (_, __) => _placeholder('/sacrament/anointing')),
      GoRoute(path: '/sacrament/funeral', builder: (_, __) => _placeholder('/sacrament/funeral')),
      GoRoute(path: '/groups', builder: (_, __) => _placeholder('/groups')),
      GoRoute(path: '/mass', builder: (_, __) => _placeholder('/mass')),
      GoRoute(path: '/calendar', builder: (_, __) => _placeholder('/calendar')),
      GoRoute(path: '/donations', builder: (_, __) => _placeholder('/donations')),
      GoRoute(path: '/reports', builder: (_, __) => _placeholder('/reports')),
    ],
  );
});

Widget _placeholder(String route, {ComingSoonConfig? custom}) {
  final cfg = custom ?? ComingSoonCatalog.all[route];
  if (cfg == null) {
    return ComingSoonScreen(
      appBarTitle: 'Đang phát triển',
      icon: RealCmIcons.info,
      heading: 'Module sắp ra mắt',
      description: 'Module này đang được phát triển.',
      features: const ['Sẽ có ở các phase tiếp theo'],
    );
  }
  return ComingSoonScreen(
    appBarTitle: cfg.title,
    icon: cfg.icon,
    heading: cfg.heading,
    description: cfg.description,
    features: cfg.features,
    targetVersion: cfg.targetVersion,
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

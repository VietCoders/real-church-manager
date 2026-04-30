// Real Church Manager — App root
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'design/theme.dart';
import 'features/auth/login_screen.dart';
import 'features/member/list_screen.dart';
import 'features/settings/connection_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'platform/pocketbase/auth.dart';

final realCmRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(realCmAuthProvider);
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login';
      final connecting = state.matchedLocation == '/setup';
      if (!auth.hasBackend) return connecting ? null : '/setup';
      if (!auth.isAuthenticated) return loggingIn ? null : '/login';
      if (loggingIn || connecting) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/setup', builder: (_, __) => const ConnectionScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/', builder: (_, __) => const MemberListScreen()),
    ],
  );
});

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

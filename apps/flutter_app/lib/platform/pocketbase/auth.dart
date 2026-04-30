// Auth state — Riverpod provider + login/logout + role check.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../core/logging/logger.dart';
import 'client.dart';

class RealCmAuthState {
  RealCmAuthState({
    required this.hasBackend,
    required this.isAuthenticated,
    this.user,
    this.role,
    this.mustChangePassword = false,
  });

  final bool hasBackend;
  final bool isAuthenticated;
  final RecordModel? user;
  final String? role;
  final bool mustChangePassword;

  bool get isPriestPastor => role == 'priest_pastor';
  bool get isPriest => role?.startsWith('priest_') ?? false;
  bool get isSecretary => role == 'secretary';
  bool get isCouncilMember => role == 'council_member';
  bool get canEditMembers => isPriest || isSecretary;
  bool get canDeleteRecords => isPriestPastor;

  RealCmAuthState copyWith({
    bool? hasBackend,
    bool? isAuthenticated,
    RecordModel? user,
    String? role,
    bool? mustChangePassword,
  }) =>
      RealCmAuthState(
        hasBackend: hasBackend ?? this.hasBackend,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        user: user ?? this.user,
        role: role ?? this.role,
        mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      );

  static RealCmAuthState initial() {
    final url = RealCmPocketBase.backendUrl();
    if (url == null || url.isEmpty) {
      return RealCmAuthState(hasBackend: false, isAuthenticated: false);
    }
    final pb = RealCmPocketBase.instance();
    final rec = pb.authStore.record;
    return RealCmAuthState(
      hasBackend: true,
      isAuthenticated: pb.authStore.isValid,
      user: rec,
      role: rec?.data['role'] as String?,
      mustChangePassword: (rec?.data['must_change_password'] as bool?) ?? false,
    );
  }
}

class RealCmAuthController extends StateNotifier<RealCmAuthState> {
  RealCmAuthController() : super(RealCmAuthState.initial());

  final _log = RealCmLogger.of('auth');

  Future<void> login({required String email, required String password}) async {
    final pb = RealCmPocketBase.instance();
    final res = await pb.collection('users').authWithPassword(email, password);
    state = state.copyWith(
      isAuthenticated: true,
      user: res.record,
      role: res.record.data['role'] as String?,
    );
    _log.info('Login OK: ${res.record.id}, role=${state.role}');
  }

  Future<void> logout() async {
    final pb = RealCmPocketBase.instance();
    pb.authStore.clear();
    state = state.copyWith(isAuthenticated: false, user: null, role: null);
    _log.info('Logout');
  }

  Future<void> setBackendUrl(String url) async {
    await RealCmPocketBase.setBackendUrl(url);
    state = RealCmAuthState.initial();
  }
}

final realCmAuthProvider = StateNotifierProvider<RealCmAuthController, RealCmAuthState>(
  (ref) => RealCmAuthController(),
);

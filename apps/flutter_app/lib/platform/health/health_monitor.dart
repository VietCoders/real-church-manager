// Health monitor — periodic ping pb.health.check() để detect offline / server down.
// Provider serverHealthProvider expose enum state. AppShell hiển thị banner đỏ khi unhealthy.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pocketbase/client.dart';

enum ServerHealth { unknown, healthy, unhealthy }

class ServerHealthState {
  const ServerHealthState({required this.status, this.message, this.lastChecked});
  final ServerHealth status;
  final String? message;
  final DateTime? lastChecked;
}

class ServerHealthController extends StateNotifier<ServerHealthState> {
  ServerHealthController() : super(const ServerHealthState(status: ServerHealth.unknown));

  Timer? _timer;

  void start({Duration interval = const Duration(seconds: 30)}) {
    stop();
    _check();
    _timer = Timer.periodic(interval, (_) => _check());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> ping() => _check();

  Future<void> _check() async {
    try {
      final pb = RealCmPocketBase.instance();
      final res = await pb.health.check();
      // PB v0.22 health.check() returns HealthCheck with `code` (200 OK), `message`, `data`.
      if (res.code == 200) {
        state = ServerHealthState(status: ServerHealth.healthy, lastChecked: DateTime.now());
      } else {
        state = ServerHealthState(
          status: ServerHealth.unhealthy,
          message: res.message,
          lastChecked: DateTime.now(),
        );
      }
    } catch (e) {
      state = ServerHealthState(
        status: ServerHealth.unhealthy,
        message: e.toString(),
        lastChecked: DateTime.now(),
      );
    }
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

final serverHealthProvider = StateNotifierProvider<ServerHealthController, ServerHealthState>(
  (ref) => ServerHealthController(),
);

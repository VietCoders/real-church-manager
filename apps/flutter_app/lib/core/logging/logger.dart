// Logger — wrapper quanh `package:logging`. Mọi module dùng RealCmLogger.
import 'package:logging/logging.dart';

class RealCmLogger {
  RealCmLogger._();

  static void init() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((rec) {
      // ignore: avoid_print
      print('[${rec.level.name}] ${rec.loggerName}: ${rec.message}');
    });
  }

  static Logger of(String name) => Logger('real-cm.$name');
}

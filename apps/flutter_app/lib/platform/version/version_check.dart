// Version + GitHub release update check.
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionInfo {
  const AppVersionInfo({required this.appName, required this.version, required this.buildNumber, required this.packageName});
  final String appName;
  final String version;
  final String buildNumber;
  final String packageName;

  String get full => '$version+$buildNumber';
}

Future<AppVersionInfo> getCurrentVersion() async {
  final info = await PackageInfo.fromPlatform();
  return AppVersionInfo(
    appName: info.appName,
    version: info.version,
    buildNumber: info.buildNumber,
    packageName: info.packageName,
  );
}

class GitHubRelease {
  const GitHubRelease({required this.tag, required this.name, required this.htmlUrl, required this.publishedAt, this.body});
  final String tag;
  final String name;
  final String htmlUrl;
  final DateTime? publishedAt;
  final String? body;
}

class UpdateCheckResult {
  const UpdateCheckResult({required this.current, this.latest, this.hasUpdate = false, this.error});
  final String current;
  final GitHubRelease? latest;
  final bool hasUpdate;
  final String? error;
}

/// Compare semver-ish "1.2.3" → list int.
List<int> _parseVersion(String v) {
  final clean = v.replaceFirst(RegExp(r'^v'), '').split('+').first.split('-').first;
  return clean.split('.').map((s) => int.tryParse(s) ?? 0).toList();
}

bool _isNewer(List<int> a, List<int> b) {
  for (var i = 0; i < a.length || i < b.length; i++) {
    final av = i < a.length ? a[i] : 0;
    final bv = i < b.length ? b[i] : 0;
    if (av > bv) return true;
    if (av < bv) return false;
  }
  return false;
}

/// Check GitHub releases API cho `VietCoders/real-church-manager`.
/// Trả về result với hasUpdate=true nếu remote version > current.
Future<UpdateCheckResult> checkForUpdate({
  String repo = 'VietCoders/real-church-manager',
}) async {
  try {
    final current = await getCurrentVersion();
    final res = await http.get(
      Uri.parse('https://api.github.com/repos/$repo/releases/latest'),
      headers: {'Accept': 'application/vnd.github+json'},
    );
    if (res.statusCode == 404) {
      return UpdateCheckResult(current: current.version, error: 'Chưa có release nào trên GitHub');
    }
    if (res.statusCode != 200) {
      return UpdateCheckResult(current: current.version, error: 'GitHub API trả về ${res.statusCode}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final tag = (json['tag_name'] ?? '').toString();
    final name = (json['name'] ?? tag).toString();
    final url = (json['html_url'] ?? '').toString();
    final published = DateTime.tryParse((json['published_at'] ?? '').toString());
    final body = json['body']?.toString();
    final latest = GitHubRelease(tag: tag, name: name, htmlUrl: url, publishedAt: published, body: body);
    final hasUpdate = _isNewer(_parseVersion(tag), _parseVersion(current.version));
    return UpdateCheckResult(current: current.version, latest: latest, hasUpdate: hasUpdate);
  } catch (e) {
    return UpdateCheckResult(current: '?', error: e.toString());
  }
}

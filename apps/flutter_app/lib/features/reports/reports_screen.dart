// Reports — 6 báo cáo thống kê dùng StatsRepository.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:open_filex/open_filex.dart';

import '../../data/stats/repository.dart';
import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../platform/excel/exporter.dart';
import '../../platform/pdf/report_builder.dart';
import '../../platform/pocketbase/client.dart';
import '../../ui/scaffold/app_shell.dart';
import '../../ui/toast/service.dart';

Future<String> _fetchParishName() async {
  try {
    final pb = RealCmPocketBase.instance();
    final res = await pb.collection('parish_settings').getList(page: 1, perPage: 1);
    if (res.items.isEmpty) return 'Giáo xứ';
    final d = res.items.first.data;
    return (d['name'] ?? d['parish_name'] ?? 'Giáo xứ').toString();
  } catch (_) {
    return 'Giáo xứ';
  }
}

Future<void> _exportReportPdf(
  BuildContext ctx,
  String title,
  List<MapEntry<String, String>> rows, {
  String? caption,
  ReportChartType chartType = ReportChartType.none,
}) async {
  try {
    final parishName = await _fetchParishName();
    final doc = await RealCmReportPdfBuilder.simpleTable(
      parishName: parishName,
      title: title,
      caption: caption,
      rows: rows,
      chartType: chartType,
    );
    await RealCmReportPdfBuilder.print(doc, jobName: title);
  } catch (e) {
    if (ctx.mounted) realCmToast(ctx, 'Lỗi xuất PDF: $e', type: RealCmToastType.error);
  }
}

Future<void> _exportReportExcel(
  BuildContext ctx,
  String title,
  List<MapEntry<String, String>> rows, {
  String? caption,
}) async {
  try {
    final parishName = await _fetchParishName();
    final path = await RealCmExcelExporter.exportSimpleTable(
      parishName: parishName,
      title: title,
      caption: caption,
      rows: rows,
    );
    if (!ctx.mounted) return;
    realCmToast(ctx, 'Đã xuất: $path', type: RealCmToastType.success);
    await OpenFilex.open(path);
  } catch (e) {
    if (ctx.mounted) realCmToast(ctx, 'Lỗi xuất Excel: $e', type: RealCmToastType.error);
  }
}

final _statsRepoProvider = Provider((_) => StatsRepository());

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _activeReport = 'overview';

  @override
  Widget build(BuildContext context) {
    return RealCmAppShell(
      title: 'Báo cáo thống kê',
      actions: [
        IconButton(
          icon: const Icon(RealCmIcons.refresh),
          tooltip: 'Làm mới',
          onPressed: () => setState(() {}),
        ),
      ],
      body: Row(
        children: [
          // Sidebar list báo cáo
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(right: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
            ),
            child: ListView(
              padding: const EdgeInsets.all(RealCmSpacing.s2),
              children: const [
                _ReportListHeader('Tổng quan'),
                _ReportItem(id: 'overview', icon: RealCmIcons.report, title: 'Tổng quan giáo xứ', subtitle: 'Số liệu tổng hợp tất cả module'),
                _ReportListHeader('Giáo dân'),
                _ReportItem(id: 'by_age', icon: RealCmIcons.member, title: 'Theo độ tuổi', subtitle: '5 nhóm tuổi + biểu đồ'),
                _ReportItem(id: 'by_gender', icon: RealCmIcons.member, title: 'Theo giới tính', subtitle: 'Nam / Nữ / Khác'),
                _ReportListHeader('Bí Tích'),
                _ReportItem(id: 'sacrament_year', icon: RealCmIcons.baptism, title: 'Bí Tích theo năm', subtitle: 'Số rửa tội / hôn phối / an táng từng năm'),
                _ReportListHeader('Tài chính'),
                _ReportItem(id: 'donation_summary', icon: RealCmIcons.donation, title: 'Tổng thu chi', subtitle: 'Theo loại trong năm'),
                _ReportListHeader('Hoạt động'),
                _ReportItem(id: 'mass_intentions', icon: RealCmIcons.mass, title: 'Lễ ý cầu nguyện', subtitle: 'Theo trạng thái'),
              ],
            ),
          ),
          Expanded(child: _buildReport()),
        ],
      ),
    );
  }

  Widget _buildReport() {
    switch (_activeReport) {
      case 'overview':
        return const _OverviewReport();
      case 'by_age':
        return const _ByAgeReport();
      case 'by_gender':
        return const _ByGenderReport();
      case 'sacrament_year':
        return const _SacramentYearReport();
      case 'donation_summary':
        return const _DonationSummaryReport();
      case 'mass_intentions':
        return const _MassIntentionsReport();
      default:
        return const Center(child: Text('Chọn báo cáo từ danh sách bên trái'));
    }
  }
}

class _ReportListHeader extends StatelessWidget {
  const _ReportListHeader(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(RealCmSpacing.s3, RealCmSpacing.s4, RealCmSpacing.s3, RealCmSpacing.s2),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: RealCmColors.textMuted),
      ),
    );
  }
}

class _ReportItem extends ConsumerWidget {
  const _ReportItem({required this.id, required this.icon, required this.title, required this.subtitle});
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = context.findAncestorStateOfType<_ReportsScreenState>()!;
    final active = state._activeReport == id;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: RealCmSpacing.s2, vertical: 2),
      decoration: BoxDecoration(
        color: active ? RealCmColors.primary.withValues(alpha: 0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(RealCmRadius.md),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, size: 20, color: active ? RealCmColors.primary : RealCmColors.textMuted),
        title: Text(title, style: TextStyle(fontWeight: active ? FontWeight.w600 : FontWeight.w500, fontSize: 14, color: active ? RealCmColors.primary : null)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: RealCmColors.textMuted)),
        onTap: () => state.setState(() => state._activeReport = id),
      ),
    );
  }
}

// ─── Tổng quan ────────────────────────────────────────────
class _OverviewReport extends ConsumerWidget {
  const _OverviewReport();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(_statsRepoProvider);
    final yr = DateTime.now().year;
    return _ReportFrame(
      title: 'Tổng quan giáo xứ',
      onExport: () async {
        final d = await Future.wait([
          repo.totalActiveMembers(),
          repo.totalFamilies(),
          repo.totalDistricts(),
          repo.baptismsThisYear(),
          repo.marriagesThisYear(),
          repo.funeralsThisYear(),
        ]);
        if (!context.mounted) return;
        await _exportReportPdf(context, 'Tổng quan giáo xứ', [
          MapEntry('Giáo dân', '${d[0]}'),
          MapEntry('Gia đình', '${d[1]}'),
          MapEntry('Giáo họ', '${d[2]}'),
          MapEntry('Rửa Tội $yr', '${d[3]}'),
          MapEntry('Hôn Phối $yr', '${d[4]}'),
          MapEntry('An Táng $yr', '${d[5]}'),
        ], caption: 'Năm $yr', chartType: ReportChartType.bar);
      },
      onExportExcel: () async {
        final d = await Future.wait([
          repo.totalActiveMembers(),
          repo.totalFamilies(),
          repo.totalDistricts(),
          repo.baptismsThisYear(),
          repo.marriagesThisYear(),
          repo.funeralsThisYear(),
        ]);
        if (!context.mounted) return;
        await _exportReportExcel(context, 'Tổng quan giáo xứ', [
          MapEntry('Giáo dân', '${d[0]}'),
          MapEntry('Gia đình', '${d[1]}'),
          MapEntry('Giáo họ', '${d[2]}'),
          MapEntry('Rửa Tội $yr', '${d[3]}'),
          MapEntry('Hôn Phối $yr', '${d[4]}'),
          MapEntry('An Táng $yr', '${d[5]}'),
        ], caption: 'Năm $yr');
      },
      child: FutureBuilder(
        future: Future.wait([
          repo.totalActiveMembers(),
          repo.totalFamilies(),
          repo.totalDistricts(),
          repo.baptismsThisYear(),
          repo.marriagesThisYear(),
          repo.funeralsThisYear(),
        ]),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final d = snap.data as List<int>;
          return GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 1.6,
            mainAxisSpacing: RealCmSpacing.s3,
            crossAxisSpacing: RealCmSpacing.s3,
            children: [
              _Stat(icon: RealCmIcons.member, color: RealCmColors.primary, label: 'Giáo dân', value: d[0]),
              _Stat(icon: RealCmIcons.family, color: RealCmColors.info, label: 'Gia đình', value: d[1]),
              _Stat(icon: RealCmIcons.district, color: RealCmColors.success, label: 'Giáo họ', value: d[2]),
              _Stat(icon: RealCmIcons.baptism, color: RealCmColors.info, label: 'Rửa Tội $yr', value: d[3]),
              _Stat(icon: RealCmIcons.marriage, color: RealCmColors.accent, label: 'Hôn Phối $yr', value: d[4]),
              _Stat(icon: RealCmIcons.funeral, color: RealCmColors.textMuted, label: 'An Táng $yr', value: d[5]),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.color, required this.label, required this.value});
  final IconData icon;
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RealCmSpacing.s4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(RealCmRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(RealCmSpacing.s3),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(RealCmRadius.md)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: RealCmSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, color: RealCmColors.textMuted)),
                Text('$value', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color, height: 1.1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Theo độ tuổi ─────────────────────────────────────────
class _ByAgeReport extends ConsumerWidget {
  const _ByAgeReport();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(_statsRepoProvider);
    return _ReportFrame(
      title: 'Phân bổ giáo dân theo độ tuổi',
      onExport: () async {
        final m = await repo.membersByAgeGroup();
        if (!context.mounted) return;
        await _exportReportPdf(context, 'Giáo dân theo độ tuổi',
          m.entries.map((e) => MapEntry(e.key, '${e.value}')).toList(),
          chartType: ReportChartType.bar);
      },
      onExportExcel: () async {
        final m = await repo.membersByAgeGroup();
        if (!context.mounted) return;
        await _exportReportExcel(context, 'Giáo dân theo độ tuổi',
          m.entries.map((e) => MapEntry(e.key, '${e.value}')).toList());
      },
      child: FutureBuilder(
        future: repo.membersByAgeGroup(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final m = snap.data as Map<String, int>;
          final entries = m.entries.where((e) => e.key != 'Không rõ').toList();
          final maxY = entries.map((e) => e.value).fold<int>(0, (mx, v) => v > mx ? v : mx).toDouble();
          if (maxY == 0) {
            return const Center(child: Text('Chưa có dữ liệu giáo dân', style: TextStyle(color: RealCmColors.textMuted)));
          }
          return Column(
            children: [
              SizedBox(
                height: 320,
                child: BarChart(BarChartData(
                  maxY: maxY * 1.2,
                  alignment: BarChartAlignment.spaceAround,
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true, reservedSize: 32,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= entries.length) return const SizedBox();
                        return Padding(padding: const EdgeInsets.only(top: 4), child: Text(entries[i].key, style: const TextStyle(fontSize: 11)));
                      },
                    )),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(entries.length, (i) => BarChartGroupData(x: i, barRods: [
                    BarChartRodData(toY: entries[i].value.toDouble(), color: RealCmColors.primary, width: 32, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                  ])),
                )),
              ),
              const SizedBox(height: RealCmSpacing.s4),
              _DataTable(rows: entries.map((e) => MapEntry(e.key, e.value.toString())).toList()),
            ],
          );
        },
      ),
    );
  }
}

// ─── Theo giới tính ───────────────────────────────────────
class _ByGenderReport extends ConsumerWidget {
  const _ByGenderReport();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(_statsRepoProvider);
    return _ReportFrame(
      title: 'Phân bổ giáo dân theo giới tính',
      onExport: () async {
        final m = await repo.membersByGender();
        if (!context.mounted) return;
        final total = (m['male']??0) + (m['female']??0) + (m['other']??0);
        await _exportReportPdf(context, 'Giáo dân theo giới tính', [
          MapEntry('Nam', '${m['male']??0}'),
          MapEntry('Nữ', '${m['female']??0}'),
          MapEntry('Khác', '${m['other']??0}'),
          MapEntry('Tổng', '$total'),
        ], chartType: ReportChartType.pie);
      },
      onExportExcel: () async {
        final m = await repo.membersByGender();
        if (!context.mounted) return;
        final total = (m['male']??0) + (m['female']??0) + (m['other']??0);
        await _exportReportExcel(context, 'Giáo dân theo giới tính', [
          MapEntry('Nam', '${m['male']??0}'),
          MapEntry('Nữ', '${m['female']??0}'),
          MapEntry('Khác', '${m['other']??0}'),
          MapEntry('Tổng', '$total'),
        ]);
      },
      child: FutureBuilder(
        future: repo.membersByGender(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final m = snap.data as Map<String, int>;
          final total = (m['male']??0) + (m['female']??0) + (m['other']??0);
          if (total == 0) return const Center(child: Text('Chưa có dữ liệu', style: TextStyle(color: RealCmColors.textMuted)));
          final sections = <PieChartSectionData>[
            if ((m['male']??0)>0) PieChartSectionData(value: m['male']!.toDouble(), color: RealCmColors.info, title: 'Nam ${((m['male']!/total)*100).toStringAsFixed(0)}%', radius: 80, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            if ((m['female']??0)>0) PieChartSectionData(value: m['female']!.toDouble(), color: RealCmColors.primary, title: 'Nữ ${((m['female']!/total)*100).toStringAsFixed(0)}%', radius: 80, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            if ((m['other']??0)>0) PieChartSectionData(value: m['other']!.toDouble(), color: RealCmColors.textMuted, title: 'Khác', radius: 80, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ];
          return Column(children: [
            SizedBox(height: 320, child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 60, sectionsSpace: 2, borderData: FlBorderData(show: false)))),
            const SizedBox(height: RealCmSpacing.s4),
            _DataTable(rows: [
              MapEntry('Nam', '${m['male']??0}'),
              MapEntry('Nữ', '${m['female']??0}'),
              MapEntry('Khác', '${m['other']??0}'),
              MapEntry('Tổng', '$total'),
            ]),
          ]);
        },
      ),
    );
  }
}

// ─── Bí tích theo năm ─────────────────────────────────────
class _SacramentYearReport extends ConsumerStatefulWidget {
  const _SacramentYearReport();
  @override
  ConsumerState<_SacramentYearReport> createState() => _SacramentYearReportState();
}

class _SacramentYearReportState extends ConsumerState<_SacramentYearReport> {
  int _year = DateTime.now().year;
  Future<List<int>>? _future;

  Future<List<int>> _load() async {
    final pb = RealCmPocketBase.instance();
    final start = '$_year-01-01';
    final end = '$_year-12-31';
    final colDateMap = {
      'sacrament_baptism': 'baptism_date',
      'sacrament_confirmation': 'confirmation_date',
      'sacrament_marriage': 'marriage_date',
      'sacrament_anointing': 'anointing_date',
      'sacrament_funeral': 'funeral_date',
    };
    final results = <int>[];
    for (final entry in colDateMap.entries) {
      final res = await pb.collection(entry.key).getList(
        page: 1, perPage: 1,
        filter: '${entry.value} >= "$start" && ${entry.value} <= "$end"',
      );
      results.add(res.totalItems);
    }
    return results;
  }

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  Widget build(BuildContext context) {
    final years = List.generate(5, (i) => DateTime.now().year - i);
    const labels = ['Rửa Tội', 'Thêm Sức', 'Hôn Phối', 'Xức Dầu', 'An Táng'];
    return _ReportFrame(
      title: 'Bí Tích theo năm',
      headerActions: [
        DropdownButton<int>(
          value: _year,
          items: years.map((y) => DropdownMenuItem(value: y, child: Text('Năm $y'))).toList(),
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              _year = v;
              _future = _load();
            });
          },
        ),
      ],
      onExport: () async {
        final d = await _load();
        if (!context.mounted) return;
        await _exportReportPdf(context, 'Bí Tích theo năm',
          List.generate(labels.length, (i) => MapEntry(labels[i], '${d[i]}')),
          caption: 'Năm $_year', chartType: ReportChartType.bar);
      },
      onExportExcel: () async {
        final d = await _load();
        if (!context.mounted) return;
        await _exportReportExcel(context, 'Bí Tích theo năm',
          List.generate(labels.length, (i) => MapEntry(labels[i], '${d[i]}')),
          caption: 'Năm $_year');
      },
      child: FutureBuilder<List<int>>(
        future: _future,
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final d = snap.data!;
          final colors = [RealCmColors.info, RealCmColors.danger, RealCmColors.accent, RealCmColors.warning, RealCmColors.textMuted];
          final maxY = d.fold<int>(0, (m, v) => v > m ? v : m).toDouble();
          return Column(children: [
            SizedBox(
              height: 280,
              child: maxY == 0
                  ? const Center(child: Text('Chưa có Bí Tích nào trong năm', style: TextStyle(color: RealCmColors.textMuted)))
                  : BarChart(BarChartData(
                      maxY: maxY * 1.2,
                      alignment: BarChartAlignment.spaceAround,
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true, reservedSize: 36,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i < 0 || i >= labels.length) return const SizedBox();
                            return Padding(padding: const EdgeInsets.only(top: 4), child: Text(labels[i], style: const TextStyle(fontSize: 10)));
                          },
                        )),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(d.length, (i) => BarChartGroupData(x: i, barRods: [
                        BarChartRodData(toY: d[i].toDouble(), color: colors[i], width: 28, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                      ])),
                    )),
            ),
            const SizedBox(height: RealCmSpacing.s4),
            _DataTable(rows: List.generate(labels.length, (i) => MapEntry(labels[i], '${d[i]}'))),
          ]);
        },
      ),
    );
  }
}

// ─── Tổng thu chi ─────────────────────────────────────────
class _DonationSummaryReport extends ConsumerStatefulWidget {
  const _DonationSummaryReport();
  @override
  ConsumerState<_DonationSummaryReport> createState() => _DonationSummaryReportState();
}

class _DonationSummaryReportState extends ConsumerState<_DonationSummaryReport> {
  int _year = DateTime.now().year;
  Future<Map<String, num>>? _future;

  Future<Map<String, num>> _load() async {
    final pb = RealCmPocketBase.instance();
    final res = await pb.collection('donations').getList(
      page: 1, perPage: 500,
      filter: 'date >= "$_year-01-01" && date <= "$_year-12-31"',
    );
    final byType = <String, num>{};
    for (final r in res.items) {
      final t = r.data['type']?.toString() ?? 'other_in';
      final amt = (r.data['amount'] as num?) ?? 0;
      byType[t] = (byType[t] ?? 0) + amt;
    }
    return byType;
  }

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  String _typeLabel(String t) => {
    'sunday_offering': 'Dâng Chúa Nhật',
    'feast_offering': 'Dâng lễ trọng',
    'building_fund': 'Quỹ xây dựng',
    'mass_intention': 'Xin lễ',
    'other_in': 'Thu khác',
    'expense': 'Chi',
  }[t] ?? t;

  @override
  Widget build(BuildContext context) {
    final years = List.generate(5, (i) => DateTime.now().year - i);
    final fmt = NumberFormat.decimalPattern('vi');
    return _ReportFrame(
      title: 'Tổng thu chi',
      headerActions: [
        DropdownButton<int>(
          value: _year,
          items: years.map((y) => DropdownMenuItem(value: y, child: Text('Năm $y'))).toList(),
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              _year = v;
              _future = _load();
            });
          },
        ),
      ],
      onExport: () async {
        final m = await _load();
        if (!context.mounted) return;
        num totalIn = 0, totalOut = 0;
        m.forEach((k, v) {
          if (k == 'expense') { totalOut += v; } else { totalIn += v; }
        });
        final rows = m.entries.map((e) => MapEntry(_typeLabel(e.key), '${fmt.format(e.value)} đ')).toList()
          ..add(MapEntry('Tổng thu', '${fmt.format(totalIn)} đ'))
          ..add(MapEntry('Tổng chi', '${fmt.format(totalOut)} đ'))
          ..add(MapEntry('Số dư', '${fmt.format(totalIn - totalOut)} đ'));
        await _exportReportPdf(context, 'Tổng thu chi', rows, caption: 'Năm $_year', chartType: ReportChartType.pie);
      },
      child: FutureBuilder<Map<String, num>>(
        future: _future,
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final m = snap.data!;
          if (m.isEmpty) return const Center(child: Text('Chưa có giao dịch nào trong năm', style: TextStyle(color: RealCmColors.textMuted)));
          num totalIn = 0, totalOut = 0;
          m.forEach((k, v) {
            if (k == 'expense') {
              totalOut += v;
            } else {
              totalIn += v;
            }
          });
          final balance = totalIn - totalOut;
          return Column(children: [
            Row(children: [
              Expanded(child: _MoneyCard(label: 'Tổng thu', amount: totalIn, color: RealCmColors.success)),
              const SizedBox(width: RealCmSpacing.s3),
              Expanded(child: _MoneyCard(label: 'Tổng chi', amount: totalOut, color: RealCmColors.danger)),
              const SizedBox(width: RealCmSpacing.s3),
              Expanded(child: _MoneyCard(label: 'Số dư', amount: balance, color: balance >= 0 ? RealCmColors.primary : RealCmColors.warning)),
            ]),
            const SizedBox(height: RealCmSpacing.s4),
            _DataTable(rows: m.entries.map((e) => MapEntry(_typeLabel(e.key), '${fmt.format(e.value)} đ')).toList()),
          ]);
        },
      ),
    );
  }
}

class _MoneyCard extends StatelessWidget {
  const _MoneyCard({required this.label, required this.amount, required this.color});
  final String label;
  final num amount;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern('vi');
    return Container(
      padding: const EdgeInsets.all(RealCmSpacing.s4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(RealCmRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('${fmt.format(amount)} đ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

// ─── Lễ ý cầu nguyện ──────────────────────────────────────
class _MassIntentionsReport extends ConsumerWidget {
  const _MassIntentionsReport();

  Future<Map<String, int>> _load() async {
    final pb = RealCmPocketBase.instance();
    final r = <String, int>{};
    for (final s in ['pending', 'scheduled', 'done', 'cancelled']) {
      final res = await pb.collection('mass_intentions').getList(page: 1, perPage: 1, filter: 'status = "$s"');
      r[s] = res.totalItems;
    }
    return r;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const labels = {'pending': 'Chờ duyệt', 'scheduled': 'Đã xếp lịch', 'done': 'Đã cử hành', 'cancelled': 'Huỷ'};
    return _ReportFrame(
      title: 'Lễ ý cầu nguyện theo trạng thái',
      onExport: () async {
        final m = await _load();
        if (!context.mounted) return;
        final total = m.values.fold<int>(0, (s, v) => s + v);
        final rows = m.entries.map((e) => MapEntry(labels[e.key]!, '${e.value}')).toList()
          ..add(MapEntry('Tổng', '$total'));
        await _exportReportPdf(context, 'Lễ ý cầu nguyện', rows, chartType: ReportChartType.pie);
      },
      child: FutureBuilder<Map<String, int>>(
        future: _load(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final m = snap.data!;
          final colors = {'pending': RealCmColors.warning, 'scheduled': RealCmColors.info, 'done': RealCmColors.success, 'cancelled': RealCmColors.textMuted};
          final total = m.values.fold<int>(0, (s, v) => s + v);
          if (total == 0) return const Center(child: Text('Chưa có lễ ý nào', style: TextStyle(color: RealCmColors.textMuted)));
          return Column(children: [
            SizedBox(
              height: 280,
              child: PieChart(PieChartData(
                sections: m.entries.where((e) => e.value > 0).map((e) {
                  final pct = (e.value / total * 100).toStringAsFixed(0);
                  return PieChartSectionData(
                    value: e.value.toDouble(),
                    color: colors[e.key]!,
                    title: '${labels[e.key]}\n${e.value} ($pct%)',
                    radius: 100,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11),
                  );
                }).toList(),
                centerSpaceRadius: 50,
                sectionsSpace: 2,
                borderData: FlBorderData(show: false),
              )),
            ),
            const SizedBox(height: RealCmSpacing.s4),
            _DataTable(rows: m.entries.map((e) => MapEntry(labels[e.key]!, '${e.value}')).toList()..add(MapEntry('Tổng', '$total'))),
          ]);
        },
      ),
    );
  }
}

class _ReportFrame extends StatelessWidget {
  const _ReportFrame({required this.title, required this.child, this.headerActions, this.onExport, this.onExportExcel});
  final String title;
  final Widget child;
  final List<Widget>? headerActions;
  final VoidCallback? onExport;
  final VoidCallback? onExportExcel;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(RealCmSpacing.s4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
        ),
        child: Row(children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
          if (headerActions != null) ...headerActions!,
          const SizedBox(width: RealCmSpacing.s2),
          OutlinedButton.icon(
            icon: const Icon(RealCmIcons.print, size: 18),
            label: const Text('Xuất PDF'),
            onPressed: onExport,
          ),
          const SizedBox(width: RealCmSpacing.s2),
          OutlinedButton.icon(
            icon: const Icon(Icons.table_view, size: 18),
            label: const Text('Xuất Excel'),
            onPressed: onExportExcel,
          ),
        ]),
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RealCmSpacing.s4),
          child: child,
        ),
      ),
    ]);
  }
}

class _DataTable extends StatelessWidget {
  const _DataTable({required this.rows});
  final List<MapEntry<String, String>> rows;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(RealCmRadius.md),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: RealCmSpacing.s4, vertical: RealCmSpacing.s3),
              decoration: BoxDecoration(
                border: i < rows.length - 1 ? Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)) : null,
              ),
              child: Row(children: [
                Expanded(child: Text(rows[i].key, style: const TextStyle(fontWeight: FontWeight.w500))),
                Text(rows[i].value, style: const TextStyle(fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()])),
              ]),
            ),
        ],
      ),
    );
  }
}

// Lịch phụng vụ — calendar view với table_calendar + list events ngày được chọn.
// Click ngày → list events. FAB → tạo event mới qua CollectionCrudScreen modal.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../platform/pocketbase/auth.dart';
import '../../platform/pocketbase/client.dart';
import '../../ui/crud/crud_scaffold.dart';
import '../../ui/modal/service.dart';
import '../../ui/scaffold/app_shell.dart';
import '../../ui/toast/service.dart';
import '../modules/configs.dart' as cfg;
import '../../ui/crud/collection_crud.dart' as crud;

class LiturgicalCalendarScreen extends ConsumerStatefulWidget {
  const LiturgicalCalendarScreen({super.key});

  @override
  ConsumerState<LiturgicalCalendarScreen> createState() => _LiturgicalCalendarScreenState();
}

class _LiturgicalCalendarScreenState extends ConsumerState<LiturgicalCalendarScreen> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focused = DateTime.now();
  DateTime? _selected;
  Future<List<RecordModel>>? _eventsFuture;
  Map<DateTime, List<RecordModel>> _eventsByDay = {};

  @override
  void initState() {
    super.initState();
    _selected = DateTime.now();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _eventsFuture = _loadEvents();
    });
  }

  Future<List<RecordModel>> _loadEvents() async {
    final pb = RealCmPocketBase.instance();
    // Lấy events trong khoảng ±6 tháng từ focused date.
    final start = DateTime(_focused.year, _focused.month - 6, 1);
    final end = DateTime(_focused.year, _focused.month + 7, 0);
    final res = await pb.collection('liturgical_events').getList(
      page: 1, perPage: 500,
      filter: 'event_date >= "${start.toIso8601String()}" && event_date <= "${end.toIso8601String()}"',
      sort: 'event_date',
    );
    final map = <DateTime, List<RecordModel>>{};
    for (final r in res.items) {
      final raw = r.data['event_date']?.toString();
      if (raw == null) continue;
      final dt = DateTime.tryParse(raw);
      if (dt == null) continue;
      final key = DateTime(dt.year, dt.month, dt.day);
      map.putIfAbsent(key, () => []).add(r);
    }
    setState(() => _eventsByDay = map);
    return res.items;
  }

  List<RecordModel> _eventsFor(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _eventsByDay[key] ?? [];
  }

  Future<void> _addEvent({DateTime? defaultDate}) async {
    final auth = ref.read(realCmAuthProvider);
    if (!auth.canEditMembers) {
      realCmToast(context, 'Bạn không có quyền thêm sự kiện.', type: RealCmToastType.warning);
      return;
    }
    // Reuse generic CRUD form
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => crud.CrudFormDialogPublic(config: cfg.liturgicalConfig, defaults: defaultDate != null ? {'event_date': defaultDate} : null),
    );
    if (result == true) {
      if (mounted) realCmToast(context, 'Đã thêm sự kiện', type: RealCmToastType.success);
      _refresh();
    }
  }

  Future<void> _editEvent(RecordModel rec) async {
    final auth = ref.read(realCmAuthProvider);
    if (!auth.canEditMembers) return;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => crud.CrudFormDialogPublic(config: cfg.liturgicalConfig, existing: rec),
    );
    if (result == true) {
      if (mounted) realCmToast(context, 'Đã cập nhật sự kiện', type: RealCmToastType.success);
      _refresh();
    }
  }

  Future<void> _deleteEvent(RecordModel rec) async {
    final ok = await realCmConfirm(
      context,
      title: 'Xoá sự kiện',
      body: 'Xoá "${rec.data['title']}"?',
      danger: true,
    );
    if (!ok) return;
    try {
      await RealCmPocketBase.instance().collection('liturgical_events').delete(rec.id);
      if (mounted) {
        realCmToast(context, 'Đã xoá', type: RealCmToastType.success);
        _refresh();
      }
    } catch (e) {
      if (mounted) realCmToast(context, 'Lỗi: $e', type: RealCmToastType.error);
    }
  }

  Color _colorFor(String color) {
    switch (color) {
      case 'white': return RealCmColors.surfaceVariant;
      case 'red': return RealCmColors.danger;
      case 'green': return RealCmColors.success;
      case 'purple': return RealCmColors.primary;
      case 'rose': return Colors.pink;
      case 'black': return RealCmColors.text;
      default: return RealCmColors.info;
    }
  }

  String _typeLabel(String? type) {
    return {
      'mass_regular': 'Lễ thường',
      'mass_solemn': 'Lễ trọng',
      'mass_feast': 'Lễ kính',
      'confession': 'Xưng tội',
      'adoration': 'Chầu Thánh Thể',
      'meeting': 'Họp',
      'other': 'Khác',
    }[type] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(realCmAuthProvider);
    final df = DateFormat('dd/MM/yyyy', 'vi');
    final eventsToday = _selected != null ? _eventsFor(_selected!) : <RecordModel>[];
    final isWide = MediaQuery.of(context).size.width >= 900;

    return RealCmAppShell(
      title: 'Lịch phụng vụ',
      actions: [
        IconButton(icon: const Icon(RealCmIcons.refresh), tooltip: 'Làm mới', onPressed: _refresh),
      ],
      floatingActionButton: auth.canEditMembers
          ? FloatingActionButton.extended(
              onPressed: () => _addEvent(defaultDate: _selected),
              icon: const Icon(RealCmIcons.add),
              label: const Text('Thêm sự kiện'),
            )
          : null,
      body: FutureBuilder(
        future: _eventsFuture,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting && _eventsByDay.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return CrudErrorState(error: snap.error!, onRetry: _refresh);
          final calendarWidget = TableCalendar<RecordModel>(
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2100, 12, 31),
            focusedDay: _focused,
            selectedDayPredicate: (d) => isSameDay(_selected, d),
            calendarFormat: _format,
            onFormatChanged: (f) => setState(() => _format = f),
            availableCalendarFormats: const {
              CalendarFormat.month: 'Tháng',
              CalendarFormat.twoWeeks: '2 Tuần',
              CalendarFormat.week: 'Tuần',
            },
            onDaySelected: (sel, foc) {
              setState(() {
                _selected = sel;
                _focused = foc;
              });
            },
            onPageChanged: (foc) {
              _focused = foc;
              _refresh();
            },
            eventLoader: _eventsFor,
            locale: 'vi_VN',
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonShowsNext: false,
              titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: RealCmColors.primary.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(color: RealCmColors.primary, shape: BoxShape.circle),
              markerDecoration: const BoxDecoration(color: RealCmColors.accent, shape: BoxShape.circle),
              markersMaxCount: 3,
              weekendTextStyle: const TextStyle(color: RealCmColors.danger),
            ),
            calendarBuilders: CalendarBuilders<RecordModel>(
              markerBuilder: (ctx, day, events) {
                if (events.isEmpty) return const SizedBox.shrink();
                return Positioned(
                  bottom: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: events.take(3).map((e) {
                      final color = _colorFor(e.data['liturgical_color']?.toString() ?? '');
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        width: 6, height: 6,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          );

          final eventsList = _buildEventsList(eventsToday, df);

          if (isWide) {
            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(RealCmSpacing.s3),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RealCmRadius.lg)),
                      child: Padding(padding: const EdgeInsets.all(RealCmSpacing.s2), child: calendarWidget),
                    ),
                  ),
                ),
                VerticalDivider(width: 1, color: Theme.of(context).colorScheme.outlineVariant),
                Expanded(flex: 2, child: eventsList),
              ],
            );
          }
          return Column(
            children: [
              Padding(padding: const EdgeInsets.all(RealCmSpacing.s2), child: calendarWidget),
              const Divider(height: 1),
              Expanded(child: eventsList),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventsList(List<RecordModel> events, DateFormat df) {
    final auth = ref.watch(realCmAuthProvider);
    if (_selected == null) {
      return const Center(child: Text('Chọn ngày để xem sự kiện', style: TextStyle(color: RealCmColors.textMuted)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(RealCmSpacing.s4),
          color: RealCmColors.surfaceVariant,
          child: Row(
            children: [
              const Icon(RealCmIcons.calendar, color: RealCmColors.primary),
              const SizedBox(width: RealCmSpacing.s2),
              Expanded(
                child: Text(
                  df.format(_selected!),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: RealCmColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(RealCmRadius.full),
                ),
                child: Text('${events.length} sự kiện',
                    style: const TextStyle(fontSize: 12, color: RealCmColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        Expanded(
          child: events.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(RealCmSpacing.s5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(RealCmIcons.calendar, size: 56, color: RealCmColors.textDisabled),
                        const SizedBox(height: RealCmSpacing.s3),
                        const Text('Không có sự kiện', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: RealCmSpacing.s2),
                        const Text('Thêm lễ Mass / hội họp / sinh hoạt cho ngày này.',
                            style: TextStyle(color: RealCmColors.textMuted), textAlign: TextAlign.center),
                        if (auth.canEditMembers) ...[
                          const SizedBox(height: RealCmSpacing.s4),
                          ElevatedButton.icon(
                            onPressed: () => _addEvent(defaultDate: _selected),
                            icon: const Icon(RealCmIcons.add),
                            label: const Text('Thêm sự kiện'),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(RealCmSpacing.s3),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: RealCmSpacing.s2),
                  itemBuilder: (_, i) {
                    final e = events[i];
                    final color = _colorFor(e.data['liturgical_color']?.toString() ?? '');
                    return Material(
                      color: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RealCmRadius.md),
                        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: ListTile(
                        leading: Container(width: 6, height: double.infinity, color: color),
                        title: Text(e.data['title']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          [
                            _typeLabel(e.data['event_type']?.toString()),
                            if (e.data['priest_name']?.toString().isNotEmpty == true) 'Cha: ${e.data['priest_name']}',
                          ].where((s) => s.isNotEmpty).join(' · '),
                          style: const TextStyle(fontSize: 13, color: RealCmColors.textMuted),
                        ),
                        trailing: auth.canEditMembers
                            ? PopupMenuButton<String>(
                                icon: const Icon(RealCmIcons.more),
                                onSelected: (v) {
                                  if (v == 'edit') _editEvent(e);
                                  if (v == 'delete') _deleteEvent(e);
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(value: 'edit', child: Text('Sửa')),
                                  PopupMenuItem(value: 'delete', child: Text('Xoá', style: TextStyle(color: RealCmColors.danger))),
                                ],
                              )
                            : null,
                        onTap: auth.canEditMembers ? () => _editEvent(e) : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

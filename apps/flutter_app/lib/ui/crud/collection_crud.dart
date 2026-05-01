// Generic CRUD screen cho bất kỳ collection PocketBase nào.
// Render list + form modal từ CollectionConfig + CrudFieldConfig[].
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../platform/pocketbase/auth.dart';
import '../../platform/pocketbase/client.dart';
import '../../platform/sync/queue.dart';
import '../../platform/sync/safe_write.dart';
import '../scaffold/app_shell.dart';
import '../modal/service.dart';
import '../toast/service.dart';
import 'crud_scaffold.dart';
import 'field_config.dart';

class CollectionCrudScreen extends ConsumerStatefulWidget {
  const CollectionCrudScreen({super.key, required this.config});
  final CollectionConfig config;

  @override
  ConsumerState<CollectionCrudScreen> createState() => _CollectionCrudScreenState();
}

class _CollectionCrudScreenState extends ConsumerState<CollectionCrudScreen> {
  static const _perPage = 50;
  static const _debounce = Duration(milliseconds: 300);

  String _search = '';
  late final TextEditingController _searchCtrl;
  Timer? _debounceTimer;
  bool _showDeleted = false;

  final List<RecordModel> _items = [];
  int _page = 1;
  int _totalPages = 1;
  bool _loading = false;
  bool _loadingMore = false;
  Object? _error;

  Future<void> Function()? _unsubscribe;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _refresh();
    _subscribeRealtime();
  }

  Future<void> _subscribeRealtime() async {
    try {
      final pb = RealCmPocketBase.instance();
      _unsubscribe = await pb.collection(widget.config.collection).subscribe('*', (e) {
        if (!mounted) return;
        _refresh();
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchCtrl.dispose();
    _unsubscribe?.call();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _search = value;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () {
      if (mounted) _refresh();
    });
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() {
      _items.clear();
      _page = 1;
      _loading = true;
      _error = null;
    });
    await _loadPage(reset: true);
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _loading || _page >= _totalPages) return;
    setState(() => _loadingMore = true);
    _page++;
    await _loadPage(reset: false);
  }

  Future<void> _loadPage({required bool reset}) async {
    try {
      final pb = RealCmPocketBase.instance();
      final filters = <String>[];
      if (widget.config.softDelete) {
        filters.add(_showDeleted ? 'deleted_at != null' : 'deleted_at = null');
      }
      if (widget.config.extraFilter != null) {
        filters.add('(${widget.config.extraFilter})');
      }
      if (_search.trim().isNotEmpty) {
        final q = _search.replaceAll('"', '');
        final fieldFilters = widget.config.searchFields.map((f) => '$f ~ "$q"').join(' || ');
        if (fieldFilters.isNotEmpty) filters.add('($fieldFilters)');
      }
      final res = await pb.collection(widget.config.collection).getList(
        page: _page,
        perPage: _perPage,
        filter: filters.isEmpty ? null : filters.join(' && '),
        sort: widget.config.sort,
        expand: widget.config.expand,
      );
      if (!mounted) return;
      setState(() {
        if (reset) _items.clear();
        _items.addAll(res.items);
        _totalPages = res.totalPages;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _showForm({RecordModel? existing}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CrudFormDialogPublic(config: widget.config, existing: existing),
    );
    if (result == true) {
      if (mounted) realCmToast(context, existing == null ? 'Đã thêm ${widget.config.itemSingular}' : 'Đã cập nhật', type: RealCmToastType.success);
      _refresh();
    }
  }

  Future<void> _restore(RecordModel rec) async {
    try {
      final pb = RealCmPocketBase.instance();
      await safePbUpdate(pb, widget.config.collection, rec.id, {'deleted_at': null});
      if (mounted) {
        realCmToast(context, 'Đã khôi phục', type: RealCmToastType.success);
        _refresh();
      }
    } on OfflineQueuedException catch (e) {
      ref.read(pendingSyncCountProvider.notifier).state = RealCmSyncQueue.instance.pendingCount();
      if (mounted) {
        realCmToast(context, e.message, type: RealCmToastType.warning);
        _refresh();
      }
    } catch (e) {
      if (mounted) realCmToast(context, 'Lỗi khôi phục: $e', type: RealCmToastType.error);
    }
  }

  Future<void> _delete(RecordModel rec) async {
    final ok = await realCmConfirm(
      context,
      title: 'Xoá ${widget.config.itemSingular}',
      body: 'Bạn có chắc muốn xoá "${widget.config.primaryDisplay(rec.data)}"?',
      confirmLabel: 'Xoá',
      danger: true,
    );
    if (!ok) return;
    try {
      final pb = RealCmPocketBase.instance();
      if (widget.config.softDelete) {
        await safePbUpdate(pb, widget.config.collection, rec.id, {
          'deleted_at': DateTime.now().toIso8601String(),
        });
      } else {
        await safePbDelete(pb, widget.config.collection, rec.id);
      }
      if (mounted) {
        realCmToast(context, 'Đã xoá', type: RealCmToastType.success);
        _refresh();
      }
    } on OfflineQueuedException catch (e) {
      ref.read(pendingSyncCountProvider.notifier).state = RealCmSyncQueue.instance.pendingCount();
      if (mounted) {
        realCmToast(context, e.message, type: RealCmToastType.warning);
        _refresh();
      }
    } catch (e) {
      if (mounted) realCmToast(context, 'Xoá thất bại: $e', type: RealCmToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(realCmAuthProvider);
    final canEdit = auth.canEditMembers;
    final cfg = widget.config;
    final color = cfg.color ?? RealCmColors.primary;
    final iconColor = cfg.iconColor ?? color;

    return RealCmAppShell(
      title: cfg.title,
      actions: [
        if (cfg.softDelete)
          IconButton(
            icon: Icon(_showDeleted ? Icons.restore_from_trash : Icons.delete_outline),
            tooltip: _showDeleted ? 'Đang xem mục đã xoá — chuyển về danh sách chính' : 'Xem mục đã xoá',
            color: _showDeleted ? RealCmColors.warning : null,
            onPressed: () {
              setState(() => _showDeleted = !_showDeleted);
              _refresh();
            },
          ),
        IconButton(icon: const Icon(RealCmIcons.refresh), tooltip: 'Làm mới', onPressed: _refresh),
      ],
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () => _showForm(),
              icon: const Icon(RealCmIcons.add),
              label: Text('Thêm ${cfg.itemSingular}'),
              backgroundColor: color,
              foregroundColor: Colors.white,
            )
          : null,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(RealCmSpacing.s4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
            ),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(RealCmIcons.search),
                hintText: cfg.searchHint,
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(RealCmIcons.close),
                        onPressed: () {
                          _searchCtrl.clear();
                          _search = '';
                          _refresh();
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: Builder(builder: (ctx) {
              if (_loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_error != null) {
                return CrudErrorState(error: _error!, onRetry: _refresh);
              }
              if (_items.isEmpty) {
                return CrudEmptyState(
                  icon: cfg.icon,
                  title: 'Chưa có ${cfg.itemSingular} nào',
                  hint: 'Thêm mới để bắt đầu.',
                  canAdd: canEdit && _search.isEmpty,
                  addLabel: 'Thêm ${cfg.itemSingular}',
                  onAdd: () => _showForm(),
                  isSearching: _search.isNotEmpty,
                );
              }
              final hasMore = _page < _totalPages;
              return NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n is ScrollEndNotification && n.metrics.extentAfter < 200 && hasMore) {
                    _loadMore();
                  }
                  return false;
                },
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: RealCmSpacing.s2),
                  itemCount: _items.length + (hasMore ? 1 : 0),
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                  itemBuilder: (_, i) {
                    if (i >= _items.length) {
                      return Padding(
                        padding: const EdgeInsets.all(RealCmSpacing.s4),
                        child: Center(
                          child: _loadingMore
                              ? const CircularProgressIndicator()
                              : TextButton.icon(
                                  icon: const Icon(Icons.expand_more),
                                  label: Text('Tải thêm (${_items.length}/${_totalPages * _perPage})'),
                                  onPressed: _loadMore,
                                ),
                        ),
                      );
                    }
                    final r = _items[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: RealCmSpacing.s4, vertical: RealCmSpacing.s2),
                      leading: CircleAvatar(
                        backgroundColor: iconColor.withValues(alpha: 0.15),
                        child: Icon(cfg.icon, color: iconColor, size: 20),
                      ),
                      title: Text(cfg.primaryDisplay(r.data), style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(cfg.secondaryDisplay(r.data),
                          style: const TextStyle(color: RealCmColors.textMuted, fontSize: 13)),
                      trailing: (canEdit || cfg.onPrintCertificate != null)
                          ? PopupMenuButton<String>(
                              icon: const Icon(RealCmIcons.more),
                              onSelected: (v) async {
                                if (v == 'edit') _showForm(existing: r);
                                if (v == 'delete') _delete(r);
                                if (v == 'restore') _restore(r);
                                if (v == 'print') {
                                  try {
                                    await cfg.onPrintCertificate!(context, r);
                                  } catch (e) {
                                    if (mounted) realCmToast(context, 'Lỗi in chứng chỉ: $e', type: RealCmToastType.error);
                                  }
                                }
                              },
                              itemBuilder: (_) => [
                                if (cfg.onPrintCertificate != null && !_showDeleted)
                                  const PopupMenuItem(value: 'print', child: Row(children: [Icon(Icons.print, size: 18), SizedBox(width: 8), Text('In chứng chỉ')])),
                                if (canEdit && !_showDeleted) const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                                if (canEdit && _showDeleted)
                                  const PopupMenuItem(value: 'restore', child: Row(children: [Icon(Icons.restore, size: 18, color: RealCmColors.success), SizedBox(width: 8), Text('Khôi phục', style: TextStyle(color: RealCmColors.success))])),
                                if (canEdit) const PopupMenuItem(value: 'delete', child: Text('Xoá', style: TextStyle(color: RealCmColors.danger))),
                              ],
                            )
                          : null,
                      onTap: cfg.detailRoutePrefix != null
                          ? () => context.push('${cfg.detailRoutePrefix}/${r.id}')
                          : (canEdit ? () => _showForm(existing: r) : null),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class CrudFormDialogPublic extends ConsumerStatefulWidget {
  const CrudFormDialogPublic({super.key, required this.config, this.existing, this.defaults});
  final Map<String, dynamic>? defaults;
  final CollectionConfig config;
  final RecordModel? existing;

  @override
  ConsumerState<CrudFormDialogPublic> createState() => _CrudFormDialogState();
}

class _CrudFormDialogState extends ConsumerState<CrudFormDialogPublic> {
  final _formKey = GlobalKey<FormState>();
  final _values = <String, dynamic>{};
  final _ctrls = <String, TextEditingController>{};
  final _fieldErrors = <String, String>{};
  String? _formError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = Map<String, dynamic>.from(widget.existing?.data ?? widget.defaults ?? {});
    for (final f in widget.config.fields) {
      final v = initial[f.name];
      _values[f.name] = v;
      if ([CrudFieldType.text, CrudFieldType.textarea, CrudFieldType.number].contains(f.type)) {
        _ctrls[f.name] = TextEditingController(text: v?.toString() ?? '');
      }
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _formError = null;
      _fieldErrors.clear();
    });
    try {
      final body = <String, dynamic>{};
      for (final f in widget.config.fields) {
        if (_ctrls.containsKey(f.name)) {
          final s = _ctrls[f.name]!.text.trim();
          if (s.isNotEmpty) {
            if (f.type == CrudFieldType.number) {
              body[f.name] = num.tryParse(s) ?? 0;
            } else {
              body[f.name] = s;
            }
          }
        } else {
          final v = _values[f.name];
          if (v != null) {
            if (v is DateTime) {
              body[f.name] = v.toIso8601String();
            } else {
              body[f.name] = v;
            }
          }
        }
      }
      final pb = RealCmPocketBase.instance();
      if (widget.existing == null) {
        await safePbCreate(pb, widget.config.collection, body);
      } else {
        await safePbUpdate(pb, widget.config.collection, widget.existing!.id, body);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on OfflineQueuedException catch (e) {
      ref.read(pendingSyncCountProvider.notifier).state = RealCmSyncQueue.instance.pendingCount();
      if (mounted) {
        realCmToast(context, e.message, type: RealCmToastType.warning);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // Parse PB validation error → friendly message
      _formError = _parsePbError(e);
      if (mounted) {
        realCmToast(context, _formError ?? 'Lỗi: $e', type: RealCmToastType.error);
        setState(() => _saving = false);
      }
    }
  }

  String? _parsePbError(Object e) {
    if (e is ClientException) {
      final data = e.response['data'];
      if (data is Map && data.isNotEmpty) {
        final entries = <String>[];
        data.forEach((field, info) {
          final cfgField = widget.config.fields.where((f) => f.name == field).firstOrNull;
          final label = cfgField?.label ?? field;
          final msg = (info is Map ? info['message'] : info)?.toString() ?? 'không hợp lệ';
          entries.add('$label: $msg');
          _fieldErrors[field.toString()] = msg;
        });
        return entries.join(' · ');
      }
      final msg = e.response['message']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cfg = widget.config;
    final df = DateFormat('dd/MM/yyyy', 'vi');
    String? lastSection;
    final children = <Widget>[];

    for (var i = 0; i < cfg.fields.length; i++) {
      final f = cfg.fields[i];
      if (f.section != lastSection && f.section != null) {
        children.add(CrudFormSection(label: f.section!));
        lastSection = f.section;
      }
      // Group fields cùng section + có flex thành Row.
      Widget fieldWidget = _buildField(f, df);
      // Look-ahead: nếu field tiếp theo cùng section + flex>0 → Row
      if (f.flex > 0 && i + 1 < cfg.fields.length) {
        final next = cfg.fields[i + 1];
        if (next.section == f.section && next.flex > 0) {
          children.add(Row(children: [
            Expanded(flex: f.flex, child: fieldWidget),
            const SizedBox(width: RealCmSpacing.s3),
            Expanded(flex: next.flex, child: _buildField(next, df)),
          ]));
          children.add(const SizedBox(height: RealCmSpacing.s3));
          i++; // skip next
          continue;
        }
      }
      children.add(fieldWidget);
      children.add(const SizedBox(height: RealCmSpacing.s3));
    }

    return CrudFormScaffold(
      title: widget.existing == null ? 'Thêm ${cfg.itemSingular}' : 'Sửa ${cfg.itemSingular}',
      icon: cfg.icon,
      isEdit: widget.existing != null,
      saving: _saving,
      onCancel: () => Navigator.of(context).pop(false),
      onSave: _save,
      body: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      ),
    );
  }

  InputDecoration _decoration(CrudFieldConfig f, {Widget? suffixIcon, bool alignLabelWithHint = false}) {
    return InputDecoration(
      labelText: f.required ? '${f.label} *' : f.label,
      hintText: f.hint,
      helperText: f.helper,
      errorText: _fieldErrors[f.name],
      suffixIcon: suffixIcon,
      alignLabelWithHint: alignLabelWithHint,
    );
  }

  Widget _buildField(CrudFieldConfig f, DateFormat df) {
    switch (f.type) {
      case CrudFieldType.textarea:
        return TextFormField(
          controller: _ctrls[f.name],
          decoration: _decoration(f, alignLabelWithHint: true),
          maxLines: f.maxLines ?? 3,
          validator: f.required ? (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null : null,
          onChanged: (_) {
            if (_fieldErrors.remove(f.name) != null) setState(() {});
          },
        );
      case CrudFieldType.number:
        return TextFormField(
          controller: _ctrls[f.name],
          decoration: _decoration(f),
          keyboardType: TextInputType.number,
          validator: f.required ? (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null : null,
          onChanged: (_) {
            if (_fieldErrors.remove(f.name) != null) setState(() {});
          },
        );
      case CrudFieldType.date:
      case CrudFieldType.datetime:
        return InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _values[f.name] is DateTime ? _values[f.name] as DateTime : DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
              locale: const Locale('vi'),
            );
            if (picked != null) setState(() => _values[f.name] = picked);
          },
          child: InputDecorator(
            decoration: _decoration(f, suffixIcon: const Icon(RealCmIcons.calendar)),
            child: Text(
              _values[f.name] is DateTime ? df.format(_values[f.name] as DateTime) : 'Chọn...',
              style: TextStyle(color: _values[f.name] == null ? RealCmColors.textMuted : null),
            ),
          ),
        );
      case CrudFieldType.select:
        return DropdownButtonFormField<String>(
          value: _values[f.name] as String?,
          decoration: _decoration(f),
          items: f.options.map((o) => DropdownMenuItem(value: o.value, child: Text(o.label))).toList(),
          onChanged: (v) {
            setState(() {
              _values[f.name] = v;
              _fieldErrors.remove(f.name);
            });
          },
          validator: f.required ? (v) => (v == null || v.isEmpty) ? 'Bắt buộc' : null : null,
        );
      case CrudFieldType.bool:
        return CheckboxListTile(
          value: (_values[f.name] as bool?) ?? false,
          onChanged: (v) => setState(() => _values[f.name] = v ?? false),
          title: Text(f.label),
          subtitle: f.helper != null ? Text(f.helper!) : null,
          contentPadding: EdgeInsets.zero,
        );
      case CrudFieldType.relation:
        return _RelationField(
          field: f,
          value: _values[f.name] as String?,
          onChanged: (v) => setState(() => _values[f.name] = v),
        );
      case CrudFieldType.text:
        return TextFormField(
          controller: _ctrls[f.name],
          decoration: _decoration(f),
          validator: f.required ? (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null : null,
          onChanged: (_) {
            if (_fieldErrors.remove(f.name) != null) setState(() {});
          },
        );
    }
  }
}

class _RelationField extends ConsumerStatefulWidget {
  const _RelationField({required this.field, required this.value, required this.onChanged});
  final CrudFieldConfig field;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  ConsumerState<_RelationField> createState() => _RelationFieldState();
}

class _RelationFieldState extends ConsumerState<_RelationField> {
  String? _displayLabel;

  @override
  void initState() {
    super.initState();
    if (widget.value != null) _loadLabel();
  }

  Future<void> _loadLabel() async {
    try {
      final pb = RealCmPocketBase.instance();
      final r = await pb.collection(widget.field.relationCollection!).getOne(widget.value!);
      final df = widget.field.relationDisplayField ?? 'name';
      setState(() => _displayLabel = r.data[df]?.toString() ?? r.id);
    } catch (_) {
      setState(() => _displayLabel = widget.value);
    }
  }

  Future<void> _pick() async {
    final pb = RealCmPocketBase.instance();
    final res = await pb.collection(widget.field.relationCollection!).getList(page: 1, perPage: 100, sort: widget.field.relationDisplayField ?? 'created');
    if (!mounted) return;
    final picked = await showDialog<RecordModel>(
      context: context,
      builder: (ctx) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 540),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(RealCmSpacing.s3),
                child: Text('Chọn ${widget.field.label.toLowerCase()}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: res.items.length,
                  itemBuilder: (_, i) {
                    final r = res.items[i];
                    final df = widget.field.relationDisplayField ?? 'name';
                    final label = r.data[df]?.toString() ?? r.id;
                    return ListTile(
                      leading: const Icon(RealCmIcons.member),
                      title: Text(label),
                      onTap: () => Navigator.of(ctx).pop(r),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) {
      widget.onChanged(picked.id);
      final df = widget.field.relationDisplayField ?? 'name';
      setState(() => _displayLabel = picked.data[df]?.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _pick,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.field.required ? '${widget.field.label} *' : widget.field.label,
          suffixIcon: widget.value != null
              ? IconButton(
                  icon: const Icon(RealCmIcons.close, size: 18),
                  onPressed: () {
                    widget.onChanged(null);
                    setState(() => _displayLabel = null);
                  },
                )
              : const Icon(RealCmIcons.search),
        ),
        child: Text(
          _displayLabel ?? (widget.value ?? 'Chọn...'),
          style: TextStyle(color: widget.value == null ? RealCmColors.textMuted : null),
        ),
      ),
    );
  }
}

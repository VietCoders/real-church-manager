// Domain types cho dashboard layout — widget spec, size, layout.

enum DashboardWidgetSize {
  sm,
  md,
  lg,
  xl;

  int get cols {
    switch (this) {
      case DashboardWidgetSize.sm: return 3;
      case DashboardWidgetSize.md: return 6;
      case DashboardWidgetSize.lg: return 8;
      case DashboardWidgetSize.xl: return 12;
    }
  }

  String get label {
    switch (this) {
      case DashboardWidgetSize.sm: return 'Nhỏ';
      case DashboardWidgetSize.md: return 'Vừa';
      case DashboardWidgetSize.lg: return 'Lớn';
      case DashboardWidgetSize.xl: return 'Toàn rộng';
    }
  }

  static DashboardWidgetSize fromName(String? name) {
    return DashboardWidgetSize.values.firstWhere(
      (s) => s.name == name,
      orElse: () => DashboardWidgetSize.sm,
    );
  }
}

class DashboardWidgetSpec {
  const DashboardWidgetSpec({
    required this.type,
    required this.order,
    this.enabled = true,
    this.size = DashboardWidgetSize.sm,
  });

  final String type;
  final int order;
  final bool enabled;
  final DashboardWidgetSize size;

  DashboardWidgetSpec copyWith({
    String? type,
    int? order,
    bool? enabled,
    DashboardWidgetSize? size,
  }) {
    return DashboardWidgetSpec(
      type: type ?? this.type,
      order: order ?? this.order,
      enabled: enabled ?? this.enabled,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'order': order,
        'enabled': enabled,
        'size': size.name,
      };

  factory DashboardWidgetSpec.fromJson(Map<String, dynamic> json) {
    return DashboardWidgetSpec(
      type: (json['type'] ?? '') as String,
      order: (json['order'] ?? 0) as int,
      enabled: (json['enabled'] ?? true) as bool,
      size: DashboardWidgetSize.fromName(json['size'] as String?),
    );
  }
}

class DashboardLayout {
  const DashboardLayout({required this.widgets});

  final List<DashboardWidgetSpec> widgets;

  factory DashboardLayout.empty() => const DashboardLayout(widgets: []);

  List<DashboardWidgetSpec> get visible {
    final list = widgets.where((w) => w.enabled).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  DashboardLayout copyWith({List<DashboardWidgetSpec>? widgets}) {
    return DashboardLayout(widgets: widgets ?? this.widgets);
  }

  List<dynamic> toJson() => widgets.map((w) => w.toJson()).toList();

  factory DashboardLayout.fromJson(dynamic raw) {
    if (raw is! List) return DashboardLayout.empty();
    final items = raw
        .whereType<Map>()
        .map((m) => DashboardWidgetSpec.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    return DashboardLayout(widgets: items);
  }
}

// Dashboard widget spec — cấu hình per-user (id, type, kích thước, vị trí, on/off).
// Lưu vào users.dashboard_layout JSON. Mặc định nếu chưa có = layout default từ Registry.
import 'package:equatable/equatable.dart';

class DashboardWidgetSpec extends Equatable {
  const DashboardWidgetSpec({
    required this.type,
    required this.order,
    this.enabled = true,
    this.size = DashboardWidgetSize.md,
  });

  /// Type id — match với key trong DashboardWidgetRegistry.
  final String type;

  /// Vị trí hiển thị (0 = đầu).
  final int order;

  /// Bật/tắt hiển thị. False = không render trên grid.
  final bool enabled;

  /// Kích thước. sm = 1 col, md = 2 col, lg = 3 col, xl = 4 col (12-col grid).
  final DashboardWidgetSize size;

  factory DashboardWidgetSpec.fromJson(Map<String, dynamic> j) => DashboardWidgetSpec(
        type: j['type'] as String,
        order: (j['order'] as num?)?.toInt() ?? 0,
        enabled: (j['enabled'] as bool?) ?? true,
        size: DashboardWidgetSize.values.firstWhere(
          (e) => e.name == j['size'],
          orElse: () => DashboardWidgetSize.md,
        ),
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'order': order,
        'enabled': enabled,
        'size': size.name,
      };

  DashboardWidgetSpec copyWith({
    String? type,
    int? order,
    bool? enabled,
    DashboardWidgetSize? size,
  }) =>
      DashboardWidgetSpec(
        type: type ?? this.type,
        order: order ?? this.order,
        enabled: enabled ?? this.enabled,
        size: size ?? this.size,
      );

  @override
  List<Object?> get props => [type, order, enabled, size];
}

enum DashboardWidgetSize {
  sm, // 3 cols (1/4 màn hình)
  md, // 4 cols (1/3)
  lg, // 6 cols (1/2)
  xl, // 12 cols (full width)
}

extension DashboardWidgetSizeX on DashboardWidgetSize {
  /// Số cột chiếm trên 12-col grid.
  int get cols {
    switch (this) {
      case DashboardWidgetSize.sm:
        return 3;
      case DashboardWidgetSize.md:
        return 4;
      case DashboardWidgetSize.lg:
        return 6;
      case DashboardWidgetSize.xl:
        return 12;
    }
  }

  String get label {
    switch (this) {
      case DashboardWidgetSize.sm:
        return 'Nhỏ';
      case DashboardWidgetSize.md:
        return 'Vừa';
      case DashboardWidgetSize.lg:
        return 'Lớn';
      case DashboardWidgetSize.xl:
        return 'Toàn ngang';
    }
  }
}

/// Layout = list các spec, theo thứ tự `order`.
class DashboardLayout {
  DashboardLayout({required this.widgets});

  final List<DashboardWidgetSpec> widgets;

  factory DashboardLayout.empty() => DashboardLayout(widgets: const []);

  factory DashboardLayout.fromJson(dynamic j) {
    if (j is List) {
      return DashboardLayout(
        widgets: j.map((e) => DashboardWidgetSpec.fromJson(Map<String, dynamic>.from(e as Map))).toList()
          ..sort((a, b) => a.order.compareTo(b.order)),
      );
    }
    return DashboardLayout.empty();
  }

  List<Map<String, dynamic>> toJson() => widgets.map((w) => w.toJson()).toList();

  DashboardLayout copyWith({List<DashboardWidgetSpec>? widgets}) =>
      DashboardLayout(widgets: widgets ?? this.widgets);

  /// Chỉ widget đang enabled, sorted theo order.
  List<DashboardWidgetSpec> get visible {
    final list = widgets.where((w) => w.enabled).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return list;
  }
}

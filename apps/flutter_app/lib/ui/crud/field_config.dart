// Field config — define schema cho generic CRUD form.
import 'package:flutter/material.dart';

enum CrudFieldType { text, textarea, number, date, datetime, select, relation, bool }

class CrudFieldConfig {
  const CrudFieldConfig({
    required this.name,
    required this.label,
    this.type = CrudFieldType.text,
    this.required = false,
    this.hint,
    this.helper,
    this.options = const [],
    this.relationCollection,
    this.relationDisplayField,
    this.section,
    this.flex = 1,
    this.maxLines,
    this.icon,
  });

  final String name;
  final String label;
  final CrudFieldType type;
  final bool required;
  final String? hint;
  final String? helper;
  /// Cho select: list <{value, label}>
  final List<({String value, String label})> options;
  final String? relationCollection;
  final String? relationDisplayField;
  /// Group fields theo section header trong form.
  final String? section;
  /// flex trong row khi 2 field cùng section đứng cạnh nhau.
  final int flex;
  final int? maxLines;
  final IconData? icon;
}

class CollectionConfig {
  const CollectionConfig({
    required this.collection,
    required this.title,
    required this.icon,
    required this.itemSingular,
    required this.searchHint,
    required this.searchFields,
    required this.primaryDisplay,
    required this.secondaryDisplay,
    required this.fields,
    this.color,
    this.sort = '-created',
    this.expand,
    this.softDelete = false,
    this.iconColor,
  });

  /// Tên collection PocketBase.
  final String collection;
  /// Tiêu đề trang.
  final String title;
  /// Icon hiển thị (drawer + form header).
  final IconData icon;
  final Color? iconColor;
  /// "giáo dân" / "rửa tội" — singular noun cho count + add button.
  final String itemSingular;
  final String searchHint;
  /// Fields để filter "ANY ~ search".
  final List<String> searchFields;
  /// Function lấy primary text từ record data.
  final String Function(Map<String, dynamic> data) primaryDisplay;
  /// Function lấy secondary text (subtitle) từ record data.
  final String Function(Map<String, dynamic> data) secondaryDisplay;
  /// Fields khi render form.
  final List<CrudFieldConfig> fields;
  /// Color theme cho list (avatar background, FAB).
  final Color? color;
  final String sort;
  final String? expand;
  /// True = update deleted_at instead of DELETE physical.
  final bool softDelete;
}

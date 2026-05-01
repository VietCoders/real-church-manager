// Module configs — 8 collection CRUD configs.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../ui/crud/field_config.dart';
import 'certificates.dart';

String _date(dynamic v) {
  if (v == null || v.toString().isEmpty) return '';
  final d = DateTime.tryParse(v.toString());
  if (d == null) return v.toString();
  return DateFormat('dd/MM/yyyy', 'vi').format(d);
}

String _money(dynamic v) {
  if (v == null) return '';
  final n = num.tryParse(v.toString()) ?? 0;
  return NumberFormat.decimalPattern('vi').format(n) + ' đ';
}

// ─── Sổ Rửa Tội ───────────────────────────────────────────
final baptismConfig = CollectionConfig(
  collection: 'sacrament_baptism',
  title: 'Sổ Rửa Tội',
  icon: RealCmIcons.baptism,
  iconColor: RealCmColors.info,
  itemSingular: 'Rửa Tội',
  searchHint: 'Tìm theo số sổ, cha cử hành...',
  searchFields: ['book_number', 'priest_name'],
  primaryDisplay: (d) => d['book_number']?.toString().isNotEmpty == true ? 'Số sổ ${d['book_number']}' : 'Rửa Tội (chưa có số sổ)',
  secondaryDisplay: (d) => '${_date(d['baptism_date'])} · Cha: ${d['priest_name'] ?? ''}',
  sort: '-baptism_date',
  onPrintCertificate: printBaptismCertificate,
  fields: const [
    CrudFieldConfig(name: 'book_number', label: 'Số sổ', section: 'Thông tin chung', helper: 'Để trống = tự sinh RT-YYYY-NNNN', flex: 1),
    CrudFieldConfig(name: 'baptism_date', label: 'Ngày rửa tội', type: CrudFieldType.date, required: true, section: 'Thông tin chung', flex: 1),
    CrudFieldConfig(name: 'baptism_place', label: 'Nơi cử hành', section: 'Thông tin chung'),
    CrudFieldConfig(name: 'priest_name', label: 'Cha cử hành', required: true, section: 'Thông tin chung'),

    CrudFieldConfig(name: 'member_id', label: 'Người được rửa tội', type: CrudFieldType.relation, required: true, relationCollection: 'members', relationDisplayField: 'full_name', section: 'Người được rửa'),

    CrudFieldConfig(name: 'father_name', label: 'Tên cha', section: 'Cha mẹ', flex: 1),
    CrudFieldConfig(name: 'mother_name', label: 'Tên mẹ', section: 'Cha mẹ', flex: 1),

    CrudFieldConfig(name: 'godfather_name', label: 'Tên cha đỡ đầu', section: 'Cha mẹ đỡ đầu', flex: 1),
    CrudFieldConfig(name: 'godmother_name', label: 'Tên mẹ đỡ đầu', section: 'Cha mẹ đỡ đầu', flex: 1),

    CrudFieldConfig(name: 'notes', label: 'Ghi chú', type: CrudFieldType.textarea, section: 'Ghi chú'),
  ],
);

// ─── Sổ Thêm Sức ──────────────────────────────────────────
final confirmationConfig = CollectionConfig(
  collection: 'sacrament_confirmation',
  title: 'Sổ Thêm Sức',
  icon: RealCmIcons.confirmation,
  iconColor: RealCmColors.danger,
  itemSingular: 'Thêm Sức',
  searchHint: 'Tìm theo số sổ, đức Giám mục...',
  searchFields: ['book_number', 'bishop_name'],
  primaryDisplay: (d) => d['book_number']?.toString().isNotEmpty == true ? 'Số sổ ${d['book_number']}' : 'Thêm Sức (chưa có số sổ)',
  secondaryDisplay: (d) => '${_date(d['confirmation_date'])} · ĐGM: ${d['bishop_name'] ?? ''}',
  sort: '-confirmation_date',
  onPrintCertificate: printConfirmationCertificate,
  fields: const [
    CrudFieldConfig(name: 'book_number', label: 'Số sổ', section: 'Thông tin chung', helper: 'TS-YYYY-NNNN', flex: 1),
    CrudFieldConfig(name: 'confirmation_date', label: 'Ngày Thêm Sức', type: CrudFieldType.date, required: true, section: 'Thông tin chung', flex: 1),
    CrudFieldConfig(name: 'confirmation_place', label: 'Nơi cử hành', section: 'Thông tin chung'),
    CrudFieldConfig(name: 'bishop_name', label: 'Đức Giám mục', required: true, section: 'Thông tin chung'),

    CrudFieldConfig(name: 'member_id', label: 'Người được Thêm Sức', type: CrudFieldType.relation, required: true, relationCollection: 'members', relationDisplayField: 'full_name', section: 'Người nhận'),
    CrudFieldConfig(name: 'confirmation_saint_name', label: 'Tên Thánh Thêm Sức', helper: 'Có thể khác Tên Thánh Rửa Tội', section: 'Người nhận'),

    CrudFieldConfig(name: 'sponsor_name', label: 'Tên người đỡ đầu', section: 'Người đỡ đầu'),

    CrudFieldConfig(name: 'notes', label: 'Ghi chú', type: CrudFieldType.textarea, section: 'Ghi chú'),
  ],
);

// ─── Sổ Hôn Phối ──────────────────────────────────────────
final marriageConfig = CollectionConfig(
  collection: 'sacrament_marriage',
  title: 'Sổ Hôn Phối',
  icon: RealCmIcons.marriage,
  iconColor: RealCmColors.accent,
  itemSingular: 'Hôn Phối',
  searchHint: 'Tìm theo số sổ, cha chủ sự...',
  searchFields: ['book_number', 'priest_name'],
  primaryDisplay: (d) => d['book_number']?.toString().isNotEmpty == true ? 'Số sổ ${d['book_number']}' : 'Hôn Phối (chưa có số sổ)',
  secondaryDisplay: (d) => '${_date(d['marriage_date'])} · Cha: ${d['priest_name'] ?? ''}',
  sort: '-marriage_date',
  onPrintCertificate: printMarriageCertificate,
  fields: const [
    CrudFieldConfig(name: 'book_number', label: 'Số sổ', section: 'Thông tin chung', helper: 'HP-YYYY-NNNN', flex: 1),
    CrudFieldConfig(name: 'marriage_date', label: 'Ngày Hôn Phối', type: CrudFieldType.date, required: true, section: 'Thông tin chung', flex: 1),
    CrudFieldConfig(name: 'marriage_place', label: 'Nơi cử hành', section: 'Thông tin chung'),
    CrudFieldConfig(name: 'priest_name', label: 'Cha chủ sự', required: true, section: 'Thông tin chung'),

    CrudFieldConfig(name: 'groom_id', label: 'Chú rể', type: CrudFieldType.relation, required: true, relationCollection: 'members', relationDisplayField: 'full_name', section: 'Cô dâu / chú rể'),
    CrudFieldConfig(name: 'bride_id', label: 'Cô dâu', type: CrudFieldType.relation, required: true, relationCollection: 'members', relationDisplayField: 'full_name', section: 'Cô dâu / chú rể'),

    CrudFieldConfig(name: 'groom_father_name', label: 'Cha chú rể', section: 'Cha mẹ 2 bên', flex: 1),
    CrudFieldConfig(name: 'groom_mother_name', label: 'Mẹ chú rể', section: 'Cha mẹ 2 bên', flex: 1),
    CrudFieldConfig(name: 'bride_father_name', label: 'Cha cô dâu', section: 'Cha mẹ 2 bên', flex: 1),
    CrudFieldConfig(name: 'bride_mother_name', label: 'Mẹ cô dâu', section: 'Cha mẹ 2 bên', flex: 1),

    CrudFieldConfig(name: 'witness_1_name', label: 'Người chứng 1', required: true, section: 'Người chứng', flex: 1),
    CrudFieldConfig(name: 'witness_2_name', label: 'Người chứng 2', required: true, section: 'Người chứng', flex: 1),

    CrudFieldConfig(name: 'dispensation', label: 'Miễn chuẩn', helper: 'Vd: khác đạo, miễn chuẩn cản trở...', section: 'Miễn chuẩn'),

    CrudFieldConfig(name: 'notes', label: 'Ghi chú', type: CrudFieldType.textarea, section: 'Ghi chú'),
  ],
);

// ─── Sổ Xức Dầu ───────────────────────────────────────────
final anointingConfig = CollectionConfig(
  collection: 'sacrament_anointing',
  title: 'Sổ Xức Dầu',
  icon: RealCmIcons.anointing,
  iconColor: RealCmColors.warning,
  itemSingular: 'Xức Dầu',
  searchHint: 'Tìm theo cha cử hành, nơi...',
  searchFields: ['priest_name', 'anointing_place'],
  primaryDisplay: (d) => 'Xức Dầu ${_date(d['anointing_date'])}',
  secondaryDisplay: (d) => 'Cha: ${d['priest_name'] ?? ''} · ${d['anointing_place'] ?? ''}',
  sort: '-anointing_date',
  onPrintCertificate: printAnointingCertificate,
  fields: const [
    CrudFieldConfig(name: 'anointing_date', label: 'Ngày xức dầu', type: CrudFieldType.date, required: true, section: 'Thông tin chung', flex: 1),
    CrudFieldConfig(name: 'priest_name', label: 'Cha cử hành', required: true, section: 'Thông tin chung', flex: 1),
    CrudFieldConfig(name: 'anointing_place', label: 'Nơi cử hành', helper: 'Bệnh viện, nhà, nhà thờ...', section: 'Thông tin chung'),

    CrudFieldConfig(name: 'member_id', label: 'Người được xức dầu', type: CrudFieldType.relation, required: true, relationCollection: 'members', relationDisplayField: 'full_name', section: 'Người nhận'),
    CrudFieldConfig(name: 'condition', label: 'Tình trạng', type: CrudFieldType.textarea, section: 'Người nhận', maxLines: 2),

    CrudFieldConfig(name: 'notes', label: 'Ghi chú', type: CrudFieldType.textarea, section: 'Ghi chú'),
  ],
);

// ─── Sổ An Táng ───────────────────────────────────────────
final funeralConfig = CollectionConfig(
  collection: 'sacrament_funeral',
  title: 'Sổ An Táng',
  icon: RealCmIcons.funeral,
  iconColor: RealCmColors.textMuted,
  itemSingular: 'An Táng',
  searchHint: 'Tìm theo số sổ, cha cử hành...',
  searchFields: ['book_number', 'priest_name'],
  primaryDisplay: (d) => d['book_number']?.toString().isNotEmpty == true ? 'Số sổ ${d['book_number']}' : 'An Táng (chưa có số sổ)',
  secondaryDisplay: (d) => 'Mất: ${_date(d['death_date'])} · An táng: ${_date(d['funeral_date'])}',
  sort: '-funeral_date',
  onPrintCertificate: printFuneralCertificate,
  fields: const [
    CrudFieldConfig(name: 'book_number', label: 'Số sổ', section: 'Thông tin chung', helper: 'AT-YYYY-NNNN', flex: 1),
    CrudFieldConfig(name: 'priest_name', label: 'Cha cử hành', required: true, section: 'Thông tin chung', flex: 1),

    CrudFieldConfig(name: 'member_id', label: 'Người qua đời', type: CrudFieldType.relation, required: true, relationCollection: 'members', relationDisplayField: 'full_name', section: 'Người qua đời'),
    CrudFieldConfig(name: 'death_date', label: 'Ngày qua đời', type: CrudFieldType.date, required: true, section: 'Người qua đời', flex: 1),
    CrudFieldConfig(name: 'funeral_date', label: 'Ngày an táng', type: CrudFieldType.date, required: true, section: 'Người qua đời', flex: 1),
    CrudFieldConfig(name: 'death_cause', label: 'Nguyên nhân qua đời', section: 'Người qua đời'),
    CrudFieldConfig(name: 'burial_place', label: 'Nơi an táng', helper: 'Nghĩa trang giáo xứ...', section: 'Người qua đời'),

    CrudFieldConfig(name: 'notes', label: 'Ghi chú', type: CrudFieldType.textarea, section: 'Ghi chú'),
  ],
);

// ─── Đoàn thể ──────────────────────────────────────────────
final groupConfig = CollectionConfig(
  collection: 'groups',
  title: 'Đoàn thể',
  icon: RealCmIcons.group,
  iconColor: RealCmColors.primary,
  itemSingular: 'đoàn thể',
  searchHint: 'Tìm theo tên hội, mã...',
  searchFields: ['name', 'code'],
  primaryDisplay: (d) => d['name']?.toString() ?? '',
  secondaryDisplay: (d) {
    final type = d['type']?.toString() ?? '';
    final typeLabel = {
      'confraternity': 'Hội đoàn',
      'youth': 'Giới trẻ',
      'choir': 'Ca đoàn',
      'pastoral': 'Mục vụ',
      'other': 'Khác',
    }[type] ?? type;
    return [
      if (d['code']?.toString().isNotEmpty == true) 'Mã: ${d['code']}',
      typeLabel,
      if (d['meeting_schedule']?.toString().isNotEmpty == true) d['meeting_schedule'],
    ].join(' · ');
  },
  softDelete: true,
  sort: 'name',
  fields: const [
    CrudFieldConfig(name: 'name', label: 'Tên hội/đoàn', required: true, section: 'Thông tin chung', flex: 1),
    CrudFieldConfig(name: 'code', label: 'Mã', helper: 'Vd: HMC, LM, TNTT', section: 'Thông tin chung', flex: 1),
    CrudFieldConfig(name: 'type', label: 'Loại', type: CrudFieldType.select, required: true, section: 'Thông tin chung', options: [
      (value: 'confraternity', label: 'Hội đoàn'),
      (value: 'youth', label: 'Giới trẻ'),
      (value: 'choir', label: 'Ca đoàn'),
      (value: 'pastoral', label: 'Mục vụ'),
      (value: 'other', label: 'Khác'),
    ]),
    CrudFieldConfig(name: 'founding_date', label: 'Ngày thành lập', type: CrudFieldType.date, section: 'Thông tin chung'),

    CrudFieldConfig(name: 'head_member_id', label: 'Trưởng hội', type: CrudFieldType.relation, relationCollection: 'members', relationDisplayField: 'full_name', section: 'Ban điều hành', flex: 1),
    CrudFieldConfig(name: 'vice_head_member_id', label: 'Phó hội', type: CrudFieldType.relation, relationCollection: 'members', relationDisplayField: 'full_name', section: 'Ban điều hành', flex: 1),

    CrudFieldConfig(name: 'meeting_schedule', label: 'Lịch sinh hoạt', helper: 'Vd: Mỗi Chúa Nhật sau lễ 7h', type: CrudFieldType.textarea, section: 'Sinh hoạt', maxLines: 2),

    CrudFieldConfig(name: 'notes', label: 'Ghi chú', type: CrudFieldType.textarea, section: 'Ghi chú'),
  ],
);

// ─── Lễ ý cầu nguyện ──────────────────────────────────────
final massIntentionConfig = CollectionConfig(
  collection: 'mass_intentions',
  title: 'Lễ ý cầu nguyện',
  icon: RealCmIcons.mass,
  iconColor: RealCmColors.primary,
  itemSingular: 'lễ ý',
  searchHint: 'Tìm theo người xin, ý chỉ...',
  searchFields: ['requester_name', 'intention_text'],
  primaryDisplay: (d) => d['intention_text']?.toString() ?? '(không có ý chỉ)',
  secondaryDisplay: (d) {
    final status = d['status']?.toString() ?? '';
    final statusLabel = {
      'pending': '⏳ Chờ duyệt',
      'scheduled': '📅 Đã xếp lịch',
      'done': '✅ Đã cử hành',
      'cancelled': '❌ Huỷ',
    }[status] ?? status;
    return 'Người xin: ${d['requester_name'] ?? ''} · ${_date(d['mass_date'])} · $statusLabel';
  },
  sort: '-created',
  fields: const [
    CrudFieldConfig(name: 'requester_name', label: 'Tên người xin', required: true, section: 'Người xin', flex: 1),
    CrudFieldConfig(name: 'mass_date', label: 'Ngày dự kiến', type: CrudFieldType.date, section: 'Người xin', flex: 1),
    CrudFieldConfig(name: 'donation_amount', label: 'Tiền dâng (VND)', type: CrudFieldType.number, section: 'Người xin', flex: 1),

    CrudFieldConfig(name: 'intention_text', label: 'Ý chỉ', type: CrudFieldType.textarea, required: true, section: 'Ý chỉ', maxLines: 3, helper: 'Vd: Cầu cho linh hồn ông Phêrô / Tạ ơn / Xin ơn bình an...'),

    CrudFieldConfig(name: 'status', label: 'Trạng thái', type: CrudFieldType.select, required: true, section: 'Trạng thái', options: [
      (value: 'pending', label: 'Chờ duyệt'),
      (value: 'scheduled', label: 'Đã xếp lịch'),
      (value: 'done', label: 'Đã cử hành'),
      (value: 'cancelled', label: 'Huỷ'),
    ]),

    CrudFieldConfig(name: 'notes', label: 'Ghi chú', type: CrudFieldType.textarea, section: 'Ghi chú'),
  ],
);

// ─── Gia đình ─────────────────────────────────────────────
final familyConfig = CollectionConfig(
  collection: 'families',
  title: 'Gia đình',
  icon: RealCmIcons.family,
  iconColor: RealCmColors.primary,
  itemSingular: 'gia đình',
  searchHint: 'Tìm theo tên gia đình, địa chỉ...',
  searchFields: const ['family_name', 'address', 'phone'],
  primaryDisplay: (d) => d['family_name']?.toString().isNotEmpty == true ? d['family_name']!.toString() : 'Gia đình (chưa đặt tên)',
  secondaryDisplay: (d) => [
    if (d['address']?.toString().isNotEmpty == true) d['address'],
    if (d['phone']?.toString().isNotEmpty == true) d['phone'],
  ].join(' · '),
  softDelete: true,
  sort: 'family_name',
  fields: const [
    CrudFieldConfig(name: 'family_name', label: 'Tên gia đình', helper: 'Vd: Gia đình ông Phêrô Nguyễn Văn A', section: 'Thông tin chung'),
    CrudFieldConfig(name: 'head_id', label: 'Gia trưởng', type: CrudFieldType.relation, required: true, relationCollection: 'members', relationDisplayField: 'full_name', section: 'Thông tin chung'),
    CrudFieldConfig(name: 'district_id', label: 'Giáo họ', type: CrudFieldType.relation, relationCollection: 'districts', relationDisplayField: 'name', section: 'Thông tin chung'),

    CrudFieldConfig(name: 'address', label: 'Địa chỉ', section: 'Liên hệ', flex: 2),
    CrudFieldConfig(name: 'phone', label: 'Điện thoại', section: 'Liên hệ', flex: 1),

    CrudFieldConfig(name: 'notes', label: 'Ghi chú', type: CrudFieldType.textarea, section: 'Ghi chú'),
  ],
);

// ─── Lịch phụng vụ (events list — calendar view riêng) ────
final liturgicalConfig = CollectionConfig(
  collection: 'liturgical_events',
  title: 'Lịch phụng vụ',
  icon: RealCmIcons.calendar,
  iconColor: RealCmColors.primary,
  itemSingular: 'sự kiện',
  searchHint: 'Tìm theo tiêu đề, cha chủ sự...',
  searchFields: const ['title', 'priest_name'],
  primaryDisplay: (d) => d['title']?.toString() ?? '',
  secondaryDisplay: (d) {
    final type = d['event_type']?.toString() ?? '';
    final typeLabel = {
      'mass_regular': 'Lễ thường',
      'mass_solemn': 'Lễ trọng',
      'mass_feast': 'Lễ kính',
      'confession': 'Xưng tội',
      'adoration': 'Chầu Thánh Thể',
      'meeting': 'Họp',
      'other': 'Khác',
    }[type] ?? type;
    return '${_date(d['event_date'])} · $typeLabel${d['priest_name']?.toString().isNotEmpty == true ? ' · ${d['priest_name']}' : ''}';
  },
  sort: '-event_date',
  fields: const [
    CrudFieldConfig(name: 'title', label: 'Tiêu đề', required: true, helper: 'Vd: Lễ Chúa Nhật, Lễ Phục Sinh...', section: 'Thông tin chung'),
    CrudFieldConfig(name: 'event_date', label: 'Ngày bắt đầu', type: CrudFieldType.date, required: true, section: 'Thông tin chung', flex: 1),
    CrudFieldConfig(name: 'end_date', label: 'Ngày kết thúc', type: CrudFieldType.date, helper: 'Bỏ trống nếu chỉ 1 ngày', section: 'Thông tin chung', flex: 1),
    CrudFieldConfig(name: 'event_type', label: 'Loại', type: CrudFieldType.select, required: true, section: 'Thông tin chung', options: [
      (value: 'mass_regular', label: 'Lễ thường'),
      (value: 'mass_solemn', label: 'Lễ trọng'),
      (value: 'mass_feast', label: 'Lễ kính'),
      (value: 'confession', label: 'Xưng tội'),
      (value: 'adoration', label: 'Chầu Thánh Thể'),
      (value: 'meeting', label: 'Họp'),
      (value: 'other', label: 'Khác'),
    ]),

    CrudFieldConfig(name: 'liturgical_color', label: 'Màu phụng vụ', type: CrudFieldType.select, section: 'Phụng vụ', options: [
      (value: 'white', label: 'Trắng (lễ Chúa, Đức Mẹ, các Thánh)'),
      (value: 'red', label: 'Đỏ (Hiện Xuống, tử đạo, Lễ Lá)'),
      (value: 'green', label: 'Xanh (Mùa Thường Niên)'),
      (value: 'purple', label: 'Tím (Mùa Vọng, Mùa Chay)'),
      (value: 'rose', label: 'Hồng (CN Vui mừng)'),
      (value: 'black', label: 'Đen (lễ an táng)'),
    ]),
    CrudFieldConfig(name: 'priest_name', label: 'Cha chủ sự', section: 'Phụng vụ'),

    CrudFieldConfig(name: 'is_recurring', label: 'Lặp lại định kỳ', type: CrudFieldType.bool, helper: 'Vd: lễ Chúa Nhật hàng tuần', section: 'Lặp lại'),
    CrudFieldConfig(name: 'recurrence_rule', label: 'Quy tắc lặp', helper: 'Tuỳ chọn: FREQ=WEEKLY;BYDAY=SU', section: 'Lặp lại'),

    CrudFieldConfig(name: 'notes', label: 'Ghi chú', type: CrudFieldType.textarea, section: 'Ghi chú'),
  ],
);

// ─── Sổ thu chi ───────────────────────────────────────────
final donationConfig = CollectionConfig(
  collection: 'donations',
  title: 'Sổ thu chi',
  icon: RealCmIcons.donation,
  iconColor: RealCmColors.success,
  itemSingular: 'phiếu',
  searchHint: 'Tìm theo người dâng, số phiếu, mô tả...',
  searchFields: ['donor_name', 'receipt_no', 'description'],
  primaryDisplay: (d) {
    final amount = (d['amount'] as num?) ?? 0;
    final type = d['type']?.toString() ?? '';
    final isExpense = type == 'expense';
    return '${isExpense ? '- ' : '+ '}${_money(amount)}';
  },
  secondaryDisplay: (d) {
    final type = d['type']?.toString() ?? '';
    final typeLabel = {
      'sunday_offering': 'Dâng Chúa Nhật',
      'feast_offering': 'Dâng lễ trọng',
      'building_fund': 'Quỹ xây dựng',
      'mass_intention': 'Xin lễ',
      'other_in': 'Thu khác',
      'expense': 'Chi',
    }[type] ?? type;
    return '${_date(d['date'])} · $typeLabel · ${d['donor_name'] ?? 'Khuyết danh'}';
  },
  sort: '-date',
  fields: const [
    CrudFieldConfig(name: 'date', label: 'Ngày', type: CrudFieldType.date, required: true, section: 'Phiếu', flex: 1),
    CrudFieldConfig(name: 'receipt_no', label: 'Số phiếu', section: 'Phiếu', flex: 1),
    CrudFieldConfig(name: 'type', label: 'Loại', type: CrudFieldType.select, required: true, section: 'Phiếu', options: [
      (value: 'sunday_offering', label: 'Dâng Chúa Nhật'),
      (value: 'feast_offering', label: 'Dâng lễ trọng'),
      (value: 'building_fund', label: 'Quỹ xây dựng'),
      (value: 'mass_intention', label: 'Xin lễ'),
      (value: 'other_in', label: 'Thu khác'),
      (value: 'expense', label: 'Chi'),
    ]),
    CrudFieldConfig(name: 'amount', label: 'Số tiền (VND)', type: CrudFieldType.number, required: true, section: 'Phiếu'),

    CrudFieldConfig(name: 'donor_name', label: 'Người dâng / nơi chi', helper: 'Để trống = khuyết danh', section: 'Đối tác'),
    CrudFieldConfig(name: 'description', label: 'Mô tả', section: 'Đối tác'),

    CrudFieldConfig(name: 'notes', label: 'Ghi chú', type: CrudFieldType.textarea, section: 'Ghi chú'),
  ],
);

// Bảng ngày bổn mạng (lễ kính các Thánh) phổ biến nhất ở Việt Nam.
// Dùng cho dashboard widget "Tên Thánh sắp tới" + member detail.
// Format: tên Thánh (lowercase, không dấu) → MM-DD.
//
// Source: Lịch Phụng Vụ Roma + danh sách thánh phổ biến VN.
// Note: trùng tên (vd Maria nhiều lễ) → dùng lễ chính (15/8 Đức Mẹ Lên Trời cho Maria).

class SaintFeastDay {
  const SaintFeastDay(this.name, this.month, this.day, [this.note]);
  final String name;
  final int month;
  final int day;
  final String? note;

  /// Match nguyên văn (không dấu, lowercase, bỏ tiền tố nam/nữ)
  bool matches(String saintName) {
    final clean = _normalize(saintName);
    final pattern = _normalize(name);
    return clean == pattern || clean.contains(pattern);
  }

  static String _normalize(String s) {
    var x = s.toLowerCase().trim();
    // Bỏ tiền tố/hậu tố không phân biệt: ông, bà, cô, anh, đức, thánh
    x = x.replaceAll(RegExp(r'^(thánh|đức|anh|ông|bà|cô)\s+'), '');
    // Strip dấu tiếng Việt cơ bản
    const vmap = {
      'à':'a','á':'a','ả':'a','ã':'a','ạ':'a','ă':'a','ằ':'a','ắ':'a','ẳ':'a','ẵ':'a','ặ':'a',
      'â':'a','ầ':'a','ấ':'a','ẩ':'a','ẫ':'a','ậ':'a',
      'è':'e','é':'e','ẻ':'e','ẽ':'e','ẹ':'e','ê':'e','ề':'e','ế':'e','ể':'e','ễ':'e','ệ':'e',
      'ì':'i','í':'i','ỉ':'i','ĩ':'i','ị':'i',
      'ò':'o','ó':'o','ỏ':'o','õ':'o','ọ':'o','ô':'o','ồ':'o','ố':'o','ổ':'o','ỗ':'o','ộ':'o',
      'ơ':'o','ờ':'o','ớ':'o','ở':'o','ỡ':'o','ợ':'o',
      'ù':'u','ú':'u','ủ':'u','ũ':'u','ụ':'u','ư':'u','ừ':'u','ứ':'u','ử':'u','ữ':'u','ự':'u',
      'ỳ':'y','ý':'y','ỷ':'y','ỹ':'y','ỵ':'y','đ':'d',
    };
    final sb = StringBuffer();
    for (final ch in x.runes) {
      final c = String.fromCharCode(ch);
      sb.write(vmap[c] ?? c);
    }
    return sb.toString();
  }
}

const realCmFeastDays = <SaintFeastDay>[
  // ── Tên Thánh phổ biến nhất ở VN ──
  SaintFeastDay('Phêrô', 6, 29, 'Lễ Thánh Phêrô và Phaolô'),
  SaintFeastDay('Phaolô', 6, 29, 'Lễ Thánh Phêrô và Phaolô'),
  SaintFeastDay('Maria', 8, 15, 'Đức Mẹ Lên Trời'),
  SaintFeastDay('Giuse', 3, 19, 'Lễ Thánh Cả Giuse'),
  SaintFeastDay('Anna', 7, 26, 'Lễ Thánh Anna'),
  SaintFeastDay('Anrê', 11, 30, 'Lễ Thánh Anrê'),
  SaintFeastDay('Antôn', 6, 13, 'Lễ Thánh Antôn Padua'),
  SaintFeastDay('Bênêđictô', 7, 11),
  SaintFeastDay('Catarina', 4, 29, 'Lễ Thánh Catarina'),
  SaintFeastDay('Cêcilia', 11, 22),
  SaintFeastDay('Clara', 8, 11),
  SaintFeastDay('Dôminicô', 8, 8),
  SaintFeastDay('Eva', 12, 24),
  SaintFeastDay('Fanxicô', 10, 4, 'Lễ Thánh Phanxicô Assisi'),
  SaintFeastDay('Phanxicô', 10, 4, 'Lễ Thánh Phanxicô Assisi'),
  SaintFeastDay('Phanxicô Xaviê', 12, 3),
  SaintFeastDay('Gabriel', 9, 29),
  SaintFeastDay('Giacôbê', 7, 25),
  SaintFeastDay('Gioakim', 7, 26),
  SaintFeastDay('Gioan', 12, 27, 'Lễ Thánh Gioan Tông đồ'),
  SaintFeastDay('Gioan Baotixita', 6, 24),
  SaintFeastDay('Gioan Phaolô', 10, 22),
  SaintFeastDay('Gioan Maria Vianney', 8, 4),
  SaintFeastDay('Gióakim', 7, 26),
  SaintFeastDay('Hilarion', 10, 21),
  SaintFeastDay('Inhaxiô', 7, 31, 'Lễ Thánh Inhaxiô Loyola'),
  SaintFeastDay('Isave', 11, 17),
  SaintFeastDay('Êlisabet', 11, 17),
  SaintFeastDay('Khanh', 6, 5, 'Thánh Phaolô Lê Bảo Tịnh'),
  SaintFeastDay('Lôrenxô', 8, 10),
  SaintFeastDay('Luca', 10, 18),
  SaintFeastDay('Macta', 7, 29),
  SaintFeastDay('Maccô', 4, 25),
  SaintFeastDay('Mátthêu', 9, 21),
  SaintFeastDay('Mátthia', 5, 14),
  SaintFeastDay('Micae', 9, 29),
  SaintFeastDay('Mônica', 8, 27),
  SaintFeastDay('Phêrô Khanh', 7, 12),
  SaintFeastDay('Raphael', 9, 29),
  SaintFeastDay('Rôsa', 8, 23, 'Thánh Rôsa Lima'),
  SaintFeastDay('Stêphanô', 12, 26),
  SaintFeastDay('Teresa', 10, 1, 'Thánh Têrêxa Hài Đồng Giêsu'),
  SaintFeastDay('Têrêxa', 10, 1),
  SaintFeastDay('Têrêsa', 10, 1),
  SaintFeastDay('Thaddêô', 10, 28),
  SaintFeastDay('Tôma', 7, 3, 'Lễ Thánh Tôma Tông đồ'),
  SaintFeastDay('Vincentê', 9, 27),
  SaintFeastDay('Vinh Sơn', 9, 27),
];

/// Tìm lễ Thánh trong vòng [withinDays] ngày tới (tính từ hôm nay).
/// Trả về list tuple (member-style record, feast date this year, feast day info).
List<MapEntry<SaintFeastDay, DateTime>> upcomingFeastDays({int withinDays = 30}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final until = today.add(Duration(days: withinDays));
  final out = <MapEntry<SaintFeastDay, DateTime>>[];
  for (final f in realCmFeastDays) {
    var date = DateTime(now.year, f.month, f.day);
    if (date.isBefore(today)) date = DateTime(now.year + 1, f.month, f.day);
    if (date.isAfter(until)) continue;
    out.add(MapEntry(f, date));
  }
  out.sort((a, b) => a.value.compareTo(b.value));
  return out;
}

/// Match member.saintName với feast day. Trả về null nếu không tìm thấy.
SaintFeastDay? findFeastFor(String? saintName) {
  if (saintName == null || saintName.trim().isEmpty) return null;
  for (final f in realCmFeastDays) {
    if (f.matches(saintName)) return f;
  }
  return null;
}

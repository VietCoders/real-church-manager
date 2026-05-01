// Format validators chung — SĐT VN, email, CCCD/CMND.

class RealCmValidators {
  RealCmValidators._();

  /// SĐT VN: 10-11 số, đầu 0 hoặc +84.
  /// VD hợp lệ: 0901234567, 01234567890, +84901234567.
  static String? phone(String? v, {bool required = false}) {
    if (v == null || v.trim().isEmpty) return required ? 'Bắt buộc' : null;
    final cleaned = v.replaceAll(RegExp(r'[\s\.\-]'), '');
    if (!RegExp(r'^(\+?84|0)\d{9,10}$').hasMatch(cleaned)) {
      return 'SĐT không hợp lệ (10-11 số, vd: 0901234567)';
    }
    return null;
  }

  /// Email RFC 5322 đơn giản.
  static String? email(String? v, {bool required = false}) {
    if (v == null || v.trim().isEmpty) return required ? 'Bắt buộc' : null;
    if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\-\.]+$').hasMatch(v.trim())) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  /// CCCD/CMND VN: 9 số (CMND cũ) hoặc 12 số (CCCD).
  static String? idNumber(String? v, {bool required = false}) {
    if (v == null || v.trim().isEmpty) return required ? 'Bắt buộc' : null;
    final cleaned = v.replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^\d{9}$|^\d{12}$').hasMatch(cleaned)) {
      return 'CCCD/CMND phải 9 hoặc 12 số';
    }
    return null;
  }
}

// PLACEHOLDER — file này sẽ được `flutter gen-l10n` tự sinh từ `lib/l10n/app_*.arb`.
// Manual fallback cho scaffold v1 trước khi user chạy `flutter pub get && flutter gen-l10n`.
// Khi flutter SDK đã cài, chạy `flutter gen-l10n` ở thư mục apps/flutter_app/ — sẽ ghi đè file này.
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale locale;

  static AppLocalizations? of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [Locale('vi'), Locale('en')];

  String _t(Map<String, String> vi, Map<String, String> en, String key) {
    final lang = locale.languageCode;
    final map = lang == 'en' ? en : vi;
    return map[key] ?? vi[key] ?? key;
  }

  String get appTitle => _t(_vi, _en, 'appTitle');
  String get commonSubmit => _t(_vi, _en, 'commonSubmit');
  String get commonSave => _t(_vi, _en, 'commonSave');
  String get commonCancel => _t(_vi, _en, 'commonCancel');
  String get commonConfirm => _t(_vi, _en, 'commonConfirm');
  String get commonDelete => _t(_vi, _en, 'commonDelete');
  String get commonEdit => _t(_vi, _en, 'commonEdit');
  String get commonAdd => _t(_vi, _en, 'commonAdd');
  String get commonSearch => _t(_vi, _en, 'commonSearch');
  String get commonClose => _t(_vi, _en, 'commonClose');
  String get commonBack => _t(_vi, _en, 'commonBack');
  String get commonNext => _t(_vi, _en, 'commonNext');
  String get commonLoading => _t(_vi, _en, 'commonLoading');
  String get commonEmpty => _t(_vi, _en, 'commonEmpty');
  String get commonError => _t(_vi, _en, 'commonError');
  String get commonSuccess => _t(_vi, _en, 'commonSuccess');
  String get commonRequired => _t(_vi, _en, 'commonRequired');
  String get commonOptional => _t(_vi, _en, 'commonOptional');
  String get commonYes => _t(_vi, _en, 'commonYes');
  String get commonNo => _t(_vi, _en, 'commonNo');

  String get navMembers => _t(_vi, _en, 'navMembers');
  String get navFamilies => _t(_vi, _en, 'navFamilies');
  String get navDistricts => _t(_vi, _en, 'navDistricts');
  String get navSacraments => _t(_vi, _en, 'navSacraments');
  String get navGroups => _t(_vi, _en, 'navGroups');
  String get navMass => _t(_vi, _en, 'navMass');
  String get navCalendar => _t(_vi, _en, 'navCalendar');
  String get navDonations => _t(_vi, _en, 'navDonations');
  String get navReports => _t(_vi, _en, 'navReports');
  String get navSettings => _t(_vi, _en, 'navSettings');

  String get authLoginTitle => _t(_vi, _en, 'authLoginTitle');
  String get authEmailLabel => _t(_vi, _en, 'authEmailLabel');
  String get authPasswordLabel => _t(_vi, _en, 'authPasswordLabel');
  String get authLoginButton => _t(_vi, _en, 'authLoginButton');
  String get authLogoutButton => _t(_vi, _en, 'authLogoutButton');
  String get authEmailRequired => _t(_vi, _en, 'authEmailRequired');
  String get authPasswordRequired => _t(_vi, _en, 'authPasswordRequired');
  String get authLoginFailed => _t(_vi, _en, 'authLoginFailed');

  String get setupTitle => _t(_vi, _en, 'setupTitle');
  String get setupDescription => _t(_vi, _en, 'setupDescription');
  String get setupBackendUrlLabel => _t(_vi, _en, 'setupBackendUrlLabel');
  String get setupBackendUrlHint => _t(_vi, _en, 'setupBackendUrlHint');
  String get setupConnectButton => _t(_vi, _en, 'setupConnectButton');
  String get setupInvalidUrl => _t(_vi, _en, 'setupInvalidUrl');

  String get memberListTitle => _t(_vi, _en, 'memberListTitle');
  String get memberAddTitle => _t(_vi, _en, 'memberAddTitle');
  String get memberEditTitle => _t(_vi, _en, 'memberEditTitle');
  String get memberDetailTitle => _t(_vi, _en, 'memberDetailTitle');
  String get memberSaintName => _t(_vi, _en, 'memberSaintName');
  String get memberFullName => _t(_vi, _en, 'memberFullName');
  String get memberGender => _t(_vi, _en, 'memberGender');
  String get memberGenderMale => _t(_vi, _en, 'memberGenderMale');
  String get memberGenderFemale => _t(_vi, _en, 'memberGenderFemale');
  String get memberGenderOther => _t(_vi, _en, 'memberGenderOther');
  String get memberBirthDate => _t(_vi, _en, 'memberBirthDate');
  String get memberPhone => _t(_vi, _en, 'memberPhone');
  String get memberEmail => _t(_vi, _en, 'memberEmail');
  String get memberAddress => _t(_vi, _en, 'memberAddress');
  String get memberDistrict => _t(_vi, _en, 'memberDistrict');
  String get memberFamily => _t(_vi, _en, 'memberFamily');
  String get memberStatus => _t(_vi, _en, 'memberStatus');
  String get memberStatusActive => _t(_vi, _en, 'memberStatusActive');
  String get memberDeleteConfirm => _t(_vi, _en, 'memberDeleteConfirm');
  String get memberSearchHint => _t(_vi, _en, 'memberSearchHint');

  String get sacramentBaptism => _t(_vi, _en, 'sacramentBaptism');
  String get sacramentConfirmation => _t(_vi, _en, 'sacramentConfirmation');
  String get sacramentMarriage => _t(_vi, _en, 'sacramentMarriage');
  String get sacramentAnointing => _t(_vi, _en, 'sacramentAnointing');
  String get sacramentFuneral => _t(_vi, _en, 'sacramentFuneral');
  String get sacramentPrintCertificate => _t(_vi, _en, 'sacramentPrintCertificate');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => ['vi', 'en'].contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) async {
    intl.Intl.defaultLocale = locale.toLanguageTag();
    return AppLocalizations(locale);
  }
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Strings (extract từ app_vi.arb + app_en.arb để build chạy được trước khi gen_l10n).
const Map<String, String> _vi = {
  'appTitle': 'Quản lý Giáo xứ',
  'commonSubmit': 'Gửi', 'commonSave': 'Lưu', 'commonCancel': 'Huỷ',
  'commonConfirm': 'Xác nhận', 'commonDelete': 'Xoá', 'commonEdit': 'Sửa', 'commonAdd': 'Thêm',
  'commonSearch': 'Tìm kiếm', 'commonClose': 'Đóng', 'commonBack': 'Quay lại', 'commonNext': 'Tiếp',
  'commonLoading': 'Đang tải...', 'commonEmpty': 'Chưa có dữ liệu',
  'commonError': 'Đã xảy ra lỗi. Thử lại.', 'commonSuccess': 'Thành công',
  'commonRequired': '(bắt buộc)', 'commonOptional': '(tuỳ chọn)',
  'commonYes': 'Có', 'commonNo': 'Không',
  'navMembers': 'Giáo dân', 'navFamilies': 'Gia đình', 'navDistricts': 'Giáo họ',
  'navSacraments': 'Sổ Bí Tích', 'navGroups': 'Đoàn thể', 'navMass': 'Lễ ý',
  'navCalendar': 'Lịch phụng vụ', 'navDonations': 'Sổ thu chi', 'navReports': 'Báo cáo',
  'navSettings': 'Cấu hình',
  'authLoginTitle': 'Đăng nhập', 'authEmailLabel': 'Email', 'authPasswordLabel': 'Mật khẩu',
  'authLoginButton': 'Đăng nhập', 'authLogoutButton': 'Đăng xuất',
  'authEmailRequired': 'Vui lòng nhập email', 'authPasswordRequired': 'Vui lòng nhập mật khẩu',
  'authLoginFailed': 'Đăng nhập thất bại. Kiểm tra email/mật khẩu.',
  'setupTitle': 'Cấu hình kết nối',
  'setupDescription': 'Nhập địa chỉ máy chủ PocketBase của giáo xứ. Ví dụ: http://192.168.1.100:8090 hoặc https://parish.example.com',
  'setupBackendUrlLabel': 'Địa chỉ máy chủ', 'setupBackendUrlHint': 'http://127.0.0.1:8090',
  'setupConnectButton': 'Kết nối', 'setupInvalidUrl': 'URL không hợp lệ',
  'memberListTitle': 'Danh sách giáo dân', 'memberAddTitle': 'Thêm giáo dân',
  'memberEditTitle': 'Sửa giáo dân', 'memberDetailTitle': 'Hồ sơ giáo dân',
  'memberSaintName': 'Tên Thánh', 'memberFullName': 'Họ và tên',
  'memberGender': 'Giới tính', 'memberGenderMale': 'Nam', 'memberGenderFemale': 'Nữ', 'memberGenderOther': 'Khác',
  'memberBirthDate': 'Ngày sinh', 'memberPhone': 'Điện thoại', 'memberEmail': 'Email',
  'memberAddress': 'Địa chỉ', 'memberDistrict': 'Giáo họ', 'memberFamily': 'Gia đình',
  'memberStatus': 'Tình trạng', 'memberStatusActive': 'Đang hoạt động',
  'memberDeleteConfirm': 'Bạn có chắc muốn xoá giáo dân này?',
  'memberSearchHint': 'Tìm theo tên Thánh, họ tên, điện thoại...',
  'sacramentBaptism': 'Rửa Tội', 'sacramentConfirmation': 'Thêm Sức',
  'sacramentMarriage': 'Hôn Phối', 'sacramentAnointing': 'Xức Dầu Bệnh Nhân',
  'sacramentFuneral': 'An Táng', 'sacramentPrintCertificate': 'In chứng chỉ',
};

const Map<String, String> _en = {
  'appTitle': 'Parish Manager',
  'commonSubmit': 'Submit', 'commonSave': 'Save', 'commonCancel': 'Cancel',
  'commonConfirm': 'Confirm', 'commonDelete': 'Delete', 'commonEdit': 'Edit', 'commonAdd': 'Add',
  'commonSearch': 'Search', 'commonClose': 'Close', 'commonBack': 'Back', 'commonNext': 'Next',
  'commonLoading': 'Loading...', 'commonEmpty': 'No data yet',
  'commonError': 'An error occurred. Try again.', 'commonSuccess': 'Success',
  'commonRequired': '(required)', 'commonOptional': '(optional)',
  'commonYes': 'Yes', 'commonNo': 'No',
  'navMembers': 'Parishioners', 'navFamilies': 'Families', 'navDistricts': 'Districts',
  'navSacraments': 'Sacrament books', 'navGroups': 'Groups', 'navMass': 'Mass intentions',
  'navCalendar': 'Liturgical calendar', 'navDonations': 'Donations', 'navReports': 'Reports',
  'navSettings': 'Settings',
  'authLoginTitle': 'Sign in', 'authEmailLabel': 'Email', 'authPasswordLabel': 'Password',
  'authLoginButton': 'Sign in', 'authLogoutButton': 'Sign out',
  'authEmailRequired': 'Email is required', 'authPasswordRequired': 'Password is required',
  'authLoginFailed': 'Login failed. Check email/password.',
  'setupTitle': 'Connection setup',
  'setupDescription': 'Enter the PocketBase server address of your parish.',
  'setupBackendUrlLabel': 'Server address', 'setupBackendUrlHint': 'http://127.0.0.1:8090',
  'setupConnectButton': 'Connect', 'setupInvalidUrl': 'Invalid URL',
  'memberListTitle': 'Parishioner list', 'memberAddTitle': 'Add parishioner',
  'memberEditTitle': 'Edit parishioner', 'memberDetailTitle': 'Parishioner profile',
  'memberSaintName': 'Saint name', 'memberFullName': 'Full name',
  'memberGender': 'Gender', 'memberGenderMale': 'Male', 'memberGenderFemale': 'Female', 'memberGenderOther': 'Other',
  'memberBirthDate': 'Date of birth', 'memberPhone': 'Phone', 'memberEmail': 'Email',
  'memberAddress': 'Address', 'memberDistrict': 'District', 'memberFamily': 'Family',
  'memberStatus': 'Status', 'memberStatusActive': 'Active',
  'memberDeleteConfirm': 'Are you sure to delete this parishioner?',
  'memberSearchHint': 'Search by saint name, full name, phone...',
  'sacramentBaptism': 'Baptism', 'sacramentConfirmation': 'Confirmation',
  'sacramentMarriage': 'Marriage', 'sacramentAnointing': 'Anointing of the Sick',
  'sacramentFuneral': 'Funeral', 'sacramentPrintCertificate': 'Print certificate',
};

// Avoid analyzer warning about unused intl import in some setups.
// ignore: unused_element
const _kUseIntl = identical(intl.Intl.systemLocale, intl.Intl.systemLocale);
// ignore: unused_element
const _kUseFoundation = kIsWeb || !kIsWeb;

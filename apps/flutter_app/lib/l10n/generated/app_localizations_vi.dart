// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Quản lý Giáo xứ';

  @override
  String get commonSubmit => 'Gửi';

  @override
  String get commonSave => 'Lưu';

  @override
  String get commonCancel => 'Huỷ';

  @override
  String get commonConfirm => 'Xác nhận';

  @override
  String get commonDelete => 'Xoá';

  @override
  String get commonEdit => 'Sửa';

  @override
  String get commonAdd => 'Thêm';

  @override
  String get commonSearch => 'Tìm kiếm';

  @override
  String get commonClose => 'Đóng';

  @override
  String get commonBack => 'Quay lại';

  @override
  String get commonNext => 'Tiếp';

  @override
  String get commonLoading => 'Đang tải...';

  @override
  String get commonEmpty => 'Chưa có dữ liệu';

  @override
  String get commonError => 'Đã xảy ra lỗi. Thử lại.';

  @override
  String get commonSuccess => 'Thành công';

  @override
  String get commonRequired => '(bắt buộc)';

  @override
  String get commonOptional => '(tuỳ chọn)';

  @override
  String get commonYes => 'Có';

  @override
  String get commonNo => 'Không';

  @override
  String get navMembers => 'Giáo dân';

  @override
  String get navFamilies => 'Gia đình';

  @override
  String get navDistricts => 'Giáo họ';

  @override
  String get navSacraments => 'Sổ Bí Tích';

  @override
  String get navGroups => 'Đoàn thể';

  @override
  String get navMass => 'Lễ ý';

  @override
  String get navCalendar => 'Lịch phụng vụ';

  @override
  String get navDonations => 'Sổ thu chi';

  @override
  String get navReports => 'Báo cáo';

  @override
  String get navSettings => 'Cấu hình';

  @override
  String get authLoginTitle => 'Đăng nhập';

  @override
  String get authIdentityLabel => 'Tên đăng nhập';

  @override
  String get authIdentityHint => 'admin';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Mật khẩu';

  @override
  String get authLoginButton => 'Đăng nhập';

  @override
  String get authLogoutButton => 'Đăng xuất';

  @override
  String get authIdentityRequired => 'Vui lòng nhập tên đăng nhập';

  @override
  String get authEmailRequired => 'Vui lòng nhập email';

  @override
  String get authPasswordRequired => 'Vui lòng nhập mật khẩu';

  @override
  String get authLoginFailed =>
      'Đăng nhập thất bại. Kiểm tra tên đăng nhập / mật khẩu.';

  @override
  String get changePasswordTitle => 'Đổi mật khẩu';

  @override
  String get changePasswordHeading => 'Đổi mật khẩu lần đầu';

  @override
  String get changePasswordDescription =>
      'Vì bảo mật, vui lòng đổi mật khẩu mặc định trước khi tiếp tục sử dụng.';

  @override
  String get changePasswordOldLabel => 'Mật khẩu hiện tại';

  @override
  String get changePasswordNewLabel => 'Mật khẩu mới';

  @override
  String get changePasswordConfirmLabel => 'Nhập lại mật khẩu mới';

  @override
  String get changePasswordRules => 'Tối thiểu 6 ký tự, khác mật khẩu cũ';

  @override
  String get changePasswordOldRequired => 'Vui lòng nhập mật khẩu hiện tại';

  @override
  String get changePasswordNewRequired => 'Vui lòng nhập mật khẩu mới';

  @override
  String get changePasswordConfirmRequired => 'Vui lòng nhập lại mật khẩu mới';

  @override
  String get changePasswordTooShort => 'Mật khẩu quá ngắn (tối thiểu 6 ký tự)';

  @override
  String get changePasswordSameAsOld => 'Mật khẩu mới phải khác mật khẩu cũ';

  @override
  String get changePasswordConfirmMismatch => 'Mật khẩu xác nhận không khớp';

  @override
  String get changePasswordSubmit => 'Cập nhật mật khẩu';

  @override
  String get changePasswordSuccess => 'Đổi mật khẩu thành công';

  @override
  String get changePasswordFailed =>
      'Đổi mật khẩu thất bại. Kiểm tra mật khẩu hiện tại.';

  @override
  String get setupTitle => 'Cấu hình kết nối';

  @override
  String get setupDescription =>
      'Nhập địa chỉ máy chủ PocketBase của giáo xứ. Ví dụ: http://192.168.1.100:8090 hoặc https://parish.example.com';

  @override
  String get setupBackendUrlLabel => 'Địa chỉ máy chủ';

  @override
  String get setupBackendUrlHint => 'http://127.0.0.1:8090';

  @override
  String get setupConnectButton => 'Kết nối';

  @override
  String get setupInvalidUrl => 'URL không hợp lệ';

  @override
  String get memberListTitle => 'Danh sách giáo dân';

  @override
  String get memberAddTitle => 'Thêm giáo dân';

  @override
  String get memberEditTitle => 'Sửa giáo dân';

  @override
  String get memberDetailTitle => 'Hồ sơ giáo dân';

  @override
  String get memberSaintName => 'Tên Thánh';

  @override
  String get memberFullName => 'Họ và tên';

  @override
  String get memberGender => 'Giới tính';

  @override
  String get memberGenderMale => 'Nam';

  @override
  String get memberGenderFemale => 'Nữ';

  @override
  String get memberGenderOther => 'Khác';

  @override
  String get memberBirthDate => 'Ngày sinh';

  @override
  String get memberBirthPlace => 'Nơi sinh';

  @override
  String get memberDeathDate => 'Ngày qua đời';

  @override
  String get memberPhone => 'Điện thoại';

  @override
  String get memberEmail => 'Email';

  @override
  String get memberAddress => 'Địa chỉ';

  @override
  String get memberDistrict => 'Giáo họ';

  @override
  String get memberFamily => 'Gia đình';

  @override
  String get memberFather => 'Tên cha';

  @override
  String get memberMother => 'Tên mẹ';

  @override
  String get memberSpouse => 'Vợ/Chồng';

  @override
  String get memberPhoto => 'Ảnh';

  @override
  String get memberNotes => 'Ghi chú';

  @override
  String get memberStatus => 'Tình trạng';

  @override
  String get memberStatusActive => 'Đang hoạt động';

  @override
  String get memberStatusMovedOut => 'Đã chuyển xứ';

  @override
  String get memberStatusDeceased => 'Đã qua đời';

  @override
  String get memberDeleteConfirm => 'Bạn có chắc muốn xoá giáo dân này?';

  @override
  String get memberSearchHint => 'Tìm theo tên Thánh, họ tên, điện thoại...';

  @override
  String get sacramentBaptism => 'Rửa Tội';

  @override
  String get sacramentConfirmation => 'Thêm Sức';

  @override
  String get sacramentMarriage => 'Hôn Phối';

  @override
  String get sacramentAnointing => 'Xức Dầu Bệnh Nhân';

  @override
  String get sacramentFuneral => 'An Táng';

  @override
  String get sacramentBookNumber => 'Số sổ';

  @override
  String get sacramentDate => 'Ngày cử hành';

  @override
  String get sacramentPlace => 'Nơi cử hành';

  @override
  String get sacramentPriest => 'Cha cử hành';

  @override
  String get sacramentBishop => 'Đức Giám mục';

  @override
  String get sacramentGodfather => 'Cha đỡ đầu';

  @override
  String get sacramentGodmother => 'Mẹ đỡ đầu';

  @override
  String get sacramentSponsor => 'Người đỡ đầu';

  @override
  String get sacramentGroom => 'Chú rể';

  @override
  String get sacramentBride => 'Cô dâu';

  @override
  String get sacramentWitness1 => 'Người chứng 1';

  @override
  String get sacramentWitness2 => 'Người chứng 2';

  @override
  String get sacramentDispensation => 'Miễn chuẩn';

  @override
  String get sacramentDeathCause => 'Nguyên nhân qua đời';

  @override
  String get sacramentBurialPlace => 'Nơi an táng';

  @override
  String get sacramentPrintCertificate => 'In chứng chỉ';

  @override
  String get groupTitle => 'Đoàn thể';

  @override
  String get groupName => 'Tên hội';

  @override
  String get groupCode => 'Mã';

  @override
  String get groupTypeConfraternity => 'Hội đoàn';

  @override
  String get groupTypeYouth => 'Giới trẻ';

  @override
  String get groupTypeChoir => 'Ca đoàn';

  @override
  String get groupTypePastoral => 'Mục vụ';

  @override
  String get groupTypeOther => 'Khác';

  @override
  String get groupHead => 'Trưởng hội';

  @override
  String get groupViceHead => 'Phó hội';

  @override
  String get groupMeetingSchedule => 'Lịch họp/sinh hoạt';

  @override
  String get massIntentionTitle => 'Lễ ý cầu nguyện';

  @override
  String get massIntentionRequester => 'Người xin';

  @override
  String get massIntentionText => 'Ý chỉ';

  @override
  String get massIntentionDate => 'Ngày dự kiến';

  @override
  String get massIntentionStatusPending => 'Chờ duyệt';

  @override
  String get massIntentionStatusScheduled => 'Đã xếp lịch';

  @override
  String get massIntentionStatusDone => 'Đã cử hành';

  @override
  String get massIntentionStatusCancelled => 'Huỷ';

  @override
  String get donationTitle => 'Sổ thu chi';

  @override
  String get donationDate => 'Ngày';

  @override
  String get donationType => 'Loại';

  @override
  String get donationTypeSundayOffering => 'Dâng cúng Chúa Nhật';

  @override
  String get donationTypeFeastOffering => 'Dâng cúng lễ trọng';

  @override
  String get donationTypeBuildingFund => 'Quỹ xây dựng';

  @override
  String get donationTypeMassIntention => 'Xin lễ';

  @override
  String get donationTypeOtherIn => 'Thu khác';

  @override
  String get donationTypeExpense => 'Chi';

  @override
  String get donationAmount => 'Số tiền';

  @override
  String get donationDonor => 'Người dâng';

  @override
  String get reportTitle => 'Báo cáo thống kê';

  @override
  String get reportByAge => 'Theo độ tuổi';

  @override
  String get reportByGender => 'Theo giới tính';

  @override
  String get reportByDistrict => 'Theo giáo họ';

  @override
  String get reportSacramentByYear => 'Bí Tích theo năm';

  @override
  String get reportExportPdf => 'Xuất PDF';

  @override
  String get reportExportExcel => 'Xuất Excel';
}

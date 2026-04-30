import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// App title
  ///
  /// In vi, this message translates to:
  /// **'Quản lý Giáo xứ'**
  String get appTitle;

  /// No description provided for @commonSubmit.
  ///
  /// In vi, this message translates to:
  /// **'Gửi'**
  String get commonSubmit;

  /// No description provided for @commonSave.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In vi, this message translates to:
  /// **'Huỷ'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get commonConfirm;

  /// No description provided for @commonDelete.
  ///
  /// In vi, this message translates to:
  /// **'Xoá'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa'**
  String get commonEdit;

  /// No description provided for @commonAdd.
  ///
  /// In vi, this message translates to:
  /// **'Thêm'**
  String get commonAdd;

  /// No description provided for @commonSearch.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm'**
  String get commonSearch;

  /// No description provided for @commonClose.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get commonClose;

  /// No description provided for @commonBack.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp'**
  String get commonNext;

  /// No description provided for @commonLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải...'**
  String get commonLoading;

  /// No description provided for @commonEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu'**
  String get commonEmpty;

  /// No description provided for @commonError.
  ///
  /// In vi, this message translates to:
  /// **'Đã xảy ra lỗi. Thử lại.'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Thành công'**
  String get commonSuccess;

  /// No description provided for @commonRequired.
  ///
  /// In vi, this message translates to:
  /// **'(bắt buộc)'**
  String get commonRequired;

  /// No description provided for @commonOptional.
  ///
  /// In vi, this message translates to:
  /// **'(tuỳ chọn)'**
  String get commonOptional;

  /// No description provided for @commonYes.
  ///
  /// In vi, this message translates to:
  /// **'Có'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In vi, this message translates to:
  /// **'Không'**
  String get commonNo;

  /// No description provided for @navMembers.
  ///
  /// In vi, this message translates to:
  /// **'Giáo dân'**
  String get navMembers;

  /// No description provided for @navFamilies.
  ///
  /// In vi, this message translates to:
  /// **'Gia đình'**
  String get navFamilies;

  /// No description provided for @navDistricts.
  ///
  /// In vi, this message translates to:
  /// **'Giáo họ'**
  String get navDistricts;

  /// No description provided for @navSacraments.
  ///
  /// In vi, this message translates to:
  /// **'Sổ Bí Tích'**
  String get navSacraments;

  /// No description provided for @navGroups.
  ///
  /// In vi, this message translates to:
  /// **'Đoàn thể'**
  String get navGroups;

  /// No description provided for @navMass.
  ///
  /// In vi, this message translates to:
  /// **'Lễ ý'**
  String get navMass;

  /// No description provided for @navCalendar.
  ///
  /// In vi, this message translates to:
  /// **'Lịch phụng vụ'**
  String get navCalendar;

  /// No description provided for @navDonations.
  ///
  /// In vi, this message translates to:
  /// **'Sổ thu chi'**
  String get navDonations;

  /// No description provided for @navReports.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo'**
  String get navReports;

  /// No description provided for @navSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cấu hình'**
  String get navSettings;

  /// No description provided for @authLoginTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get authLoginTitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get authPasswordLabel;

  /// No description provided for @authLoginButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get authLoginButton;

  /// No description provided for @authLogoutButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get authLogoutButton;

  /// No description provided for @authEmailRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập email'**
  String get authEmailRequired;

  /// No description provided for @authPasswordRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mật khẩu'**
  String get authPasswordRequired;

  /// No description provided for @authLoginFailed.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập thất bại. Kiểm tra email/mật khẩu.'**
  String get authLoginFailed;

  /// No description provided for @setupTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cấu hình kết nối'**
  String get setupTitle;

  /// No description provided for @setupDescription.
  ///
  /// In vi, this message translates to:
  /// **'Nhập địa chỉ máy chủ PocketBase của giáo xứ. Ví dụ: http://192.168.1.100:8090 hoặc https://parish.example.com'**
  String get setupDescription;

  /// No description provided for @setupBackendUrlLabel.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ máy chủ'**
  String get setupBackendUrlLabel;

  /// No description provided for @setupBackendUrlHint.
  ///
  /// In vi, this message translates to:
  /// **'http://127.0.0.1:8090'**
  String get setupBackendUrlHint;

  /// No description provided for @setupConnectButton.
  ///
  /// In vi, this message translates to:
  /// **'Kết nối'**
  String get setupConnectButton;

  /// No description provided for @setupInvalidUrl.
  ///
  /// In vi, this message translates to:
  /// **'URL không hợp lệ'**
  String get setupInvalidUrl;

  /// No description provided for @memberListTitle.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách giáo dân'**
  String get memberListTitle;

  /// No description provided for @memberAddTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thêm giáo dân'**
  String get memberAddTitle;

  /// No description provided for @memberEditTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sửa giáo dân'**
  String get memberEditTitle;

  /// No description provided for @memberDetailTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ giáo dân'**
  String get memberDetailTitle;

  /// No description provided for @memberSaintName.
  ///
  /// In vi, this message translates to:
  /// **'Tên Thánh'**
  String get memberSaintName;

  /// No description provided for @memberFullName.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get memberFullName;

  /// No description provided for @memberGender.
  ///
  /// In vi, this message translates to:
  /// **'Giới tính'**
  String get memberGender;

  /// No description provided for @memberGenderMale.
  ///
  /// In vi, this message translates to:
  /// **'Nam'**
  String get memberGenderMale;

  /// No description provided for @memberGenderFemale.
  ///
  /// In vi, this message translates to:
  /// **'Nữ'**
  String get memberGenderFemale;

  /// No description provided for @memberGenderOther.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get memberGenderOther;

  /// No description provided for @memberBirthDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày sinh'**
  String get memberBirthDate;

  /// No description provided for @memberBirthPlace.
  ///
  /// In vi, this message translates to:
  /// **'Nơi sinh'**
  String get memberBirthPlace;

  /// No description provided for @memberDeathDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày qua đời'**
  String get memberDeathDate;

  /// No description provided for @memberPhone.
  ///
  /// In vi, this message translates to:
  /// **'Điện thoại'**
  String get memberPhone;

  /// No description provided for @memberEmail.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get memberEmail;

  /// No description provided for @memberAddress.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ'**
  String get memberAddress;

  /// No description provided for @memberDistrict.
  ///
  /// In vi, this message translates to:
  /// **'Giáo họ'**
  String get memberDistrict;

  /// No description provided for @memberFamily.
  ///
  /// In vi, this message translates to:
  /// **'Gia đình'**
  String get memberFamily;

  /// No description provided for @memberFather.
  ///
  /// In vi, this message translates to:
  /// **'Tên cha'**
  String get memberFather;

  /// No description provided for @memberMother.
  ///
  /// In vi, this message translates to:
  /// **'Tên mẹ'**
  String get memberMother;

  /// No description provided for @memberSpouse.
  ///
  /// In vi, this message translates to:
  /// **'Vợ/Chồng'**
  String get memberSpouse;

  /// No description provided for @memberPhoto.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh'**
  String get memberPhoto;

  /// No description provided for @memberNotes.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get memberNotes;

  /// No description provided for @memberStatus.
  ///
  /// In vi, this message translates to:
  /// **'Tình trạng'**
  String get memberStatus;

  /// No description provided for @memberStatusActive.
  ///
  /// In vi, this message translates to:
  /// **'Đang hoạt động'**
  String get memberStatusActive;

  /// No description provided for @memberStatusMovedOut.
  ///
  /// In vi, this message translates to:
  /// **'Đã chuyển xứ'**
  String get memberStatusMovedOut;

  /// No description provided for @memberStatusDeceased.
  ///
  /// In vi, this message translates to:
  /// **'Đã qua đời'**
  String get memberStatusDeceased;

  /// No description provided for @memberDeleteConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xoá giáo dân này?'**
  String get memberDeleteConfirm;

  /// No description provided for @memberSearchHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm theo tên Thánh, họ tên, điện thoại...'**
  String get memberSearchHint;

  /// No description provided for @sacramentBaptism.
  ///
  /// In vi, this message translates to:
  /// **'Rửa Tội'**
  String get sacramentBaptism;

  /// No description provided for @sacramentConfirmation.
  ///
  /// In vi, this message translates to:
  /// **'Thêm Sức'**
  String get sacramentConfirmation;

  /// No description provided for @sacramentMarriage.
  ///
  /// In vi, this message translates to:
  /// **'Hôn Phối'**
  String get sacramentMarriage;

  /// No description provided for @sacramentAnointing.
  ///
  /// In vi, this message translates to:
  /// **'Xức Dầu Bệnh Nhân'**
  String get sacramentAnointing;

  /// No description provided for @sacramentFuneral.
  ///
  /// In vi, this message translates to:
  /// **'An Táng'**
  String get sacramentFuneral;

  /// No description provided for @sacramentBookNumber.
  ///
  /// In vi, this message translates to:
  /// **'Số sổ'**
  String get sacramentBookNumber;

  /// No description provided for @sacramentDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày cử hành'**
  String get sacramentDate;

  /// No description provided for @sacramentPlace.
  ///
  /// In vi, this message translates to:
  /// **'Nơi cử hành'**
  String get sacramentPlace;

  /// No description provided for @sacramentPriest.
  ///
  /// In vi, this message translates to:
  /// **'Cha cử hành'**
  String get sacramentPriest;

  /// No description provided for @sacramentBishop.
  ///
  /// In vi, this message translates to:
  /// **'Đức Giám mục'**
  String get sacramentBishop;

  /// No description provided for @sacramentGodfather.
  ///
  /// In vi, this message translates to:
  /// **'Cha đỡ đầu'**
  String get sacramentGodfather;

  /// No description provided for @sacramentGodmother.
  ///
  /// In vi, this message translates to:
  /// **'Mẹ đỡ đầu'**
  String get sacramentGodmother;

  /// No description provided for @sacramentSponsor.
  ///
  /// In vi, this message translates to:
  /// **'Người đỡ đầu'**
  String get sacramentSponsor;

  /// No description provided for @sacramentGroom.
  ///
  /// In vi, this message translates to:
  /// **'Chú rể'**
  String get sacramentGroom;

  /// No description provided for @sacramentBride.
  ///
  /// In vi, this message translates to:
  /// **'Cô dâu'**
  String get sacramentBride;

  /// No description provided for @sacramentWitness1.
  ///
  /// In vi, this message translates to:
  /// **'Người chứng 1'**
  String get sacramentWitness1;

  /// No description provided for @sacramentWitness2.
  ///
  /// In vi, this message translates to:
  /// **'Người chứng 2'**
  String get sacramentWitness2;

  /// No description provided for @sacramentDispensation.
  ///
  /// In vi, this message translates to:
  /// **'Miễn chuẩn'**
  String get sacramentDispensation;

  /// No description provided for @sacramentDeathCause.
  ///
  /// In vi, this message translates to:
  /// **'Nguyên nhân qua đời'**
  String get sacramentDeathCause;

  /// No description provided for @sacramentBurialPlace.
  ///
  /// In vi, this message translates to:
  /// **'Nơi an táng'**
  String get sacramentBurialPlace;

  /// No description provided for @sacramentPrintCertificate.
  ///
  /// In vi, this message translates to:
  /// **'In chứng chỉ'**
  String get sacramentPrintCertificate;

  /// No description provided for @groupTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đoàn thể'**
  String get groupTitle;

  /// No description provided for @groupName.
  ///
  /// In vi, this message translates to:
  /// **'Tên hội'**
  String get groupName;

  /// No description provided for @groupCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã'**
  String get groupCode;

  /// No description provided for @groupTypeConfraternity.
  ///
  /// In vi, this message translates to:
  /// **'Hội đoàn'**
  String get groupTypeConfraternity;

  /// No description provided for @groupTypeYouth.
  ///
  /// In vi, this message translates to:
  /// **'Giới trẻ'**
  String get groupTypeYouth;

  /// No description provided for @groupTypeChoir.
  ///
  /// In vi, this message translates to:
  /// **'Ca đoàn'**
  String get groupTypeChoir;

  /// No description provided for @groupTypePastoral.
  ///
  /// In vi, this message translates to:
  /// **'Mục vụ'**
  String get groupTypePastoral;

  /// No description provided for @groupTypeOther.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get groupTypeOther;

  /// No description provided for @groupHead.
  ///
  /// In vi, this message translates to:
  /// **'Trưởng hội'**
  String get groupHead;

  /// No description provided for @groupViceHead.
  ///
  /// In vi, this message translates to:
  /// **'Phó hội'**
  String get groupViceHead;

  /// No description provided for @groupMeetingSchedule.
  ///
  /// In vi, this message translates to:
  /// **'Lịch họp/sinh hoạt'**
  String get groupMeetingSchedule;

  /// No description provided for @massIntentionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lễ ý cầu nguyện'**
  String get massIntentionTitle;

  /// No description provided for @massIntentionRequester.
  ///
  /// In vi, this message translates to:
  /// **'Người xin'**
  String get massIntentionRequester;

  /// No description provided for @massIntentionText.
  ///
  /// In vi, this message translates to:
  /// **'Ý chỉ'**
  String get massIntentionText;

  /// No description provided for @massIntentionDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày dự kiến'**
  String get massIntentionDate;

  /// No description provided for @massIntentionStatusPending.
  ///
  /// In vi, this message translates to:
  /// **'Chờ duyệt'**
  String get massIntentionStatusPending;

  /// No description provided for @massIntentionStatusScheduled.
  ///
  /// In vi, this message translates to:
  /// **'Đã xếp lịch'**
  String get massIntentionStatusScheduled;

  /// No description provided for @massIntentionStatusDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã cử hành'**
  String get massIntentionStatusDone;

  /// No description provided for @massIntentionStatusCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Huỷ'**
  String get massIntentionStatusCancelled;

  /// No description provided for @donationTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sổ thu chi'**
  String get donationTitle;

  /// No description provided for @donationDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get donationDate;

  /// No description provided for @donationType.
  ///
  /// In vi, this message translates to:
  /// **'Loại'**
  String get donationType;

  /// No description provided for @donationTypeSundayOffering.
  ///
  /// In vi, this message translates to:
  /// **'Dâng cúng Chúa Nhật'**
  String get donationTypeSundayOffering;

  /// No description provided for @donationTypeFeastOffering.
  ///
  /// In vi, this message translates to:
  /// **'Dâng cúng lễ trọng'**
  String get donationTypeFeastOffering;

  /// No description provided for @donationTypeBuildingFund.
  ///
  /// In vi, this message translates to:
  /// **'Quỹ xây dựng'**
  String get donationTypeBuildingFund;

  /// No description provided for @donationTypeMassIntention.
  ///
  /// In vi, this message translates to:
  /// **'Xin lễ'**
  String get donationTypeMassIntention;

  /// No description provided for @donationTypeOtherIn.
  ///
  /// In vi, this message translates to:
  /// **'Thu khác'**
  String get donationTypeOtherIn;

  /// No description provided for @donationTypeExpense.
  ///
  /// In vi, this message translates to:
  /// **'Chi'**
  String get donationTypeExpense;

  /// No description provided for @donationAmount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền'**
  String get donationAmount;

  /// No description provided for @donationDonor.
  ///
  /// In vi, this message translates to:
  /// **'Người dâng'**
  String get donationDonor;

  /// No description provided for @reportTitle.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo thống kê'**
  String get reportTitle;

  /// No description provided for @reportByAge.
  ///
  /// In vi, this message translates to:
  /// **'Theo độ tuổi'**
  String get reportByAge;

  /// No description provided for @reportByGender.
  ///
  /// In vi, this message translates to:
  /// **'Theo giới tính'**
  String get reportByGender;

  /// No description provided for @reportByDistrict.
  ///
  /// In vi, this message translates to:
  /// **'Theo giáo họ'**
  String get reportByDistrict;

  /// No description provided for @reportSacramentByYear.
  ///
  /// In vi, this message translates to:
  /// **'Bí Tích theo năm'**
  String get reportSacramentByYear;

  /// No description provided for @reportExportPdf.
  ///
  /// In vi, this message translates to:
  /// **'Xuất PDF'**
  String get reportExportPdf;

  /// No description provided for @reportExportExcel.
  ///
  /// In vi, this message translates to:
  /// **'Xuất Excel'**
  String get reportExportExcel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

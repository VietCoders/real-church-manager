// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Parish Manager';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonClose => 'Close';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonEmpty => 'No data yet';

  @override
  String get commonError => 'An error occurred. Try again.';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonRequired => '(required)';

  @override
  String get commonOptional => '(optional)';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get navMembers => 'Parishioners';

  @override
  String get navFamilies => 'Families';

  @override
  String get navDistricts => 'Districts';

  @override
  String get navSacraments => 'Sacrament books';

  @override
  String get navGroups => 'Groups';

  @override
  String get navMass => 'Mass intentions';

  @override
  String get navCalendar => 'Liturgical calendar';

  @override
  String get navDonations => 'Donations';

  @override
  String get navReports => 'Reports';

  @override
  String get navSettings => 'Settings';

  @override
  String get authLoginTitle => 'Sign in';

  @override
  String get authIdentityLabel => 'Username';

  @override
  String get authIdentityHint => 'admin';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authLoginButton => 'Sign in';

  @override
  String get authLogoutButton => 'Sign out';

  @override
  String get authIdentityRequired => 'Username is required';

  @override
  String get authEmailRequired => 'Email is required';

  @override
  String get authPasswordRequired => 'Password is required';

  @override
  String get authLoginFailed => 'Login failed. Check username/password.';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get changePasswordHeading => 'Change password on first login';

  @override
  String get changePasswordDescription =>
      'For security, please change the default password before continuing.';

  @override
  String get changePasswordOldLabel => 'Current password';

  @override
  String get changePasswordNewLabel => 'New password';

  @override
  String get changePasswordConfirmLabel => 'Confirm new password';

  @override
  String get changePasswordRules =>
      'At least 6 characters, must differ from current password';

  @override
  String get changePasswordOldRequired => 'Current password required';

  @override
  String get changePasswordNewRequired => 'New password required';

  @override
  String get changePasswordConfirmRequired => 'Confirm password required';

  @override
  String get changePasswordTooShort =>
      'Password too short (minimum 6 characters)';

  @override
  String get changePasswordSameAsOld => 'New password must differ from current';

  @override
  String get changePasswordConfirmMismatch => 'Confirmation does not match';

  @override
  String get changePasswordSubmit => 'Update password';

  @override
  String get changePasswordSuccess => 'Password changed successfully';

  @override
  String get changePasswordFailed => 'Change failed. Check current password.';

  @override
  String get setupTitle => 'Connection setup';

  @override
  String get setupDescription =>
      'Enter the PocketBase server address of your parish. Example: http://192.168.1.100:8090 or https://parish.example.com';

  @override
  String get setupBackendUrlLabel => 'Server address';

  @override
  String get setupBackendUrlHint => 'http://127.0.0.1:8090';

  @override
  String get setupConnectButton => 'Connect';

  @override
  String get setupInvalidUrl => 'Invalid URL';

  @override
  String get memberListTitle => 'Parishioner list';

  @override
  String get memberAddTitle => 'Add parishioner';

  @override
  String get memberEditTitle => 'Edit parishioner';

  @override
  String get memberDetailTitle => 'Parishioner profile';

  @override
  String get memberSaintName => 'Saint name';

  @override
  String get memberFullName => 'Full name';

  @override
  String get memberGender => 'Gender';

  @override
  String get memberGenderMale => 'Male';

  @override
  String get memberGenderFemale => 'Female';

  @override
  String get memberGenderOther => 'Other';

  @override
  String get memberBirthDate => 'Date of birth';

  @override
  String get memberBirthPlace => 'Place of birth';

  @override
  String get memberDeathDate => 'Date of death';

  @override
  String get memberPhone => 'Phone';

  @override
  String get memberEmail => 'Email';

  @override
  String get memberAddress => 'Address';

  @override
  String get memberDistrict => 'District';

  @override
  String get memberFamily => 'Family';

  @override
  String get memberFather => 'Father\'s name';

  @override
  String get memberMother => 'Mother\'s name';

  @override
  String get memberSpouse => 'Spouse';

  @override
  String get memberPhoto => 'Photo';

  @override
  String get memberNotes => 'Notes';

  @override
  String get memberStatus => 'Status';

  @override
  String get memberStatusActive => 'Active';

  @override
  String get memberStatusMovedOut => 'Moved out';

  @override
  String get memberStatusDeceased => 'Deceased';

  @override
  String get memberDeleteConfirm => 'Are you sure to delete this parishioner?';

  @override
  String get memberSearchHint => 'Search by saint name, full name, phone...';

  @override
  String get sacramentBaptism => 'Baptism';

  @override
  String get sacramentConfirmation => 'Confirmation';

  @override
  String get sacramentMarriage => 'Marriage';

  @override
  String get sacramentAnointing => 'Anointing of the Sick';

  @override
  String get sacramentFuneral => 'Funeral';

  @override
  String get sacramentBookNumber => 'Book number';

  @override
  String get sacramentDate => 'Date';

  @override
  String get sacramentPlace => 'Place';

  @override
  String get sacramentPriest => 'Officiating priest';

  @override
  String get sacramentBishop => 'Bishop';

  @override
  String get sacramentGodfather => 'Godfather';

  @override
  String get sacramentGodmother => 'Godmother';

  @override
  String get sacramentSponsor => 'Sponsor';

  @override
  String get sacramentGroom => 'Groom';

  @override
  String get sacramentBride => 'Bride';

  @override
  String get sacramentWitness1 => 'Witness 1';

  @override
  String get sacramentWitness2 => 'Witness 2';

  @override
  String get sacramentDispensation => 'Dispensation';

  @override
  String get sacramentDeathCause => 'Cause of death';

  @override
  String get sacramentBurialPlace => 'Burial place';

  @override
  String get sacramentPrintCertificate => 'Print certificate';

  @override
  String get groupTitle => 'Groups';

  @override
  String get groupName => 'Group name';

  @override
  String get groupCode => 'Code';

  @override
  String get groupTypeConfraternity => 'Confraternity';

  @override
  String get groupTypeYouth => 'Youth';

  @override
  String get groupTypeChoir => 'Choir';

  @override
  String get groupTypePastoral => 'Pastoral';

  @override
  String get groupTypeOther => 'Other';

  @override
  String get groupHead => 'Head';

  @override
  String get groupViceHead => 'Vice head';

  @override
  String get groupMeetingSchedule => 'Meeting schedule';

  @override
  String get massIntentionTitle => 'Mass intentions';

  @override
  String get massIntentionRequester => 'Requester';

  @override
  String get massIntentionText => 'Intention';

  @override
  String get massIntentionDate => 'Scheduled date';

  @override
  String get massIntentionStatusPending => 'Pending';

  @override
  String get massIntentionStatusScheduled => 'Scheduled';

  @override
  String get massIntentionStatusDone => 'Done';

  @override
  String get massIntentionStatusCancelled => 'Cancelled';

  @override
  String get donationTitle => 'Donations';

  @override
  String get donationDate => 'Date';

  @override
  String get donationType => 'Type';

  @override
  String get donationTypeSundayOffering => 'Sunday offering';

  @override
  String get donationTypeFeastOffering => 'Feast offering';

  @override
  String get donationTypeBuildingFund => 'Building fund';

  @override
  String get donationTypeMassIntention => 'Mass intention';

  @override
  String get donationTypeOtherIn => 'Other income';

  @override
  String get donationTypeExpense => 'Expense';

  @override
  String get donationAmount => 'Amount';

  @override
  String get donationDonor => 'Donor';

  @override
  String get reportTitle => 'Reports';

  @override
  String get reportByAge => 'By age';

  @override
  String get reportByGender => 'By gender';

  @override
  String get reportByDistrict => 'By district';

  @override
  String get reportSacramentByYear => 'Sacraments by year';

  @override
  String get reportExportPdf => 'Export PDF';

  @override
  String get reportExportExcel => 'Export Excel';
}

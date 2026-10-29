import '../../../../core/network/api_exception.dart';

/// Signed-in student, parsed from the backend's `StudentMeResponse`
/// (DEC-010).
///
/// Mobile only uses a small identity slice for this feature (name,
/// student code, email, forcePasswordChange). Academic fields are
/// available for future screens; Home and Profile keep their fixture
/// rows until a later spec integrates the academic APIs.
class StudentUser {
  const StudentUser({
    required this.id,
    required this.studentCode,
    required this.universityEmail,
    required this.firstName,
    required this.lastName,
    required this.accountStatus,
    required this.forcePasswordChange,
    this.phoneNumber,
    this.facultyId,
    this.facultyCode,
    this.facultyNameEn,
    this.departmentId,
    this.departmentCode,
    this.departmentName,
    this.programId,
    this.programCode,
    this.programName,
    this.semesterId,
    this.semesterNameTh,
    this.semesterNameEn,
    this.academicYear,
    this.enrollmentYear,
    this.dateOfBirth,
  });

  final int id;
  final String studentCode;
  final String universityEmail;
  final String firstName;
  final String lastName;
  final String accountStatus;
  final bool forcePasswordChange;
  final String? phoneNumber;
  final int? facultyId;
  final String? facultyCode;
  final String? facultyNameEn;
  final int? departmentId;
  final String? departmentCode;
  final String? departmentName;
  final int? programId;
  final String? programCode;
  final String? programName;
  final int? semesterId;
  final String? semesterNameTh;
  final String? semesterNameEn;
  final int? academicYear;
  final int? enrollmentYear;
  final String? dateOfBirth;

  /// `First Last` with surrounding whitespace cleaned up. Falls back to
  /// an empty string when both are blank.
  String get fullName {
    final combined = '${firstName.trim()} ${lastName.trim()}';
    return combined.trim();
  }

  /// First character of [firstName], upper-cased, used as the avatar
  /// initial. Falls back to `?` when the name is blank.
  String get initial {
    final value = firstName.trim();
    if (value.isEmpty) return '?';
    // Use the Unicode scalar at the first rune so a multi-byte codepoint
    // (e.g. a Thai initial) is not split in half.
    final firstRune = value.runes.first;
    return String.fromCharCode(firstRune).toUpperCase();
  }

  factory StudentUser.fromJson(Map<String, dynamic> json) {
    try {
      return StudentUser(
        id: _requireInt(json, 'id'),
        studentCode: _requireString(json, 'studentCode'),
        universityEmail: _requireString(json, 'universityEmail'),
        firstName: _requireString(json, 'firstName'),
        lastName: _requireString(json, 'lastName'),
        accountStatus: _requireString(json, 'accountStatus'),
        forcePasswordChange: _requireBool(json, 'forcePasswordChange'),
        phoneNumber: _optionalString(json, 'phoneNumber'),
        facultyId: _optionalInt(json, 'facultyId'),
        facultyCode: _optionalString(json, 'facultyCode'),
        facultyNameEn: _optionalString(json, 'facultyNameEn'),
        departmentId: _optionalInt(json, 'departmentId'),
        departmentCode: _optionalString(json, 'departmentCode'),
        departmentName: _optionalString(json, 'departmentName'),
        programId: _optionalInt(json, 'programId'),
        programCode: _optionalString(json, 'programCode'),
        programName: _optionalString(json, 'programName'),
        semesterId: _optionalInt(json, 'semesterId'),
        semesterNameTh: _optionalString(json, 'semesterNameTh'),
        semesterNameEn: _optionalString(json, 'semesterNameEn'),
        academicYear: _optionalInt(json, 'academicYear'),
        enrollmentYear: _optionalInt(json, 'enrollmentYear'),
        dateOfBirth: _optionalString(json, 'dateOfBirth'),
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const MalformedResponseException();
    }
  }
}

String _requireString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) return value;
  throw const MalformedResponseException();
}

String? _optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  throw const MalformedResponseException();
}

int _requireInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw const MalformedResponseException();
}

int? _optionalInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw const MalformedResponseException();
}

bool _requireBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is bool) return value;
  throw const MalformedResponseException();
}

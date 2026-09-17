class MemberModel {
  final String id;
  final String publicId; // e.g. SFOF-2024-0891
  final String fullName;
  final String gender;
  final String dob;
  final String relationType; // S/O, D/O, W/O
  final String relationName;
  final String mobile;
  final String email;
  final String state;
  final String district;
  final String address;
  final String pinCode;
  final String occupation;
  final String qualification;
  final String aadharNumber;
  final String status; // 'Active', 'Verified', 'Pending'
  final DateTime registrationDate;
  final String? profilePhotoUrl;
  final String? bloodGroup;

  const MemberModel({
    required this.id,
    required this.publicId,
    required this.fullName,
    required this.gender,
    required this.dob,
    required this.relationType,
    required this.relationName,
    required this.mobile,
    required this.email,
    required this.state,
    required this.district,
    required this.address,
    required this.pinCode,
    required this.occupation,
    required this.qualification,
    required this.aadharNumber,
    required this.status,
    required this.registrationDate,
    this.profilePhotoUrl,
    this.bloodGroup,
  });

  String get maskedAadhar {
    if (aadharNumber.length >= 12) {
      return 'XXXX-XXXX-${aadharNumber.substring(aadharNumber.length - 4)}';
    }
    return aadharNumber;
  }
}

class DocumentModel {
  final String id;
  final String title;
  final String category;
  final String registrationOrDocNumber;
  final String issuingAuthority;
  final String description;
  final String assetPath;
  final String dateOfIssue;

  const DocumentModel({
    required this.id,
    required this.title,
    required this.category,
    required this.registrationOrDocNumber,
    required this.issuingAuthority,
    required this.description,
    required this.assetPath,
    required this.dateOfIssue,
  });
}

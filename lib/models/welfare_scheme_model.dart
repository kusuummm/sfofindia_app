class WelfareScheme {
  final String id;
  final String title;
  final String hindiTitle;
  final String issuingBody;
  final String category; // 'KSB Central', 'State Ex-Gratia', 'ECHS Healthcare', 'Concessions & Quotas'
  final String eligibility;
  final String financialBenefits;
  final List<String> nonFinancialBenefits;
  final List<String> requiredDocuments;
  final String applicationProcess;
  final String helplineContact;
  final String officialPortalUrl;

  const WelfareScheme({
    required this.id,
    required this.title,
    required this.hindiTitle,
    required this.issuingBody,
    required this.category,
    required this.eligibility,
    required this.financialBenefits,
    required this.nonFinancialBenefits,
    required this.requiredDocuments,
    required this.applicationProcess,
    required this.helplineContact,
    this.officialPortalUrl = 'https://ksb.gov.in',
  });
}

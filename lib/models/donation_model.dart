class DonationModel {
  final String id;
  final String donorName;
  final String donorEmail;
  final String donorPhone;
  final String? panNumber;
  final double amount;
  final String paymentMethod; // 'UPI', 'Bank Transfer', 'Card/Gateway'
  final String paymentStatus; // 'Completed', 'Pending', 'Verified'
  final DateTime date;
  final String? transactionRef;
  final String? receiptNumber;

  const DonationModel({
    required this.id,
    required this.donorName,
    required this.donorEmail,
    required this.donorPhone,
    this.panNumber,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.date,
    this.transactionRef,
    this.receiptNumber,
  });
}

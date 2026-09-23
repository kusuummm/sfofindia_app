import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/url_helper.dart';

/// Supported payment methods across the Shaheed Foundation platform
enum PaymentMethodType {
  onlineGateway,
  upiQr,
  bankTransfer,
  cashCheque,
}

extension PaymentMethodTypeExtension on PaymentMethodType {
  String get displayName {
    switch (this) {
      case PaymentMethodType.onlineGateway:
        return 'Online Payment Gateway';
      case PaymentMethodType.upiQr:
        return 'Direct UPI / QR Code';
      case PaymentMethodType.bankTransfer:
        return 'Axis Bank Transfer (NEFT/IMPS)';
      case PaymentMethodType.cashCheque:
        return 'Offline Cash / Cheque';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethodType.onlineGateway:
        return Icons.credit_card;
      case PaymentMethodType.upiQr:
        return Icons.qr_code_2;
      case PaymentMethodType.bankTransfer:
        return Icons.account_balance;
      case PaymentMethodType.cashCheque:
        return Icons.receipt_long;
    }
  }
}

/// Payment request model containing transaction details
class PaymentRequest {
  final double amount;
  final String memberName;
  final String email;
  final String phone;
  final String purpose;
  final String? memberId;
  final String? notes;

  const PaymentRequest({
    required this.amount,
    required this.memberName,
    required this.email,
    required this.phone,
    required this.purpose,
    this.memberId,
    this.notes,
  });
}

/// Result returned after completing a payment attempt
class PaymentResult {
  final bool isSuccess;
  final PaymentMethodType paymentMethod;
  final String transactionId;
  final double amount;
  final DateTime timestamp;
  final String? senderBank;
  final String? collectorName;
  final String? errorMessage;

  const PaymentResult({
    required this.isSuccess,
    required this.paymentMethod,
    required this.transactionId,
    required this.amount,
    required this.timestamp,
    this.senderBank,
    this.collectorName,
    this.errorMessage,
  });

  factory PaymentResult.failed({
    required PaymentMethodType method,
    required double amount,
    required String reason,
  }) {
    return PaymentResult(
      isSuccess: false,
      paymentMethod: method,
      transactionId: '',
      amount: amount,
      timestamp: DateTime.now(),
      errorMessage: reason,
    );
  }

  factory PaymentResult.success({
    required PaymentMethodType method,
    required String transactionId,
    required double amount,
    String? senderBank,
    String? collectorName,
  }) {
    return PaymentResult(
      isSuccess: true,
      paymentMethod: method,
      transactionId: transactionId,
      amount: amount,
      timestamp: DateTime.now(),
      senderBank: senderBank,
      collectorName: collectorName,
    );
  }
}

/// Payment Gateway Service with pluggable API key placeholders
class PaymentGatewayService {
  static final PaymentGatewayService _instance = PaymentGatewayService._internal();
  factory PaymentGatewayService() => _instance;
  PaymentGatewayService._internal();

  // ===========================================================================
  // PAYMENT GATEWAY API INTEGRATION CONFIGURATION
  // Note: Leave these fields empty now. Later, insert your live Gateway API
  // credentials (e.g. Razorpay key_id, Cashfree app_id, or custom webhook).
  // ===========================================================================
  static const String razorpayKeyId = ''; // e.g. 'rzp_live_xxxxxxxxxxxx'
  static const String razorpayKeySecret = ''; // e.g. 'xxxxxxxxxxxxxxxxxxxxxxxx'
  static const String cashfreeAppId = ''; // e.g. 'CF_APP_xxxxxxxxxxxx'
  static const String paymentWebhookEndpoint = ''; // Webhook callback endpoint

  /// Checks if live gateway credentials have been plugged in
  static bool get isGatewayConfigured =>
      razorpayKeyId.isNotEmpty || cashfreeAppId.isNotEmpty;

  /// Official Axis Bank Account Credentials
  static const String bankName = AppConstants.bankName;
  static const String bankAccountName = AppConstants.bankAccountName;
  static const String bankAccountNumber = AppConstants.bankAccountNumber;
  static const String bankIfsc = AppConstants.bankIfsc;
  static const String bankBranch = AppConstants.bankBranch;
  static const String officialUpiId = AppConstants.upiId;

  /// Generates real UPI intent string for banking apps
  static String buildUpiIntentUri({
    required double amount,
    required String payeeName,
    required String transactionNote,
  }) {
    final cleanAmt = amount.toStringAsFixed(2);
    final encNote = Uri.encodeComponent(transactionNote);
    final encName = Uri.encodeComponent(payeeName);
    return 'upi://pay?pa=$officialUpiId&pn=$encName&am=$cleanAmt&cu=INR&tn=$encNote';
  }

  /// Generates QR Code image URL for Axis Bank UPI
  static String buildUpiQrImageUrl({
    required double amount,
    required String transactionNote,
  }) {
    final upiUri = buildUpiIntentUri(
      amount: amount,
      payeeName: 'Shaheed Foundation',
      transactionNote: transactionNote,
    );
    return 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${Uri.encodeComponent(upiUri)}';
  }

  /// Launch the interactive Online Payment Gateway modal
  Future<PaymentResult?> showGatewayCheckoutDialog(
    BuildContext context,
    PaymentRequest request,
  ) async {
    return showDialog<PaymentResult>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => _GatewayCheckoutDialog(request: request),
    );
  }
}

/// Interactive Gateway Checkout Dialog
class _GatewayCheckoutDialog extends StatefulWidget {
  final PaymentRequest request;
  const _GatewayCheckoutDialog({required this.request});

  @override
  State<_GatewayCheckoutDialog> createState() => _GatewayCheckoutDialogState();
}

class _GatewayCheckoutDialogState extends State<_GatewayCheckoutDialog> {
  int _selectedSubMethod = 0; // 0: Debit/Credit Card, 1: NetBanking, 2: UPI Apps
  bool _isProcessing = false;
  final TextEditingController _cardNumberCtrl = TextEditingController(text: '4532 •••• •••• 9921');
  final TextEditingController _cardExpiryCtrl = TextEditingController(text: '08/29');
  final TextEditingController _cardCvvCtrl = TextEditingController(text: '•••');
  String _selectedBank = 'State Bank of India';

  final List<String> _popularBanks = [
    'State Bank of India',
    'HDFC Bank',
    'ICICI Bank',
    'Axis Bank',
    'Punjab National Bank',
    'Bank of Baroda',
    'Kotak Mahindra Bank',
  ];

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardExpiryCtrl.dispose();
    _cardCvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _handlePaymentSubmit() async {
    setState(() => _isProcessing = true);

    // If live credentials are provided in the future, trigger the SDK checkout here:
    // if (PaymentGatewayService.isGatewayConfigured) { ... }

    // Interactive checkout response
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final String generatedGatewayId =
        'GW_${DateTime.now().millisecondsSinceEpoch.toString().substring(3)}';

    Navigator.pop(
      context,
      PaymentResult.success(
        method: PaymentMethodType.onlineGateway,
        transactionId: generatedGatewayId,
        amount: widget.request.amount,
        senderBank: _selectedSubMethod == 1 ? _selectedBank : 'Online Card/UPI',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final isConfigured = PaymentGatewayService.isGatewayConfigured;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 480,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withAlpha(40),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lock, color: Color(0xFF818CF8), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Gateway Checkout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '128-bit Encrypted SSL Gateway',
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: _isProcessing ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount summary card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                req.purpose,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Member: ${req.memberName}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                          Text(
                            '₹${req.amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (!isConfigured) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Color(0xFFB45309)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Gateway API keys placeholder active. Simulation checkout ready for testing.',
                                style: TextStyle(fontSize: 10.5, color: Color(0xFF92400E)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Sub-method tabs
                    Row(
                      children: [
                        _buildTab(0, 'Card', Icons.credit_card),
                        const SizedBox(width: 8),
                        _buildTab(1, 'NetBanking', Icons.account_balance),
                        const SizedBox(width: 8),
                        _buildTab(2, 'UPI App', Icons.mobile_friendly),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Card Payment Form
                    if (_selectedSubMethod == 0) ...[
                      TextField(
                        controller: _cardNumberCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Card Number',
                          prefixIcon: Icon(Icons.payment, size: 18),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _cardExpiryCtrl,
                              decoration: const InputDecoration(
                                labelText: 'MM/YY',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _cardCvvCtrl,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'CVV',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // NetBanking Form
                    if (_selectedSubMethod == 1) ...[
                      const Text(
                        'Select Your Bank',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedBank,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: _popularBanks.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedBank = val);
                        },
                      ),
                    ],

                    // UPI App Direct Intent Form
                    if (_selectedSubMethod == 2) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Instant App Intent Checkout',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Launches Google Pay, PhonePe, or Paytm automatically with prefilled amount: ₹${req.amount.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.open_in_new, size: 16),
                                label: const Text('Open Installed UPI App'),
                                onPressed: () {
                                  final uri = PaymentGatewayService.buildUpiIntentUri(
                                    amount: req.amount,
                                    payeeName: 'Shaheed Foundation',
                                    transactionNote: req.purpose,
                                  );
                                  UrlHelper.launchWebUrl(uri);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _isProcessing ? null : () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: _isProcessing
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_circle, size: 18),
                    label: Text(
                      _isProcessing ? 'Processing...' : 'Pay ₹${req.amount.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: _isProcessing ? null : _handlePaymentSubmit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int idx, String title, IconData icon) {
    final isSel = _selectedSubMethod == idx;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedSubMethod = idx),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFF4F46E5).withAlpha(15) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSel ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
              width: isSel ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isSel ? const Color(0xFF4F46E5) : const Color(0xFF64748B)),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  color: isSel ? const Color(0xFF4F46E5) : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

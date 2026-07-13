/// Payout / payment destinations available in the app.
///
/// Covers the major Pakistani banks plus the two dominant mobile wallets
/// (EasyPaisa, JazzCash). Used by the tutor payout flow and the student
/// payment flow so both pick from the same canonical list.
library;

enum PayoutKind { bank, wallet }

class PayoutOption {
  final String name;
  final PayoutKind kind;

  const PayoutOption(this.name, this.kind);

  bool get isWallet => kind == PayoutKind.wallet;
}

/// Mobile wallets — these are identified by a phone number, not an IBAN.
const List<PayoutOption> kWallets = [
  PayoutOption('EasyPaisa', PayoutKind.wallet),
  PayoutOption('JazzCash', PayoutKind.wallet),
];

/// Pakistani banks (alphabetical). Identified by an account/IBAN number.
const List<PayoutOption> kPakistaniBanks = [
  PayoutOption('Allied Bank (ABL)', PayoutKind.bank),
  PayoutOption('Askari Bank', PayoutKind.bank),
  PayoutOption('Bank Alfalah', PayoutKind.bank),
  PayoutOption('Bank Al Habib', PayoutKind.bank),
  PayoutOption('BankIslami Pakistan', PayoutKind.bank),
  PayoutOption('Bank of Punjab (BOP)', PayoutKind.bank),
  PayoutOption('Dubai Islamic Bank', PayoutKind.bank),
  PayoutOption('Faysal Bank', PayoutKind.bank),
  PayoutOption('Habib Bank (HBL)', PayoutKind.bank),
  PayoutOption('Habib Metropolitan Bank', PayoutKind.bank),
  PayoutOption('JS Bank', PayoutKind.bank),
  PayoutOption('MCB Bank', PayoutKind.bank),
  PayoutOption('Meezan Bank', PayoutKind.bank),
  PayoutOption('National Bank of Pakistan (NBP)', PayoutKind.bank),
  PayoutOption('Silkbank', PayoutKind.bank),
  PayoutOption('Sindh Bank', PayoutKind.bank),
  PayoutOption('Soneri Bank', PayoutKind.bank),
  PayoutOption('Standard Chartered Pakistan', PayoutKind.bank),
  PayoutOption('Summit Bank', PayoutKind.bank),
  PayoutOption('United Bank (UBL)', PayoutKind.bank),
];

/// Full set (wallets first, then banks) for a single dropdown.
const List<PayoutOption> kAllPayoutOptions = [...kWallets, ...kPakistaniBanks];

PayoutOption? payoutOptionByName(String? name) {
  if (name == null) return null;
  for (final o in kAllPayoutOptions) {
    if (o.name == name) return o;
  }
  return null;
}

/// A payment channel a student can use to pay NextStepLearning, together with
/// the platform's receiving-account details for that channel.
class PaymentChannel {
  final String id;
  final String name;

  /// The account the student sends money TO (NextStepLearning's account).
  final String destinationLabel; // e.g. "Meezan Bank" / "EasyPaisa"
  final String destinationAccount; // account number / IBAN / wallet number
  final String destinationHolder; // account title

  /// Label for the student's own account/reference they enter.
  final String payerFieldLabel;

  /// True when the payer identifier is a phone number (10 digits).
  final bool payerIsPhone;

  const PaymentChannel({
    required this.id,
    required this.name,
    required this.destinationLabel,
    required this.destinationAccount,
    required this.destinationHolder,
    required this.payerFieldLabel,
    this.payerIsPhone = false,
  });
}

/// NextStepLearning's receiving accounts, shown to students at payment time.
/// Pakistan-only channels (no international card processor).
const List<PaymentChannel> kPaymentChannels = [
  PaymentChannel(
    id: 'easypaisa',
    name: 'Easypaisa',
    destinationLabel: 'EasyPaisa',
    destinationAccount: '0345 1234567',
    destinationHolder: 'NextStepLearning',
    payerFieldLabel: 'Your EasyPaisa Number',
    payerIsPhone: true,
  ),
  PaymentChannel(
    id: 'jazzcash',
    name: 'JazzCash',
    destinationLabel: 'JazzCash',
    destinationAccount: '0300 7654321',
    destinationHolder: 'NextStepLearning',
    payerFieldLabel: 'Your JazzCash Number',
    payerIsPhone: true,
  ),
  PaymentChannel(
    id: 'bank_transfer',
    name: 'Bank Transfer',
    destinationLabel: 'Meezan Bank',
    destinationAccount: 'PK36 MEZN 0000 1234 5678 9012',
    destinationHolder: 'NextStepLearning',
    payerFieldLabel: 'Your Account Number',
  ),
];

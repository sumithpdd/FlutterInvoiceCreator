class PaymentMethod {
  final String accountName;
  final String accountNumber;
  final String sortCode;

  PaymentMethod({
    required this.accountName,
    required this.accountNumber,
    required this.sortCode,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      accountName: json['accountName'] as String,
      accountNumber: json['accountNumber'] as String,
      sortCode: json['sortCode'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'accountName': accountName,
    'accountNumber': accountNumber,
    'sortCode': sortCode,
  };
}

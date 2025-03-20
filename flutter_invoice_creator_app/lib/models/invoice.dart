import 'company.dart';
import 'product.dart';
import 'payment_method.dart';

class Invoice {
  final String id;
  final String reference;
  final double amountDue;
  final String dueDate;
  final String issueDate;
  final String note;
  final CompanyDetails companyTo;
  final List<ProductItem> products;
  final PaymentMethod paymentMethod;

  Invoice({
    required this.id,
    required this.reference,
    required this.dueDate,
    required this.issueDate,
    required this.note,
    required this.companyTo,
    required this.products,
    required this.paymentMethod,
  }) : amountDue = products.fold(0, (sum, product) => sum + product.amount!);

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as String,
      reference: json['reference'] as String,
      dueDate: json['dueDate'] as String,
      issueDate: json['issueDate'] as String,
      note: json['note'] as String,
      companyTo: CompanyDetails.fromJson(
        json['companyTo'] as Map<String, dynamic>,
      ),
      products:
          (json['products'] as List)
              .map((p) => ProductItem.fromJson(p as Map<String, dynamic>))
              .toList(),
      paymentMethod: PaymentMethod.fromJson(
        json['paymentMethod'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reference': reference,
    'amountDue': amountDue,
    'dueDate': dueDate,
    'issueDate': issueDate,
    'note': note,
    'companyTo': companyTo.toJson(),
    'products': products.map((p) => p.toJson()).toList(),
    'paymentMethod': paymentMethod.toJson(),
  };
}

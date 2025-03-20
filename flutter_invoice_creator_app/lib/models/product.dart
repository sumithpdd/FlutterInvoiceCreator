class ProductItem {
  final String? description;
  final int? quantity;
  final String? unit;
  final double? unitCost;
  final double? discount;
  final double? amount;

  ProductItem({
    required this.description,
    required this.quantity,
    required this.unit,
    required this.unitCost,
    required this.discount,
    required this.amount,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      description: json['description'] as String,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
      unitCost: json['unitCost'] as double,
      discount: json['discount'] as double,
      amount: json['amount'] as double,
    );
  }

  Map<String, dynamic> toJson() => {
    'description': description,
    'quantity': quantity,
    'unit': unit,
    'unitCost': unitCost,
    'discount': discount,
    'amount': amount,
  };
}

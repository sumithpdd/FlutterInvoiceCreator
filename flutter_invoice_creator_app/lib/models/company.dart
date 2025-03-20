class CompanyDetails {
  final String name;
  final String? address;
  final String? email;
  final String? phone;
  final String? companyNo;

  CompanyDetails({
    required this.name,
    this.address,
    this.email,
    this.phone,
    this.companyNo,
  });

  factory CompanyDetails.fromJson(Map<String, dynamic> json) {
    return CompanyDetails(
      name: json['name'] as String,
      address: json['address'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      companyNo: json['companyNo'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'email': email,
    'phone': phone,
    'companyNo': companyNo,
  };
}

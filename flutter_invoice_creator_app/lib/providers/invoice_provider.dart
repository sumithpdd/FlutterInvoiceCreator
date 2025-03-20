import 'package:flutter/foundation.dart';
import '../models/invoice.dart';
import '../data/dummy_data.dart';

class InvoiceProvider with ChangeNotifier {
  List<Invoice> _invoices = [];

  List<Invoice> get invoices => _invoices;

  InvoiceProvider() {
    loadInvoices(); // Load data when provider initializes
  }

  void loadInvoices() {
    _invoices =
        (dummyData['invoices'] as List)
            .map<Invoice>((data) => Invoice.fromJson(data))
            .toList();
    notifyListeners();
  }

  Invoice getInvoiceById(String id) {
    return _invoices.firstWhere((invoice) => invoice.id == id);
  }

  void addInvoice(Invoice invoice) {
    _invoices.add(invoice);
    notifyListeners();
  }

  void updateInvoice(Invoice invoice) {
    final index = _invoices.indexWhere((inv) => inv.id == invoice.id);
    if (index != -1) {
      _invoices[index] = invoice;
      notifyListeners();
    }
  }
}

import 'package:flutter/foundation.dart';
import '../models/invoice.dart';

class InvoiceProvider with ChangeNotifier {
  List<Invoice> _invoices = [];

  List<Invoice> get invoices => _invoices;

  void addInvoice(Invoice invoice) {
    _invoices.add(invoice);
    notifyListeners();
  }
}

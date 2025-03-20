import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../providers/invoice_provider.dart';
import '../services/generate_pdf.dart';

class InvoicePreviewPage extends StatelessWidget {
  final String id;

  const InvoicePreviewPage({super.key, required this.id});

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  bool _hasDiscounts(List<ProductItem> products) {
    return products.any((product) => product.discount! > 0);
  }

  @override
  Widget build(BuildContext context) {
    final invoice = context.watch<InvoiceProvider>().getInvoiceById(id);
    final hasDiscounts = _hasDiscounts(invoice.products);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Invoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final pdfData = await generateInvoicePdf(invoice);
              // TODO: Display PDF preview
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section with INVOICE and Company Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Invoice and Issue Date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INVOICE',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Issue date: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: _formatDate(invoice.issueDate)),
                        ],
                      ),
                    ),
                  ],
                ),
                // Company Details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      invoice.companyTo.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (invoice.companyTo.address != null)
                      Text(invoice.companyTo.address!),
                    if (invoice.companyTo.email != null)
                      Text(invoice.companyTo.email!),
                    if (invoice.companyTo.phone != null)
                      Text(invoice.companyTo.phone!),
                    if (invoice.companyTo.companyNo != null)
                      Text('Company No: ${invoice.companyTo.companyNo}'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Invoice Details
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reference: ${invoice.reference}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Due Date: ${_formatDate(invoice.dueDate)}'),
                  Text(
                    'Amount Due: £${invoice.amountDue.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Products Table
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Products',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                      4: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        children: [
                          Text(
                            'Description',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Qty',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Unit',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Unit Cost',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                          Text(
                            'Amount',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                      ...invoice.products.map(
                        (product) => TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(product.description!),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                product.quantity.toString(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(product.unit!),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                '£${product.unitCost!.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '£${(product.quantity! * product.unitCost!).toStringAsFixed(2)}',
                                    textAlign: TextAlign.right,
                                  ),
                                  if (hasDiscounts && product.discount! > 0)
                                    Text(
                                      '- £${product.discount!.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      TableRow(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Text(''),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Text(''),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Text(''),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              'Total:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              '£${invoice.amountDue.toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Payment Methods
            Container(
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PAYMENT METHODS',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        children: [
                          Text(
                            'Account Name',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Account Number',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Sort Code',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Text(invoice.paymentMethod.accountName),
                          Text(invoice.paymentMethod.accountNumber),
                          Text(invoice.paymentMethod.sortCode),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

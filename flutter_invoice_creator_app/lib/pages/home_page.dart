import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/invoice_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Dashboard')),
      body: Row(
        children: [
          // Navigation Rail on the left side
          NavigationRail(
            selectedIndex: 0,
            onDestinationSelected: (int index) {
              if (index == 1) {
                context.push('/invoice-form');
              }
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add),
                label: Text('Create Invoice'),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<InvoiceProvider>(
                builder: (context, invoiceProvider, _) {
                  return ListView.builder(
                    itemCount: invoiceProvider.invoices.length,
                    itemBuilder: (context, index) {
                      final invoice = invoiceProvider.invoices[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            invoice.reference,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Amount Due: £${invoice.amountDue.toStringAsFixed(2)}',
                              ),
                              Text('Due Date: ${_formatDate(invoice.dueDate)}'),
                              Text('To: ${invoice.companyTo.name}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  context.push('/invoice-form/${invoice.id}');
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_red_eye),
                                onPressed: () {
                                  context.push(
                                    '/invoice-details/${invoice.id}',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

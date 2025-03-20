import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/invoice.dart';
import '../models/product.dart';
import '../models/company.dart';
import '../models/payment_method.dart';
import '../providers/invoice_provider.dart';

class InvoiceFormPage extends StatefulWidget {
  final String? invoiceId;

  const InvoiceFormPage({super.key, this.invoiceId});

  @override
  State<InvoiceFormPage> createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends State<InvoiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  late Invoice _invoice;
  bool _isEditing = false;
  final List<ProductItem> _products = [];
  bool _hasDiscount = false;

  // Controllers for form fields
  final _referenceController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _noteController = TextEditingController();

  // Company To controllers
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _companyEmailController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  final _companyNoController = TextEditingController();

  // Payment Method controllers
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _sortCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isEditing = widget.invoiceId != null;
    if (_isEditing) {
      _invoice = context.read<InvoiceProvider>().getInvoiceById(
        widget.invoiceId!,
      );
      _loadInvoiceData();
    }
    _setDefaultDates();
  }

  void _setDefaultDates() {
    if (!_isEditing) {
      final now = DateTime.now();
      _issueDateController.text = DateFormat('yyyy-MM-dd').format(now);
      _dueDateController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(now.add(const Duration(days: 30)));
    }
  }

  void _loadInvoiceData() {
    _referenceController.text = _invoice.reference;
    _dueDateController.text = _invoice.dueDate;
    _issueDateController.text = _invoice.issueDate;
    _noteController.text = _invoice.note;

    // Load company details
    _companyNameController.text = _invoice.companyTo.name;
    _companyAddressController.text = _invoice.companyTo.address ?? '';
    _companyEmailController.text = _invoice.companyTo.email ?? '';
    _companyPhoneController.text = _invoice.companyTo.phone ?? '';
    _companyNoController.text = _invoice.companyTo.companyNo ?? '';

    // Load payment method
    _accountNameController.text = _invoice.paymentMethod.accountName;
    _accountNumberController.text = _invoice.paymentMethod.accountNumber;
    _sortCodeController.text = _invoice.paymentMethod.sortCode;

    // Load products
    _products.addAll(_invoice.products);

    // Check if any product has discount
    _hasDiscount = _products.any((product) => product.discount! > 0);
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _addProduct() {
    showDialog(
      context: context,
      builder:
          (context) => ProductDialog(
            onSave: (product) {
              setState(() {
                _products.add(product);
              });
            },
            hasDiscount: _hasDiscount,
          ),
    );
  }

  void _editProduct(int index) {
    showDialog(
      context: context,
      builder:
          (context) => ProductDialog(
            product: _products[index],
            onSave: (product) {
              setState(() {
                _products[index] = product;
              });
            },
            hasDiscount: _hasDiscount,
          ),
    );
  }

  void _deleteProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  void _saveInvoice() {
    if (_formKey.currentState!.validate()) {
      final invoice = Invoice(
        id: _isEditing ? _invoice.id : DateTime.now().toString(),
        reference: _referenceController.text,
        dueDate: _dueDateController.text,
        issueDate: _issueDateController.text,
        note: _noteController.text,
        companyTo: CompanyDetails(
          name: _companyNameController.text,
          address: _companyAddressController.text,
          email: _companyEmailController.text,
          phone: _companyPhoneController.text,
          companyNo: _companyNoController.text,
        ),
        paymentMethod: PaymentMethod(
          accountName: _accountNameController.text,
          accountNumber: _accountNumberController.text,
          sortCode: _sortCodeController.text,
        ),
        products: List.from(_products),
      );

      final provider = context.read<InvoiceProvider>();
      if (_isEditing) {
        // Update existing invoice
        provider.updateInvoice(invoice);
      } else {
        // Add new invoice
        provider.addInvoice(invoice);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Invoice' : 'Create Invoice'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Invoice Details
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(labelText: 'Reference'),
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Dates
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _issueDateController,
                      decoration: const InputDecoration(
                        labelText: 'Issue Date',
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, _issueDateController),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _dueDateController,
                      decoration: const InputDecoration(labelText: 'Due Date'),
                      readOnly: true,
                      onTap: () => _selectDate(context, _dueDateController),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Company Details Section
              Text(
                'Company Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(labelText: 'Company Name'),
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _companyAddressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 2,
              ),
              TextFormField(
                controller: _companyEmailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _companyPhoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _companyNoController,
                decoration: const InputDecoration(labelText: 'Company Number'),
              ),
              const SizedBox(height: 24),

              // Products Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Products',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Row(
                    children: [
                      Text('Enable Discount'),
                      Switch(
                        value: _hasDiscount,
                        onChanged: (value) {
                          setState(() {
                            _hasDiscount = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return Card(
                    child: ListTile(
                      title: Text(product.description!),
                      subtitle: Text(
                        'Qty: ${product.quantity} × £${product.unitCost!.toStringAsFixed(2)} = £${(product.quantity! * product.unitCost!).toStringAsFixed(2)}' +
                            (_hasDiscount && product.discount! > 0
                                ? '\nDiscount: £${product.discount!.toStringAsFixed(2)}'
                                : ''),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editProduct(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteProduct(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _addProduct,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                ),
              ),
              const SizedBox(height: 24),

              // Payment Method Section
              Text(
                'Payment Method',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextFormField(
                controller: _accountNameController,
                decoration: const InputDecoration(labelText: 'Account Name'),
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _accountNumberController,
                decoration: const InputDecoration(labelText: 'Account Number'),
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _sortCodeController,
                decoration: const InputDecoration(labelText: 'Sort Code'),
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              // Note
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: _saveInvoice,
                  child: Text(_isEditing ? 'Update Invoice' : 'Create Invoice'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _dueDateController.dispose();
    _issueDateController.dispose();
    _noteController.dispose();
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companyEmailController.dispose();
    _companyPhoneController.dispose();
    _companyNoController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _sortCodeController.dispose();
    super.dispose();
  }
}

class ProductDialog extends StatefulWidget {
  final ProductItem? product;
  final Function(ProductItem) onSave;
  final bool hasDiscount;

  const ProductDialog({
    super.key,
    this.product,
    required this.onSave,
    required this.hasDiscount,
  });

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _discountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _descriptionController.text = widget.product!.description!;
      _quantityController.text = widget.product!.quantity.toString();
      _unitController.text = widget.product!.unit!;
      _unitCostController.text = widget.product!.unitCost.toString();
      _discountController.text = widget.product!.discount.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(labelText: 'Unit'),
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _unitCostController,
                decoration: const InputDecoration(labelText: 'Unit Cost'),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              if (widget.hasDiscount)
                TextFormField(
                  controller: _discountController,
                  decoration: const InputDecoration(labelText: 'Discount'),
                  keyboardType: TextInputType.number,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                ProductItem(
                  description: _descriptionController.text,
                  quantity: int.parse(_quantityController.text),
                  unit: _unitController.text,
                  unitCost: double.parse(_unitCostController.text),
                  discount:
                      widget.hasDiscount
                          ? double.tryParse(_discountController.text) ?? 0
                          : 0,
                  amount:
                      (int.parse(_quantityController.text) *
                          double.parse(_unitCostController.text)) -
                      (widget.hasDiscount
                          ? double.tryParse(_discountController.text) ?? 0
                          : 0),
                ),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _unitCostController.dispose();
    _discountController.dispose();
    super.dispose();
  }
}

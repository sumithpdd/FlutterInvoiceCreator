import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../pages/home_page.dart';
import '../pages/invoice_form_page.dart';
import '../pages/invoice_preview_page.dart';
import '../pages/invoice_details_page.dart';
import '../providers/invoice_provider.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    // Home Page Route
    GoRoute(path: '/', builder: (context, state) => const HomePage()),

    // Invoice Form Routes
    GoRoute(
      path: '/invoice-form',
      builder: (context, state) => const InvoiceFormPage(),
    ),
    GoRoute(
      path: '/invoice-form/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return InvoiceFormPage(invoiceId: id);
      },
    ),

    // Invoice Preview Route
    GoRoute(
      path: '/invoice-preview/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final invoice = Provider.of<InvoiceProvider>(
          context,
          listen: false,
        ).getInvoiceById(id);
        return InvoicePreviewPage(id: id);
      },
    ),

    // Invoice Details Route
    GoRoute(
      path: '/invoice-details/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return InvoiceDetailsPage(invoiceId: id);
      },
    ),
  ],
);

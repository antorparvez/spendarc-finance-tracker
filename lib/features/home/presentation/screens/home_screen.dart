import 'package:flutter/material.dart';

import '../../../finance_tracker/presentation/pages/finance_dashboard_page.dart';

/// Main SpendArc dashboard (finance tracker).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FinanceDashboardPage(embedded: true);
  }
}

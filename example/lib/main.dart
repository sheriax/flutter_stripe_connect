import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe_connect/flutter_stripe_connect.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

void main() {
  // Use path-based URL strategy for clean URLs (no # in the URL)
  usePathUrlStrategy();
  runApp(const MyApp());
}

/// Route paths matching the Next.js structure from WEBVIEW_INTEGRATION.md
/// These match the StripeConnectPaths class in the main package
class AppRoutes {
  // Home
  static const home = '/';

  // Onboarding & Compliance
  static const onboarding = '/onboarding';
  static const account = '/account';
  static const notifications = '/notifications';

  // Payments
  static const payments = '/payments';
  static const paymentDetails = '/payment-details';
  static const paymentMethods = '/payment-methods';
  static const disputes = '/disputes';
  static const dispute = '/dispute';

  // Payouts
  static const payouts = '/payouts';
  static const payoutDetails = '/payout-details';
  static const payoutsList = '/payouts-list';
  static const balances = '/balances';
  static const instantPayouts = '/instant-payouts';
  static const recipients = '/recipients';

  // Capital
  static const capital = '/capital';
  static const capitalApply = '/capital-apply';
  static const capitalPromo = '/capital-promo';

  // Tax
  static const taxRegistrations = '/tax-registrations';
  static const taxSettings = '/tax-settings';

  // Financial Services / Issuing
  static const financialAccount = '/financial-account';
  static const financialTxns = '/financial-txns';
  static const issuingCard = '/issuing-card';
  static const issuingCards = '/issuing-cards';

  // Reporting
  static const documents = '/documents';
  static const reporting = '/reporting';
}

// ============================================================================
// App State - Manages initialization state
// ============================================================================

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();
  AppState._();

  bool _isInitialized = false;
  bool _isLoading = true;
  String? _error;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      const String publishableKey =
          'pk_test_51S8VfeDNmGBmmekGKA8WYt57O1xg5xoefjAKMLrieoe2d539F5xUoWd4xRD0vRgyVppQjIr75pzAln5khchyIDmM00u9bSCJJf';

      await StripeConnect.instance.initialize(
        publishableKey: publishableKey,
        clientSecretProvider: _fetchClientSecret,
      );
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _fetchClientSecret() async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost:3000/account-session"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'accountId': 'acct_1SVw6YDZmxxyNwRz'}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Fetched client secret successfully');
        return data['client_secret'];
      } else {
        throw Exception(
          'Failed to fetch client secret: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching client secret: $e');
      rethrow;
    }
  }
}

// ============================================================================
// Router Configuration
// ============================================================================

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  refreshListenable: AppState.instance,
  routes: [
    // Home
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => HomePage(
        isInitialized: AppState.instance.isInitialized,
        isLoading: AppState.instance.isLoading,
        error: AppState.instance.error,
        onRetry: AppState.instance.initialize,
      ),
    ),

    // Onboarding & Compliance
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.account,
      builder: (context, state) => const AccountManagementScreen(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationBannerScreen(),
    ),

    // Payments
    GoRoute(
      path: AppRoutes.payments,
      builder: (context, state) => const PaymentsScreen(),
    ),
    GoRoute(
      path: AppRoutes.paymentDetails,
      builder: (context, state) {
        final paymentId = state.uri.queryParameters['id'];
        return PaymentDetailsScreen(paymentId: paymentId);
      },
    ),
    GoRoute(
      path: AppRoutes.disputes,
      builder: (context, state) => const DisputesListScreen(),
    ),

    // Payouts
    GoRoute(
      path: AppRoutes.payouts,
      builder: (context, state) => const PayoutsScreen(),
    ),
    GoRoute(
      path: AppRoutes.payoutDetails,
      builder: (context, state) {
        final payoutId = state.uri.queryParameters['id'];
        return PayoutDetailsScreen(payoutId: payoutId);
      },
    ),
    GoRoute(
      path: AppRoutes.payoutsList,
      builder: (context, state) => const PayoutsListScreen(),
    ),
    GoRoute(
      path: AppRoutes.balances,
      builder: (context, state) => const BalancesScreen(),
    ),

    // Tax
    GoRoute(
      path: AppRoutes.taxRegistrations,
      builder: (context, state) => const TaxRegistrationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.taxSettings,
      builder: (context, state) => const TaxSettingsScreen(),
    ),

    // Reporting
    GoRoute(
      path: AppRoutes.documents,
      builder: (context, state) => const DocumentsScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Route not found: ${state.uri}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);

// ============================================================================
// App Widget
// ============================================================================

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    AppState.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Stripe Connect Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}

// Home Page
class HomePage extends StatelessWidget {
  final bool isInitialized;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const HomePage({
    super.key,
    required this.isInitialized,
    required this.isLoading,
    this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Connect Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (kIsWeb)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: const Text('Web'),
                backgroundColor: Colors.green.shade100,
              ),
            ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!isInitialized) {
      return const Center(child: Text('Not initialized'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Main Components Section
        _buildSectionHeader(context, 'Onboarding & Compliance'),
        _buildCard(
          context,
          title: 'Account Onboarding',
          description: 'Collect required information from connected accounts',
          icon: Icons.person_add,
          route: AppRoutes.onboarding,
        ),
        _buildCard(
          context,
          title: 'Account Management',
          description: 'Let connected accounts manage their settings',
          icon: Icons.settings,
          route: AppRoutes.account,
          mobileNote: kIsWeb ? null : 'Limited on Android',
        ),
        _buildCard(
          context,
          title: 'Notification Banner',
          description: 'Show required actions for compliance',
          icon: Icons.notifications,
          route: AppRoutes.notifications,
        ),

        // Payments Section
        const SizedBox(height: 16),
        _buildSectionHeader(context, 'Payments'),
        _buildCard(
          context,
          title: 'Payments',
          description: 'View payment history',
          icon: Icons.payment,
          route: AppRoutes.payments,
        ),
        _buildCard(
          context,
          title: 'Disputes List',
          description: 'View and manage disputes',
          icon: Icons.gavel,
          route: AppRoutes.disputes,
        ),

        // Payouts Section
        const SizedBox(height: 16),
        _buildSectionHeader(context, 'Payouts'),
        _buildCard(
          context,
          title: 'Payouts',
          description: 'View and manage payouts',
          icon: Icons.account_balance,
          route: AppRoutes.payouts,
        ),
        _buildCard(
          context,
          title: 'Payouts List',
          description: 'Filterable list of payouts',
          icon: Icons.list_alt,
          route: AppRoutes.payoutsList,
        ),
        _buildCard(
          context,
          title: 'Balances',
          description: 'View balance information',
          icon: Icons.account_balance_wallet,
          route: AppRoutes.balances,
        ),

        // Tax Section (Web Only)
        if (kIsWeb) ...[
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Tax (Web Only)'),
          _buildCard(
            context,
            title: 'Tax Settings',
            description: 'Configure tax settings',
            icon: Icons.receipt_long,
            route: AppRoutes.taxSettings,
            webOnly: true,
          ),
          _buildCard(
            context,
            title: 'Tax Registrations',
            description: 'Manage tax registrations',
            icon: Icons.app_registration,
            route: AppRoutes.taxRegistrations,
            webOnly: true,
          ),
        ],

        // Reporting Section
        const SizedBox(height: 16),
        _buildSectionHeader(context, 'Reporting'),
        _buildCard(
          context,
          title: 'Documents',
          description: 'View available documents',
          icon: Icons.description,
          route: AppRoutes.documents,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required String route,
    bool webOnly = false,
    String? mobileNote,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          size: 36,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Row(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (webOnly) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Web', style: TextStyle(fontSize: 10)),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            if (mobileNote != null)
              Text(
                mobileNote,
                style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go(route),
      ),
    );
  }
}

// ============================================================================
// Component Screens - Each maps to a Next.js route
// ============================================================================

// /onboarding - Account Onboarding
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Onboarding'),
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
      ),
      body: StripeAccountOnboarding(
        onLoaded: () => debugPrint('Onboarding loaded'),
        onLoadError: (error) => _showError(context, error),
        onExit: () {
          debugPrint('User exited onboarding');
          context.go(AppRoutes.home);
        },
        appearance: const ConnectAppearance(
          colors: ConnectColors(primary: '#6366f1', background: '#ffffff'),
          cornerRadius: 8,
        ),
      ),
    );
  }
}

// /account - Account Management
class AccountManagementScreen extends StatelessWidget {
  const AccountManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Management'),
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
      ),
      body: StripeAccountManagement(
        onLoaded: () => debugPrint('Account management loaded'),
        onLoadError: (error) => _showError(context, error),
      ),
    );
  }
}

// /notifications - Notification Banner
class NotificationBannerScreen extends StatelessWidget {
  const NotificationBannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Banner'),
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 100,
            child: StripeNotificationBanner(
              onLoaded: () => debugPrint('Notification banner loaded'),
              onLoadError: (error) => _showError(context, error),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'The notification banner appears above when there are required actions.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// /payments - Payments
class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
      ),
      body: StripePayments(
        onLoaded: () => debugPrint('Payments loaded'),
        onLoadError: (error) => _showError(context, error),
      ),
    );
  }
}

// /payment-details - Payment Details
class PaymentDetailsScreen extends StatelessWidget {
  final String? paymentId;

  const PaymentDetailsScreen({super.key, this.paymentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
        leading: BackButton(onPressed: () => context.go(AppRoutes.payments)),
      ),
      body: paymentId != null
          ? StripePaymentDetails(
              paymentId: paymentId!,
              onLoaded: () => debugPrint('Payment details loaded'),
              onLoadError: (error) => _showError(context, error),
              onClose: () => context.go(AppRoutes.payments),
            )
          : const Center(child: Text('No payment ID provided')),
    );
  }
}

// /disputes - Disputes List
class DisputesListScreen extends StatelessWidget {
  const DisputesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disputes List'),
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
      ),
      body: StripeDisputesList(
        onLoaded: () => debugPrint('Disputes list loaded'),
        onLoadError: (error) => _showError(context, error),
      ),
    );
  }
}

// /payouts - Payouts
class PayoutsScreen extends StatelessWidget {
  const PayoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payouts'),
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
      ),
      body: StripePayouts(
        onLoaded: () => debugPrint('Payouts loaded'),
        onLoadError: (error) => _showError(context, error),
      ),
    );
  }
}

// /payout-details - Payout Details
class PayoutDetailsScreen extends StatelessWidget {
  final String? payoutId;

  const PayoutDetailsScreen({super.key, this.payoutId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payout Details'),
        leading: BackButton(onPressed: () => context.go(AppRoutes.payouts)),
      ),
      body: payoutId != null
          ? StripePayoutDetails(
              payoutId: payoutId!,
              onLoaded: () => debugPrint('Payout details loaded'),
              onLoadError: (error) => _showError(context, error),
              onClose: () => context.go(AppRoutes.payouts),
            )
          : const Center(child: Text('No payout ID provided')),
    );
  }
}

// /payouts-list - Payouts List
class PayoutsListScreen extends StatelessWidget {
  const PayoutsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payouts List'),
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
      ),
      body: StripePayoutsList(
        onLoaded: () => debugPrint('Payouts list loaded'),
        onLoadError: (error) => _showError(context, error),
      ),
    );
  }
}

// /balances - Balances
class BalancesScreen extends StatelessWidget {
  const BalancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balances'),
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
      ),
      body: StripeBalances(
        onLoaded: () => debugPrint('Balances loaded'),
        onLoadError: (error) => _showError(context, error),
      ),
    );
  }
}

// /tax-settings - Tax Settings (Web Only)
class TaxSettingsScreen extends StatelessWidget {
  const TaxSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Settings'),
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
      ),
      body: StripeTaxSettings(
        onLoaded: () => debugPrint('Tax settings loaded'),
        onLoadError: (error) => _showError(context, error),
      ),
    );
  }
}

// /tax-registrations - Tax Registrations (Web Only)
class TaxRegistrationsScreen extends StatelessWidget {
  const TaxRegistrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Registrations'),
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
      ),
      body: StripeTaxRegistrations(
        onLoaded: () => debugPrint('Tax registrations loaded'),
        onLoadError: (error) => _showError(context, error),
      ),
    );
  }
}

// /documents - Documents
class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
      ),
      body: StripeDocuments(
        onLoaded: () => debugPrint('Documents loaded'),
        onLoadError: (error) => _showError(context, error),
      ),
    );
  }
}

// ============================================================================
// Helpers
// ============================================================================

void _showError(BuildContext context, String error) {
  debugPrint('Component error: $error');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
  );
}

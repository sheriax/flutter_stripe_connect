import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe_connect/flutter_stripe_connect.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stripe Connect Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeStripeConnect();
  }

  Future<void> _initializeStripeConnect() async {
    try {
      // Update this to your Stripe publishable key
      const String publishableKey = 'pk_test_5******';

      await StripeConnect.instance.initialize(
        publishableKey: publishableKey,
        clientSecretProvider: _fetchClientSecret,
      );
      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Fetch client secret from your backend server
  Future<String> _fetchClientSecret() async {
    try {
      // Update this to your backend server URL
      final response = await http.post(
        Uri.parse("http://localhost:3000/account-session"),
        headers: {'Content-Type': 'application/json'},
        // Update this to your connected account ID
        body: jsonEncode({'accountId': 'acct_**********'}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Fetched client secret successfully');
        print(data);
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _initializeStripeConnect();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(child: Text('Not initialized'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Main Components Section
        _buildSectionHeader('Main Components'),
        _buildCard(
          title: 'Account Onboarding',
          description: 'Collect required information from connected accounts',
          icon: Icons.person_add,
          onTap: () => _navigateTo(const OnboardingScreen()),
        ),
        _buildCard(
          title: 'Account Management',
          description: 'Let connected accounts manage their settings',
          icon: Icons.settings,
          onTap: () => _navigateTo(const AccountManagementScreen()),
          webOnly: false,
          mobileNote: kIsWeb ? null : 'Limited on Android',
        ),
        _buildCard(
          title: 'Payments',
          description: 'View payment history',
          icon: Icons.payment,
          onTap: () => _navigateTo(const PaymentsScreen()),
        ),
        _buildCard(
          title: 'Payouts',
          description: 'View and manage payouts',
          icon: Icons.account_balance,
          onTap: () => _navigateTo(const PayoutsScreen()),
        ),

        // Additional Components Section
        const SizedBox(height: 16),
        _buildSectionHeader('Additional Components'),
        _buildCard(
          title: 'Balances',
          description: 'View balance information',
          icon: Icons.account_balance_wallet,
          onTap: () => _navigateTo(const BalancesScreen()),
        ),
        _buildCard(
          title: 'Notification Banner',
          description: 'Show required actions for compliance',
          icon: Icons.notifications,
          onTap: () => _navigateTo(const NotificationBannerScreen()),
        ),
        _buildCard(
          title: 'Documents',
          description: 'View available documents',
          icon: Icons.description,
          onTap: () => _navigateTo(const DocumentsScreen()),
        ),

        // Web-Only Components Section
        if (kIsWeb) ...[
          const SizedBox(height: 16),
          _buildSectionHeader('Web-Only Components'),
          _buildCard(
            title: 'Tax Settings',
            description: 'Configure tax settings',
            icon: Icons.receipt_long,
            onTap: () => _navigateTo(const TaxSettingsScreen()),
            webOnly: true,
          ),
          _buildCard(
            title: 'Tax Registrations',
            description: 'Manage tax registrations',
            icon: Icons.app_registration,
            onTap: () => _navigateTo(const TaxRegistrationsScreen()),
            webOnly: true,
          ),
        ],

        // Lists Section
        const SizedBox(height: 16),
        _buildSectionHeader('Lists & Details'),
        _buildCard(
          title: 'Disputes List',
          description: 'View and manage disputes',
          icon: Icons.gavel,
          onTap: () => _navigateTo(const DisputesListScreen()),
        ),
        _buildCard(
          title: 'Payouts List',
          description: 'Filterable list of payouts',
          icon: Icons.list_alt,
          onTap: () => _navigateTo(const PayoutsListScreen()),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
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

  Widget _buildCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
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
        onTap: onTap,
      ),
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

// Onboarding Screen
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Onboarding')),
      body: StripeAccountOnboarding(
        onLoaded: () => debugPrint('Onboarding loaded'),
        onLoadError: (error) => _showError(context, error),
        onExit: () {
          debugPrint('User exited onboarding');
          Navigator.pop(context);
        },
        appearance: const ConnectAppearance(
          colors: ConnectColors(primary: '#6366f1', background: '#ffffff'),
          cornerRadius: 8,
        ),
      ),
    );
  }
}

// Account Management Screen
class AccountManagementScreen extends StatelessWidget {
  const AccountManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Management')),
      body: StripeAccountManagement(
        onLoaded: () => debugPrint('Account management loaded'),
        onLoadError: (error) => _showError(context, error),
      ),
    );
  }
}

// Payouts Screen
class PayoutsScreen extends StatelessWidget {
  const PayoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payouts')),
      body: StripePayouts(
        onLoaded: () => debugPrint('Payouts loaded'),
        onLoadError: (error) => _showError(context, error),
      ),
    );
  }
}

// Payments Screen
class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: StripePayments(
        onLoaded: () => debugPrint('Payments loaded'),
        onLoadError: (error) => _showError(context, error),
      ),
    );
  }
}

// Balances Screen
class BalancesScreen extends StatelessWidget {
  const BalancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Balances')),
      body: StripeBalances(
        onLoaded: () => debugPrint('Balances loaded'),
        onLoadError: (error) => _showError(context, error),
      ),
    );
  }
}

// Notification Banner Screen
class NotificationBannerScreen extends StatelessWidget {
  const NotificationBannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Banner')),
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

// Documents Screen
class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      body: StripeDocuments(
        onLoaded: () => debugPrint('Documents loaded'),
        onLoadError: (error) => _showError(context, error),
      ),
    );
  }
}

// Tax Settings Screen (Web Only)
class TaxSettingsScreen extends StatelessWidget {
  const TaxSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tax Settings')),
      body: StripeTaxSettings(
        onLoaded: () => debugPrint('Tax settings loaded'),
        onLoadError: (error) => _showError(context, error),
      ),
    );
  }
}

// Tax Registrations Screen (Web Only)
class TaxRegistrationsScreen extends StatelessWidget {
  const TaxRegistrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tax Registrations')),
      body: StripeTaxRegistrations(
        onLoaded: () => debugPrint('Tax registrations loaded'),
        onLoadError: (error) => _showError(context, error),
      ),
    );
  }
}

// Disputes List Screen
class DisputesListScreen extends StatelessWidget {
  const DisputesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disputes List')),
      body: StripeDisputesList(
        onLoaded: () => debugPrint('Disputes list loaded'),
        onLoadError: (error) => _showError(context, error),
      ),
    );
  }
}

// Payouts List Screen
class PayoutsListScreen extends StatelessWidget {
  const PayoutsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payouts List')),
      body: StripePayoutsList(
        onLoaded: () => debugPrint('Payouts list loaded'),
        onLoadError: (error) => _showError(context, error),
      ),
    );
  }
}

void _showError(BuildContext context, String error) {
  debugPrint('Component error: $error');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
  );
}

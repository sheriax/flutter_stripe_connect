import 'dart:convert';
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
      await StripeConnect.instance.initialize(
        // 'pk_live_your_publishable_key' or 'pk_test_your_publishable_key'
        publishableKey: 'pk_test_your_publishable_key',
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
  /// Your server should create an Account Session and return the client_secret
  Future<String> _fetchClientSecret() async {
    // Replace with your actual backend endpoint
    final response = await http.post(
      Uri.parse('https://your-backend.com/api/stripe/account-session'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'account': 'acct_connected_account_id', // The connected account ID
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['client_secret']; // 'acct_sess_XXX_secret_XXX'
    } else {
      throw Exception('Failed to fetch client secret');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Connect Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading || !_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeStripeConnect,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
        ),
        _buildCard(
          title: 'Payouts',
          description: 'View and manage payouts',
          icon: Icons.account_balance,
          onTap: () => _navigateTo(const PayoutsScreen()),
        ),
        _buildCard(
          title: 'Payments',
          description: 'View payment history',
          icon: Icons.payment,
          onTap: () => _navigateTo(const PaymentsScreen()),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
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

void _showError(BuildContext context, String error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
  );
}

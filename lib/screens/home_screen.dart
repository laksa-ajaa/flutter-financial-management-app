import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../utils/theme.dart';

import '../widgets/transaction_list.dart';
import '../widgets/monthly_summary.dart';

import 'add_transaction_screen.dart';
import 'ai_assistant_screen.dart';
import 'reports_screen.dart';
import 'debug_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isInit = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _loadData();
      _isInit = false;
    }
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Wait for auth state to be determined
    if (!authProvider.isAuth) {
      await authProvider.checkAuthState();
    }

    if (!authProvider.isAuth) {
      return; // User not authenticated
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = authProvider.userId;
      print('Loading data for userId: $userId'); // Debug log

      // Load categories first, then transactions
      await Provider.of<CategoryProvider>(
        context,
        listen: false,
      ).fetchCategories(userId);

      await Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).fetchTransactions(userId);

      print('Data loaded successfully'); // Debug log
    } catch (error) {
      print('Error loading data: $error'); // Debug log
      setState(() {
        _errorMessage = error.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data. Tap debug button for details.'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Debug',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const DebugScreen()),
                );
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _signOut() async {
    // Clear data before signing out
    Provider.of<TransactionProvider>(
      context,
      listen: false,
    ).clearTransactions();
    Provider.of<CategoryProvider>(context, listen: false).clearCategories();

    await Provider.of<AuthProvider>(context, listen: false).signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Manajer Keuangan'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.bug_report,
              color: _errorMessage != null ? Colors.red : null,
            ),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (ctx) => const DebugScreen()));
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(icon: const Icon(Icons.exit_to_app), onPressed: _signOut),
        ],
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memuat data...'),
                  ],
                ),
              )
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Terjadi masalah saat memuat data. Silakan coba lagi atau gunakan debug screen untuk informasi lebih lanjut.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => const DebugScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.bug_report),
                          label: const Text('Debug'),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'Asisten AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Laporan',
          ),
        ],
        elevation: 8,
      ),
      // FAB hanya muncul di halaman beranda (index 0)
      floatingActionButton:
          _selectedIndex == 0 && _errorMessage == null
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const AddTransactionScreen(),
                    ),
                  );
                },
                child: const Icon(Icons.add),
                elevation: 4,
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              children: const [
                MonthlySummary(),
                SizedBox(height: 16),
                TransactionList(),
                // Add extra space at bottom for FAB
                SizedBox(height: 80),
              ],
            ),
          ),
        );
      case 1:
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: const AiAssistantScreen(),
        );
      case 2:
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: const ReportsScreen(),
        );
      default:
        return const Center(child: Text('Terjadi kesalahan'));
    }
  }
}

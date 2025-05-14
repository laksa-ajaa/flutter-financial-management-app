import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';

import '../widgets/transaction_list.dart';
import '../widgets/monthly_summary.dart';

import 'add_transaction_screen.dart';
import 'categories_screen.dart';
import 'reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      final userId = Provider.of<AuthProvider>(context, listen: false).userId;

      Future.wait([
            Provider.of<CategoryProvider>(
              context,
              listen: false,
            ).fetchCategories(userId),
            Provider.of<TransactionProvider>(
              context,
              listen: false,
            ).fetchTransactions(userId),
          ])
          .then((_) {
            setState(() {
              _isLoading = false;
            });
          })
          .catchError((error) {
            // Optional: handle error
            setState(() {
              _isLoading = false;
            });
          });

      _isInit = false;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _signOut() {
    Provider.of<AuthProvider>(context, listen: false).signOut();
    // Optional: navigate to login screen after sign out
    // Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Manager'),
        actions: [
          IconButton(icon: const Icon(Icons.exit_to_app), onPressed: _signOut),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return SingleChildScrollView(
          child: Column(
            children: const [
              MonthlySummary(),
              SizedBox(height: 16),
              TransactionList(),
            ],
          ),
        );
      case 1:
        return const CategoriesScreen();
      case 2:
        return const ReportsScreen();
      default:
        return const Center(child: Text('Something went wrong'));
    }
  }
}

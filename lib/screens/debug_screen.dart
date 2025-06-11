import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({Key? key}) : super(key: key);

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String _debugInfo = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _checkFirestoreConnection,
                  child: const Text('Check Connection'),
                ),
                ElevatedButton(
                  onPressed: _checkUserData,
                  child: const Text('Check User Data'),
                ),
                ElevatedButton(
                  onPressed: _reloadData,
                  child: const Text('Reload Data'),
                ),
                ElevatedButton(
                  onPressed: _testSimpleQuery,
                  child: const Text('Test Simple Query'),
                ),
                ElevatedButton(
                  onPressed: _createTestData,
                  child: const Text('Create Test Data'),
                ),
                ElevatedButton(
                  onPressed: _clearDebugInfo,
                  child: const Text('Clear Log'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const LinearProgressIndicator()
            else
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _debugInfo.isEmpty
                          ? 'No debug info yet. Click a button above to start.'
                          : _debugInfo,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _clearDebugInfo() {
    setState(() {
      _debugInfo = '';
    });
  }

  Future<void> _checkFirestoreConnection() async {
    setState(() {
      _isLoading = true;
      _debugInfo += '\n=== CHECKING FIRESTORE CONNECTION ===\n';
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // Test basic connection
      final testCollection = firestore.collection('test');
      await testCollection.doc('connection-test').set({
        'timestamp': FieldValue.serverTimestamp(),
        'test': true,
      });

      setState(() {
        _debugInfo += '✅ Firestore connection: OK\n';
        _debugInfo += '✅ Write test: SUCCESS\n';
      });

      // Test read
      final doc = await testCollection.doc('connection-test').get();
      setState(() {
        _debugInfo += '✅ Read test: SUCCESS\n';
        _debugInfo += 'Document exists: ${doc.exists}\n';
      });

      // Clean up test document
      await testCollection.doc('connection-test').delete();
      setState(() {
        _debugInfo += '✅ Cleanup: SUCCESS\n';
      });
    } catch (e) {
      setState(() {
        _debugInfo += '❌ Firestore connection error: $e\n';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testSimpleQuery() async {
    setState(() {
      _isLoading = true;
      _debugInfo += '\n=== TESTING SIMPLE QUERY ===\n';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;

      setState(() {
        _debugInfo += 'Testing with userId: $userId\n';
      });

      if (userId.isEmpty) {
        setState(() {
          _debugInfo += '❌ No user ID available\n';
        });
        return;
      }

      // Test 1: Simple query without orderBy
      setState(() {
        _debugInfo += '\nTest 1: Simple query without orderBy\n';
      });

      final simpleQuery =
          await FirebaseFirestore.instance
              .collection('transactions')
              .where('userId', isEqualTo: userId)
              .get();

      setState(() {
        _debugInfo +=
            '✅ Simple query result: ${simpleQuery.docs.length} documents\n';
      });

      // Test 2: Query with limit
      setState(() {
        _debugInfo += '\nTest 2: Query with limit\n';
      });

      final limitedQuery =
          await FirebaseFirestore.instance
              .collection('transactions')
              .where('userId', isEqualTo: userId)
              .limit(5)
              .get();

      setState(() {
        _debugInfo +=
            '✅ Limited query result: ${limitedQuery.docs.length} documents\n';
      });

      // Show sample data
      if (simpleQuery.docs.isNotEmpty) {
        setState(() {
          _debugInfo += '\nSample documents:\n';
        });

        for (int i = 0; i < simpleQuery.docs.length && i < 3; i++) {
          final doc = simpleQuery.docs[i];
          final data = doc.data();
          setState(() {
            _debugInfo += 'Doc ${i + 1}: ${doc.id}\n';
            _debugInfo += '  name: ${data['name']}\n';
            _debugInfo += '  amount: ${data['amount']}\n';
            _debugInfo += '  type: ${data['type']}\n';
            _debugInfo += '  userId: ${data['userId']}\n';
          });
        }
      }
    } catch (e) {
      setState(() {
        _debugInfo += '❌ Query error: $e\n';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _createTestData() async {
    setState(() {
      _isLoading = true;
      _debugInfo += '\n=== CREATING TEST DATA ===\n';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;

      if (userId.isEmpty) {
        setState(() {
          _debugInfo += '❌ No user ID available\n';
        });
        return;
      }

      // Create a test transaction
      final testTransaction = {
        'name': 'Test Transaction',
        'amount': 50000,
        'type': 'expense',
        'categoryId': 'test-category',
        'date': Timestamp.now(),
        'note': 'Created by debug screen',
        'userId': userId,
      };

      final docRef = await FirebaseFirestore.instance
          .collection('transactions')
          .add(testTransaction);

      setState(() {
        _debugInfo += '✅ Test transaction created with ID: ${docRef.id}\n';
        _debugInfo += 'Data: $testTransaction\n';
      });

      // Verify it was created
      final doc = await docRef.get();
      setState(() {
        _debugInfo += '✅ Verification: Document exists = ${doc.exists}\n';
      });
    } catch (e) {
      setState(() {
        _debugInfo += '❌ Error creating test data: $e\n';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkUserData() async {
    setState(() {
      _isLoading = true;
      _debugInfo += '\n=== CHECKING USER DATA ===\n';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;

      setState(() {
        _debugInfo += 'User ID: $userId\n';
        _debugInfo += 'Is authenticated: ${authProvider.isAuth}\n';
      });

      if (userId.isNotEmpty) {
        // Check transactions
        final transactionsSnapshot =
            await FirebaseFirestore.instance
                .collection('transactions')
                .where('userId', isEqualTo: userId)
                .get();

        setState(() {
          _debugInfo += '\n📊 TRANSACTIONS:\n';
          _debugInfo +=
              'Found: ${transactionsSnapshot.docs.length} documents\n';
        });

        for (int i = 0; i < transactionsSnapshot.docs.length && i < 5; i++) {
          final doc = transactionsSnapshot.docs[i];
          final data = doc.data();
          setState(() {
            _debugInfo += '\nTransaction ${i + 1} (${doc.id}):\n';
            _debugInfo += '  name: ${data['name']}\n';
            _debugInfo += '  amount: ${data['amount']}\n';
            _debugInfo += '  type: ${data['type']}\n';
            _debugInfo += '  date: ${data['date']}\n';
          });
        }

        // Check categories
        final categoriesSnapshot =
            await FirebaseFirestore.instance
                .collection('categories')
                .where('userId', isEqualTo: userId)
                .get();

        setState(() {
          _debugInfo += '\n📁 CATEGORIES:\n';
          _debugInfo += 'Found: ${categoriesSnapshot.docs.length} documents\n';
        });

        for (int i = 0; i < categoriesSnapshot.docs.length && i < 5; i++) {
          final doc = categoriesSnapshot.docs[i];
          final data = doc.data();
          setState(() {
            _debugInfo += '\nCategory ${i + 1} (${doc.id}):\n';
            _debugInfo += '  name: ${data['name']}\n';
            _debugInfo += '  type: ${data['type']}\n';
          });
        }
      }
    } catch (e) {
      setState(() {
        _debugInfo += '❌ Error checking user data: $e\n';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _reloadData() async {
    setState(() {
      _isLoading = true;
      _debugInfo += '\n=== RELOADING ALL DATA ===\n';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final transactionProvider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );

      final userId = authProvider.userId;

      if (userId.isNotEmpty) {
        setState(() {
          _debugInfo += 'Reloading categories...\n';
        });

        await categoryProvider.fetchCategories(userId);

        setState(() {
          _debugInfo +=
              '✅ Categories loaded: ${categoryProvider.categories.length}\n';
          _debugInfo += 'Reloading transactions...\n';
        });

        await transactionProvider.fetchTransactions(userId);

        setState(() {
          _debugInfo +=
              '✅ Transactions loaded: ${transactionProvider.transactions.length}\n';
          _debugInfo += '\n🎉 Data reload completed successfully!\n';
        });
      } else {
        setState(() {
          _debugInfo += '❌ No user ID available\n';
        });
      }
    } catch (e) {
      setState(() {
        _debugInfo += '❌ Error reloading data: $e\n';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/transaction.dart' as model;

class TransactionProvider with ChangeNotifier {
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;
  List<model.Transaction> _transactions = [];

  List<model.Transaction> get transactions => [..._transactions];

  List<model.Transaction> getTransactionsByMonth(int year, int month) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    return _transactions
        .where((tx) => tx.date.isAfter(startDate) && tx.date.isBefore(endDate))
        .toList();
  }

  List<model.Transaction> getTransactionsByDay(DateTime date) {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _transactions
        .where((tx) => tx.date.isAfter(startDate) && tx.date.isBefore(endDate))
        .toList();
  }

  double getTotalIncomeByMonth(int year, int month) {
    final monthTransactions = getTransactionsByMonth(year, month);
    return monthTransactions
        .where((tx) => tx.type == model.TransactionType.income)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double getTotalExpenseByMonth(int year, int month) {
    final monthTransactions = getTransactionsByMonth(year, month);
    return monthTransactions
        .where((tx) => tx.type == model.TransactionType.expense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  Map<String, double> getExpensesByCategory(int year, int month) {
    final monthTransactions = getTransactionsByMonth(year, month);
    final expensesByCategory = <String, double>{};

    for (final tx in monthTransactions) {
      if (tx.type == model.TransactionType.expense) {
        if (expensesByCategory.containsKey(tx.categoryId)) {
          expensesByCategory[tx.categoryId] =
              expensesByCategory[tx.categoryId]! + tx.amount;
        } else {
          expensesByCategory[tx.categoryId] = tx.amount;
        }
      }
    }

    return expensesByCategory;
  }

  Future<void> fetchTransactions(String userId) async {
    try {
      print('Fetching transactions for userId: $userId'); // Debug log

      // Option 1: Fetch without orderBy first, then sort in memory
      final snapshot =
          await _firestore
              .collection('transactions')
              .where('userId', isEqualTo: userId)
              .get(); // Remove orderBy to avoid index requirement

      print('Found ${snapshot.docs.length} transactions'); // Debug log

      _transactions =
          snapshot.docs
              .map((doc) {
                try {
                  return model.Transaction.fromFirestore(doc);
                } catch (e) {
                  print('Error parsing transaction ${doc.id}: $e'); // Debug log
                  return null;
                }
              })
              .where((tx) => tx != null)
              .cast<model.Transaction>()
              .toList();

      // Sort in memory instead of using orderBy in query
      _transactions.sort((a, b) => b.date.compareTo(a.date));

      print(
        'Successfully parsed ${_transactions.length} transactions',
      ); // Debug log

      notifyListeners();
    } catch (e) {
      print('Error fetching transactions: $e'); // Debug log

      // Fallback: Try alternative query method
      try {
        print('Trying alternative query method...'); // Debug log
        await _fetchTransactionsAlternative(userId);
      } catch (e2) {
        print('Alternative query also failed: $e2'); // Debug log
        rethrow;
      }
    }
  }

  // Alternative method using pagination or different query structure
  Future<void> _fetchTransactionsAlternative(String userId) async {
    try {
      // Method 1: Use limit and multiple queries if needed
      final snapshot =
          await _firestore
              .collection('transactions')
              .where('userId', isEqualTo: userId)
              .limit(100) // Limit to avoid large queries
              .get();

      _transactions =
          snapshot.docs
              .map((doc) {
                try {
                  return model.Transaction.fromFirestore(doc);
                } catch (e) {
                  print('Error parsing transaction ${doc.id}: $e');
                  return null;
                }
              })
              .where((tx) => tx != null)
              .cast<model.Transaction>()
              .toList();

      // Sort in memory
      _transactions.sort((a, b) => b.date.compareTo(a.date));

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Method to fetch transactions with date range (more efficient)
  Future<void> fetchTransactionsByDateRange(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('Fetching transactions by date range for userId: $userId');

      var query = _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId);

      // Add date filters if provided
      if (startDate != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: firestore.Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'date',
          isLessThanOrEqualTo: firestore.Timestamp.fromDate(endDate),
        );
      }

      final snapshot = await query.get();

      _transactions =
          snapshot.docs
              .map((doc) {
                try {
                  return model.Transaction.fromFirestore(doc);
                } catch (e) {
                  print('Error parsing transaction ${doc.id}: $e');
                  return null;
                }
              })
              .where((tx) => tx != null)
              .cast<model.Transaction>()
              .toList();

      // Sort in memory
      _transactions.sort((a, b) => b.date.compareTo(a.date));

      notifyListeners();
    } catch (e) {
      print('Error fetching transactions by date range: $e');
      rethrow;
    }
  }

  Future<void> addTransaction(model.Transaction transaction) async {
    try {
      final docRef = await _firestore
          .collection('transactions')
          .add(transaction.toMap());

      _transactions.add(transaction.copyWith(id: docRef.id));
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTransaction(model.Transaction transaction) async {
    try {
      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .update(transaction.toMap());

      final index = _transactions.indexWhere((tx) => tx.id == transaction.id);
      if (index >= 0) {
        _transactions[index] = transaction;
        _transactions.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection('transactions').doc(transactionId).delete();

      _transactions.removeWhere((tx) => tx.id == transactionId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Method to clear transactions (useful for logout)
  void clearTransactions() {
    _transactions.clear();
    notifyListeners();
  }

  // Method to refresh data
  Future<void> refreshTransactions(String userId) async {
    _transactions.clear();
    await fetchTransactions(userId);
  }
}

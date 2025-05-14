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
      final snapshot =
          await _firestore
              .collection('transactions')
              .where('userId', isEqualTo: userId)
              .orderBy('date', descending: true)
              .get();

      _transactions =
          snapshot.docs
              .map((doc) => model.Transaction.fromFirestore(doc))
              .toList();

      notifyListeners();
    } catch (e) {
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
}

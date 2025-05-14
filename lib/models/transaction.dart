import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String name;
  final String categoryId;
  final double amount;
  final DateTime date;
  final String note;
  final TransactionType type;
  final String userId;

  Transaction({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.amount,
    required this.date,
    required this.note,
    required this.type,
    required this.userId,
  });

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      name: data['name'] ?? '',
      categoryId: data['categoryId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'] ?? '',
      type: data['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categoryId': categoryId,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'note': note,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'userId': userId,
    };
  }

  Transaction copyWith({
    String? id,
    String? name,
    String? categoryId,
    double? amount,
    DateTime? date,
    String? note,
    TransactionType? type,
    String? userId,
  }) {
    return Transaction(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      type: type ?? this.type,
      userId: userId ?? this.userId,
    );
  }
}

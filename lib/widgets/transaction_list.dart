import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart' as model;
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../screens/add_transaction_screen.dart';
import '../utils/theme.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({Key? key}) : super(key: key);

  String _getIndonesianDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (_isSameDay(date, now)) {
      return 'Hari Ini';
    } else if (_isSameDay(date, yesterday)) {
      return 'Kemarin';
    } else {
      final days = [
        'Minggu',
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
      ];
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];

      final dayName = days[date.weekday % 7];
      final monthName = months[date.month - 1];

      return '$dayName, ${date.day} $monthName ${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final transactions = transactionProvider.transactions;

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Belum ada transaksi!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan transaksi pertama Anda dengan menekan tombol +.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const AddTransactionScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Transaksi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Group transactions by date
    final groupedTransactions = <DateTime, List<model.Transaction>>{};
    for (final tx in transactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      groupedTransactions.putIfAbsent(date, () => []).add(tx);
    }

    // Sort dates in descending order
    final sortedDates =
        groupedTransactions.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedDates.length,
      itemBuilder: (ctx, index) {
        final date = sortedDates[index];
        final dayTransactions = groupedTransactions[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getIndonesianDate(date),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...dayTransactions.map((tx) {
              late final category;
              try {
                category = categoryProvider.getCategoryById(tx.categoryId);
              } catch (_) {
                return const SizedBox.shrink(); // Skip unknown category
              }

              return Dismissible(
                key: Key(tx.id),
                background: Container(
                  color: Colors.red.shade400,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) {
                  return showDialog(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: const Text('Hapus Transaksi'),
                          content: const Text(
                            'Apakah Anda yakin ingin menghapus transaksi ini?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Hapus'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                  );
                },
                onDismissed:
                    (_) => transactionProvider.deleteTransaction(tx.id),
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      tx.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      tx.note.isNotEmpty ? tx.note : category.name,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat.currency(
                            locale: 'id',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(tx.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                tx.type == model.TransactionType.income
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat.Hm().format(tx.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (ctx) => AddTransactionScreen(transaction: tx),
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

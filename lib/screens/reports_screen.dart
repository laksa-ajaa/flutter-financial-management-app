import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../models/transaction.dart';
import '../utils/theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _selectedMonth = DateTime.now();

  String _getIndonesianMonthYear(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    final totalIncome = transactionProvider.getTotalIncomeByMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );

    final totalExpense = transactionProvider.getTotalExpenseByMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );

    final expensesByCategory = transactionProvider.getExpensesByCategory(
      _selectedMonth.year,
      _selectedMonth.month,
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Laporan Keuangan',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 18),
                          onPressed: () {
                            setState(() {
                              _selectedMonth = DateTime(
                                _selectedMonth.year,
                                _selectedMonth.month - 1,
                              );
                            });
                          },
                        ),
                        Container(
                          constraints: const BoxConstraints(minWidth: 100),
                          child: Text(
                            _getIndonesianMonthYear(_selectedMonth),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 18),
                          onPressed: () {
                            final now = DateTime.now();
                            if (_selectedMonth.year < now.year ||
                                (_selectedMonth.year == now.year &&
                                    _selectedMonth.month < now.month)) {
                              setState(() {
                                _selectedMonth = DateTime(
                                  _selectedMonth.year,
                                  _selectedMonth.month + 1,
                                );
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Summary Cards Section
              _buildSummarySection(totalIncome, totalExpense),
              const SizedBox(height: 24),

              // Chart Section
              Expanded(
                child:
                    expensesByCategory.isNotEmpty
                        ? _buildChartSection(
                          expensesByCategory,
                          categoryProvider,
                          totalExpense,
                        )
                        : _buildEmptyState(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(double totalIncome, double totalExpense) {
    return Column(
      children: [
        // Income and Expense Row
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Pemasukan',
                totalIncome,
                Colors.green,
                Icons.arrow_upward,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Pengeluaran',
                totalExpense,
                Colors.red,
                Icons.arrow_downward,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Balance Card
        _buildSummaryCard(
          'Saldo',
          totalIncome - totalExpense,
          totalIncome - totalExpense >= 0 ? Colors.blue : Colors.orange,
          Icons.account_balance_wallet,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildChartSection(
    Map<String, double> expensesByCategory,
    CategoryProvider categoryProvider,
    double totalExpense,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pengeluaran per Kategori',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Use different layouts based on screen width
              if (constraints.maxWidth > 600) {
                // Wide screen: side by side layout
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildPieChart(
                        expensesByCategory,
                        categoryProvider,
                        totalExpense,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: _buildLegend(expensesByCategory, categoryProvider),
                    ),
                  ],
                );
              } else {
                // Narrow screen: stacked layout
                return Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildPieChart(
                        expensesByCategory,
                        categoryProvider,
                        totalExpense,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      flex: 2,
                      child: _buildLegend(expensesByCategory, categoryProvider),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(
    Map<String, double> expensesByCategory,
    CategoryProvider categoryProvider,
    double totalExpense,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: PieChart(
          PieChartData(
            sections: _buildPieChartSections(
              expensesByCategory,
              categoryProvider,
              totalExpense,
            ),
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(
    Map<String, double> expensesByCategory,
    CategoryProvider categoryProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children:
                    expensesByCategory.entries.map((entry) {
                      final category = categoryProvider.getCategoryById(
                        entry.key,
                      );
                      if (category == null) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: category.color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    NumberFormat.compactCurrency(
                                      locale: 'id',
                                      symbol: 'Rp ',
                                      decimalDigits: 0,
                                    ).format(entry.value),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada pengeluaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada data pengeluaran untuk bulan ini',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon, {
    bool fullWidth = false,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              NumberFormat.compactCurrency(
                locale: 'id',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(amount),
              style: TextStyle(
                fontSize: fullWidth ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, double> expensesByCategory,
    CategoryProvider categoryProvider,
    double totalExpense,
  ) {
    final List<PieChartSectionData> sections = [];

    expensesByCategory.forEach((categoryId, amount) {
      final category = categoryProvider.getCategoryById(categoryId);
      if (category == null) return;

      final percentage = (amount / totalExpense) * 100;

      sections.add(
        PieChartSectionData(
          color: category.color,
          value: amount,
          title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
          radius: 70,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });

    return sections;
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../models/transaction.dart';
import '../utils/theme.dart';
import 'dart:math';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({Key? key}) : super(key: key);

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  bool _isLoading = false;
  String _selectedTab = 'insights'; // insights, chat
  final TextEditingController _questionController = TextEditingController();
  final List<Map<String, dynamic>> _chatMessages = [];

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asisten AI Keuangan',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Didukung oleh Gemini AI',
            style: TextStyle(
              color: secondaryColor,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 'insights';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            _selectedTab == 'insights'
                                ? primaryColor
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Wawasan & Rekomendasi',
                          style: TextStyle(
                            color:
                                _selectedTab == 'insights'
                                    ? Colors.white
                                    : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 'chat';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            _selectedTab == 'chat'
                                ? primaryColor
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Chat AI',
                          style: TextStyle(
                            color:
                                _selectedTab == 'chat'
                                    ? Colors.white
                                    : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child:
                _selectedTab == 'insights'
                    ? _buildInsightsContent()
                    : _buildChatContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildInsightCard(
                  'Analisis Pengeluaran',
                  'Lihat pola dan tren pengeluaran Anda',
                  Icons.analytics,
                  () => _showSpendingAnalysis(),
                ),
                const SizedBox(width: 12),
                _buildInsightCard(
                  'Saran Anggaran',
                  'Anggaran bulanan berbasis pendapatan',
                  Icons.account_balance_wallet,
                  () => _showBudgetSuggestions(),
                ),
                const SizedBox(width: 12),
                _buildInsightCard(
                  'Wawasan Kebiasaan',
                  'Pahami kebiasaan keuangan Anda',
                  Icons.lightbulb_outline,
                  () => _showSpendingHabitsInsights(),
                ),
                const SizedBox(width: 12),
                _buildInsightCard(
                  'Rekomendasi Investasi',
                  'Saham & reksa dana sesuai profil',
                  Icons.trending_up,
                  () => _showInvestmentRecommendations(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildQuickInsights(),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: primaryColor),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInsights() {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    final now = DateTime.now();
    final thisMonthExpenses =
        transactionProvider
            .getTransactionsByMonth(now.year, now.month)
            .where((tx) => tx.type == TransactionType.expense)
            .toList();

    if (thisMonthExpenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.insights, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Belum Ada Data',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tambahkan transaksi untuk mendapatkan wawasan AI',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    final totalExpenses = thisMonthExpenses.fold<double>(
      0,
      (sum, tx) => sum + tx.amount,
    );
    final expensesByCategory = <String, double>{};

    for (final tx in thisMonthExpenses) {
      expensesByCategory.update(
        tx.categoryId,
        (value) => value + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }

    String? topCategoryId;
    double topAmount = 0;
    expensesByCategory.forEach((categoryId, amount) {
      if (amount > topAmount) {
        topAmount = amount;
        topCategoryId = categoryId;
      }
    });

    final estimatedIncome = _estimateMonthlyIncome(transactionProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Wawasan Cepat Bulan Ini',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (topCategoryId != null) ...[
            Text(
              'Kategori pengeluaran terbesar:',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    categoryProvider.getCategoryById(topCategoryId!)?.icon ??
                        Icons.category,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryProvider
                                .getCategoryById(topCategoryId!)
                                ?.name ??
                            'Tidak Diketahui',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        NumberFormat.currency(
                          locale: 'id',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(topAmount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Ini ${((topAmount / totalExpenses) * 100).toStringAsFixed(1)}% dari pengeluaran bulan ini. '
              'Estimasi pendapatan: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(estimatedIncome)}.',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChatContent() {
    return Column(
      children: [
        Expanded(
          child:
              _chatMessages.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Mulai Percakapan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tanyakan tentang keuangan, anggaran, atau investasi Anda',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildSuggestedQuestion(
                              'Analisis pengeluaran saya bulan ini?',
                            ),
                            _buildSuggestedQuestion(
                              'Buat anggaran berdasarkan pendapatan saya',
                            ),
                            _buildSuggestedQuestion(
                              'Kebiasaan pengeluaran saya seperti apa?',
                            ),
                            _buildSuggestedQuestion(
                              'Rekomendasi investasi untuk saya?',
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    itemCount: _chatMessages.length,
                    itemBuilder: (context, index) {
                      final message = _chatMessages[index];
                      return _buildChatMessage(message);
                    },
                  ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    hintText: 'Tanyakan tentang keuangan Anda...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _sendMessage(),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  backgroundColor: accentColor,
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedQuestion(String question) {
    return GestureDetector(
      onTap: () {
        _questionController.text = question;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withOpacity(0.3)),
        ),
        child: Text(
          question,
          style: TextStyle(color: primaryColor, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildChatMessage(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy, color: accentColor, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? primaryColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message['text'] as String,
                style: TextStyle(color: isUser ? Colors.white : Colors.black87),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: primaryColor, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  void _sendMessage() {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    if (!_isFinanceRelated(question)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Maaf, saya hanya dapat membantu dengan pertanyaan seputar keuangan.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _chatMessages.add({
        'text': question,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });

    _questionController.clear();

    Future.delayed(const Duration(seconds: 2), () {
      final response = _generateAIResponse(question);
      setState(() {
        _chatMessages.add({
          'text': response,
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });
    });
  }

  bool _isFinanceRelated(String question) {
    final financeKeywords = [
      'uang',
      'keuangan',
      'anggaran',
      'pengeluaran',
      'pendapatan',
      'investasi',
      'saham',
      'reksa',
      'tabungan',
      'hutang',
      'kredit',
      'cicilan',
      'bunga',
      'profit',
      'rugi',
      'modal',
      'bisnis',
      'ekonomi',
      'finansial',
      'budget',
      'expense',
      'income',
      'money',
      'finance',
      'saving',
      'investment',
      'stock',
      'debt',
      'kategori',
      'transaksi',
      'belanja',
      'beli',
      'jual',
      'bayar',
      'transfer',
      'saldo',
      'rekening',
      'bank',
      'kartu',
      'cash',
      'tunai',
      'digital',
      'hemat',
      'boros',
      'irit',
      'mahal',
      'murah',
      'harga',
      'biaya',
      'cost',
    ];
    final lowerQuestion = question.toLowerCase();
    return financeKeywords.any((keyword) => lowerQuestion.contains(keyword));
  }

  String _generateAIResponse(String question) {
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final lowerQuestion = question.toLowerCase();

    final estimatedIncome = _estimateMonthlyIncome(transactionProvider);

    if (lowerQuestion.contains('pengeluaran') ||
        lowerQuestion.contains('expense')) {
      final now = DateTime.now();
      final monthlyExpenses = transactionProvider.getTotalExpenseByMonth(
        now.year,
        now.month,
      );
      final topCategory = _getTopSpendingCategory(
        transactionProvider,
        categoryProvider,
        now.year,
        now.month,
      );
      return 'Pengeluaran bulan ini: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(monthlyExpenses)}. '
          'Kategori terbesar: ${topCategory['name']} (${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(topCategory['amount'])}). '
          'Ingin analisis tren pengeluaran?';
    }

    if (lowerQuestion.contains('anggaran') ||
        lowerQuestion.contains('budget')) {
      final budget = _generateBudgetSuggestions(
        transactionProvider,
        estimatedIncome,
      );
      return 'Berdasarkan estimasi pendapatan Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(estimatedIncome)}, '
          'saran anggaran: Kebutuhan Pokok Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(budget['needs'])}, '
          'Keinginan Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(budget['wants'])}, '
          'Tabungan/Investasi Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(budget['savings'])}.';
    }

    if (lowerQuestion.contains('kebiasaan') ||
        lowerQuestion.contains('habit')) {
      final habits = _analyzeSpendingHabits(
        transactionProvider,
        categoryProvider,
      );
      return habits.isNotEmpty
          ? 'Kebiasaan pengeluaran: ${habits.join(', ')}. Ingin saran untuk mengoptimalkan? '
          : 'Belum cukup data untuk menganalisis kebiasaan. Tambahkan lebih banyak transaksi.';
    }

    if (lowerQuestion.contains('investasi') ||
        lowerQuestion.contains('saham') ||
        lowerQuestion.contains('reksa')) {
      final riskProfile = _determineRiskProfile(estimatedIncome);
      return 'Berdasarkan pendapatan dan profil risiko ($riskProfile), saya sarankan ${riskProfile == 'Konservatif'
              ? 'reksa dana pasar uang'
              : riskProfile == 'Moderat'
              ? 'reksa dana campuran atau saham blue-chip'
              : 'saham pertumbuhan atau reksa dana saham'}. '
          'Ingin rekomendasi spesifik?';
    }

    return 'Berdasarkan data keuangan Anda, saya bisa bantu dengan analisis pengeluaran, anggaran, kebiasaan, atau investasi. Apa yang ingin Anda dalami?';
  }

  // Optimized Methods for Insights
  void _showSpendingAnalysis() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Analisis Pengeluaran',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          child: _buildSpendingAnalysisContent(),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  void _showBudgetSuggestions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Saran Anggaran Bulanan',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          child: _buildBudgetSuggestionsContent(),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  void _showSpendingHabitsInsights() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Wawasan Kebiasaan Pengeluaran',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          child: _buildSpendingHabitsInsightsContent(),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  void _showInvestmentRecommendations() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Rekomendasi Investasi',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          child: _buildInvestmentRecommendationsContent(),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  // Helper Methods
  double _estimateMonthlyIncome(TransactionProvider provider) {
    final now = DateTime.now();
    final incomes = provider
        .getTransactionsByMonth(now.year, now.month)
        .where((tx) => tx.type == TransactionType.income)
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    final expenses = provider.getTotalExpenseByMonth(now.year, now.month);
    // Assume income is at least 1.5x expenses if no income data
    return incomes > 0 ? incomes : expenses * 1.5;
  }

  Map<String, dynamic> _getTopSpendingCategory(
    TransactionProvider provider,
    CategoryProvider categoryProvider,
    int year,
    int month,
  ) {
    final expenses =
        provider
            .getTransactionsByMonth(year, month)
            .where((tx) => tx.type == TransactionType.expense)
            .toList();
    final expensesByCategory = <String, double>{};
    for (final tx in expenses) {
      expensesByCategory.update(
        tx.categoryId,
        (value) => value + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }
    String? topCategoryId;
    double topAmount = 0;
    expensesByCategory.forEach((categoryId, amount) {
      if (amount > topAmount) {
        topAmount = amount;
        topCategoryId = categoryId;
      }
    });
    final category = categoryProvider.getCategoryById(topCategoryId ?? '');
    return {
      'name': category?.name ?? 'Tidak Diketahui',
      'amount': topAmount,
      'icon': category?.icon ?? Icons.category,
    };
  }

  Map<String, double> _generateBudgetSuggestions(
    TransactionProvider provider,
    double income,
  ) {
    final now = DateTime.now();
    final expenses = provider.getTotalExpenseByMonth(now.year, now.month);
    final needsRatio =
        expenses > 0.5 * income ? 0.6 : 0.5; // Adjust if overspending
    final wantsRatio = expenses > 0.5 * income ? 0.25 : 0.3;
    final savingsRatio = 1 - needsRatio - wantsRatio;
    return {
      'needs': income * needsRatio,
      'wants': income * wantsRatio,
      'savings': income * savingsRatio,
    };
  }

  List<String> _analyzeSpendingHabits(
    TransactionProvider provider,
    CategoryProvider categoryProvider,
  ) {
    final now = DateTime.now();
    final transactions =
        provider
            .getTransactionsByMonth(now.year, now.month)
            .where((tx) => tx.type == TransactionType.expense)
            .toList();
    final categoryCounts = <String, int>{};
    final categoryAmounts = <String, double>{};
    for (final tx in transactions) {
      categoryCounts.update(
        tx.categoryId,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      categoryAmounts.update(
        tx.categoryId,
        (value) => value + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }
    final habits = <String>[];
    categoryCounts.forEach((categoryId, count) {
      if (count >= 5) {
        // Frequent category
        final category = categoryProvider.getCategoryById(categoryId);
        final avgSpend = categoryAmounts[categoryId]! / count;
        habits.add(
          'Anda sering berbelanja di ${category?.name ?? 'kategori lain'} '
          '(${count}x, rata-rata ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(avgSpend)} per transaksi)',
        );
      }
    });
    return habits;
  }

  String _determineRiskProfile(double income) {
    // Simplified risk profiling based on income
    if (income < 5000000) return 'Konservatif';
    if (income < 15000000) return 'Moderat';
    return 'Agresif';
  }

  // Optimized Content Builders
  Widget _buildSpendingAnalysisContent() {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final now = DateTime.now();
    final expenses =
        transactionProvider
            .getTransactionsByMonth(now.year, now.month)
            .where((tx) => tx.type == TransactionType.expense)
            .toList();

    if (expenses.isEmpty) {
      return const Center(child: Text('Belum ada pengeluaran bulan ini'));
    }

    final expensesByCategory = <String, double>{};
    for (final tx in expenses) {
      expensesByCategory.update(
        tx.categoryId,
        (value) => value + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }

    final lastMonthExpenses = transactionProvider
        .getTransactionsByMonth(now.year, now.month - 1)
        .where((tx) => tx.type == TransactionType.expense)
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    final thisMonthExpenses = expenses.fold<double>(
      0,
      (sum, tx) => sum + tx.amount,
    );
    final trend =
        thisMonthExpenses > lastMonthExpenses ? 'meningkat' : 'menurun';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analisis Pengeluaran Bulan ${DateFormat('MMMM yyyy', 'id').format(now)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: secondaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Total: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(thisMonthExpenses)} '
          '($trend dibandingkan bulan lalu)',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        ...expensesByCategory.entries.map((entry) {
          final category = categoryProvider.getCategoryById(entry.key);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                category?.icon ?? Icons.category,
                color: category?.color ?? Colors.grey,
              ),
              title: Text(category?.name ?? 'Tidak Diketahui'),
              subtitle: Text(
                '${((entry.value / thisMonthExpenses) * 100).toStringAsFixed(1)}% dari total',
              ),
              trailing: Text(
                NumberFormat.currency(
                  locale: 'id',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(entry.value),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBudgetSuggestionsContent() {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final estimatedIncome = _estimateMonthlyIncome(transactionProvider);
    final budget = _generateBudgetSuggestions(
      transactionProvider,
      estimatedIncome,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Anggaran Bulanan (Estimasi Pendapatan: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(estimatedIncome)})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '• Kebutuhan Pokok: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(budget['needs'])} '
                '(${((budget['needs']! / estimatedIncome) * 100).toStringAsFixed(0)}%)',
              ),
              Text(
                '• Keinginan: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(budget['wants'])} '
                '(${((budget['wants']! / estimatedIncome) * 100).toStringAsFixed(0)}%)',
              ),
              Text(
                '• Tabungan/Investasi: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(budget['savings'])} '
                '(${((budget['savings']! / estimatedIncome) * 100).toStringAsFixed(0)}%)',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Anggaran ini disesuaikan dengan pola pengeluaran Anda. Prioritaskan tabungan untuk tujuan jangka panjang.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildSpendingHabitsInsightsContent() {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final habits = _analyzeSpendingHabits(
      transactionProvider,
      categoryProvider,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb, color: accentColor),
                  const SizedBox(width: 8),
                  Text(
                    'Wawasan Kebiasaan Pengeluaran',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (habits.isEmpty)
                const Text(
                  'Belum cukup data untuk menganalisis kebiasaan. Tambahkan lebih banyak transaksi.',
                )
              else
                ...habits.map(
                  (habit) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('• $habit'),
                  ),
                ),
            ],
          ),
        ),
        if (habits.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Saran: Kurangi frekuensi pengeluaran impulsif dan alokasikan lebih banyak ke tabungan.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ],
    );
  }

  Widget _buildInvestmentRecommendationsContent() {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final estimatedIncome = _estimateMonthlyIncome(transactionProvider);
    final riskProfile = _determineRiskProfile(estimatedIncome);

    final investments = [
      if (riskProfile == 'Konservatif') ...[
        {
          'type': 'Reksa Dana',
          'name': 'BNI-AM Dana Pasar Uang',
          'expectedReturn': '4-6% p.a.',
          'risk': 'Rendah',
          'minInvestment': 100000,
          'reason': 'Cocok untuk stabilitas dan likuiditas tinggi',
        },
        {
          'type': 'Deposito',
          'name': 'Deposito BRI',
          'expectedReturn': '3-5% p.a.',
          'risk': 'Rendah',
          'minInvestment': 1000000,
          'reason': 'Keamanan terjamin dengan pengembalian stabil',
        },
      ] else if (riskProfile == 'Moderat') ...[
        {
          'type': 'Reksa Dana',
          'name': 'Mandiri Investa Campuran',
          'expectedReturn': '8-12% p.a.',
          'risk': 'Sedang',
          'minInvestment': 500000,
          'reason': 'Keseimbangan antara saham dan obligasi',
        },
        {
          'type': 'Saham',
          'name': 'Bank Central Asia (BBCA)',
          'expectedReturn': '10-15% p.a.',
          'risk': 'Sedang',
          'minInvestment': 945000,
          'reason': 'Fundamental kuat, cocok untuk jangka menengah',
        },
      ] else ...[
        {
          'type': 'Reksa Dana',
          'name': 'Schroders Dana Ekuitas',
          'expectedReturn': '15-20% p.a.',
          'risk': 'Tinggi',
          'minInvestment': 500000,
          'reason': 'Potensi pertumbuhan tinggi di saham',
        },
        {
          'type': 'Saham',
          'name': 'GOTO Gojek Tokopedia',
          'expectedReturn': '20-30% p.a.',
          'risk': 'Tinggi',
          'minInvestment': 500000,
          'reason': 'Pertumbuhan agresif di sektor teknologi',
        },
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Disclaimer: Rekomendasi ini untuk informasi, bukan saran investasi resmi.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Profil Risiko: $riskProfile',
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        ),
        const SizedBox(height: 8),
        ...investments.map((inv) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          inv['type'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          inv['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (inv['risk'] as String) == 'Rendah'
                                  ? Colors.green.withOpacity(0.2)
                                  : (inv['risk'] as String) == 'Sedang'
                                  ? Colors.orange.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          inv['risk'] as String,
                          style: TextStyle(
                            color:
                                (inv['risk'] as String) == 'Rendah'
                                    ? Colors.green
                                    : (inv['risk'] as String) == 'Sedang'
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Ekspektasi Return: ${inv['expectedReturn']}'),
                  Text(
                    'Investasi Minimum: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(inv['minInvestment'])}',
                  ),
                  Text(
                    'Alasan: ${inv['reason']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

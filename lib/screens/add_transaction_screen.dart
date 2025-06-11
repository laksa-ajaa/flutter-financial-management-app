import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../providers/auth_provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/theme.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddTransactionScreen({Key? key, this.transaction}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _newCategoryController = TextEditingController();

  late TransactionType _type;
  late DateTime _selectedDate;
  String? _selectedCategoryId;
  bool _isInit = true;
  bool _isLoading = false;
  bool _isAddingNewCategory = false;
  Color _selectedColor = accentColor;
  IconData _selectedIcon = Icons.category;

  // Predefined safe icons for new categories
  static const List<IconData> _availableIcons = [
    Icons.home,
    Icons.restaurant,
    Icons.shopping_cart,
    Icons.directions_car,
    Icons.local_grocery_store,
    Icons.local_hospital,
    Icons.school,
    Icons.movie,
    Icons.sports_basketball,
    Icons.flight,
    Icons.hotel,
    Icons.attach_money,
    Icons.account_balance,
    Icons.credit_card,
    Icons.receipt,
    Icons.local_laundry_service,
    Icons.fitness_center,
    Icons.pets,
    Icons.child_care,
    Icons.local_bar,
    Icons.local_cafe,
    Icons.local_mall,
    Icons.local_pharmacy,
    Icons.work,
    Icons.trending_up,
    Icons.card_giftcard,
    Icons.more_horiz,
    Icons.category,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _type = widget.transaction?.type ?? TransactionType.expense;
      _selectedDate = widget.transaction?.date ?? DateTime.now();
      _selectedCategoryId = widget.transaction?.categoryId;

      if (widget.transaction != null) {
        _nameController.text = widget.transaction!.name;
        _amountController.text = widget.transaction!.amount.toString();
        _noteController.text = widget.transaction!.note;
      }

      _isInit = false;
    }
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null && !_isAddingNewCategory) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih kategori'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    try {
      // If adding a new category
      if (_isAddingNewCategory && _newCategoryController.text.isNotEmpty) {
        final newCategory = Category(
          id: '',
          name: _newCategoryController.text.trim(),
          color: _selectedColor,
          icon: _selectedIcon,
          userId: userId,
          isDefault: false,
          type:
              _type == TransactionType.income
                  ? CategoryType.income
                  : CategoryType.expense,
        );

        final docRef = await categoryProvider.addCategory(newCategory);
        _selectedCategoryId = docRef;
      }

      final transaction = Transaction(
        id: widget.transaction?.id ?? '',
        name: _nameController.text.trim(),
        categoryId: _selectedCategoryId!,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        note: _noteController.text.trim(),
        type: _type,
        userId: userId,
      );

      if (widget.transaction == null) {
        await transactionProvider.addTransaction(transaction);
      } else {
        await transactionProvider.updateTransaction(transaction);
      }

      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final availableCategories =
        _type == TransactionType.income
            ? categoryProvider.incomeCategories
            : categoryProvider.expenseCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null ? 'Tambah Transaksi' : 'Edit Transaksi',
        ),
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Transaction Type Selector
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
                                      _type = TransactionType.expense;
                                      _selectedCategoryId = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          _type == TransactionType.expense
                                              ? primaryColor
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Pengeluaran',
                                        style: TextStyle(
                                          color:
                                              _type == TransactionType.expense
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
                                      _type = TransactionType.income;
                                      _selectedCategoryId = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          _type == TransactionType.income
                                              ? primaryColor
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Pemasukan',
                                        style: TextStyle(
                                          color:
                                              _type == TransactionType.income
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

                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nama',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.description),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Silakan masukkan nama';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Amount Field
                        TextFormField(
                          controller: _amountController,
                          decoration: InputDecoration(
                            labelText: 'Jumlah',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.attach_money),
                            prefixText: 'Rp ',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Silakan masukkan jumlah';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Silakan masukkan angka yang valid';
                            }
                            if (double.parse(value) <= 0) {
                              return 'Jumlah harus lebih dari nol';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Category Section
                        Text(
                          'Kategori',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Show category grid or new category form
                        if (!_isAddingNewCategory) ...[
                          SizedBox(
                            height: 200,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 0.8,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                              itemCount:
                                  availableCategories.length +
                                  1, // +1 for "Add New" button
                              itemBuilder: (ctx, index) {
                                // Last item is "Add New" button
                                if (index == availableCategories.length) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isAddingNewCategory = true;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: backgroundColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: accentColor),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_circle_outline,
                                            color: accentColor,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tambah',
                                            style: TextStyle(
                                              color: accentColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final category = availableCategories[index];

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryId = category.id;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          _selectedCategoryId == category.id
                                              ? category.color.withOpacity(0.2)
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            _selectedCategoryId == category.id
                                                ? category.color
                                                : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          category.icon,
                                          color: category.color,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          category.name,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight:
                                                _selectedCategoryId ==
                                                        category.id
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ] else ...[
                          // New Category Form
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Kategori Baru',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: secondaryColor,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          _isAddingNewCategory = false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _newCategoryController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nama Kategori',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator:
                                      _isAddingNewCategory
                                          ? (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Silakan masukkan nama kategori';
                                            }
                                            return null;
                                          }
                                          : null,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Pilih Warna:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: secondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildColorPicker(),
                                const SizedBox(height: 16),
                                Text(
                                  'Pilih Ikon:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: secondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildIconPicker(),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Date Picker
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: secondaryColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tanggal: ${DateFormat.yMMMd().format(_selectedDate)}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _presentDatePicker,
                                icon: const Icon(Icons.edit),
                                label: const Text('Ubah'),
                                style: TextButton.styleFrom(
                                  foregroundColor: accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Note Field
                        TextFormField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            labelText: 'Catatan (Opsional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.note),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveTransaction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              widget.transaction == null
                                  ? 'TAMBAH TRANSAKSI'
                                  : 'PERBARUI TRANSAKSI',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildColorPicker() {
    final colors = [
      primaryColor,
      secondaryColor,
      accentColor,
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.amber,
      Colors.orange,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          colors.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        _selectedColor == color
                            ? Colors.white
                            : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow:
                      _selectedColor == color
                          ? [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                          : null,
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildIconPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          _availableIcons.map((icon) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIcon = icon;
                });
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color:
                      _selectedIcon == icon
                          ? _selectedColor.withOpacity(0.2)
                          : Colors.grey.shade200,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        _selectedIcon == icon
                            ? _selectedColor
                            : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  color: _selectedIcon == icon ? _selectedColor : Colors.grey,
                  size: 20,
                ),
              ),
            );
          }).toList(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }
}

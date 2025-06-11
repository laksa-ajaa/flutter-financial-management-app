import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

class CategoryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Category> _categories = [];

  List<Category> get categories => [..._categories];

  List<Category> get incomeCategories =>
      _categories.where((cat) => cat.type == CategoryType.income).toList();

  List<Category> get expenseCategories =>
      _categories.where((cat) => cat.type == CategoryType.expense).toList();

  Future<void> fetchCategories(String userId) async {
    try {
      print('Fetching categories for userId: $userId'); // Debug log

      final snapshot =
          await _firestore
              .collection('categories')
              .where('userId', isEqualTo: userId)
              .get();

      print('Found ${snapshot.docs.length} categories'); // Debug log

      _categories =
          snapshot.docs
              .map((doc) {
                try {
                  return Category.fromFirestore(doc);
                } catch (e) {
                  print('Error parsing category ${doc.id}: $e'); // Debug log
                  return null;
                }
              })
              .where((cat) => cat != null)
              .cast<Category>()
              .toList();

      print(
        'Successfully parsed ${_categories.length} categories',
      ); // Debug log

      notifyListeners();
    } catch (e) {
      print('Error fetching categories: $e'); // Debug log
      rethrow;
    }
  }

  Future<String> addCategory(Category category) async {
    try {
      final docRef = await _firestore
          .collection('categories')
          .add(category.toMap());

      _categories.add(category.copyWith(id: docRef.id));
      notifyListeners();
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _firestore
          .collection('categories')
          .doc(category.id)
          .update(category.toMap());

      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index >= 0) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();

      _categories.removeWhere((c) => c.id == categoryId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      print('Category not found: $id'); // Debug log
      return null;
    }
  }

  // Method to clear categories (useful for logout)
  void clearCategories() {
    _categories.clear();
    notifyListeners();
  }
}
// This method is useful for clearing the categories when the user logs out or switches accounts.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

class CategoryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Category> _categories = [];

  List<Category> get categories => [..._categories];

  Future<void> fetchCategories(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('userId', isEqualTo: userId)
          .get();
      
      _categories = snapshot.docs
          .map((doc) => Category.fromFirestore(doc))
          .toList();
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      final docRef = await _firestore.collection('categories').add(category.toMap());
      
      _categories.add(category.copyWith(id: docRef.id));
      notifyListeners();
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
    return _categories.firstWhere((c) => c.id == id, orElse: () => throw Exception('Category not found'));
  }
}

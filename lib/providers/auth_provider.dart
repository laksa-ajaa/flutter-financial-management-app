import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manajemen_keuangan/models/user.dart' as app_user;

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  bool get isAuth => _user != null;
  String get userId => _user?.uid ?? '';

  Future<void> signUp(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;

      // Create user document in Firestore
      await _firestore.collection('users').doc(_user!.uid).set({
        'email': email,
        'name': name,
        'createdAt': Timestamp.now(),
      });

      // Create default categories
      await _createDefaultCategories(_user!.uid);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> _createDefaultCategories(String userId) async {
    final defaultCategories = [
      {
        'name': 'Food',
        'color': Colors.red.value,
        'iconCodePoint': Icons.restaurant.codePoint,
        'isDefault': true,
      },
      {
        'name': 'Transportation',
        'color': Colors.blue.value,
        'iconCodePoint': Icons.directions_car.codePoint,
        'isDefault': true,
      },
      {
        'name': 'Entertainment',
        'color': Colors.purple.value,
        'iconCodePoint': Icons.movie.codePoint,
        'isDefault': true,
      },
      {
        'name': 'Bills',
        'color': Colors.orange.value,
        'iconCodePoint': Icons.receipt.codePoint,
        'isDefault': true,
      },
      {
        'name': 'Shopping',
        'color': Colors.pink.value,
        'iconCodePoint': Icons.shopping_bag.codePoint,
        'isDefault': true,
      },
      {
        'name': 'Salary',
        'color': Colors.green.value,
        'iconCodePoint': Icons.attach_money.codePoint,
        'isDefault': true,
      },
    ];

    final batch = _firestore.batch();

    for (final category in defaultCategories) {
      final docRef = _firestore.collection('categories').doc();
      batch.set(docRef, {...category, 'userId': userId});
    }

    await batch.commit();
  }
}

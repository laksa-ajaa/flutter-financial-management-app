import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:manajemen_keuangan/screens/home_screen.dart';
import 'package:manajemen_keuangan/providers/auth_provider.dart';
import 'package:manajemen_keuangan/providers/category_provider.dart';
import 'package:manajemen_keuangan/providers/transaction_provider.dart';

void main() {
  testWidgets('HomeScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('Finance Manager'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}

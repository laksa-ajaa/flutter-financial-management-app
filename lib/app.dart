import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'providers/auth_provider.dart';
import 'utils/theme.dart';

class FinanceApp extends StatelessWidget {
  const FinanceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Manager',
      theme: appTheme,
      home: Consumer<AuthProvider>(
        builder: (ctx, authProvider, _) {
          return authProvider.isAuth ? const HomeScreen() : const AuthScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

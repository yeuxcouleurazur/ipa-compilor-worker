import 'package:flutter/material.dart';
import 'screens/main_navigation.dart';

void main() {
  runApp(const LarpzWalletApp());
}

class LarpzWalletApp extends StatelessWidget {
  const LarpzWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LarpzWallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFA693F5),
        fontFamily: 'Roboto', // Fallback to standard font
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFA693F5),
          background: Color(0xFF121212),
          surface: Color(0xFF1E1E1E),
        ),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

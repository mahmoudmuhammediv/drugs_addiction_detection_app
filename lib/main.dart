import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Addiction Detection',
      debugShowCheckedModeBanner: false, // Hides the debug banner
      theme: ThemeData(
        useMaterial3: true, // Enables Material 3 design
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 2, 17, 181),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

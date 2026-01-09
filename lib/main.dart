import 'package:flutter/material.dart';
import 'package:madcamp_lounge/pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF4C46E5);
    return MaterialApp(
      title: 'Madcamp Lounge',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: .fromSeed(seedColor: primary),
        fontFamilyFallback: const ["Apple SD Gothic Neo", "Noto Sans KR", "Roboto"],
      ),
      home: const LoginPage(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TH4 - Nhóm 11', 
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF6F7FB),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF1A1C1E),
          ),
        ),
        home: const HomeScreen(), 
      ),
    );
  }
}
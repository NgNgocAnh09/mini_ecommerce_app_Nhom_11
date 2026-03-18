import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const MiniEcommerceApp());
}

class MiniEcommerceApp extends StatelessWidget {
  const MiniEcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. ChangeNotifierProvider bao bọc MaterialApp để cung cấp State cho toàn App
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      // 2. Tham số 'child' phải chứa MaterialApp
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mini E-Commerce App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF6F7FB),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF1A1C1E),
            surfaceTintColor: Colors.transparent,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        // 3. 'home' phải nằm trong MaterialApp. 
        // Bạn nên để HomeScreen làm màn hình mặc định khi mở app.
        home: const HomeScreen(), 
      ),
    );
  }
}
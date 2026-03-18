import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        // Nếu sau này có thêm UserProvider hay AuthProvider thì thêm ở đây
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TH4 - Nhóm 11', 
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const HomeScreen(), // Thành viên 2 sẽ code file này
    );
  }
}
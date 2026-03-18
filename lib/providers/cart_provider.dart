// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import 'package:mini_ecommerce_app/models/product.dart';

class CartProvider with ChangeNotifier {
  final Map<int, CartItem> _items = {};
  Map<int, CartItem> get items => {..._items};
  int get itemCount => _items.length;

  // Hàm để Thành viên 3 gọi khi bấm "Thêm vào giỏ"
  void addToCart(Product product, String size, String color) {
    if (_items.containsKey(product.id)) {
      _items.update(product.id, (existing) => CartItem(
        product: existing.product,
        quantity: existing.quantity + 1,
        size: size,
        color: color,
      ));
    } else {
      _items.putIfAbsent(product.id, () => CartItem(product: product, size: size, color: color));
    }
    notifyListeners();
  }

  // Hàm để Thành viên 4 gọi để tính tổng tiền
  double get totalAmount {
    double total = 0.0;
    _items.forEach((id, item) {
      if (item.isSelected) total += item.product.price * item.quantity;
    });
    return total;
  }
}
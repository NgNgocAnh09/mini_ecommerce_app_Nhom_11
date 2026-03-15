import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [
    CartItem(
      product: Product(
        id: 1,
        title: 'Tai nghe Bluetooth Mini Pro',
        price: 259000,
        description: 'Tai nghe không dây pin trau, am thanh ro net.',
        category: 'Dien tu',
        image:
            'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=600',
      ),
      size: 'M',
      color: 'Den',
      quantity: 1,
      isSelected: true,
    ),
    CartItem(
      product: Product(
        id: 2,
        title: 'Ao khoac unisex basic',
        price: 349000,
        description: 'Chat lieu ni mem, mac thoang va giu form.',
        category: 'Thoi trang',
        image:
            'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600',
      ),
      size: 'L',
      color: 'Xanh',
      quantity: 2,
      isSelected: false,
    ),
  ];

  List<CartItem> get items => List.unmodifiable(_items);

  int get cartTypeCount => _items.length;

  bool get isAllSelected =>
      _items.isNotEmpty && _items.every((item) => item.isSelected);

  List<CartItem> get selectedItems =>
      _items.where((item) => item.isSelected).toList(growable: false);

  double get selectedTotal => _items
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + item.subtotal);

  void toggleItemSelection(String id, bool? value) {
    final item = _findById(id);
    if (item == null) {
      return;
    }
    item.isSelected = value ?? false;
    notifyListeners();
  }

  void toggleSelectAll(bool value) {
    for (final item in _items) {
      item.isSelected = value;
    }
    notifyListeners();
  }

  void increaseQuantity(String id) {
    final item = _findById(id);
    if (item == null) {
      return;
    }
    item.quantity += 1;
    notifyListeners();
  }

  bool decreaseQuantity(String id) {
    final item = _findById(id);
    if (item == null) {
      return false;
    }
    if (item.quantity <= 1) {
      return true;
    }
    item.quantity -= 1;
    notifyListeners();
    return false;
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearSelectedItems() {
    _items.removeWhere((item) => item.isSelected);
    notifyListeners();
  }

  void addOrMergeItem({
    required Product product,
    required String size,
    required String color,
    required int quantity,
  }) {
    final key = '${product.id}_${size}_$color';
    final existing = _findById(key);
    if (existing != null) {
      existing.quantity += quantity;
      existing.isSelected = true;
    } else {
      _items.add(
        CartItem(
          product: product,
          size: size,
          color: color,
          quantity: quantity,
          isSelected: true,
        ),
      );
    }
    notifyListeners();
  }

  CartItem? _findById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}

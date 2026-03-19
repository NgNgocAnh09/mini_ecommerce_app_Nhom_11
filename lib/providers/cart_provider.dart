import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [
    CartItem(
      id: '1_M_Den', 
      product: Product(
        id: 1,
        title: 'Tai nghe Bluetooth Mini Pro',
        price: 259,
        rating: 4.8,       
        soldCount: 120,
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
      id: '2_L_Xanh', 
      product: Product(
        id: 2,
        title: 'Ao khoac unisex basic',
        price: 349,
        rating: 4.5,       
        soldCount: 85,     
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


  // Khai báo thêm danh sách đơn hàng
final List<Map<String, dynamic>> _orders = [];
List<Map<String, dynamic>> get orders => _orders;

// Hàm để chuyển từ giỏ hàng sang đơn hàng (gọi khi bấm Đặt hàng thành công)
void addOrder(List<CartItem> cartItems, double total, String address, String paymentMethod) {
  _orders.insert(0, {
    'id': DateTime.now().toString(),
    'items': cartItems,
    'total': total,
    'address': address,
    'paymentMethod': paymentMethod,
    'status': 'Chờ xác nhận', // Trạng thái mặc định
    'date': DateTime.now(),
  });
  notifyListeners();
}

  // Cập nhật trạng thái đơn hàng theo id
  void updateOrderStatus(String id, String status) {
    final idx = _orders.indexWhere((o) => o['id'] == id);
    if (idx >= 0) {
      _orders[idx]['status'] = status;
      notifyListeners();
    }
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
          id: key, // Đã trả lại id
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
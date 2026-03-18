// lib/models/cart_item.dart
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  String size;
  String color;
  bool isSelected; // Dùng cho logic Checkbox tính tiền

  CartItem({
    required this.product,
    this.quantity = 1,
    this.size = 'M',
    this.color = 'Default',
    this.isSelected = true,
  });
}
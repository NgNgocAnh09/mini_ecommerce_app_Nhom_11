import 'product.dart';

class CartItem {
  final String id; // 1. Khai báo thêm thuộc tính id
  final Product product;
  final String size;
  final String color;
  int quantity;
  bool isSelected;

  CartItem({
    required this.id, // 2. Bắt buộc truyền id vào constructor
    required this.product,
    required this.size,
    required this.color,
    this.quantity = 1,
    this.isSelected = true,
  });

  // (Đã xóa dòng getter String get id... ở đây)

  double get subtotal => product.price * quantity;
}
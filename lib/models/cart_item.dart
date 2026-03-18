import 'product.dart';

class CartItem {
  final Product product;
  final String size;
  final String color;
  int quantity;
  bool isSelected;

  CartItem({
    required this.product,
    required this.size,
    required this.color,
    this.quantity = 1,
    this.isSelected = true,
  });

  String get id => '${product.id}_${size}_$color';

  double get subtotal => product.price * quantity;
}

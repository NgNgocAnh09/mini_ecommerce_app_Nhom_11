import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Đảm bảo đường dẫn này khớp với project của bạn
import 'package:mini_ecommerce_app/providers/cart_provider.dart';
import 'package:mini_ecommerce_app/models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  // ĐỒNG BỘ: Nhân 23000 để khớp giá với ProductCard ở trang chủ
  String _formatCurrency(double value) {
    final double vndValue = value * 23000; 
    final number = vndValue.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < number.length; i++) {
      buffer.write(number[i]);
      final reverseIndex = number.length - i - 1;
      if (reverseIndex > 0 && reverseIndex % 3 == 0) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()} VND';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HIỆU ỨNG HERO: Giúp ảnh bay từ trang chủ sang trang này
            Hero(
              tag: 'product_${product.id}',
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Image.network(
                    product.image,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) {
                      return const Icon(Icons.image_not_supported, size: 48);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _formatCurrency(product.price),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: const Color(0xFFE53935),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(product.category),
                  backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.star, color: Colors.orange, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${product.rating} | Đã bán ${product.soldCount}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              'Mô tả sản phẩm',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 80), // Tạo khoảng trống để không bị nút đè
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed: () => _openAddToCartBottomSheet(context),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: const Color(0xFFFF5722), // Màu cam Shopee
          ),
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Thêm vào giỏ hàng', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  void _openAddToCartBottomSheet(BuildContext rootContext) {
    int quantity = 1;
    String selectedSize = 'M';
    String selectedColor = 'Den';

    showModalBottomSheet<void>(
      context: rootContext,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            // ĐỒNG BỘ: Tính tạm tính cũng phải nhân 23000
            final subTotal = product.price * quantity;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                16, 8, 16, 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chọn phân loại', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kích cỡ:'),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'S', label: Text('S')),
                          ButtonSegment(value: 'M', label: Text('M')),
                          ButtonSegment(value: 'L', label: Text('L')),
                        ],
                        selected: {selectedSize},
                        onSelectionChanged: (values) => setState(() => selectedSize = values.first),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Màu sắc:'),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'Den', label: Text('Đen')),
                          ButtonSegment(value: 'Trang', label: Text('Trắng')),
                          ButtonSegment(value: 'Xanh', label: Text('Xanh')),
                        ],
                        selected: {selectedColor},
                        onSelectionChanged: (values) => setState(() => selectedColor = values.first),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Số lượng:'),
                      Row(
                        children: [
                          IconButton(
                            onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('$quantity', style: Theme.of(context).textTheme.titleMedium),
                          IconButton(
                            onPressed: () => setState(() => quantity++),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tạm tính:', style: TextStyle(fontSize: 16)),
                      Text(
                        _formatCurrency(subTotal),
                        style: const TextStyle(
                          color: Color(0xFFE53935),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
                      onPressed: () {
                        rootContext.read<CartProvider>().addOrMergeItem(
                          product: product,
                          size: selectedSize,
                          color: selectedColor,
                          quantity: quantity,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(rootContext).showSnackBar(
                          SnackBar(content: Text('Đã thêm $quantity sản phẩm vào giỏ.')),
                        );
                      },
                      child: const Text('Xác nhận'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
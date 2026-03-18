import 'package:flutter/material.dart';
import 'package:mini_ecommerce_app/models/product.dart';

class ProductDetailScreen extends StatelessWidget {
	final Product product;
	final void Function(Product product, int quantity)? onAddToCart;

	const ProductDetailScreen({
		super.key,
		required this.product,
		this.onAddToCart,
	});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Chi tiet san pham'),
			),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(16),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						AspectRatio(
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
									errorBuilder: (_, __, ___) {
										return const Icon(Icons.image_not_supported, size: 48);
									},
								),
							),
						),
						const SizedBox(height: 16),
						Text(
							product.title,
							style: Theme.of(context).textTheme.titleLarge?.copyWith(
										fontWeight: FontWeight.bold,
									),
						),
						const SizedBox(height: 8),
						Text(
							'\$${product.price.toStringAsFixed(2)}',
							style: Theme.of(context).textTheme.headlineSmall?.copyWith(
										color: Theme.of(context).colorScheme.primary,
										fontWeight: FontWeight.w700,
									),
						),
						const SizedBox(height: 8),
						Chip(label: Text(product.category)),
						const SizedBox(height: 16),
						Text(
							'Mo ta san pham',
							style: Theme.of(context).textTheme.titleMedium?.copyWith(
										fontWeight: FontWeight.w700,
									),
						),
						const SizedBox(height: 8),
						Text(
							product.description,
							style: Theme.of(context).textTheme.bodyMedium,
						),
					],
				),
			),
			bottomNavigationBar: SafeArea(
				minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
				child: FilledButton.icon(
					onPressed: () => _openAddToCartBottomSheet(context),
					icon: const Icon(Icons.shopping_cart_checkout),
					label: const Text('Them vao gio hang'),
				),
			),
		);
	}

	void _openAddToCartBottomSheet(BuildContext context) {
		int quantity = 1;
		final navigator = Navigator.of(context);
		final messenger = ScaffoldMessenger.of(context);

		showModalBottomSheet<void>(
			context: context,
			isScrollControlled: true,
			useSafeArea: true,
			showDragHandle: true,
			shape: const RoundedRectangleBorder(
				borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
			),
			builder: (_) {
				return StatefulBuilder(
					builder: (context, setState) {
						final subTotal = product.price * quantity;

						return Padding(
							padding: EdgeInsets.fromLTRB(
								16,
								8,
								16,
								16 + MediaQuery.of(context).viewInsets.bottom,
							),
							child: Column(
								mainAxisSize: MainAxisSize.min,
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										'Them vao gio hang',
										style: Theme.of(context).textTheme.titleLarge,
									),
									const SizedBox(height: 12),
									Row(
										mainAxisAlignment: MainAxisAlignment.spaceBetween,
										children: [
											const Text('So luong'),
											Row(
												children: [
													IconButton(
														onPressed: quantity > 1
																? () => setState(() => quantity--)
																: null,
														icon: const Icon(Icons.remove_circle_outline),
													),
													Text(
														'$quantity',
														style: Theme.of(context).textTheme.titleMedium,
													),
													IconButton(
														onPressed: () => setState(() => quantity++),
														icon: const Icon(Icons.add_circle_outline),
													),
												],
											),
										],
									),
									const SizedBox(height: 4),
									Text(
										'Tam tinh: \$${subTotal.toStringAsFixed(2)}',
										style: Theme.of(context).textTheme.titleMedium?.copyWith(
													fontWeight: FontWeight.w700,
												),
									),
									const SizedBox(height: 16),
									SizedBox(
										width: double.infinity,
										child: FilledButton(
											onPressed: () {
												onAddToCart?.call(product, quantity);
												navigator.pop();
												messenger.showSnackBar(
													SnackBar(
														content: Text('Da chon $quantity san pham.'),
													),
												);
											},
											child: const Text('Xac nhan'),
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

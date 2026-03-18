// lib/models/product.dart

class Product {
  final int id;
  final String title;
  final double price;
  final double rating;
  final String description;
  final String category;
  final String image;
  final int soldCount;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.rating,
    required this.description,
    required this.category,
    required this.image,
    required this.soldCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rating = json['rating'];
    final rate = rating is Map<String, dynamic> ? rating['rate'] : null;
    final sold = rating is Map<String, dynamic> ? rating['count'] : null;

    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      rating: rate is num ? rate.toDouble() : 0,
      description: json['description'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
      soldCount: sold is int ? sold : 0,
    );
  }
}

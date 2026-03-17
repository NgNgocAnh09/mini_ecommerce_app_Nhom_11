import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ApiService {
  static const String _baseUrl = 'https://fakestoreapi.com';

  static Future<List<Product>> fetchProducts() async {
    final uri = Uri.parse('$_baseUrl/products');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Lỗi tải danh sách sản phẩm');
    }

    final data = json.decode(response.body) as List<dynamic>;
    return data
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

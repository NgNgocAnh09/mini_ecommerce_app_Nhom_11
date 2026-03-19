import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  // Link API mẫu từ FakeStore
  static const String baseUrl = 'https://fakestoreapi.com';

  // Lấy toàn bộ danh sách sản phẩm
 static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Product> products = body
            .map((dynamic item) => Product.fromJson(item))
            .toList();
        return products;
      } else {
        throw Exception("Không thể tải danh sách sản phẩm");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối: $e");
    }
  }

  // Lấy danh sách sản phẩm theo danh mục (cho Member 2 làm filter)
  Future<List<Product>> fetchProductsByCategory(String category) async {
    final response = await http.get(Uri.parse('$baseUrl/products/category/$category'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception("Lỗi khi tải danh mục");
    }
  }
}

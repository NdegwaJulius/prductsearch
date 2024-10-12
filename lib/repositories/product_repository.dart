import '../models/product.dart';
import '../services/api_service.dart';

class ProductRepository {
  final ApiService _apiService = ApiService();

  Future<List<Product>> getAllProducts() async {
    final jsonList = await _apiService.getAllProducts();
    return jsonList.map((json) => Product.fromJson(json)).toList();
  }

  Future<Product> getProduct(String id) async {
    final json = await _apiService.getProduct(id);
    return Product.fromJson(json);
  }

  Future<List<Product>> searchProducts(String query) async {
    final jsonList = await _apiService.searchProducts(query);
    return jsonList.map((json) => Product.fromJson(json)).toList();
  }
}
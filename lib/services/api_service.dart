// File: lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../utils/api_exception.dart';

class ApiService {
  Future<List<dynamic>> getAllProducts({int page = 1, int perPage = 20}) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/products?page=$page&per_page=$perPage'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['products'];
    } else {
      throw ApiException('Failed to fetch products');
    }
  }

  Future<dynamic> getProduct(String productId) async {
    final response = await http.get(Uri.parse('${AppConfig.apiBaseUrl}/product/$productId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ApiException('Failed to fetch product details');
    }
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/search'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'query': query, 'top_k': 20}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('API Response: $data'); // Keep this log for debugging
      final results = data['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) {
        print('No results found or results are null');
        return [];
      }
      return results.map((item) => {
        'id': item['id'] as String? ?? '',
        'name': item['metadata']['name'] as String? ?? 'No name',
        'description': item['metadata']['description'] as String? ?? 'No description',
        'price': (item['metadata']['price'] as num?)?.toDouble() ?? 0.0,
        'category': item['metadata']['category'] as String? ?? 'No category',
        'score': (item['score'] as num?)?.toDouble() ?? 0.0,
        'semanticSimilarity': (item['semantic_similarity'] as num?)?.toDouble() ?? 0.0,
        'keywordMatch': item['keyword_match'] as bool? ?? false,
      }).toList();
    } else {
      print('API Error: ${response.statusCode} - ${response.body}');
      throw ApiException('Failed to search products');
    }
  }
}
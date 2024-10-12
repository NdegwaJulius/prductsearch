// File: lib/providers/search_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class SearchResult {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final double score;
  final double semanticSimilarity;
  final bool keywordMatch;

  SearchResult({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.score,
    required this.semanticSimilarity,
    required this.keywordMatch,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      category: json['category'],
      score: json['score'],
      semanticSimilarity: json['semanticSimilarity'],
      keywordMatch: json['keywordMatch'],
    );
  }
}

final searchResultsProvider = FutureProvider.family<List<SearchResult>, String>((ref, query) async {
  try {
    final apiService = ref.read(apiServiceProvider);
    final results = await apiService.searchProducts(query);
    return results.map((result) => SearchResult.fromJson(result)).toList();
  } catch (e) {
    print('Error in searchResultsProvider: $e');
    return [];
  }
});

final apiServiceProvider = Provider((ref) => ApiService());
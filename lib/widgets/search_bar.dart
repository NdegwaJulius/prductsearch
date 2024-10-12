// File: lib/widgets/search_bar.dart

import 'package:flutter/material.dart';

class AiSearchBar extends StatefulWidget {
  final Function(String) onSearch;

  AiSearchBar({required this.onSearch});

  @override
  _AiSearchBarState createState() => _AiSearchBarState();
}

class _AiSearchBarState extends State<AiSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  void _performSearch() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      widget.onSearch(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Describe your skincare needs...',
        suffixIcon: IconButton(
          icon: Icon(Icons.search),
          onPressed: _performSearch,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onSubmitted: (_) => _performSearch(),
    );
  }
}
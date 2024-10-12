// File: lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../widgets/search_bar.dart';
import '../widgets/voice_conversation_widget.dart';
import 'product_list_screen.dart';
import 'search_result_screen.dart';
import 'cart_screen.dart';
import '../providers/cart_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final String userName = "Julius";
  bool _isLoading = false;

  final List<QueryOption> _queryOptions = [
    QueryOption(
      title: "Recommend products for oily skin",
      icon: Icons.face,
    ),
    QueryOption(
      title: "Recommend products for dry skin",
      icon: Icons.attach_money,
    ),
    QueryOption(
      title: "Suggest anti-aging serums",
      icon: Icons.access_time,
    ),

  ];

  void _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(query: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('SkinCare AI Assistant'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                },
              ),
              if (cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartItems.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  SizedBox(height: 10),
                  Text(
                    'Hello $userName,\nHow can I help you today?',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  AiSearchBar(onSearch: _performSearch),
                  SizedBox(height: 20),
                  Text(
                    'Or try one of these:',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  ..._queryOptions.map((option) => _buildQueryOption(option)).toList(),
                  Spacer(),
                  // add a clickable voice search button
                  VoiceConversationWidget(onSearch: _performSearch,),

                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Lottie.network(
                    'https://assets9.lottiefiles.com/packages/lf20_b88nh30c.json',
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueryOption(QueryOption option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton.icon(
        icon: Icon(option.icon),
        label: Text(option.title),
        onPressed: () => _performSearch(option.title),
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }
}


class QueryOption {
  final String title;
  final IconData icon;

  QueryOption({required this.title, required this.icon});
}
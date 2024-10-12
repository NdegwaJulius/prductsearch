import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/search_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/user_provider.dart';
import '../config/app_theme.dart';
import '../widgets/voice_conversation_widget.dart';
import 'cart_screen.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  final String query;

  const SearchResultsScreen({Key? key, required this.query}) : super(key: key);

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speakLoadingMessage();
  }

  Future<void> _speakLoadingMessage() async {
    String userName = ref.read(userProvider).name;
    String message = 'Hey $userName, hang in there as we look for the best match of what you need!';

    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(message);
  }

  void _performSearch(String query) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(query: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider(widget.query));
    final cartItems = ref.watch(cartProvider);
    final userName = ref.watch(userProvider).name;

    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "${widget.query}"'),
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
                      color: AppTheme.purpleLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartItems.length}',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          searchResults.when(
            data: (products) {
              if (products.isEmpty) {
                return Center(child: Text('No results found for "${widget.query}"'));
              }
              return ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Hey $userName, here are the top recommendations for you!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.greenDark),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ...products.map((product) => _buildProductCard(product)).toList(),
                  _buildFeedbackSection(),
                ],
              );
            },
            loading: () => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.purplePrimary),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Hey $userName, hang in there as we look for the best match of what you need!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.greenDark),
                  ),
                ],
              ),
            ),
            error: (error, stack) => Center(child: Text('Error: Unable to fetch results', style: TextStyle(color: AppTheme.error))),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext context) {
                    return DraggableScrollableSheet(
                      initialChildSize: 0.5,
                      minChildSize: 0.2,
                      maxChildSize: 0.8,
                      builder: (_, controller) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          child: VoiceConversationWidget(onSearch: _performSearch, ),
                        );
                      },
                    );
                  },
                );
              },
              child: Icon(Icons.mic),
              backgroundColor: AppTheme.purplePrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(SearchResult product) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.greenPrimary),
            ),
            SizedBox(height: 4),
            Text(product.description),
            SizedBox(height: 4),
            Text(
              'Price: \$${product.price.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.purpleDark),
            ),
            Text('Category: ${product.category}'),
            SizedBox(height: 8),
            _buildAccuracyIndicator(product),
            SizedBox(height: 8),
            ElevatedButton(
              child: Text('Add to Cart'),
              onPressed: () {
                ref.read(cartProvider.notifier).addToCart({
                  'id': product.id,
                  'name': product.name,
                  'price': product.price,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added to cart'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccuracyIndicator(SearchResult product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildScoreRow('Match Score', product.score),
        _buildScoreRow('Similarity', product.semanticSimilarity),
        Row(
          children: [
            Text('Keyword Match: '),
            Icon(
              product.keywordMatch ? Icons.check_circle : Icons.cancel,
              color: product.keywordMatch ? AppTheme.success : AppTheme.error,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreRow(String label, double score) {
    return Row(
      children: [
        Text('$label: '),
        Container(
          width: 100,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(5),
          ),
          child: FractionallySizedBox(
            widthFactor: score,
            child: Container(
              decoration: BoxDecoration(
                color: _getColorForScore(score),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        Text('${(score * 100).toStringAsFixed(0)}%'),
      ],
    );
  }

  Color _getColorForScore(double score) {
    if (score < 0.3) return AppTheme.error;
    if (score < 0.6) return AppTheme.warning;
    if (score < 0.8) return AppTheme.purpleLight;
    return AppTheme.success;
  }

  Widget _buildFeedbackSection() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Not satisfied with the results?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.greenDark),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _feedbackController,
            decoration: InputDecoration(
              hintText: 'Describe what you\'re looking for...',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.purplePrimary),
              ),
            ),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            child: Text('Refine Search'),
            onPressed: () {
              if (_feedbackController.text.isNotEmpty) {
                _performSearch(_feedbackController.text);
              }
            },
          ),
        ],
      ),
    );
  }
}

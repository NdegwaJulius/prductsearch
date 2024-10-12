// File: lib/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: cartItems.isEmpty
          ? Center(child: Text('Your cart is empty'))
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.image, size: 30, color: Colors.grey[600]),
            ),
            title: Text(item['name']),
            subtitle: Text('\$${(item['price'] as num).toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle_outline),
              onPressed: () {
                ref.read(cartProvider.notifier).removeFromCart(item);
              },
            ),
          );
        },
      ),
      bottomNavigationBar: cartItems.isNotEmpty
          ? Padding(
        padding: EdgeInsets.all(8.0),
        child: ElevatedButton(
          child: Text('Proceed to Checkout'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => CheckoutScreen()),
            );
          },
        ),
      )
          : null,
    );
  }
}
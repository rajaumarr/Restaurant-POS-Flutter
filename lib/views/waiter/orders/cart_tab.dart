// lib/views/waiter/order/cart_tab.dart
import 'package:flutter/material.dart';
import '../../../models/cart_item_model.dart';

class CartTab extends StatelessWidget {
  final List<CartItemModel> cartItems;
  final double totalAmount;
  final void Function(CartItemModel) onRemove;
  final void Function(CartItemModel) onIncrement;
  final void Function(CartItemModel) onDecrement;
  final int tableNumber;
  final Future<void> Function() onPlaceOrder;
  final bool isEditing;

  const CartTab({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
    required this.tableNumber,
    required this.onPlaceOrder,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    if (cartItems.isEmpty) {
      return const Center(child: Text('Cart is empty'));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cartItems[index];
              return ListTile(
                title: Text(cartItem.item.name),
                subtitle: Text('${cartItem.quantity} × ${cartItem.item.price.toStringAsFixed(3)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        // delegate decrement to parent
                        onDecrement(cartItem);
                      },
                    ),
                    Text('${cartItem.quantity}'),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        // delegate increment to parent
                        onIncrement(cartItem);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => onRemove(cartItem),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Total: ${totalAmount.toStringAsFixed(3)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await onPlaceOrder();
                  },
                  child: Text(isEditing ? 'Save Changes' : 'Place Order'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

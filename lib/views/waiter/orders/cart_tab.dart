import 'package:flutter/material.dart';
import 'package:miral/models/cart_item_model.dart';

class CartTab extends StatelessWidget {
  final List<CartItemModel> cartItems;
  final double totalAmount;
  final Function(CartItemModel) onRemove;

  const CartTab({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if(cartItems.isEmpty){
        return const Center(child: Text('Cart is empty'));
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index){
              final cartItem = cartItems[index];

              return ListTile(
                title: Text(cartItem.item.name),
                subtitle: Text(
                    '${cartItem.quantity} x ${cartItem.item.price.toStringAsFixed(3)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => onRemove(cartItem),
                ),
              );
            }
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Total: ${totalAmount.toStringAsFixed(3)} BHD',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 1),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:(){

                  },
                  child: const Text('Place Order'),
                ),
              ),

            ],
          ),

        ),
      ],
    );
  }
}

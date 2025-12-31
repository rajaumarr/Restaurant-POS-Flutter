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
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = cartItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cartItem.item.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D4D),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${cartItem.item.price.toStringAsFixed(3)} BHD',
                                style: TextStyle(
                                  color: Colors.blueAccent.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_rounded, size: 20, color: Colors.blueAccent),
                                onPressed: () => onDecrement(cartItem),
                              ),
                              Text(
                                '${cartItem.quantity}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D4D),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_rounded, size: 20, color: Colors.blueAccent),
                                onPressed: () => onIncrement(cartItem),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
                          onPressed: () => onRemove(cartItem),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL AMOUNT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '${totalAmount.toStringAsFixed(3)} BHD',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D2D4D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      await onPlaceOrder();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isEditing ? 'SAVE CHANGES' : 'PLACE ORDER',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

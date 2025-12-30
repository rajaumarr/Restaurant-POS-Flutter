import 'package:flutter/material.dart';
import 'order_detail_screen.dart';

class OrderCard extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    final orderNumber = orderData['orderNumber'] ?? orderId;
    final tableNumber = orderData['tableNumber'] ?? '-';
    final status = orderData['status'] ?? 'active';
    final total = (orderData['totalAmount'] ?? 0).toDouble();

    return Card(
      child: ListTile(
        title: Text('$orderNumber — Table $tableNumber'),
        subtitle: Text('Status: $status\nTotal: ${total.toStringAsFixed(3)}'),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId)),
            );
          },
        ),
      ),
    );
  }
}

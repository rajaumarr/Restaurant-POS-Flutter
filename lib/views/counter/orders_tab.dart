import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import 'order_detail_screen.dart';
import 'order_card.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderService orderService = OrderService();

    return Container(
      color: Colors.white,
      child: StreamBuilder<QuerySnapshot>(
        stream: orderService.streamAllActiveOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 60, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text('Failed to load orders', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  Text(
                    'No active orders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              return OrderCard(
                orderId: doc.id,
                orderData: data,
              );
            },
          );
        },
      ),
    );
  }
}

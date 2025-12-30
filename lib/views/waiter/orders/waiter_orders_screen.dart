// lib/views/waiter/waiter_orders_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../services/order_service.dart';

class WaiterOrdersScreen extends StatefulWidget {
  const WaiterOrdersScreen({super.key});

  @override
  State<WaiterOrdersScreen> createState() => _WaiterOrdersScreenState();
}

class _WaiterOrdersScreenState extends State<WaiterOrdersScreen> {
  final OrderService _orderService = OrderService();
  int _selectedIndex = 0;
  final List<String> statuses = ['all', 'active', 'completed', 'cancelled'];

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> stream;
    if (_selectedIndex == 0) {
      stream = FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).limit(50).snapshots();
    } else {
      final status = statuses[_selectedIndex];
      stream = FirebaseFirestore.instance.collection('orders').where('status', isEqualTo: status).orderBy('createdAt', descending: true).snapshots();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: Column(
        children: [
          // filter tabs
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedIndex == 0,
                  onSelected: (_) => setState(() => _selectedIndex = 0),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Active'),
                  selected: _selectedIndex == 1,
                  onSelected: (_) => setState(() => _selectedIndex = 1),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Completed'),
                  selected: _selectedIndex == 2,
                  onSelected: (_) => setState(() => _selectedIndex = 2),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Cancelled'),
                  selected: _selectedIndex == 3,
                  onSelected: (_) => setState(() => _selectedIndex = 3),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: stream,
              builder: (context, snap) {
                if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('No orders found'));

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final d = docs[index];
                    final data = d.data() as Map<String, dynamic>? ?? {};
                    final orderNo = data['orderNumber'] ?? d.id;
                    final tableNo = data['tableNumber']?.toString() ?? '-';
                    final status = data['status'] ?? '';
                    final total = (data['totalAmount'] is num) ? (data['totalAmount'] as num).toDouble() : 0.0;

                    return ListTile(
                      title: Text('$orderNo — Table $tableNo'),
                      subtitle: Text('Status: $status   Total: ${total.toStringAsFixed(3)}'),
                      onTap: () {
                        // optional: navigate to order detail screen
                      },
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

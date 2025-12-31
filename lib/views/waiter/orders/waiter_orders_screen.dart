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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'ORDER HISTORY',
          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D2D4D), letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: statuses.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blueAccent : const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        statuses[index].toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF5D5D7A),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: stream,
              builder: (context, snap) {
                if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade200),
                        const SizedBox(height: 16),
                        Text('No orders found', style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final d = docs[index];
                    final data = d.data() as Map<String, dynamic>? ?? {};
                    final orderNo = data['orderNumber'] ?? d.id.substring(0, 6);
                    final tableNo = data['tableNumber']?.toString() ?? '-';
                    final status = data['status'] ?? 'unknown';
                    final total = (data['totalAmount'] is num) ? (data['totalAmount'] as num).toDouble() : 0.0;

                    Color statusColor;
                    switch (status.toLowerCase()) {
                      case 'active': statusColor = Colors.orangeAccent; break;
                      case 'completed': statusColor = Colors.greenAccent.shade700; break;
                      case 'cancelled': statusColor = Colors.redAccent; break;
                      default: statusColor = Colors.grey;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF5F5F7), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ORDER #$orderNo',
                              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D2D4D), fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.table_bar_outlined, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('Table $tableNo', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                                const Spacer(),
                                Text(
                                  '${total.toStringAsFixed(3)} BHD',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                        },
                      ),
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

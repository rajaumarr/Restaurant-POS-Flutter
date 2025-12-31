import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CounterReportsScreen extends StatelessWidget {
  const CounterReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersRef = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .limit(30);

    return Container(
      color: Colors.white,
      child: StreamBuilder<QuerySnapshot>(
        stream: ordersRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
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
                  Icon(Icons.analytics_outlined, size: 80, color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  Text('No reports data available', style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
                ],
              ),
            );
          }

          double totalRevenue = 0.0;
          int countCompleted = 0;
          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final amt = (data['totalAmount'] is num) ? (data['totalAmount'] as num).toDouble() : 0.0;
            final status = (data['status'] ?? '').toString();
            totalRevenue += amt;
            if (status == 'completed') countCompleted++;
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'QUICK SUMMARY',
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 12, letterSpacing: 1),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'TOTAL REVENUE',
                      '${totalRevenue.toStringAsFixed(3)}',
                      Icons.payments_rounded,
                      Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      'COMPLETED',
                      countCompleted.toString(),
                      Icons.check_circle_rounded,
                      Colors.greenAccent.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'RECENT TRANSACTIONS',
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 12, letterSpacing: 1),
              ),
              const SizedBox(height: 16),
              ...docs.asMap().entries.map((entry) {
                final index = entry.key;
                final d = entry.value;
                final data = d.data() as Map<String, dynamic>;
                final orderNo = data['orderNumber'] ?? d.id.substring(0, 6);
                final amt = (data['totalAmount'] is num) ? (data['totalAmount'] as num).toDouble() : 0.0;
                final status = (data['status'] ?? 'unknown').toString();

                Color statusColor;
                switch (status.toLowerCase()) {
                  case 'completed': statusColor = Colors.greenAccent.shade700; break;
                  case 'cancelled': statusColor = Colors.redAccent; break;
                  default: statusColor = Colors.orangeAccent;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF5F5F7)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D2D4D)),
                      ),
                    ),
                    title: Text(
                      'ORDER #$orderNo',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D4D)),
                    ),
                    subtitle: Container(
                      margin: const EdgeInsets.only(top: 4),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    trailing: Text(
                      '${amt.toStringAsFixed(3)} BHD',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.blueAccent, fontSize: 14),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 10, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 20),
          ),
        ],
      ),
    );
  }
}

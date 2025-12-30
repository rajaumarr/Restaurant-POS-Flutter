// lib/views/counter/counter_reports_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CounterReportsScreen extends StatelessWidget {
  const CounterReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example report: get recent orders and compute totals (safe checks)
    final ordersRef = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .limit(30);

    return StreamBuilder<QuerySnapshot>(
      stream: ordersRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No orders yet'));
        }

        // Safely compute simple aggregates
        double totalRevenue = 0.0;
        int countCompleted = 0;
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final amt = (data['totalAmount'] is num) ? (data['totalAmount'] as num).toDouble() : 0.0;
          final status = (data['status'] ?? '').toString();
          totalRevenue += amt;
          if (status == 'completed') countCompleted++;
        }

        // Build a safe UI without indexing into fixed positions
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Card(
                child: ListTile(
                  title: const Text('Recent Orders (last 30)'),
                  subtitle: Text('Total revenue (these): ${totalRevenue.toStringAsFixed(3)}'),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: const Text('Completed orders (last 30)'),
                  trailing: Text(countCompleted.toString()),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final d = docs[index];
                    final data = d.data() as Map<String, dynamic>;
                    final orderNo = data['orderNumber'] ?? d.id;
                    final amt = (data['totalAmount'] is num) ? (data['totalAmount'] as num).toDouble() : 0.0;
                    final status = (data['status'] ?? 'unknown').toString();
                    return ListTile(
                      leading: Text('${index + 1}'),
                      title: Text('$orderNo — ${status.toUpperCase()}'),
                      subtitle: Text('Amount: ${amt.toStringAsFixed(3)}'),
                      onTap: () {
                        // Optional: navigate to order detail
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

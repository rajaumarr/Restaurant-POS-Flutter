// lib/views/admin/orders/admin_orders_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});
  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _statusFilter = 'all';
  DateTimeRange? _range;

  Stream<QuerySnapshot> _buildStream() {
    final col = FirebaseFirestore.instance.collection('orders');
    Query q = col;
    if (_statusFilter != 'all') q = q.where('status', isEqualTo: _statusFilter);
    if (_range != null) {
      q = q.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(_range!.start));
      q = q.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(_range!.end));
    }
    q = q.orderBy('createdAt', descending: true).limit(200);
    return q.snapshots();
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _range ?? DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
    );
    if (result != null) setState(() => _range = result);
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _range == null ? 'All time' : '${DateFormat.yMd().format(_range!.start)} - ${DateFormat.yMd().format(_range!.end)}';
    return Scaffold(
      appBar: AppBar(title: const Text('Orders - Admin')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _statusFilter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'processing', child: Text('Processing')),
                    DropdownMenuItem(value: 'in_kitchen', child: Text('In Kitchen')),
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                    DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                  ],
                  onChanged: (v) => setState(() => _statusFilter = v ?? 'all'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _pickRange, child: Text(dateLabel)),
                const SizedBox(width: 12),
                if (_range != null)
                  TextButton(onPressed: () => setState(() => _range = null), child: const Text('Clear range')),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildStream(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
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
                    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                    return ListTile(
                      title: Text('$orderNo — Table $tableNo'),
                      subtitle: Text('Status: $status • ${createdAt != null ? DateFormat.yMd().add_jm().format(createdAt) : ''}'),
                      trailing: Text(total.toStringAsFixed(3)),
                      onTap: () {
                        // Optional: navigate to order detail
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

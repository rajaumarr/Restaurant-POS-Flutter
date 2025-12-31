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
      q = q.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(_range!.end.add(const Duration(days: 1))));
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              onSurface: Color(0xFF2D2D4D),
            ),
          ),
          child: child!,
        );
      },
    );
    if (result != null) setState(() => _range = result);
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _range == null ? 'ALL TIME' : '${DateFormat.yMMMd().format(_range!.start)} - ${DateFormat.yMMMd().format(_range!.end)}';
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'ORDER MANAGEMENT',
          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D2D4D), fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _statusFilter,
                        isExpanded: true,
                        icon: const Icon(Icons.filter_list_rounded, color: Colors.blueAccent, size: 20),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D4D)),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('ALL STATUSES')),
                          DropdownMenuItem(value: 'active', child: Text('ACTIVE')),
                          DropdownMenuItem(value: 'processing', child: Text('PROCESSING')),
                          DropdownMenuItem(value: 'in_kitchen', child: Text('IN KITCHEN')),
                          DropdownMenuItem(value: 'completed', child: Text('COMPLETED')),
                          DropdownMenuItem(value: 'cancelled', child: Text('CANCELLED')),
                        ],
                        onChanged: (v) => setState(() => _statusFilter = v ?? 'all'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: _pickRange,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _range != null ? Colors.blueAccent.withOpacity(0.3) : Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, color: _range != null ? Colors.blueAccent : Colors.grey, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              dateLabel,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _range != null ? Colors.blueAccent : const Color(0xFF5D5D7A),
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_range != null)
                            GestureDetector(
                              onTap: () {
                                setState(() => _range = null);
                              },
                              child: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildStream(),
              builder: (context, snap) {
                if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_rounded, size: 80, color: Colors.grey.shade200),
                        const SizedBox(height: 16),
                        const Text('No matching orders found', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final d = docs[index];
                    final data = d.data() as Map<String, dynamic>? ?? {};
                    final orderNo = data['orderNumber'] ?? d.id.substring(0, 6);
                    final tableNo = data['tableNumber']?.toString() ?? '-';
                    final status = (data['status'] ?? '').toString().toLowerCase();
                    final total = (data['totalAmount'] is num) ? (data['totalAmount'] as num).toDouble() : 0.0;
                    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

                    Color statusColor;
                    IconData statusIcon;
                    switch (status) {
                      case 'active': 
                        statusColor = Colors.green.shade700; 
                        statusIcon = Icons.pending_actions_rounded;
                        break;
                      case 'processing': 
                        statusColor = Colors.orange.shade800; 
                        statusIcon = Icons.hourglass_empty_rounded;
                        break;
                      case 'in_kitchen': 
                        statusColor = Colors.blue.shade800; 
                        statusIcon = Icons.restaurant_rounded;
                        break;
                      case 'completed': 
                        statusColor = Colors.indigo.shade700; 
                        statusIcon = Icons.check_circle_rounded;
                        break;
                      case 'cancelled': 
                        statusColor = Colors.red.shade800; 
                        statusIcon = Icons.cancel_rounded;
                        break;
                      default: 
                        statusColor = Colors.grey;
                        statusIcon = Icons.help_outline_rounded;
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(statusIcon, color: statusColor, size: 24),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ORDER #$orderNo',
                              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D2D4D), fontSize: 15),
                            ),
                            Text(
                              '${total.toStringAsFixed(3)} BHD',
                              style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.blueAccent, fontSize: 15),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.table_bar_rounded, size: 14, color: statusColor),
                                const SizedBox(width: 4),
                                Text(
                                  'TABLE $tableNo', 
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 13)
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  createdAt != null ? DateFormat('HH:mm').format(createdAt) : '--:--',
                                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              status.toUpperCase(),
                              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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
          ),
        ],
      ),
    );
  }
}

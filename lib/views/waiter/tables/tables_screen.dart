import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'table_card.dart';

class TablesScreen extends StatelessWidget {
  const TablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tablesRef = FirebaseFirestore.instance.collection('tables');

    return Scaffold(
      appBar: AppBar(title: const Text('Tables')),
      body: StreamBuilder<QuerySnapshot>(
        stream: tablesRef.orderBy('tableNumber').snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No tables defined'));

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              itemCount: docs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              itemBuilder: (context, index) {
                final d = docs[index];
                final data = d.data() as Map<String, dynamic>? ?? {};
                final tableNo = (data['tableNumber'] is num) ? (data['tableNumber'] as num).toInt() : int.tryParse((data['tableNumber'] ?? '').toString()) ?? (index + 1);
                final occupied = data['isOccupied'] ?? false;
                return TableCard(tableNumber: tableNo, isOccupied: occupied);
              },
            ),
          );
        },
      ),
    );
  }
}

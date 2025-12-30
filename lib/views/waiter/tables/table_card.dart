// lib/views/waiter/tables/table_card.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../orders/order_screen.dart'; // relative import; adjust if your project structure differs

class TableCard extends StatelessWidget {
  final int tableNumber;
  final bool isOccupied;

  const TableCard({
    super.key,
    required this.tableNumber,
    required this.isOccupied,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isOccupied ? Colors.red.shade400 : Colors.green.shade400;
    final textColor = Colors.white;

    return GestureDetector(
      onTap: () async {
        final tableDocRef = FirebaseFirestore.instance.collection('tables').doc('table_$tableNumber');
        final tableSnap = await tableDocRef.get();

        final bool occupied = tableSnap.exists ? (tableSnap.data()?['isOccupied'] ?? false) : false;

        if (!occupied) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OrderScreen(tableNumber: tableNumber, orderId: null)),
          );
        } else {
          final activeOrderId = tableSnap.data()?['activeOrderId'] as String?;
          if (activeOrderId == null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OrderScreen(tableNumber: tableNumber, orderId: null)),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OrderScreen(tableNumber: tableNumber, orderId: activeOrderId)),
            );
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Center(
          child: Text(
            'Table $tableNumber',
            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

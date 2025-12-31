import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../orders/order_pos_screen.dart';
import '../orders/order_screen.dart';

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
    final Color mainColor = isOccupied ? Colors.redAccent.shade200 : Colors.greenAccent.shade700;
    
    return GestureDetector(
      onTap: () async {
        String? activeOrderId;
        
        if (isOccupied) {
          // Show loading indicator if needed, but for now we just fetch
          try {
            final tableDoc = await FirebaseFirestore.instance
                .collection('tables')
                .doc('table_$tableNumber')
                .get();
            
            if (tableDoc.exists) {
              activeOrderId = tableDoc.data()?['activeOrderId'] as String?;
            }
          } catch (e) {
            debugPrint('Error fetching active order ID: $e');
          }
        }

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                final width = MediaQuery.of(context).size.width;
                return width > 900
                    ? OrderPosScreen(tableNumber: tableNumber, orderId: activeOrderId)
                    : OrderScreen(tableNumber: tableNumber, orderId: activeOrderId);
              },
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: mainColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: mainColor.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_rounded,
                color: mainColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Table $tableNumber',
              style: const TextStyle(
                color: Color(0xFF2D2D4D),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isOccupied ? 'OCCUPIED' : 'AVAILABLE',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

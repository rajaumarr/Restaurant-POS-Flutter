import 'package:flutter/material.dart';
import 'package:miral/views/waiter/orders/order_screen.dart';

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
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderScreen(tableNumber: tableNumber),
          )
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isOccupied ? Colors.red.shade300 : Colors.green.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child:Text(
            'Table $tableNumber',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
          ),
          )
        ),
      ),
    );
  }
}

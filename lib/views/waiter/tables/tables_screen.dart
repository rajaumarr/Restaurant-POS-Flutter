import 'package:flutter/material.dart';
import 'package:miral/views/waiter/tables/table_card.dart';

class TablesScreen extends StatelessWidget {
  const TablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tables = List.generate(12, (index) => index + 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tables'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: tables.length,
          itemBuilder: (context, index){
            return TableCard(
              tableNumber: tables[index],
              isOccupied:false,
            );
          }
        ),
      ),

    );
  }
}

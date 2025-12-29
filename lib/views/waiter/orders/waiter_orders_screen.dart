import 'package:flutter/material.dart';

class WaiterOrdersScreen extends StatelessWidget {
  const WaiterOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: const Center(
        child: Text(
          'Order List\n(Active / Completed / Cancelled',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

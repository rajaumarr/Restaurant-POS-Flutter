import 'package:flutter/material.dart';

class CounterHome extends StatelessWidget {
  const CounterHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'COUNTER PORTAL',
          style: TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'tables/tables_screen.dart';
import 'orders/waiter_orders_screen.dart';

class WaiterHome extends StatefulWidget {
  const WaiterHome({super.key});

  @override
  State<WaiterHome> createState() => _WaiterHomeState();
}

class _WaiterHomeState extends State<WaiterHome> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    TablesScreen(),
    WaiterOrdersScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'WAITER PORTAL',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Color(0xFF2D2D4D)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/pin-login',
                  (_) => false,
                );
              },
            ),
          )
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.table_restaurant_rounded),
              activeIcon: Icon(Icons.table_restaurant_rounded, size: 28),
              label: 'TABLES',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              activeIcon: Icon(Icons.receipt_long_rounded, size: 28),
              label: 'ORDERS',
            ),
          ],
        ),
      ),
    );
  }
}

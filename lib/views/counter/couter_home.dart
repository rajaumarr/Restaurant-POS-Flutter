import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:miral/views/counter/counter_reports_screen.dart';
import '../../services/counter_notification_service.dart';
import 'orders_tab.dart';


class CounterHomeScreen extends StatefulWidget {
  const CounterHomeScreen({super.key});

  @override
  State<CounterHomeScreen> createState() => _CounterHomeScreenState();
}

class _CounterHomeScreenState extends State<CounterHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _notifService = CounterNotificationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _notifService.startListening().catchError((e) {
      debugPrint('Failed to start CounterNotificationService: $e');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notifService.stopListening();
    super.dispose();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/pin-login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Orders'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OrdersTab(),
          CounterReportsScreen(),
        ],
      ),
    );
  }
}

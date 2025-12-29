import 'package:flutter/material.dart';
import 'package:miral/services/admin_auth_service.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
              onPressed: () async {
                await AdminAuthService().logout();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.logout)
          )
        ],
      ),
      body: const Center(
        child: Text(
          'Admin DashBoard\n(Menu, Tables, Orders, Reveneue',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}

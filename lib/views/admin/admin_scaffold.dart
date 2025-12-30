// lib/views/admin/admin_scaffold.dart
import 'package:flutter/material.dart';
import 'menu/admin_categories_screen.dart';
import 'menu/admin_items_screen.dart';
import 'tables/admin_tables_screen.dart';
import 'orders/admin_orders_screen.dart';
import 'pin/admin_pin_screen.dart';
import 'account/admin_account_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminScaffold extends StatefulWidget {
  const AdminScaffold({super.key});

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  int _selectedIndex = 0;
  bool _collapsed = false;

  final List<_AdminPage> _pages = [
    _AdminPage('Categories', Icons.category, const AdminCategoriesScreen()),
    _AdminPage('Menu Items', Icons.food_bank, const AdminItemsScreen()),
    _AdminPage('Tables', Icons.table_bar, const AdminTablesScreen()),
    _AdminPage('Orders', Icons.list_alt, const AdminOrdersScreen()),
    _AdminPage('PIN (Staff)', Icons.pin, const AdminPinScreen()),
    _AdminPage('Account', Icons.person, const AdminAccountScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _collapsed ? 64 : 220,
            color: Theme.of(context).drawerTheme.backgroundColor ?? Colors.grey.shade100,
            child: Column(
              children: [
                SizedBox(height: 40),
                IconButton(
                  icon: Icon(_collapsed ? Icons.menu_open : Icons.menu),
                  onPressed: () => setState(() => _collapsed = !_collapsed),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _pages.length,
                    itemBuilder: (context, i) {
                      final p = _pages[i];
                      final selected = i == _selectedIndex;
                      return InkWell(
                        onTap: () => setState(() => _selectedIndex = i),
                        child: Container(
                          color: selected ? Colors.blue.withOpacity(0.12) : Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          child: Row(
                            children: [
                              Icon(p.icon, color: selected ? Colors.blue : Colors.black54),
                              if (!_collapsed) ...[
                                const SizedBox(width: 12),
                                Expanded(child: Text(p.title)),
                              ]
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                if (!_collapsed)
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      // assume your app uses routes: pop to login
                      Navigator.of(context).pushNamedAndRemoveUntil('/pin-login', (route) => false);
                    },
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushNamedAndRemoveUntil('/pin-login', (route) => false);
                    },
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Content area
          Expanded(child: _pages[_selectedIndex].page),
        ],
      ),
    );
  }
}

class _AdminPage {
  final String title;
  final IconData icon;
  final Widget page;
  _AdminPage(this.title, this.icon, this.page);
}

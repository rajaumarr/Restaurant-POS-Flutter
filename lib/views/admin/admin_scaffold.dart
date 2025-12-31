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
    _AdminPage('Categories', Icons.category_rounded, const AdminCategoriesScreen()),
    _AdminPage('Menu Items', Icons.restaurant_menu_rounded, const AdminItemsScreen()),
    _AdminPage('Tables', Icons.table_bar_rounded, const AdminTablesScreen()),
    _AdminPage('Orders', Icons.receipt_long_rounded, const AdminOrdersScreen()),
    _AdminPage('PIN (Staff)', Icons.pin_rounded, const AdminPinScreen()),
    _AdminPage('Account', Icons.person_rounded, const AdminAccountScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _collapsed ? 80 : 260,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              border: Border(right: BorderSide(color: Colors.grey.shade200, width: 1.5)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),
                if (!_collapsed)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'MIRAL ADMIN',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D2D4D),
                        letterSpacing: 1.5,
                      ),
                    ),
                  )
                else
                  const Icon(Icons.dashboard_rounded, color: Colors.blueAccent, size: 28),
                
                const SizedBox(height: 30),
                IconButton(
                  icon: Icon(_collapsed ? Icons.menu_rounded : Icons.menu_open_rounded, color: Colors.blueAccent),
                  onPressed: () => setState(() => _collapsed = !_collapsed),
                ),
                const SizedBox(height: 20),
                
                Expanded(
                  child: ListView.builder(
                    itemCount: _pages.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, i) {
                      final p = _pages[i];
                      final selected = i == _selectedIndex;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => setState(() => _selectedIndex = i),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: selected ? Colors.blueAccent : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: selected ? [
                                BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                              ] : [],
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(p.icon, color: selected ? Colors.white : const Color(0xFF5D5D7A)),
                                  if (!_collapsed) ...[
                                    const SizedBox(width: 16),
                                    Text(
                                      p.title,
                                      style: TextStyle(
                                        color: selected ? Colors.white : const Color(0xFF2D2D4D),
                                        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const Divider(indent: 15, endIndent: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  child: InkWell(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/pin-login', (route) => false);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.logout_rounded, color: Colors.redAccent),
                            if (!_collapsed) ...[
                              const SizedBox(width: 16),
                              const Text(
                                'Logout',
                                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: Container(
              color: Colors.white,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: KeyedSubtree(
                  key: ValueKey(_selectedIndex),
                  child: _pages[_selectedIndex].page,
                ),
              ),
            ),
          ),
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

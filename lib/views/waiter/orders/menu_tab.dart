// lib/views/waiter/order/menu_tab.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:miral/models/menu_item_model.dart';
import 'package:flutter/foundation.dart';

class MenuTab extends StatefulWidget {
  final Function(MenuItemModel) onAdd;

  const MenuTab({super.key, required this.onAdd});

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final categoriesRef = FirebaseFirestore.instance.collection('categories');

    return Column(
      children: [
        // Categories row
        SizedBox(
          height: 72,
          child: StreamBuilder<QuerySnapshot>(
            stream: categoriesRef
                .where('isActive', isEqualTo: true)
                .orderBy('position')
                .snapshots(),
            builder: (context, snap) {
              if (snap.hasError) {
                return Center(child: Text('Failed to load categories: ${snap.error}'));
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text('No categories defined. Add categories in Admin.'));
              }

              // Ensure selected category is set (safely after build)
              if (_selectedCategoryId == null) {
                final firstId = docs.first.id;
                // schedule setting state after this build frame
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _selectedCategoryId == null) {
                    setState(() {
                      _selectedCategoryId = firstId;
                    });
                  }
                });
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemBuilder: (context, index) {
                  final d = docs[index];
                  final data = d.data() as Map<String, dynamic>? ?? {};
                  final name = (data['name'] ?? 'Unnamed') as String;
                  final id = d.id;
                  final selected = id == _selectedCategoryId;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategoryId = id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: selected ? Theme.of(context).primaryColor : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          name,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: docs.length,
              );
            },
          ),
        ),

        // Items list for selected category
        Expanded(
          child: _selectedCategoryId == null
              ? const Center(child: Text('Loading categories...'))
              : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('items')
                .where('categoryId', isEqualTo: _selectedCategoryId)
                .where('isAvailable', isEqualTo: true)
                .orderBy('position')
                .snapshots(),
            builder: (context, snap) {
              if (snap.hasError) {
                // If Firestore asks for an index, it will show in snap.error — show friendly message
                return Center(child: Text('Failed to load items: ${snap.error}'));
              }
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snap.data!.docs;
              if (docs.isEmpty) return const Center(child: Text('No items in this category'));

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final d = docs[index];
                  final data = d.data() as Map<String, dynamic>? ?? {};
                  final name = (data['name'] ?? 'Unnamed') as String;
                  final priceNum = data['price'];
                  final price = (priceNum is num) ? priceNum.toDouble() : double.tryParse(priceNum?.toString() ?? '0') ?? 0.0;

                  final menuItem = MenuItemModel(
                    id: d.id,
                    name: name,
                    price: price,
                    category: data['categoryId'] ?? '',
                  );

                  return ListTile(
                    title: Text(menuItem.name),
                    subtitle: Text('${menuItem.price.toStringAsFixed(3)}'),
                    trailing: ElevatedButton(
                      onPressed: () => widget.onAdd(menuItem),
                      child: const Text('Add'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

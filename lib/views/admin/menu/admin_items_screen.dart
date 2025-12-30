// lib/views/admin/menu/admin_items_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../services/admin_menu_service.dart';
import 'add_edit_item_screen.dart';

class AdminItemsScreen extends StatefulWidget {
  const AdminItemsScreen({super.key});

  @override
  State<AdminItemsScreen> createState() => _AdminItemsScreenState();
}

class _AdminItemsScreenState extends State<AdminItemsScreen> {
  final AdminMenuService _service = AdminMenuService();
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditItemScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: _service.streamCategories(),
              builder: (context, snap) {
                // if (!snap.hasData) return const LinearProgressIndicator();
                final docs = snap.data!.docs;
                final items = docs.map((d) {
                  final data = d.data() as Map<String, dynamic>? ?? {};
                  return {'id': d.id, 'name': data['name'] ?? 'Unnamed'};
                }).toList();
                final dropdownItems = [
                  const DropdownMenuItem<String?>(value: null, child: Text('All categories')),
                  ...items.map((e) => DropdownMenuItem<String?>(
                    value: e['id'] as String,
                    child: Text(e['name'] as String),
                  ))
                ];
                return Row(
                  children: [
                    const Text('Category: '),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String?>(
                        isExpanded: true,
                        value: _selectedCategoryId,
                        items: dropdownItems,
                        onChanged: (v) => setState(() => _selectedCategoryId = v),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Items list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _selectedCategoryId == null
                  ? _service.streamAllItems()
                  : FirebaseFirestore.instance
                  .collection('items')
                  .where('categoryId', isEqualTo: _selectedCategoryId)
                  .orderBy('position')
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('No items found'));
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final d = docs[index];
                    final data = d.data() as Map<String, dynamic>? ?? {};
                    final name = data['name'] ?? 'Unnamed';
                    final price = (data['price'] is num) ? (data['price'] as num).toDouble() : double.tryParse(data['price']?.toString() ?? '0') ?? 0.0;
                    final available = data['isAvailable'] ?? true;
                    final categoryId = data['categoryId'] ?? '';
                    return ListTile(
                      title: Text(name),
                      subtitle: Text('Price: ${price.toStringAsFixed(3)} • Category ID: $categoryId'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AddEditItemScreen(itemId: d.id)),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete item?'),
                                  content: Text('Delete "$name"? This cannot be undone.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                await _service.deleteItem(d.id);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

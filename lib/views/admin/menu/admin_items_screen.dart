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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'MENU ITEMS',
          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D2D4D), fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditItemScreen()),
          );
        },
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('NEW ITEM', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: StreamBuilder<QuerySnapshot>(
              stream: _service.streamCategories(),
              builder: (context, snap) {
                if (!snap.hasData) return const LinearProgressIndicator(color: Colors.blueAccent);
                final docs = snap.data!.docs;
                final items = docs.map((d) {
                  final data = d.data() as Map<String, dynamic>? ?? {};
                  return {'id': d.id, 'name': data['name'] ?? 'Unnamed'};
                }).toList();
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      isExpanded: true,
                      value: _selectedCategoryId,
                      hint: const Text('All Categories', style: TextStyle(fontWeight: FontWeight.w600)),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueAccent),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('ALL CATEGORIES')),
                        ...items.map((e) => DropdownMenuItem<String?>(
                          value: e['id'] as String,
                          child: Text(e['name'].toString().toUpperCase()),
                        ))
                      ],
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                    ),
                  ),
                );
              },
            ),
          ),

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
                if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant_menu_outlined, size: 80, color: Colors.grey.shade200),
                        const SizedBox(height: 16),
                        const Text('No items found', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final d = docs[index];
                    final data = d.data() as Map<String, dynamic>? ?? {};
                    final name = data['name'] ?? 'Unnamed';
                    final price = (data['price'] is num) ? (data['price'] as num).toDouble() : double.tryParse(data['price']?.toString() ?? '0') ?? 0.0;
                    final isAvailable = data['isAvailable'] ?? true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF5F5F7), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (isAvailable ? Colors.blueAccent : Colors.grey).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.fastfood_rounded, color: isAvailable ? Colors.blueAccent : Colors.grey, size: 24),
                        ),
                        title: Text(
                          name.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D2D4D), fontSize: 15),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              '${price.toStringAsFixed(3)} BHD',
                              style: TextStyle(color: Colors.blueAccent.shade700, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isAvailable ? Colors.green : Colors.red).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isAvailable ? 'AVAILABLE' : 'OUT OF STOCK',
                                style: TextStyle(
                                  color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => AddEditItemScreen(itemId: d.id)),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                              onPressed: () async {
                                final ok = await _showDeleteConfirm(context, name);
                                if (ok == true) await _service.deleteItem(d.id);
                              },
                            ),
                          ],
                        ),
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

  Future<bool?> _showDeleteConfirm(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Item?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove "$name"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

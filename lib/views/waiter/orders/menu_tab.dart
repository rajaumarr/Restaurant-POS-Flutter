import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/menu_item_model.dart';

class MenuTab extends StatelessWidget {
  final void Function(MenuItemModel) onAdd;
  const MenuTab({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final categoriesCol = FirebaseFirestore.instance.collection('categories').orderBy('position');

    return Container(
      color: Colors.white,
      child: StreamBuilder<QuerySnapshot>(
        stream: categoriesCol.snapshots(),
        builder: (context, catSnap) {
          if (catSnap.hasError) return Center(child: Text('Failed to load categories: ${catSnap.error}'));
          if (!catSnap.hasData) return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          
          final cats = catSnap.data!.docs;
          if (cats.isEmpty) return const Center(child: Text('No categories available'));

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: cats.length,
            itemBuilder: (context, idx) {
              final c = cats[idx];
              final cData = c.data() as Map<String, dynamic>;
              final catId = c.id;
              final catName = (cData['name'] ?? 'Unnamed').toString();

              return Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    title: Text(
                      catName.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Color(0xFF2D2D4D),
                        letterSpacing: 1.1,
                      ),
                    ),
                    iconColor: Colors.blueAccent,
                    collapsedIconColor: Colors.grey,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('items')
                            .where('categoryId', isEqualTo: catId)
                            .orderBy('position')
                            .snapshots(),
                        builder: (context, itemSnap) {
                          if (itemSnap.hasError) return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Error: ${itemSnap.error}'),
                          );
                          if (!itemSnap.hasData) return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                          
                          final items = itemSnap.data!.docs;
                          if (items.isEmpty) return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No items in this category'),
                          );

                          return Column(
                            children: items.map((doc) {
                              final d = doc.data() as Map<String, dynamic>;
                              final menuItem = MenuItemModel(
                                id: doc.id,
                                name: (d['name'] ?? '').toString(),
                                price: (d['price'] is num) ? (d['price'] as num).toDouble() : double.tryParse(d['price'].toString()) ?? 0.0,
                                category: catName,
                              );
                              return Container(
                                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  title: Text(
                                    menuItem.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D2D4D),
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${menuItem.price.toStringAsFixed(3)} BHD',
                                    style: TextStyle(
                                      color: Colors.blueAccent.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  trailing: SizedBox(
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () => onAdd(menuItem),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                      ),
                                      child: const Text('ADD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
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
    );
  }
}

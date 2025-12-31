import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../services/table_service.dart';

class AdminTablesScreen extends StatelessWidget {
  const AdminTablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = TableService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'TABLE MANAGEMENT',
          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D2D4D), fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTableDialog(context),
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('ADD TABLE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.streamTables(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.table_bar_outlined, size: 80, color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  const Text('No tables defined', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: docs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (_, i) {
              final d = docs[i];
              final data = d.data() as Map<String, dynamic>;
              final tableNum = data['tableNumber'] ?? '-';
              final isOccupied = data['isOccupied'] ?? false;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isOccupied ? Colors.redAccent : Colors.blueAccent).withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_rounded, 
                            color: isOccupied ? Colors.redAccent : Colors.blueAccent, 
                            size: 28
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'TABLE $tableNum',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D2D4D), fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isOccupied ? 'OCCUPIED' : 'AVAILABLE',
                            style: TextStyle(
                              color: isOccupied ? Colors.redAccent : Colors.greenAccent.shade700,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 18),
                        onPressed: () async {
                          final ok = await _showDeleteConfirm(context, tableNum.toString());
                          if (ok == true) await service.deleteTable(d.id);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddTableDialog(BuildContext context) {
    final controller = TextEditingController();
    final service = TableService();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'ADD NEW TABLE',
          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D2D4D), fontSize: 18),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Table Number',
            prefixIcon: const Icon(Icons.table_bar_rounded, color: Colors.blueAccent),
            filled: true,
            fillColor: const Color(0xFFF5F5F7),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await service.addTable(int.parse(controller.text));
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('ADD TABLE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirm(BuildContext context, String num) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Table?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Delete Table $num from the system?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('REMOVE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

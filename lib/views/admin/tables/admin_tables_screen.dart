import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../services/table_service.dart';

class AdminTablesScreen extends StatelessWidget {
  const AdminTablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = TableService();

    return Scaffold(
      appBar: AppBar(title: const Text('Tables')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTableDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.streamTables(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              final data = d.data() as Map<String, dynamic>;

              return ListTile(
                title: Text('Table ${data['tableNumber']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => service.deleteTable(d.id),
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
      builder: (_) => AlertDialog(
        title: const Text('Add Table'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Table Number'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await service.addTable(int.parse(controller.text));
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

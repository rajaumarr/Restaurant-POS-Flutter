import 'package:flutter/material.dart';
import '../../../services/admin_menu_service.dart';

class AddEditCategoryDialog extends StatefulWidget {
  final String? categoryId;
  const AddEditCategoryDialog({super.key, this.categoryId});

  @override
  State<AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends State<AddEditCategoryDialog> {
  final _nameController = TextEditingController();
  final _service = AdminMenuService();
  bool _loading = false;

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter category name')));
      return;
    }
    setState(() => _loading = true);
    try {
      await _service.addCategory(name);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Category'),
      content: _loading
          ? const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()))
          : TextField(
        controller: _nameController,
        decoration: const InputDecoration(labelText: 'Category Name'),
      ),
      actions: _loading
          ? []
          : [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

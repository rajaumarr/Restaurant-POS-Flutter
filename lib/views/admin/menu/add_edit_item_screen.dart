// lib/views/admin/menu/add_edit_item_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../services/admin_menu_service.dart';

class AddEditItemScreen extends StatefulWidget {
  final String? itemId;
  const AddEditItemScreen({super.key, this.itemId});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminMenuService _service = AdminMenuService();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  String? _categoryId;
  bool _isAvailable = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.itemId != null) _loadItem();
  }

  Future<void> _loadItem() async {
    setState(() => _loading = true);
    final doc = await _service.getItemDoc(widget.itemId!);
    if (!doc.exists) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item not found')));
      Navigator.pop(context);
      return;
    }
    final data = doc.data() as Map<String, dynamic>;
    _nameCtrl.text = data['name'] ?? '';
    _priceCtrl.text = (data['price'] ?? 0).toString();
    _descCtrl.text = (data['description'] ?? '');
    _categoryId = data['categoryId'];
    _isAvailable = data['isAvailable'] ?? true;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose category')));
      return;
    }
    final name = _nameCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    final desc = _descCtrl.text.trim();
    setState(() => _loading = true);
    try {
      if (widget.itemId == null) {
        await _service.addItem(
          name: name,
          categoryId: _categoryId!,
          price: price,
          isAvailable: _isAvailable,
          description: desc,
        );
      } else {
        await _service.updateItem(
          itemId: widget.itemId!,
          name: name,
          categoryId: _categoryId!,
          price: price,
          isAvailable: _isAvailable,
          description: desc,
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed save item: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemId == null ? 'Add Item' : 'Edit Item'),
        actions: [
          if (!_loading)
            TextButton(
              onPressed: _save,
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),

              // Category dropdown (by name, saves id)
              StreamBuilder<QuerySnapshot>(
                stream: _service.streamCategories(),
                builder: (context, snap) {
                  if (!snap.hasData) return const LinearProgressIndicator();
                  final docs = snap.data!.docs;
                  if (docs.isEmpty) return const Text('No categories available');
                  if (_categoryId == null) _categoryId = docs.first.id;
                  return DropdownButtonFormField<String>(
                    value: _categoryId,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: docs.map((d) {
                      final data = d.data() as Map<String, dynamic>? ?? {};
                      return DropdownMenuItem<String>(
                        value: d.id,
                        child: Text(data['name'] ?? 'Unnamed'),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _categoryId = v),
                  );
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter price';
                  if (double.tryParse(v) == null) return 'Invalid price';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Text('Available'),
                  const SizedBox(width: 8),
                  Switch(value: _isAvailable, onChanged: (v) => setState(() => _isAvailable = v)),
                ],
              ),

              const SizedBox(height: 16),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}

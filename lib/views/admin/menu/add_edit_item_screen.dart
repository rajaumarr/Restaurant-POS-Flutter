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
    try {
      final doc = await _service.getItemDoc(widget.itemId!);
      if (!doc.exists) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item not found')));
        if (mounted) Navigator.pop(context);
        return;
      }
      final data = doc.data() as Map<String, dynamic>;
      _nameCtrl.text = data['name'] ?? '';
      _priceCtrl.text = (data['price'] ?? 0).toString();
      _descCtrl.text = (data['description'] ?? '');
      _categoryId = data['categoryId'];
      _isAvailable = data['isAvailable'] ?? true;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
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
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      filled: true,
      fillColor: const Color(0xFFF5F5F7),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.itemId == null ? 'ADD MENU ITEM' : 'EDIT MENU ITEM',
          style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D2D4D), fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: _buildInputDecoration('Item Name', Icons.fastfood_rounded),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter item name' : null,
                    ),
                    const SizedBox(height: 20),

                    StreamBuilder<QuerySnapshot>(
                      stream: _service.streamCategories(),
                      builder: (context, snap) {
                        if (!snap.hasData) return const LinearProgressIndicator(color: Colors.blueAccent);
                        final docs = snap.data!.docs;
                        if (docs.isEmpty) return const Text('No categories available. Please create one first.', style: TextStyle(color: Colors.red));
                        
                        return DropdownButtonFormField<String>(
                          value: _categoryId,
                          decoration: _buildInputDecoration('Select Category', Icons.category_rounded),
                          items: docs.map((d) {
                            final data = d.data() as Map<String, dynamic>? ?? {};
                            return DropdownMenuItem<String>(
                              value: d.id,
                              child: Text(data['name']?.toString().toUpperCase() ?? 'UNNAMED'),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _categoryId = v),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _buildInputDecoration('Price (BHD)', Icons.payments_rounded),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter price';
                        if (double.tryParse(v) == null) return 'Invalid price';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _descCtrl,
                      decoration: _buildInputDecoration('Description (Optional)', Icons.description_rounded),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.inventory_2_rounded, color: Colors.blueAccent, size: 20),
                              SizedBox(width: 12),
                              Text('In Stock / Available', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D4D))),
                            ],
                          ),
                          Switch(
                            value: _isAvailable,
                            onChanged: (v) => setState(() => _isAvailable = v),
                            activeColor: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          widget.itemId == null ? 'CREATE ITEM' : 'SAVE CHANGES',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

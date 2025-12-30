// lib/views/admin/pin/admin_pin_screen.dart
import 'package:flutter/material.dart';
import '../../../services/settings_service.dart';

class AdminPinScreen extends StatefulWidget {
  const AdminPinScreen({super.key});
  @override
  State<AdminPinScreen> createState() => _AdminPinScreenState();
}

class _AdminPinScreenState extends State<AdminPinScreen> {
  final _waiterCtrl = TextEditingController();
  final _counterCtrl = TextEditingController();
  final _service = SettingsService();
  bool _loading = false;

  final RegExp _pinRg = RegExp(r'^\d{4}$');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final doc = await _service.getConfigDoc();
      final data = doc.data() as Map<String, dynamic>? ?? {};
      _waiterCtrl.text = (data['waiterPin'] ?? '').toString();
      _counterCtrl.text = (data['counterPin'] ?? '').toString();
      setState(() {});
    } catch (_) {}
  }

  Future<void> _saveWaiter() async {
    final pin = _waiterCtrl.text.trim();
    if (!_pinRg.hasMatch(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Waiter PIN must be exactly 4 digits (0-9)')));
      return;
    }
    setState(() => _loading = true);
    try {
      await _service.setPins(waiterPin: pin);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Waiter PIN saved')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save waiter PIN: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveCounter() async {
    final pin = _counterCtrl.text.trim();
    if (!_pinRg.hasMatch(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Counter PIN must be exactly 4 digits (0-9)')));
      return;
    }
    setState(() => _loading = true);
    try {
      await _service.setPins(counterPin: pin);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Counter PIN saved')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save counter PIN: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _waiterCtrl.dispose();
    _counterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PIN (Staff)')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            const Text('Waiter PIN (4 digits)'),
            TextField(
              controller: _waiterCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(hintText: 'e.g. 1234'),
            ),
            ElevatedButton(onPressed: _loading ? null : _saveWaiter, child: const Text('Save Waiter PIN')),
            const SizedBox(height: 24),
            const Text('Counter PIN (4 digits)'),
            TextField(
              controller: _counterCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(hintText: 'e.g. 4321'),
            ),
            ElevatedButton(onPressed: _loading ? null : _saveCounter, child: const Text('Save Counter PIN')),
            if (_loading) const Padding(padding: EdgeInsets.only(top:16), child: Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }
}

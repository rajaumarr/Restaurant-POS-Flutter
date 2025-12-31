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
    setState(() => _loading = true);
    try {
      final doc = await _service.getConfigDoc();
      final data = doc.data() as Map<String, dynamic>? ?? {};
      _waiterCtrl.text = (data['waiterPin'] ?? '').toString();
      _counterCtrl.text = (data['counterPin'] ?? '').toString();
    } catch (_) {} finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _savePin(String type, String pin) async {
    if (!_pinRg.hasMatch(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN must be exactly 4 digits'), backgroundColor: Colors.redAccent)
      );
      return;
    }
    
    setState(() => _loading = true);
    try {
      if (type == 'waiter') {
        await _service.setPins(waiterPin: pin);
      } else {
        await _service.setPins(counterPin: pin);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${type.toUpperCase()} PIN updated successfully'),
            backgroundColor: Colors.blueAccent,
            behavior: SnackBarBehavior.floating,
          )
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
      counterText: "",
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
    );
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'STAFF SECURITY PINS',
          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D2D4D), fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: _loading && _waiterCtrl.text.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MANAGE ACCESS CODES',
                    style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 12, letterSpacing: 1),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildPinCard(
                    'Waiter Access',
                    'Used by waitstaff to place orders and manage tables.',
                    _waiterCtrl,
                    Icons.person_pin_rounded,
                    () => _savePin('waiter', _waiterCtrl.text.trim()),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildPinCard(
                    'Counter Access',
                    'Used by counter staff to process payments and reports.',
                    _counterCtrl,
                    Icons.account_balance_wallet_rounded,
                    () => _savePin('counter', _counterCtrl.text.trim()),
                  ),
                  
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      'Security Tip: Change PINs regularly to maintain system security.',
                      style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPinCard(String title, String description, TextEditingController controller, IconData icon, VoidCallback onSave) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF5F5F7), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D2D4D), fontSize: 16)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 8),
                  decoration: _buildInputDecoration('Enter 4-digit PIN', icon),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

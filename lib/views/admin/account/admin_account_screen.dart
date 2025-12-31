import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminAccountScreen extends StatefulWidget {
  const AdminAccountScreen({super.key});
  @override
  State<AdminAccountScreen> createState() => _AdminAccountScreenState();
}

class _AdminAccountScreenState extends State<AdminAccountScreen> {
  final _emailCtrl = TextEditingController();
  final _currentPwdCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();
  bool _loading = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = _user?.email ?? '';
  }

  Future<bool> _reauthenticate(String currentPassword) async {
    final user = _user;
    if (user == null || user.email == null) return false;
    final cred = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
    try {
      await user.reauthenticateWithCredential(cred);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _changeEmail() async {
    final newEmail = _emailCtrl.text.trim();
    final currentPassword = _currentPwdCtrl.text.trim();
    if (newEmail.isEmpty || currentPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter current password and new email')));
      return;
    }
    setState(() => _loading = true);
    final ok = await _reauthenticate(currentPassword);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reauthentication failed')));
      setState(() => _loading = false);
      return;
    }
    try {
      await _user!.verifyBeforeUpdateEmail(newEmail);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A verification link has been sent to your new email. Please verify it to complete the change.'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to change email: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPwdCtrl.text.trim();
    final newPassword = _newPwdCtrl.text.trim();
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter current and new password')));
      return;
    }
    setState(() => _loading = true);
    final ok = await _reauthenticate(currentPassword);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reauthentication failed')));
      setState(() => _loading = false);
      return;
    }
    try {
      await _user!.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed successfully')));
      _currentPwdCtrl.clear();
      _newPwdCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to change password: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF5D5D7A), fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      filled: true,
      fillColor: const Color(0xFFF5F5F7),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'ACCOUNT SETTINGS',
          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D2D4D), fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _loading 
        ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.account_circle_outlined, size: 80, color: Colors.blueAccent),
                const SizedBox(height: 10),
                const Text(
                  'Update Admin Credentials',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D2D4D)),
                ),
                const SizedBox(height: 40),

                TextFormField(
                  controller: _emailCtrl,
                  decoration: _buildInputDecoration('New Email Address', Icons.email_rounded),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _currentPwdCtrl,
                  decoration: _buildInputDecoration('Current Password', Icons.lock_rounded),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _changeEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('UPDATE EMAIL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                  ),
                ),

                const SizedBox(height: 40),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR CHANGE PASSWORD', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 40),

                TextFormField(
                  controller: _newPwdCtrl,
                  decoration: _buildInputDecoration('New Admin Password', Icons.security_rounded),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D2D4D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('CHANGE PASSWORD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
    );
  }
}

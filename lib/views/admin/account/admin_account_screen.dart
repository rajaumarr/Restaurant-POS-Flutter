// lib/views/admin/account/admin_account_screen.dart
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
      // Use verifyBeforeUpdateEmail instead of updateEmail
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to change password: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Account')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextFormField(controller: _currentPwdCtrl, decoration: const InputDecoration(labelText: 'Current Password'), obscureText: true),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _changeEmail, child: const Text('Change Email')),
            const Divider(),
            TextFormField(controller: _newPwdCtrl, decoration: const InputDecoration(labelText: 'New Password'), obscureText: true),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _changePassword, child: const Text('Change Password')),
            if (_loading) const SizedBox(height: 20, child: Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }
}

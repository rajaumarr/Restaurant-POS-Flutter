import 'package:flutter/material.dart';
import 'package:miral/navigation/route_names.dart';
import 'package:miral/services/admin_auth_service.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AdminAuthService _authService = AdminAuthService();
  bool _isLoading = false;

  void _login() async{
    setState(() => _isLoading = true);
    try{
      await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(
          context,
          RouteNames.adminScaffold
      );
    }catch(e){
      _showError();
    }finally{
      setState(() => _isLoading = false);
    }
  }

  void _showError() {
    showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Login Failed'),
          content: Text('Invalid email or password'),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16,),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 30,),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    :const Text ('Login'),
                 ),
              ),
          ]
        ),
      ),
    );
  }
}

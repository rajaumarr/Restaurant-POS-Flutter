import 'package:flutter/material.dart';
import 'package:miral/services/pin_auth_service.dart';
import '../../navigation/route_names.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final PinAuthService _pinAuthService = PinAuthService();
  static const int pinLength = 4;
  String enteredPin = '';

  void _showError() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Invalid PIN'),
        content: const Text('Please enter a valid PIN'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                enteredPin = '';
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _submitPin() async {
    try {
      final role = await _pinAuthService.verifyPin(enteredPin);
      if (role == 'waiter') {
        Navigator.pushReplacementNamed(context, RouteNames.waiterHome);
      } else if (role == 'counter') {
        Navigator.pushReplacementNamed(context, RouteNames.counterHome);
      } else {
        _showError();
      }
    } catch (e) {
      _showError();
    }
  }

  void _onKeyTap(String value) {
    if (enteredPin.length < pinLength) {
      setState(() {
        enteredPin += value;
      });
    }
    if (enteredPin.length == pinLength) {
      _submitPin();
    }
  }

  void _onBackspace() {
    if (enteredPin.isNotEmpty) {
      setState(() {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
      });
    }
  }

  Widget _buildPinDot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pinLength,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < enteredPin.length ? Colors.blueAccent : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String value) {
    return InkWell(
      onTap: () => _onKeyTap(value),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5D5D7A),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'PIN LOGIN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.blueAccent,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Enter staff security PIN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildPinDot(),
                    const SizedBox(height: 50),
                    

                    SizedBox(
                      width: 320,
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          _buildKey('1'), _buildKey('2'), _buildKey('3'),
                          _buildKey('4'), _buildKey('5'), _buildKey('6'),
                          _buildKey('7'), _buildKey('8'), _buildKey('9'),
                          const SizedBox.shrink(),
                          _buildKey('0'),
                          InkWell(
                            onTap: _onBackspace,
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F7),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.backspace_outlined,
                                color: Color(0xFF5D5D7A),
                                size: 26,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 10,
              right: 20,
              child: TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, RouteNames.adminLogin),
                icon: const Icon(Icons.admin_panel_settings, color: Colors.blueAccent, size: 22),
                label: const Text(
                  'Admin',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: Colors.blueAccent.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

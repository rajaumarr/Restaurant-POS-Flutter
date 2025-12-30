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
  @override
  Widget build(BuildContext context) {


    void _showError(){
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
              title: const Text('Invalid PIN'),
              content: const Text('Please enter a valid PIN'),
              actions:[
                TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                    setState((){
                      enteredPin = '';
                    });

                  }, child: const Text('OK'),
                ),
              ]
          )
      );
    }

    void _submitPin() async {
      try {
        debugPrint('Submitting PIN: $enteredPin');
        final role = await _pinAuthService.verifyPin(enteredPin);
        debugPrint('verifyPin returned: $role');
        if (role == 'waiter') {
          Navigator.pushReplacementNamed(context, RouteNames.waiterHome);
        } else if (role == 'counter') {
          Navigator.pushReplacementNamed(context, RouteNames.counterHome);
        } else {
          _showError();
        }
      } catch (e) {
        debugPrint('Pin submit error: $e');
        _showError();
      }
    }


    void _onKeyTap(String value){
      if(enteredPin.length < pinLength){
        setState(() {
          enteredPin += value;
        });
      }
      if(enteredPin.length == pinLength){
        _submitPin();
      }
    }

    void _onBackspace(){
      if(enteredPin.isNotEmpty){
        setState(() {
          enteredPin = enteredPin.substring(0, enteredPin.length - 1);
        });
      }
    }

    Widget _buildPinDot(){
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pinLength,
                (index) => Container(
              margin: const EdgeInsets.all(8),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index < enteredPin.length ? Colors.black : Colors.grey.shade300,
              ),
            ),
          )
      );
    }

    Widget _buildKey(String value){
      return ElevatedButton(
          onPressed: ()=> _onKeyTap(value),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(90, 90),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child:Text(
            value,
            style: const TextStyle(fontSize:28),
          )
      );
    }

    Widget _buildBackSpace(){
      return ElevatedButton(
        onPressed: _onBackspace,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(90, 90),
        ),
        child: const Icon(Icons.backspace, size:28),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pin Login'),
        actions: [
          TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.deepPurple),

              ),
              onPressed: (){
                Navigator.pushNamed(context, RouteNames.adminLogin);
              },
              child: Container(
                margin: EdgeInsets.only(right: 10),
                child: const Text(
                    'Admin',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16
                    )
                )
              ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20,),
          _buildPinDot(),
          const SizedBox(height: 30,),

          //KeyPad
          Center(
            child: SizedBox(
              width: 320,
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildKey('1'),
                  _buildKey('2'),
                  _buildKey('3'),
                  _buildKey('4'),
                  _buildKey('5'),
                  _buildKey('6'),
                  _buildKey('7'),
                  _buildKey('8'),
                  _buildKey('9'),
                  const SizedBox.shrink(),
                  _buildKey('0'),
                  _buildBackSpace(),
                ],
              )
            ),
          ),
        ]
      ),
    );
  }
}

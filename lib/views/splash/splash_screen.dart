import 'package:flutter/material.dart';

import '../../navigation/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _goNext();
  }

  void _goNext() async{
    await Future.delayed(const Duration(seconds: 2));

    if(!mounted) return;
    
    Navigator.pushReplacementNamed(
        context,
        RouteNames.pinLogin,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'MIRAL RESTAURANT',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

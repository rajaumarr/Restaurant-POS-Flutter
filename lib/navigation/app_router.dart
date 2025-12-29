import 'package:flutter/material.dart';
import 'package:miral/views/admin/admin_home.dart';
import 'package:miral/views/admin/admin_login_screen.dart';
import 'package:miral/views/counter/couter_home.dart';
import 'package:miral/views/splash/splash_screen.dart';
import 'package:miral/views/auth/pin_login_screen.dart';
import 'package:miral/views/waiter/waiter_home.dart';

class AppRouter{
  static Route<dynamic> generateRoute(RouteSettings settings){
    switch (settings.name){
      case '/':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/pin-login':
        return MaterialPageRoute(builder: (_) => PinLoginScreen());
      case '/waiter-home':
        return MaterialPageRoute(builder: (_) => WaiterHome());
      case '/counter-home':
        return MaterialPageRoute(builder: (_) => CounterHome());
      case '/admin-login':
        return MaterialPageRoute(builder: (_) => AdminLoginScreen());
      case '/admin-home':
        return MaterialPageRoute(builder: (_) => AdminHome());

      default:
        return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('Page not found'),
              ),
            ),
        );
    }
  }
}
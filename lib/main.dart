import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'services/counter_notification_service.dart';
import 'app.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    try {

      final cred = await auth.signInAnonymously();
      debugPrint('Main: anonymous sign-in uid=${cred.user?.uid}');
    } catch (e) {
      debugPrint('Main: anonymous sign-in failed: $e');
    }
  } else {
    debugPrint('Main: already signed-in uid=${auth.currentUser?.uid} anonymous=${auth.currentUser?.isAnonymous}');
  }

  final counterNotif = CounterNotificationService();

  try {
    await counterNotif.init();
    await counterNotif.startListening();
    debugPrint('Main: counter notifications started');
  } catch (e, st) {
    debugPrint('Main: counter notification service startup failed: $e\n$st');
  }

  runApp(MyApp());
}

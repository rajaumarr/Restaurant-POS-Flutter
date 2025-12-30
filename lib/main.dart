import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Ensure anonymous sign-in so reads (settings, categories, etc.) are allowed.
  // If you've already got a sign-in in order_service, this makes reads safe early.
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    try {
      final cred = await auth.signInAnonymously();
      debugPrint('Main: anonymous sign-in uid=${cred.user?.uid}');
    } catch (e) {
      debugPrint('Main: anonymous sign-in failed: $e');
      // Optionally continue — UI will handle errors; but printing helps debug.
    }
  } else {
    debugPrint('Main: already signed-in uid=${auth.currentUser?.uid} anonymous=${auth.currentUser?.isAnonymous}');
  }

  runApp(const MyApp());
}



// lib/services/pin_auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PinAuthService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Ensure we are signed in (anonymous sign-in if needed)
  Future<void> _ensureSignedIn() async {
    if (_auth.currentUser == null) {
      final cred = await _auth.signInAnonymously();
      // debug
      // ignore: avoid_print
      print('PinAuthService: signInAnonymously uid=${cred.user?.uid}');
    }
  }

  /// Verifies a 4-digit PIN and returns role: 'waiter'|'counter'|null
  Future<String?> verifyPin(String pin) async {
    if (pin == null || pin.trim().isEmpty) return null;
    await _ensureSignedIn();

    try {
      final docRef = _firestore.collection('settings').doc('config');
      final snapshot = await docRef.get();
      if (!snapshot.exists) return null;
      final data = snapshot.data() ?? {};

      final waiterPin = (data['waiterPin'] ?? '').toString().trim();
      final counterPin = (data['counterPin'] ?? '').toString().trim();

      if (pin == waiterPin) return 'waiter';
      if (pin == counterPin) return 'counter';
      return null;
    } catch (e) {
      // log error and return null (invalid)
      // ignore: avoid_print
      print('PinAuthService.verifyPin error: $e');
      return null;
    }
  }
}

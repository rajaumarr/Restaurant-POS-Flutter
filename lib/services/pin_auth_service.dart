import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings_service.dart';

class PinAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _signedIn = false;

  Future<User?> _ensureSignedInAnonymously() async {
    final current = _auth.currentUser;
    if (current != null) {
      _signedIn = true;
      return current;
    }
    if (_signedIn) return _auth.currentUser; // safety
    final cred = await _auth.signInAnonymously();
    _signedIn = true;
    return cred.user;
  }


  Future<String?> verifyPin(String pin) async {
    await _ensureSignedInAnonymously();

    final doc = await SettingsService().getConfigDoc();
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final waiterPin = (data['waiterPin'] ?? '').toString();
    final counterPin = (data['counterPin'] ?? '').toString();

    if (pin == waiterPin) return 'waiter';
    if (pin == counterPin) return 'counter';
    return null;
  }
}

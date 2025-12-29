import 'package:cloud_firestore/cloud_firestore.dart';

class PinAuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> verifyPin(String enteredPin) async {
    final doc = await _firestore.collection('settings').doc('config').get();

    if (!doc.exists) return null;

    final data = doc.data()!;

    if(enteredPin == data['waiterPin']){
      return 'waiter';
    }
    if(enteredPin == data['counterPin']){
      return 'counter';
    }
    return null;
  }
}

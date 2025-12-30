// lib/services/settings_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsService {
  final CollectionReference settings = FirebaseFirestore.instance.collection('settings');
  final String configDoc = 'config';

  // read the config doc snapshot
  Stream<DocumentSnapshot> streamConfig() {
    return settings.doc(configDoc).snapshots();
  }

  Future<DocumentSnapshot> getConfigDoc() {
    return settings.doc(configDoc).get();
  }

  // update both pins (merge so other fields remain)
  Future<void> setPins({String? waiterPin, String? counterPin}) async {
    final payload = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
    if (waiterPin != null) payload['waiterPin'] = waiterPin;
    if (counterPin != null) payload['counterPin'] = counterPin;
    await settings.doc(configDoc).set(payload, SetOptions(merge: true));
  }

  Future<String?> getWaiterPin() async {
    final doc = await getConfigDoc();
    final data = doc.data() as Map<String, dynamic>?;
    return data?['waiterPin']?.toString();
  }

  Future<String?> getCounterPin() async {
    final doc = await getConfigDoc();
    final data = doc.data() as Map<String, dynamic>?;
    return data?['counterPin']?.toString();
  }
}

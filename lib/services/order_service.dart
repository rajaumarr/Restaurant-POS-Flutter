import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _authEnsured = false;

  Future<void> _ensureAuth() async {
    if (_auth.currentUser != null) {
      _authEnsured = true;
      return;
    }
    if (!_authEnsured) {
      await _auth.signInAnonymously();
      _authEnsured = true;
    }
  }


  Future<String> createOrder({
    required int tableNumber,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
  }) async {
    await _ensureAuth();
    final ordersCol = _firestore.collection('orders');
    final tablesCol = _firestore.collection('tables');

    final newOrderRef = ordersCol.doc();
    final orderNumber = 'ORD-${newOrderRef.id.substring(0, 6).toUpperCase()}';

    final batch = _firestore.batch();
    batch.set(newOrderRef, {
      'orderNumber': orderNumber,
      'tableNumber': tableNumber,
      'items': items,
      'totalAmount': totalAmount,
      'status': 'active',
      'isEditable': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final tableDocRef = tablesCol.doc('table_$tableNumber');
    batch.set(tableDocRef, {
      'tableNumber': tableNumber,
      'isOccupied': true,
      'activeOrderId': newOrderRef.id,
    }, SetOptions(merge: true));

    await batch.commit();
    return newOrderRef.id;
  }

  Future<void> editOrder({
    required String orderId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
  }) async {
    await _ensureAuth();
    final orderRef = _firestore.collection('orders').doc(orderId);

    final doc = await orderRef.get();
    if (!doc.exists) {
      throw Exception('Order not found');
    }

    final data = doc.data() as Map<String, dynamic>? ?? {};
    if (data.containsKey('isEditable') && data['isEditable'] == false) {
      throw Exception('Order cannot be edited');
    }

    await orderRef.update({
      'items': items,
      'totalAmount': totalAmount,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _ensureAuth();
    final orderRef = _firestore.collection('orders').doc(orderId);
    await orderRef.update({
      'status': status,
      'isEditable': (status == 'active' || status == 'processing' || status == 'in_kitchen'),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (status == 'completed' || status == 'cancelled') {
      final orderSnap = await orderRef.get();
      if (orderSnap.exists) {
        final data = orderSnap.data()!;
        final tableNumber = data['tableNumber'];
        if (tableNumber != null) {
          final tableRef = _firestore.collection('tables').doc('table_$tableNumber');
          final tableSnap = await tableRef.get();
          if (tableSnap.exists) {
            final activeOrderId = tableSnap.data()?['activeOrderId'];
            if (activeOrderId == orderId) {
              await tableRef.update({
                'isOccupied': false,
                'activeOrderId': FieldValue.delete(),
              });
            }
          }
        }
      }
    }
  }

  Future<void> startProcessing(String orderId) => updateOrderStatus(orderId, 'processing');

  Future<void> markInKitchen(String orderId) async {
    await _ensureAuth();
    final orderRef = _firestore.collection('orders').doc(orderId);
    await orderRef.update({
      'status': 'in_kitchen',
      'inKitchen': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> completeOrder(String orderId) => updateOrderStatus(orderId, 'completed');

  Future<void> cancelOrder(String orderId, {String? reason}) async {
    await _ensureAuth();
    final orderRef = _firestore.collection('orders').doc(orderId);
    final Map<String, dynamic> payload = {
      'status': 'cancelled',
      'isEditable': false,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (reason != null) payload['cancelReason'] = reason;
    await orderRef.update(payload);

    final doc = await orderRef.get();
    if (doc.exists) {
      final d = doc.data()!;
      final tableNumber = d['tableNumber'];
      if (tableNumber != null) {
        final tableRef = _firestore.collection('tables').doc('table_$tableNumber');
        final tableSnap = await tableRef.get();
        if (tableSnap.exists) {
          final activeOrderId = tableSnap.data()?['activeOrderId'];
          if (activeOrderId == orderId) {
            await tableRef.update({
              'isOccupied': false,
              'activeOrderId': FieldValue.delete(),
            });
          }
        }
      }
    }
  }

  Future<void> logPrint({
    required String orderId,
    required String deviceId,
    required String type,
    required bool success,
    String? notes,
  }) async {
    await _ensureAuth();
    await _firestore.collection('print_logs').add({
      'orderId': orderId,
      'deviceId': deviceId,
      'type': type,
      'success': success,
      'notes': notes ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> streamAllActiveOrders() {
    return _firestore
        .collection('orders')
        .where('status', whereIn: ['active', 'processing', 'in_kitchen'])
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Stream<DocumentSnapshot> streamOrder(String orderId) {
    return _firestore.collection('orders').doc(orderId).snapshots();
  }

  Future<DocumentSnapshot> getOrderDoc(String orderId) {
    return _firestore.collection('orders').doc(orderId).get();
  }
}

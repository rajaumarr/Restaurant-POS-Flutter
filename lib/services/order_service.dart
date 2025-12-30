// lib/services/order_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ensure the device/user is signed in (anonymous sign-in for devices).
  // Call this before any Firestore write that requires request.auth != null.
  Future<void> _ensureSignedIn() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    if (user == null) {
      try {
        final cred = await auth.signInAnonymously();
        // debug print - remove or change to your logger as needed
        // ignore: avoid_print
        print('Anonymous sign-in successful: uid=${cred.user?.uid}');
      } catch (e) {
        // ignore: avoid_print
        print('Anonymous sign-in failed: $e');
        rethrow;
      }
    } else {
      // ignore: avoid_print
      print('Already signed-in: uid=${user.uid} anonymous=${user.isAnonymous}');
    }
  }

  /// Create a new order AND mark table occupied (batched).
  /// Returns the created order document id.
  Future<String> createOrder({
    required int tableNumber,
    required List<CartItemModel> cartItems,
    required double totalAmount,
  }) async {
    // ensure authenticated (rules require request.auth != null to create orders)
    await _ensureSignedIn();

    final ordersCol = _firestore.collection('orders');
    final tablesCol = _firestore.collection('tables');

    final newOrderRef = ordersCol.doc();
    final orderNumber = 'ORD-${newOrderRef.id.substring(0, 6).toUpperCase()}';

    final itemsData = cartItems.map((c) => {
      'name': c.item.name,
      'price': c.item.price,
      'quantity': c.quantity,
    }).toList();

    final batch = _firestore.batch();

    // debug: show current uid
    final uid = FirebaseAuth.instance.currentUser?.uid;
    // ignore: avoid_print
    print('Creating order as uid=$uid');

    batch.set(newOrderRef, {
      'orderNumber': orderNumber,
      'tableNumber': tableNumber,
      'items': itemsData,
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

  /// Edit an existing order (only if isEditable == true)
  Future<void> editOrder({
    required String orderId,
    required List<CartItemModel> cartItems,
    required double totalAmount,
  }) async {
    // ensure authenticated (rules require request.auth != null for updates by authenticated users)
    await _ensureSignedIn();

    final orderRef = _firestore.collection('orders').doc(orderId);
    final doc = await orderRef.get();
    if (!doc.exists) throw Exception('Order not found');

    final data = doc.data()!;
    if (data['isEditable'] == false) {
      throw Exception('Order is locked and cannot be edited');
    }

    final itemsData = cartItems.map((c) => {
      'name': c.item.name,
      'price': c.item.price,
      'quantity': c.quantity,
    }).toList();

    // debug: show current uid
    final uid = FirebaseAuth.instance.currentUser?.uid;
    // ignore: avoid_print
    print('Editing order $orderId as uid=$uid');

    await orderRef.update({
      'items': itemsData,
      'totalAmount': totalAmount,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update status. Also set isEditable appropriately and release table when done.
  Future<void> updateOrderStatus(String orderId, String status) async {
    // ensure authenticated
    await _ensureSignedIn();

    final orderRef = _firestore.collection('orders').doc(orderId);

    // debug: show current uid
    final uid = FirebaseAuth.instance.currentUser?.uid;
    // ignore: avoid_print
    print('Updating orderStatus for $orderId to $status as uid=$uid');

    await orderRef.update({
      'status': status,
      'isEditable': (status == 'active' || status == 'draft'),
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

  /// Stream of active/processing orders
  Stream<QuerySnapshot> streamAllActiveOrders() {
    return _firestore
        .collection('orders')
        .where('status', whereIn: ['active', 'processing'])
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<DocumentSnapshot> getOrderDoc(String orderId) {
    return _firestore.collection('orders').doc(orderId).get();
  }

  /// Log a print attempt (kitchen/customer) into 'print_logs'
  Future<void> logPrint({
    required String orderId,
    required String type, // 'kitchen' | 'customer'
    required String deviceId,
    required bool success,
    String? content,
  }) async {
    // ensure authenticated before writing logs
    await _ensureSignedIn();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    // ignore: avoid_print
    print('Logging print for order $orderId as uid=$uid type=$type success=$success');

    await _firestore.collection('print_logs').add({
      'orderId': orderId,
      'type': type,
      'deviceId': deviceId,
      'success': success,
      'content': content ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

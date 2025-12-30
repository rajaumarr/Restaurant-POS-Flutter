import 'package:cloud_firestore/cloud_firestore.dart';

class TableService {
  final _tables = FirebaseFirestore.instance.collection('tables');

  Stream<QuerySnapshot> streamTables() {
    return _tables.orderBy('tableNumber').snapshots();
  }

  Future<void> addTable(int tableNumber) async {
    await _tables.doc('table_$tableNumber').set({
      'tableNumber': tableNumber,
      'isOccupied': false,
      'activeOrderId': null,
    });
  }

  Future<void> deleteTable(String id) async {
    await _tables.doc(id).delete();
  }
}

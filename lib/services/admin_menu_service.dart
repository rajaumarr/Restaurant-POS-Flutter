import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMenuService {
  final CollectionReference categories = FirebaseFirestore.instance.collection('categories');
  final CollectionReference items = FirebaseFirestore.instance.collection('items');

  Stream<QuerySnapshot> streamCategories() {
    return categories.orderBy('position').snapshots();
  }

  Future<int> getNextCategoryPosition() async {
    final snap = await categories.orderBy('position', descending: true).limit(1).get();
    if (snap.docs.isEmpty) return 1;
    final top = snap.docs.first.data() as Map<String, dynamic>? ?? {};
    return ((top['position'] as num?)?.toInt() ?? 0) + 1;
  }

  Future<void> addCategory(String name) async {
    final id = name.toLowerCase().replaceAll(' ', '_');
    final pos = await getNextCategoryPosition();
    await categories.doc(id).set({
      'name': name,
      'position': pos,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCategory({
    required String id, 
    required String name, 
    required int position, 
    bool? isActive
  }) async {
    final payload = {
      'name': name, 
      'position': position,
      'updatedAt': FieldValue.serverTimestamp()
    };
    if (isActive != null) payload['isActive'] = isActive;
    await categories.doc(id).update(payload);
  }

  Future<void> deleteCategory(String id) async {
    final itemsSnap = await items.where('categoryId', isEqualTo: id).limit(1).get();
    if (itemsSnap.docs.isNotEmpty) {
      throw Exception('Category is used by items; remove items first.');
    }
    await categories.doc(id).delete();
  }

  Stream<QuerySnapshot> streamAllItems() {
    return items.orderBy('position').snapshots();
  }

  Stream<QuerySnapshot> streamItemsByCategory(String categoryId) {
    return items.where('categoryId', isEqualTo: categoryId).orderBy('position').snapshots();
  }

  Future<int> getNextItemPosition(String categoryId) async {
    final snap = await items.where('categoryId', isEqualTo: categoryId).orderBy('position', descending: true).limit(1).get();
    if (snap.docs.isEmpty) return 1;
    final top = snap.docs.first.data() as Map<String, dynamic>? ?? {};
    return ((top['position'] as num?)?.toInt() ?? 0) + 1;
  }

  Future<DocumentSnapshot> getItemDoc(String itemId) async {
    return items.doc(itemId).get();
  }

  Future<void> addItem({
    required String name,
    required String categoryId,
    required double price,
    required bool isAvailable,
    String? description,
  }) async {
    final position = await getNextItemPosition(categoryId);
    final newDoc = items.doc();
    await newDoc.set({
      'name': name,
      'categoryId': categoryId,
      'price': price,
      'position': position,
      'isAvailable': isAvailable,
      'description': description ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateItem({
    required String itemId,
    required String name,
    required String categoryId,
    required double price,
    required bool isAvailable,
    String? description,
  }) async {
    await items.doc(itemId).update({
      'name': name,
      'categoryId': categoryId,
      'price': price,
      'isAvailable': isAvailable,
      'description': description ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteItem(String itemId) async {
    await items.doc(itemId).delete();
  }
}

import 'package:flutter/material.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/menu_item_model.dart';
import '../../../services/order_service.dart';
import 'menu_tab.dart';
import 'cart_tab.dart';

class OrderPosScreen extends StatefulWidget {
  final int tableNumber;
  final String? orderId;

  const OrderPosScreen({
    super.key,
    required this.tableNumber,
    this.orderId,
  });

  @override
  State<OrderPosScreen> createState() => _OrderPosScreenState();
}

class _OrderPosScreenState extends State<OrderPosScreen> {
  final List<CartItemModel> cartItems = [];
  final OrderService _orderService = OrderService();
  bool loading = false;
  String? editingOrderId;

  @override
  void initState() {
    super.initState();
    editingOrderId = widget.orderId;
    if (editingOrderId != null) {
      _loadExistingOrder();
    }
  }

  Future<void> _loadExistingOrder() async {
    setState(() => loading = true);
    try {
      final doc = await _orderService.getOrderDoc(editingOrderId!);
      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order not found')));
        return;
      }
      final data = doc.data() as Map<String, dynamic>;

      if (data['isEditable'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order cannot be edited')));
        return;
      }

      cartItems.clear();
      final items = (data['items'] as List<dynamic>?) ?? [];
      for (final it in items) {
        final m = Map<String, dynamic>.from(it as Map);
        final menuItem = MenuItemModel(
          id: m['id']?.toString() ?? m['name'].toString(),
          name: m['name']?.toString() ?? '-',
          price: (m['price'] is num) ? (m['price'] as num).toDouble() : double.tryParse(m['price'].toString()) ?? 0.0,
          category: m['category']?.toString() ?? '',
        );
        cartItems.add(CartItemModel(item: menuItem, quantity: (m['quantity'] ?? 1) as int));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load order: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void addToCart(MenuItemModel item) {
    final index = cartItems.indexWhere((c) => c.item.id == item.id);
    setState(() {
      if (index >= 0) {
        cartItems[index].quantity++;
      } else {
        cartItems.add(CartItemModel(item: item));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added'),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blueAccent,
        width: 200,
      ),
    );
  }

  void increment(CartItemModel item) {
    setState(() => item.quantity++);
  }

  void decrement(CartItemModel item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        cartItems.remove(item);
      }
    });
  }

  double get totalAmount => cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  List<Map<String, dynamic>> _cartItemsToFirestoreItems() {
    return cartItems.map((c) {
      return {
        'id': c.item.id,
        'name': c.item.name,
        'price': c.item.price,
        'quantity': c.quantity,
        'category': c.item.category ?? '',
      };
    }).toList();
  }

  Future<void> placeOrder() async {
    if (cartItems.isEmpty) return;

    setState(() => loading = true);
    try {
      final items = _cartItemsToFirestoreItems();
      if (editingOrderId == null) {
        await _orderService.createOrder(
          tableNumber: widget.tableNumber,
          items: items,
          totalAmount: totalAmount,
        );
      } else {
        await _orderService.editOrder(
          orderId: editingOrderId!,
          items: items,
          totalAmount: totalAmount,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save order: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'POS TERMINAL',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2),
            ),
            Text(
              'Table ${widget.tableNumber}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2D2D4D)),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blueAccent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 8, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF5F5F7), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: MenuTab(onAdd: addToCart),
              ),
            ),
          ),
          Container(
            width: 400,
            margin: const EdgeInsets.fromLTRB(8, 0, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF5F5F7), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CartTab(
                cartItems: cartItems,
                totalAmount: totalAmount,
                onIncrement: increment,
                onDecrement: decrement,
                onRemove: decrement,
                onPlaceOrder: placeOrder,
                tableNumber: widget.tableNumber,
                isEditing: editingOrderId != null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

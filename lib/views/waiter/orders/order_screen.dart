// lib/views/waiter/order/order_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/menu_item_model.dart';
import '../../../services/order_service.dart';
import 'menu_tab.dart';
import 'cart_tab.dart';

class OrderScreen extends StatefulWidget {
  final int tableNumber;
  final String? orderId; // null = create new

  const OrderScreen({super.key, required this.tableNumber, this.orderId});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<CartItemModel> cartItems = [];
  bool loading = false;
  String? editingOrderId;

  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    editingOrderId = widget.orderId;
    if (editingOrderId != null) {
      _loadExistingOrder();
    }
  }


  void incrementItem(CartItemModel cartItem) {
    setState(() {
      cartItem.quantity++;
    });
  }

  void decrementItem(CartItemModel cartItem) {
    setState(() {
      if (cartItem.quantity > 1) {
        cartItem.quantity--;
      } else {
        cartItems.remove(cartItem);
      }
    });
  }


  Future<void> _loadExistingOrder() async {
    setState(() => loading = true);
    try {
      final doc = await _orderService.getOrderDoc(editingOrderId!);
      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order not found')));
        Navigator.pop(context);
        return;
      }
      final data = doc.data() as Map<String, dynamic>;

      // check lock
      if (data['isEditable'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order is being processed and cannot be edited')));
        Navigator.pop(context);
        return;
      }

      cartItems.clear();
      final items = (data['items'] as List<dynamic>).cast<Map<String, dynamic>>();
      for (final it in items) {
        final menuItem = MenuItemModel(
          id: it['name'], // if item id exists in your DB, use it instead
          name: it['name'],
          price: (it['price'] is num) ? (it['price'] as num).toDouble() : double.tryParse(it['price'].toString()) ?? 0.0,
          category: '',
        );
        cartItems.add(CartItemModel(item: menuItem, quantity: (it['quantity'] ?? 1) as int));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load order: $e')));
      Navigator.pop(context);
    } finally {
      setState(() => loading = false);
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
    // _tabController.animateTo(1);
  }

  void removeFromCart(CartItemModel cartItem) {
    setState(() {
      cartItems.remove(cartItem);
    });
  }

  double get totalAmount => cartItems.fold(0.0, (s, c) => s + c.totalPrice);

  Future<void> _placeOrSaveOrder() async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    setState(() => loading = true);

    try {
      if (editingOrderId == null) {
        final createdId = await _orderService.createOrder(
          tableNumber: widget.tableNumber,
          cartItems: cartItems,
          totalAmount: totalAmount,
        );
        Navigator.pop(context);
      } else {
        await _orderService.editOrder(
          orderId: editingOrderId!,
          cartItems: cartItems,
          totalAmount: totalAmount,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save order: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Table ${widget.tableNumber}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Menu'),
            Tab(text: 'Cart'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MenuTab(onAdd: addToCart),
          CartTab(
            cartItems: cartItems,
            totalAmount: totalAmount,
            onRemove: removeFromCart,
            onIncrement: incrementItem,
            onDecrement: decrementItem,
            tableNumber: widget.tableNumber,
            onPlaceOrder: _placeOrSaveOrder,
            isEditing: editingOrderId != null,
          ),

        ],
      ),
    );
  }
}

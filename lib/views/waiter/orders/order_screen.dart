import 'package:flutter/material.dart';
import 'package:miral/models/cart_item_model.dart';
import 'menu_tab.dart';
import 'cart_tab.dart';


class OrderScreen extends StatefulWidget {
  final int tableNumber;

  const OrderScreen({super.key, required this.tableNumber});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>  with SingleTickerProviderStateMixin{

  late TabController _tabController;
  final List<CartItemModel> cartItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void addToCart(item){
    final index = cartItems.indexWhere(
        (c) => c.item.id == item.id
    );
    setState(() {
     if(index >= 0){
       cartItems[index].quantity++;
     }else{
       cartItems.add(CartItemModel(item: item));
     }
    });
  }

  void removeFromCart(CartItemModel cartItem){
    setState(() {
      cartItems.remove(cartItem);
    });
  }

  double get totalAmount =>
      cartItems.fold(0, (sum,item) => sum + item.totalPrice);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table ${widget.tableNumber}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Menu'),
            Tab(text: 'Cart'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MenuTab(onAdd:addToCart),
          CartTab(
            cartItems: cartItems,
            totalAmount: totalAmount,
            onRemove: removeFromCart,
          ),
        ],
      ),
    );
  }
}

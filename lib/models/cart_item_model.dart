import 'package:miral/models/menu_item_model.dart';

class CartItemModel{
  final MenuItemModel item;
  int quantity;

  CartItemModel({
    required this.item,
    this.quantity = 1,
  });
  double get totalPrice => item.price * quantity;
}
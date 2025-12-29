import 'package:flutter/material.dart';
import 'package:miral/models/menu_item_model.dart';

class MenuTab extends StatelessWidget {
  final Function(MenuItemModel) onAdd;

  const MenuTab({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final items = [
      MenuItemModel(
        id: '1',
        name: 'Pizza',
        price: 0.329,
        category: 'Main',
      ),
      MenuItemModel(
        id: '2',
        name: 'Burger',
        price: 0.329,
        category: 'Main',
      ),
      MenuItemModel(
        id: '3',
        name: 'Fries',
        price: 0.329,
        category: 'Side'
      ),
    ];
    return ListView.builder(
      itemCount: items.length,
      itemBuilder:(context, index){
        final item = items[index];

        return ListTile(
          title: Text(item.name),
          subtitle: Text('${item.price.toStringAsFixed(3)} BHD'),
          trailing: ElevatedButton(
            onPressed: () => onAdd(item),
            child: const Text('Add'),
          ),

        );
      }
    );
  }
}

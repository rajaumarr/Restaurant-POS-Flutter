import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../services/printing_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  final PrintingService _printingService = PrintingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').doc(widget.orderId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final items = (data['items'] as List<dynamic>).cast<Map<String, dynamic>>();
          final subtotal = (data['totalAmount'] as num).toDouble();
          final orderNumber = data['orderNumber'] ?? widget.orderId;
          final tableNumber = data['tableNumber'] ?? '-';
          final status = data['status'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text('Order: $orderNumber', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Table: $tableNumber'),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, i) {
                      final it = items[i];
                      return ListTile(
                        title: Text(it['name']),
                        subtitle: Text('${it['quantity']} × ${it['price'].toString()}'),
                        trailing: Text((it['price'] * it['quantity']).toStringAsFixed(3)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Print kitchen receipt
                        final pdf = await _printingService.buildCustomerReceiptPdf(
                          orderNumber: orderNumber,
                          tableNumber: tableNumber,
                          items: items,
                          subtotal: subtotal,
                          tax: 0.0, // calculate from settings if needed
                          discount: 0.0,
                          total: subtotal,
                          restaurantName: 'Miral',
                        );
                        try {
                          await _printingService.printPdfFromBytes(pdf);
                          await _orderService.logPrint(orderId: widget.orderId, type: 'kitchen', deviceId: 'counter_device_1', success: true);
                        } catch (e) {
                          await _orderService.logPrint(orderId: widget.orderId, type: 'kitchen', deviceId: 'counter_device_1', success: false, content: e.toString());
                        }
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('Print Kitchen'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Print customer receipt
                        final pdf = await _printingService.buildCustomerReceiptPdf(
                          orderNumber: orderNumber,
                          tableNumber: tableNumber,
                          items: items,
                          subtotal: subtotal,
                          tax: 0.0,
                          discount: 0.0,
                          total: subtotal,
                          restaurantName: 'Miral',
                        );
                        try {
                          await _printingService.printPdfFromBytes(pdf);
                          await _orderService.logPrint(orderId: widget.orderId, type: 'customer', deviceId: 'counter_device_1', success: true);
                        } catch (e) {
                          await _orderService.logPrint(orderId: widget.orderId, type: 'customer', deviceId: 'counter_device_1', success: false, content: e.toString());
                        }
                      },
                      icon: const Icon(Icons.receipt),
                      label: const Text('Print Customer'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await _orderService.updateOrderStatus(widget.orderId, 'processing');


                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Order locked for editing')),
                        );
                      },
                      child: const Text('Start Processing'),
                    ),

                    ElevatedButton(
                      onPressed: status == 'in_kitchen'
                          ? null
                          : () async {
                        await _orderService.updateOrderStatus(widget.orderId, 'in_kitchen');
                      },
                      child: const Text('Mark In Kitchen'),
                    ),
                    ElevatedButton(
                      onPressed: status == 'completed'
                          ? null
                          : () async {
                        await _orderService.updateOrderStatus(widget.orderId, 'completed');
                        Navigator.pop(context);
                      },
                      child: const Text('Complete Order'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: status == 'cancelled'
                          ? null
                          : () async {
                        await _orderService.updateOrderStatus(widget.orderId, 'cancelled');
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel Order'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

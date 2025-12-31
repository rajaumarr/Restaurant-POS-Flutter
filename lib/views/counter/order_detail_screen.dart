import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../services/printing_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final String? initialAction;

  const OrderDetailScreen({super.key, required this.orderId, this.initialAction});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  final PrintingService _printingService = PrintingService();
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAction != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleInitialAction();
      });
    }
  }

  Future<void> _handleInitialAction() async {
    final doc = await _orderService.getOrderDoc(widget.orderId);
    if (!doc.exists) return;
    
    if (widget.initialAction == 'print_kitchen') _printToKitchen(doc);
    if (widget.initialAction == 'print_customer') _printToCustomer(doc);
  }

  Future<void> _printToKitchen(DocumentSnapshot doc) async {
    setState(() => _isActionInProgress = true);
    try {
      final data = doc.data() as Map<String, dynamic>;
      final items = (data['items'] as List<dynamic>? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();

      final bytes = await _printingService.buildKitchenReceiptPdf(
        orderNumber: data['orderNumber']?.toString() ?? widget.orderId,
        tableNumber: (data['tableNumber'] is int) ? data['tableNumber'] : int.tryParse(data['tableNumber']?.toString() ?? '0') ?? 0,
        items: items,
        restaurantName: (data['restaurantName'] ?? 'Restaurant').toString(),
        notes: data['notes']?.toString(),
      );

      await _printingService.printPdfFromBytes(bytes);
      await _orderService.logPrint(orderId: widget.orderId, deviceId: 'counter_device', type: 'kitchen', success: true);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sent to kitchen (printed)')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Print failed: $e')));
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  Future<void> _printToCustomer(DocumentSnapshot doc) async {
    setState(() => _isActionInProgress = true);
    try {
      final data = doc.data() as Map<String, dynamic>;
      final items = (data['items'] as List<dynamic>? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();

      final subtotal = (data['subtotal'] is num) ? (data['subtotal'] as num).toDouble()
          : items.fold<double>(0, (s, it) => s + ((it['price'] as num? ?? 0) * (it['quantity'] as num? ?? 1))).toDouble();
      final tax = (data['tax'] is num) ? (data['tax'] as num).toDouble() : 0.0;
      final discount = (data['discount'] is num) ? (data['discount'] as num).toDouble() : 0.0;
      final total = (data['totalAmount'] is num) ? (data['totalAmount'] as num).toDouble() : (subtotal + tax - discount);

      final bytes = await _printingService.buildCustomerReceiptPdf(
        orderNumber: data['orderNumber']?.toString() ?? widget.orderId,
        tableNumber: (data['tableNumber'] is int) ? data['tableNumber'] : int.tryParse(data['tableNumber']?.toString() ?? '0') ?? 0,
        items: items,
        subtotal: subtotal,
        tax: tax,
        discount: discount,
        total: total,
        restaurantName: (data['restaurantName'] ?? 'Restaurant').toString(),
        footer: data['footer']?.toString(),
      );

      await _printingService.printPdfFromBytes(bytes);
      await _orderService.logPrint(orderId: widget.orderId, deviceId: 'counter_device', type: 'customer', success: true);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer receipt printed')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Print failed: $e')));
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  Future<void> _updateStatus(String action, Future<void> Function() serviceCall) async {
    setState(() => _isActionInProgress = true);
    try {
      await serviceCall();
      if (action == 'complete' || action == 'cancel') {
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action failed: $e')));
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _orderService.streamOrder(widget.orderId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(appBar: AppBar(), body: Center(child: Text('Error: ${snapshot.error}')));
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)));
        }

        final doc = snapshot.data;
        if (doc == null || !doc.exists) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Order not found')),
          );
        }

        final data = doc.data() as Map<String, dynamic>;
        final orderNumber = data['orderNumber'] ?? widget.orderId.substring(0, 6);
        final status = data['status']?.toString().toUpperCase() ?? 'UNKNOWN';

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'ORDER DETAILS #$orderNumber',
              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2D2D4D), fontSize: 18),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blueAccent, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow('Table Number', data['tableNumber']?.toString() ?? '-'),
                              const Divider(height: 30),
                              _buildDetailRow('Current Status', status, isStatus: true),
                              const Divider(height: 30),
                              _buildDetailRow('Total Amount', '${(data['totalAmount'] ?? 0).toStringAsFixed(3)} BHD', isPrice: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'ORDERED ITEMS',
                          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 12, letterSpacing: 1),
                        ),
                        const SizedBox(height: 16),
                        ...(data['items'] as List<dynamic>? ?? []).map((e) {
                          final m = Map<String, dynamic>.from(e as Map);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFF5F5F7)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: Text(m['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D4D))),
                              subtitle: Text('Price: ${m['price'] ?? ''} BHD', style: TextStyle(color: Colors.blueAccent.shade700, fontWeight: FontWeight.w500)),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(8)),
                                child: Text('x${m['quantity'] ?? 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                          childAspectRatio: 3.2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children: [
                            _buildActionButton('KITCHEN PRINT', Icons.restaurant_menu_rounded, () => _printToKitchen(doc), Colors.blueGrey.shade800),
                            _buildActionButton('CUSTOMER PRINT', Icons.receipt_long_rounded, () => _printToCustomer(doc), Colors.indigo.shade700),
                            _buildActionButton('START ORDER', Icons.play_arrow_rounded, () => _updateStatus('process', () => _orderService.startProcessing(widget.orderId)), Colors.orange.shade800),
                            _buildActionButton('IN KITCHEN', Icons.kitchen_rounded, () => _updateStatus('kitchen', () => _orderService.markInKitchen(widget.orderId)), Colors.blue.shade800),
                            _buildActionButton('COMPLETE', Icons.check_circle_rounded, () => _updateStatus('complete', () => _orderService.completeOrder(widget.orderId)), Colors.green.shade800),
                            _buildActionButton('CANCEL', Icons.cancel_rounded, () => _updateStatus('cancel', () => _orderService.cancelOrder(widget.orderId)), Colors.red.shade800),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_isActionInProgress)
                Container(
                  color: Colors.black.withOpacity(0.1),
                  child: const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false, bool isPrice = false}) {
    Color valColor = const Color(0xFF2D2D4D);
    if (isStatus) valColor = Colors.blueAccent;
    if (isPrice) valColor = Colors.blueAccent.shade700;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
        Text(value, style: TextStyle(color: valColor, fontWeight: FontWeight.w900, fontSize: isPrice ? 18 : 14)),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed, Color color) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isActionInProgress ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

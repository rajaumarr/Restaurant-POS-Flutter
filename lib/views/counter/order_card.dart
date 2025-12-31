import 'package:flutter/material.dart';
import 'order_detail_screen.dart';

class OrderCard extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    final orderNumber = orderData['orderNumber'] ?? orderId.substring(0, 6);
    final tableNumber = orderData['tableNumber'] ?? '-';
    final status = orderData['status'] ?? 'active';
    final total = (orderData['totalAmount'] ?? 0).toDouble();

    Color statusColor;
    Color cardBgColor;
    IconData statusIcon;
    String statusText;

    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green.shade700;
        cardBgColor = const Color(0xFFE8F5E9);
        statusIcon = Icons.pending_actions_rounded;
        statusText = 'NEW ORDER';
        break;
      case 'processing':
        statusColor = Colors.orange.shade800;
        cardBgColor = const Color(0xFFFFF3E0);
        statusIcon = Icons.hourglass_empty_rounded;
        statusText = 'PROCESSING';
        break;
      case 'in_kitchen':
        statusColor = Colors.blue.shade800;
        cardBgColor = const Color(0xFFE3F2FD);
        statusIcon = Icons.restaurant_rounded;
        statusText = 'IN KITCHEN';
        break;
      case 'completed':
        statusColor = Colors.grey.shade700;
        cardBgColor = Colors.white;
        statusIcon = Icons.check_circle_rounded;
        statusText = 'COMPLETED';
        break;
      case 'cancelled':
        statusColor = Colors.red.shade800;
        cardBgColor = Colors.white;
        statusIcon = Icons.cancel_rounded;
        statusText = 'CANCELLED';
        break;
      default:
        statusColor = Colors.grey;
        cardBgColor = Colors.white;
        statusIcon = Icons.help_outline_rounded;
        statusText = status.toUpperCase();
    }

    final bool isSpecialStatus = status.toLowerCase() != 'completed' && status.toLowerCase() != 'cancelled';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSpecialStatus ? statusColor.withOpacity(0.2) : const Color(0xFFF5F5F7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ORDER #$orderNumber',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2D2D4D),
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 12, color: statusColor),
                                const SizedBox(width: 4),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.table_bar_rounded, size: 18, color: statusColor),
                          const SizedBox(width: 6),
                          Text(
                            'TABLE $tableNumber',
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${total.toStringAsFixed(3)} BHD',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSpecialStatus ? statusColor : Colors.blueAccent,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

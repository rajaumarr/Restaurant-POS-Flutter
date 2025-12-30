// lib/views/counter/counter_orders_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/order_service.dart';
import 'order_card.dart';

class CounterOrdersScreen extends StatelessWidget {
  const CounterOrdersScreen({super.key});

  String? _extractFirebaseConsoleLink(String errorText) {
    final start = errorText.indexOf('https://console.firebase.google.com');
    if (start == -1) return null;

    final substr = errorText.substring(start);
    final endIndex = substr.indexOf(RegExp(r'\s'));
    if (endIndex == -1) return substr;
    return substr.substring(0, endIndex);
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();

    return StreamBuilder<QuerySnapshot>(
      stream: orderService.streamAllActiveOrders(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error;
          String message = 'An error occurred';
          String? indexLink;

          if (error is FirebaseException) {
            message = error.message ?? error.code;
            indexLink = _extractFirebaseConsoleLink(error.toString());
          } else {
            message = error.toString();
            indexLink = _extractFirebaseConsoleLink(message);
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Error loading orders:',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  if (indexLink != null)
                    Column(
                      children: [
                        const Text(
                          'This query requires a Firestore index. Tap the button to open the console and create it.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _openLink(indexLink!),
                          child: const Text('Open index creation link'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      (context as Element).reassemble();
                    },
                    child: const Text('Retry'),
                  )
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text('No active orders'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final d = docs[index];
            final data = d.data() as Map<String, dynamic>;
            return OrderCard(
              orderId: d.id,
              orderData: data,
            );
          },
        );
      },
    );
  }
}

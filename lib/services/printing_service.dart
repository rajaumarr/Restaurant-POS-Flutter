import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintingService {
  Future<Uint8List> buildCustomerReceiptPdf({
    required String orderNumber,
    required int tableNumber,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double total,
    required String restaurantName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(restaurantName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Order: $orderNumber'),
              pw.Text('Table: $tableNumber'),
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.Column(
                children: items.map((it) {
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('${it['quantity']} x ${it['name']}'),
                      pw.Text((it['price'] * it['quantity']).toStringAsFixed(3)),
                    ],
                  );
                }).toList(),
              ),
              pw.Divider(),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Subtotal'), pw.Text(subtotal.toStringAsFixed(3))]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Tax'), pw.Text(tax.toStringAsFixed(3))]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Discount'), pw.Text(discount.toStringAsFixed(3))]),
              pw.Divider(),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Total', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)), pw.Text(total.toStringAsFixed(3), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold))]),
              pw.SizedBox(height: 10),
              pw.Text('Thank you!', style: pw.TextStyle(fontSize: 12)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }


  Future<void> printPdfFromBytes(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (format) => bytes);
  }
}

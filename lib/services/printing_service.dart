import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintingService {
  static const double roll58mm = 164.41;

  Future<Uint8List> buildKitchenReceiptPdf({
    required String orderNumber,
    required int tableNumber,
    required List<Map<String, dynamic>> items,
    required String restaurantName,
    String? notes,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final df = DateFormat('yyyy-MM-dd HH:mm');

    pdf.addPage(pw.Page(
      pageFormat: const PdfPageFormat(roll58mm, double.infinity, marginAll: 5),
      build: (pw.Context ctx) {
        return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Center(child: pw.Text('MIRAL', 
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
          pw.Center(child: pw.Text('- KITCHEN COPY -', 
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 8),
          pw.Text('ORDER: $orderNumber', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          pw.Text('TABLE: $tableNumber', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.Text('TIME: ${df.format(now)}', style: const pw.TextStyle(fontSize: 8)),
          pw.SizedBox(height: 6),
          pw.Divider(thickness: 1, color: PdfColors.black),
          pw.SizedBox(height: 4),

          pw.Column(children: items.map((it) {
            final qty = (it['quantity'] ?? 1).toString();
            final name = (it['name'] ?? '').toString().toUpperCase();
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(width: 20, child: pw.Text('$qty x', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(child: pw.Text(name, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                ],
              ),
            );
          }).toList()),
          
          pw.Divider(thickness: 1, color: PdfColors.black),
          if (notes != null && notes.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text('NOTES:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.Text(notes, style: const pw.TextStyle(fontSize: 8)),
          ],
          pw.SizedBox(height: 15),
          pw.Center(child: pw.Text('--- END OF ORDER ---', style: const pw.TextStyle(fontSize: 7))),
        ]);
      }
    ));

    return pdf.save();
  }

  Future<Uint8List> buildCustomerReceiptPdf({
    required String orderNumber,
    required int tableNumber,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double total,
    required String restaurantName,
    String? footer,
  }) async {
    final pdf = pw.Document();
    final df = DateFormat('yyyy-MM-dd HH:mm');

    pdf.addPage(pw.Page(
      pageFormat: const PdfPageFormat(roll58mm, double.infinity, marginAll: 5),
      build: (pw.Context ctx) {
        return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
          pw.Center(child: pw.Text('MIRAL', 
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
          pw.Center(child: pw.Text('*** RECEIPT ***', style: const pw.TextStyle(fontSize: 8))),
          pw.SizedBox(height: 8),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text('ORDER: #$orderNumber', style: const pw.TextStyle(fontSize: 8)),
            pw.Text('TABLE: $tableNumber', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
          ]),
          pw.Text('DATE: ${df.format(DateTime.now())}', style: const pw.TextStyle(fontSize: 7)),
          pw.SizedBox(height: 4),
          pw.Divider(thickness: 0.5),
          
          pw.Row(children: [
            pw.Expanded(flex: 3, child: pw.Text('ITEM', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 1, child: pw.Text('QTY', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text('TOTAL', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold))),
          ]),
          pw.SizedBox(height: 2),
          
          pw.Column(children: items.map((it) {
            final qty = (it['quantity'] ?? 1);
            final name = (it['name'] ?? '').toString();
            final price = (it['price'] ?? 0);
            final lineTotal = (price is num ? (price * (qty as num)) : 0);
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 2),
              child: pw.Row(children: [
                pw.Expanded(flex: 3, child: pw.Text(name, style: const pw.TextStyle(fontSize: 7))),
                pw.Expanded(flex: 1, child: pw.Text(qty.toString(), textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 7))),
                pw.Expanded(flex: 2, child: pw.Text(lineTotal.toStringAsFixed(3), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 7))),
              ]),
            );
          }).toList()),
          
          pw.Divider(thickness: 0.5),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('SUBTOTAL', style: const pw.TextStyle(fontSize: 7)), pw.Text(subtotal.toStringAsFixed(3), style: const pw.TextStyle(fontSize: 7))]),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('TAX', style: const pw.TextStyle(fontSize: 7)), pw.Text(tax.toStringAsFixed(3), style: const pw.TextStyle(fontSize: 7))]),
          if (discount > 0)
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('DISCOUNT', style: const pw.TextStyle(fontSize: 7)), pw.Text('-${discount.toStringAsFixed(3)}', style: const pw.TextStyle(fontSize: 7))]),
          
          pw.SizedBox(height: 2),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(width: 0.5), bottom: pw.BorderSide(width: 0.5))),
            child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('TOTAL', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.Text('${total.toStringAsFixed(3)} BHD', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ]),
          ),
          
          pw.SizedBox(height: 10),
          if (footer != null) pw.Center(child: pw.Text(footer, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 7))),
          pw.Center(child: pw.Text('THANK YOU!', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
        ]);
      }
    ));

    return pdf.save();
  }

  Future<void> printPdfFromBytes(Uint8List bytes) async {
    await Printing.layoutPdf(
      onLayout: (format) => bytes,
      name: 'Receipt_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

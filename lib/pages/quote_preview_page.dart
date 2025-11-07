import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class QuotePreviewPage extends StatelessWidget {
  final String clientName;
  final String clientAddress;
  final String reference;
  final List<Map<String, dynamic>> items;
  final double total;
  final String? status;
  final bool isTaxInclusive;

  const QuotePreviewPage({
    required this.clientName,
    required this.clientAddress,
    required this.reference,
    required this.items,
    required this.total,
    required this.status,
    required this.isTaxInclusive,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: "en_IN", symbol: "₹");

    return Scaffold(
      appBar: AppBar(
        title: Text("Quote Preview"),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            tooltip: "Download PDF",
            onPressed: () {
              generatePdf(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Client: $clientName",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Address: $clientAddress"),
            Text("Reference: $reference"),
            Text("Status: ${status ?? 'Draft'}"),
            Text("Tax Mode: ${isTaxInclusive ? 'Inclusive' : 'Exclusive'}"),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, i) {
                  var item = items[i];
                  double rate = (item['rate'] ?? 0).toDouble();
                  double qty = (item['qty'] ?? 0).toDouble();
                  double discount = (item['discount'] ?? 0).toDouble();
                  double tax = (item['tax'] ?? 0).toDouble();

                  double totalItem = (rate - discount) * qty;
                  if (!isTaxInclusive) {
                    totalItem += totalItem * (tax / 100);
                  }

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(
                        item['name'].isEmpty ? "Unnamed Item" : item['name'],
                      ),
                      subtitle: Text(
                        "Qty: $qty | Rate: ${formatCurrency.format(rate)} | Tax: $tax%",
                      ),
                      trailing: Text(formatCurrency.format(totalItem)),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Grand Total: ${formatCurrency.format(total)}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.picture_as_pdf),
                label: Text("Download as PDF"),
                onPressed: () => generatePdf(context),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: OutlinedButton.icon(
                icon: Icon(Icons.send),
                label: Text("Simulate Send"),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Quote sent to client! (Simulated)"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    final formatCurrency = NumberFormat.currency(locale: "en_IN", symbol: "₹");

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Product Quote",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text("Client: $clientName"),
              pw.Text("Address: $clientAddress"),
              pw.Text("Reference: $reference"),
              pw.Text("Status: ${status ?? 'Draft'}"),
              pw.Text(
                "Tax Mode: ${isTaxInclusive ? 'Inclusive' : 'Exclusive'}",
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Product', 'Qty', 'Rate', 'Tax%', 'Total'],
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(color: PdfColors.deepPurple),
                data: items.map((item) {
                  double rate = (item['rate'] ?? 0).toDouble();
                  double qty = (item['qty'] ?? 0).toDouble();
                  double discount = (item['discount'] ?? 0).toDouble();
                  double tax = (item['tax'] ?? 0).toDouble();

                  double totalItem = (rate - discount) * qty;
                  if (!isTaxInclusive) {
                    totalItem += totalItem * (tax / 100);
                  }

                  return [
                    item['name'] ?? '',
                    qty.toString(),
                    formatCurrency.format(rate),
                    tax.toString(),
                    formatCurrency.format(totalItem),
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "Grand Total: ${formatCurrency.format(total)}",
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                "Generated on: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}",
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'quote_preview_page.dart';

class QuoteFormPage extends StatefulWidget {
  @override
  State<QuoteFormPage> createState() => _QuoteFormPageState();
}

class _QuoteFormPageState extends State<QuoteFormPage> {
  TextEditingController clientName = TextEditingController();
  TextEditingController clientAddress = TextEditingController();
  TextEditingController reference = TextEditingController();

  String quoteStatus = "Draft";
  bool isTaxInclusive = false;
  List<Map<String, dynamic>> items = [
    {"name": "", "qty": 1.0, "rate": 0.0, "discount": 0.0, "tax": 0.0},
  ];

  final formatCurrency = NumberFormat.currency(
    locale: "en_IN",
    symbol: "₹",
    decimalDigits: 2,
  );

  double calculateTotal() {
    double total = 0;
    for (var item in items) {
      double rate = (item['rate'] ?? 0).toDouble();
      double qty = (item['qty'] ?? 0).toDouble();
      double discount = (item['discount'] ?? 0).toDouble();
      double tax = (item['tax'] ?? 0).toDouble();

      double base = (rate - discount) * qty;
      if (!isTaxInclusive) base += base * (tax / 100);
      total += base;
    }
    return total;
  }

  Future<void> saveQuote() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double total = calculateTotal();

    Map<String, dynamic> newQuote = {
      "clientName": clientName.text,
      "clientAddress": clientAddress.text,
      "reference": reference.text,
      "items": items,
      "total": total,
      "status": quoteStatus,
      "taxInclusive": isTaxInclusive,
      "time": DateTime.now().toString(),
    };

    List<String> oldQuotes = prefs.getStringList("quotes") ?? [];
    oldQuotes.add(jsonEncode(newQuote));
    await prefs.setStringList("quotes", oldQuotes);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Quote saved successfully")));
  }

  @override
  Widget build(BuildContext context) {
    double total = calculateTotal();

    return Scaffold(
      appBar: AppBar(
        title: Text("Product Quote Builder"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveQuote,
            tooltip: "Save Quote",
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/saved'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section("Client Details"),
            _input("Client Name", clientName),
            _input("Client Address", clientAddress),
            _input("Reference / Notes", reference),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Quote Status:"),
                DropdownButton<String>(
                  value: quoteStatus,
                  items: ["Draft", "Sent", "Accepted"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => quoteStatus = v!),
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tax Mode:"),
                Row(
                  children: [
                    Text(isTaxInclusive ? "Inclusive" : "Exclusive"),
                    Switch(
                      value: isTaxInclusive,
                      onChanged: (v) => setState(() => isTaxInclusive = v),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            _section("Items"),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, i) {
                var item = items[i];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            labelText: "Product Name",
                          ),
                          onChanged: (v) => item['name'] = v,
                        ),
                        Row(
                          children: [
                            Expanded(child: _numField("Qty", item, "qty")),
                            SizedBox(width: 8),
                            Expanded(child: _numField("Rate", item, "rate")),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _numField("Discount", item, "discount"),
                            ),
                            SizedBox(width: 8),
                            Expanded(child: _numField("Tax %", item, "tax")),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            icon: Icon(Icons.delete, color: Colors.red),
                            label: Text("Remove"),
                            onPressed: () => setState(() => items.removeAt(i)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text("Add New Item"),
                onPressed: () => setState(() {
                  items.add({
                    "name": "",
                    "qty": 1.0,
                    "rate": 0.0,
                    "discount": 0.0,
                    "tax": 0.0,
                  });
                }),
              ),
            ),
            Divider(),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatCurrency.format(total),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.remove_red_eye),
                label: Text("Preview Quote"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuotePreviewPage(
                        clientName: clientName.text,
                        clientAddress: clientAddress.text,
                        reference: reference.text,
                        items: items,
                        total: total,
                        status: quoteStatus,
                        isTaxInclusive: isTaxInclusive,
                      ),
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

  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _numField(String label, Map item, String key) {
    return TextField(
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      onChanged: (v) => item[key] = double.tryParse(v) ?? 0,
      onEditingComplete: () => setState(() {}),
    );
  }

  Widget _section(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}

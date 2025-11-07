import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'quote_preview_page.dart';

class SavedQuotesPage extends StatefulWidget {
  const SavedQuotesPage({Key? key}) : super(key: key);

  @override
  State<SavedQuotesPage> createState() => _SavedQuotesPageState();
}

class _SavedQuotesPageState extends State<SavedQuotesPage> {
  List<Map<String, dynamic>> quotes = [];

  @override
  void initState() {
    super.initState();
    loadQuotes();
  }

  Future<void> loadQuotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> data = prefs.getStringList("quotes") ?? [];
    setState(() {
      quotes = data.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: "en_IN", symbol: "₹");

    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Quotes"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            tooltip: "Clear All",
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove("quotes");
              setState(() => quotes.clear());
            },
          ),
        ],
      ),
      body: quotes.isEmpty
          ? Center(child: Text("No saved quotes yet"))
          : ListView.builder(
              itemCount: quotes.length,
              itemBuilder: (context, i) {
                var q = quotes[i];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(q["clientName"] ?? "Unnamed Client"),
                    subtitle: Text(
                      "Total: ${formatCurrency.format(q["total"] ?? 0)}\n"
                      "Status: ${q["status"] ?? 'Draft'}\n"
                      "Tax Mode: ${(q["taxInclusive"] ?? false) ? 'Inclusive' : 'Exclusive'}\n"
                      "${q["time"]}",
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuotePreviewPage(
                            clientName: q["clientName"],
                            clientAddress: q["clientAddress"],
                            reference: q["reference"],
                            items: List<Map<String, dynamic>>.from(q["items"]),
                            total: (q["total"] ?? 0).toDouble(),
                            status: q["status"],
                            isTaxInclusive: q["taxInclusive"] ?? false,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

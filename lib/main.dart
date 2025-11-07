import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'pages/saved_quotes_page.dart';
import 'pages/quote_form_page.dart';

void main() {
  runApp(ProductQuoteApp());
}

class ProductQuoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Quote Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple.shade100,
          foregroundColor: Colors.deepPurple.shade900,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          elevation: 0,
        ),
      ),
      home: SplashPage(),
      routes: {
        '/form': (context) => QuoteFormPage(),
        '/saved': (context) => SavedQuotesPage(),
      },
    );
  }
}

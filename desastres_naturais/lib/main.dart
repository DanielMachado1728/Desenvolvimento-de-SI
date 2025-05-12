import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  runApp(const AjudaEnchentesApp());
}

class AjudaEnchentesApp extends StatelessWidget {
  const AjudaEnchentesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ajuda em Enchentes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

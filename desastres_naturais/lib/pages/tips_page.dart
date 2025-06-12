import 'package:flutter/material.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dicas de Segurança')),
      body: const Center(
        child: Text(
          'Tela: Dicas de Segurança',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CalmPage extends StatelessWidget {
  const CalmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preciso me Acalmar')),
      body: const Center(
        child: Text(
          'Tela: Preciso me Acalmar',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

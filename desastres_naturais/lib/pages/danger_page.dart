import 'package:flutter/material.dart';

class DangerPage extends StatelessWidget {
  const DangerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estou em Perigo')),
      body: const Center(
        child: Text(
          'Tela: Estou em Perigo',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

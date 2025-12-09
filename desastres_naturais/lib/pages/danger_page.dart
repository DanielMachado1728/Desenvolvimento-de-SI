import 'package:flutter/material.dart';

class DangerPage extends StatelessWidget {
  const DangerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estou em Perigo')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 100),
            const SizedBox(height: 20),
            const Text(
              'Se você está em perigo imediato:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              '• Ligue para os serviços de emergência imediatamente.\n'
              '• Vá para um local seguro e elevado, se possível.\n'
              '• Evite atravessar áreas alagadas.\n'
              '• Compartilhe sua localização com seus contatos de confiança.\n',
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.phone),
              label: const Text('Ligar para Emergência'),
              onPressed: () {
                // Aqui você pode implementar a ligação para 193
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


//22222
/*

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
*/
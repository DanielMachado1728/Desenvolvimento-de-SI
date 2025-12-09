import 'package:flutter/material.dart';

class CalmPage extends StatelessWidget {
  const CalmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preciso Me Acalmar')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.spa, color: Colors.blue, size: 100),
            const SizedBox(height: 20),
            const Text(
              'Técnica de respiração:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Inspire lentamente pelo nariz contando até 4...\n'
              'Segure a respiração por 4 segundos...\n'
              'Expire lentamente pela boca contando até 4...\n\n'
              'Repita esse ciclo algumas vezes.\n'
              'Você está seguro e não está sozinho.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_circle_fill),
              label: const Text('Iniciar respiração guiada'),
              onPressed: () {
                // Aqui você pode futuramente implementar um temporizador ou áudio
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


//222222222

/*
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
*/
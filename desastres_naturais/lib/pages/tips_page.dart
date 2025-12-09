import 'package:flutter/material.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dicas de Segurança')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.tips_and_updates, size: 100, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Como se manter seguro durante enchentes:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    title: Text('Evite áreas alagadas.'),
                    subtitle: Text('Mesmo com pouca água, há risco de correnteza e contaminação.'),
                  ),
                  ListTile(
                    leading: Icon(Icons.flash_on, color: Colors.red),
                    title: Text('Desligue aparelhos elétricos.'),
                    subtitle: Text('Evite choques e curtos-circuitos em áreas úmidas.'),
                  ),
                  ListTile(
                    leading: Icon(Icons.clean_hands, color: Colors.blue),
                    title: Text('Evite contato com a água.'),
                    subtitle: Text('Pode estar contaminada com esgoto ou produtos tóxicos.'),
                  ),
                  ListTile(
                    leading: Icon(Icons.backpack, color: Colors.brown),
                    title: Text('Tenha uma mochila de emergência.'),
                    subtitle: Text('Inclua lanterna, documentos, remédios, água e alimentos não perecíveis.'),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone_in_talk, color: Colors.purple),
                    title: Text('Mantenha contato com pessoas próximas.'),
                    subtitle: Text('Avise familiares e amigos sobre sua situação e localização.'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



//22222222
/*
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
*/
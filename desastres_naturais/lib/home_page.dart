import 'package:flutter/material.dart';
import 'pages/danger_page.dart';
import 'pages/calm_page.dart';
import 'pages/tips_page.dart';
import 'pages/contacts_page.dart'; 
import 'pages/map_page.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco
      appBar: AppBar(
        title: const Text(
          'Ark App',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [ 
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87, size: 28),
            tooltip: 'Meu Perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Como podemos te ajudar agora?',
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.w600,
                color: Colors.black87
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            // 1. Botão PERIGO (Crítico - Vermelho)
            _buildCustomButton(
              context,
              label: 'Estou em perigo',
              icon: Icons.warning_amber_rounded,
              bgColor: Colors.redAccent,
              textColor: Colors.white,
              page: const DangerPage(),
            ),
            
            const SizedBox(height: 16),
            
            // 2. Botão CALMA (Secundário - Cinza Claro)
            _buildCustomButton(
              context,
              label: 'Preciso me acalmar',
              icon: Icons.spa_outlined,
              bgColor: Colors.grey[100]!,
              textColor: Colors.black87,
              page: const CalmPage(),
            ),
            
            const SizedBox(height: 16),
            
            // 3. Botão DICAS (Secundário - Cinza Claro)
            _buildCustomButton(
              context,
              label: 'Dicas de segurança',
              icon: Icons.shield_outlined,
              bgColor: Colors.grey[100]!,
              textColor: Colors.black87,
              page: const SafetyTipsPage(),
            ),
            
            const SizedBox(height: 16),
            
            // 4. Botão CONTATOS (Secundário - Cinza Claro)
            _buildCustomButton(
              context,
              label: 'Contatos de confiança',
              icon: Icons.people_outline,
              bgColor: Colors.grey[100]!,
              textColor: Colors.black87,
              page: const ContactsPage(),
            ),
            
            const SizedBox(height: 16),
            
            // 5. Botão MAPA (Principal - Azul Royal, no final como você pediu)
            _buildCustomButton(
              context,
              label: 'Ver mapa',
              icon: Icons.map_outlined,
              bgColor: Colors.blueAccent,
              textColor: Colors.white,
              page: const MapPage(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para padronizar os botões com cores dinâmicas
  Widget _buildCustomButton(BuildContext context, {
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor, // Recebe a cor do texto/ícone
    required Widget page,
  }) {
    return SizedBox(
      height: 60, // Altura fixa para todos ficarem iguais
      child: ElevatedButton.icon(
        icon: Icon(icon, color: textColor, size: 28), // Ícone acompanha a cor do texto
        label: Text(
          label,
          style: TextStyle(
            color: textColor, // Texto acompanha a cor dinâmica
            fontSize: 18,        
            fontWeight: FontWeight.bold, 
            letterSpacing: 1.1,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          // Tira a sombra se o botão for clarinho para ficar mais limpo
          elevation: bgColor == Colors.grey[100] ? 0 : 4, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), 
            // Adiciona uma borda sutil apenas nos botões cinzas
            side: bgColor == Colors.grey[100] 
                ? BorderSide(color: Colors.grey[300]!, width: 1.5) 
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft, 
        ),
      ),
    );
  }
}









/*
import 'package:flutter/material.dart';
import 'pages/danger_page.dart';
import 'pages/calm_page.dart';
import 'pages/tips_page.dart';
import 'pages/contacts_page.dart'; 
import 'pages/map_page.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco
      appBar: AppBar(
        title: const Text(
          'Ark App',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [ 
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87, size: 28), // mudança no ícone
            tooltip: 'Meu Perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Como podemos te ajudar agora?',
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.w600,
                color: Colors.black87
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            
            //AQUI !!!!!!!!!!!!!!!!!
            //AQUI11!11111!!!!!!!!!


            _buildCustomButton(
              context,
              label: 'Estou em perigo',
              icon: Icons.warning_amber_rounded,
              color: Colors.redAccent, 
              page: const DangerPage(),
            ),
            
            const SizedBox(height: 16),
            
            // Botão CALMA 
            _buildCustomButton(
              context,
              label: 'Preciso me acalmar',
              icon: Icons.spa_outlined,
              color: Colors.blueAccent,
              page: const CalmPage(),
            ),
            
            const SizedBox(height: 16),
            
            // Botão DICAS
            _buildCustomButton(
              context,
              label: 'Dicas de segurança',
              icon: Icons.shield_outlined,
              color: Colors.green,
              page: const SafetyTipsPage(), // Ajustado para o nome correto da classe
            ),
            
            const SizedBox(height: 16),
            
            // Botão CONTATOS
            _buildCustomButton(
              context,
              label: 'Contatos de confiança',
              icon: Icons.people_outline,
              color: Colors.orange,
              page: const ContactsPage(),
            ),


            
            const SizedBox(height: 16),
            
            // Botão MAPA (Roxo)
            _buildCustomButton(
              context,
              label: 'Ver mapa',
              icon: Icons.map_outlined,
              color: Colors.purple,
              page: const MapPage(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para padronizar os botões
  Widget _buildCustomButton(BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required Widget page,
  }) {
    return SizedBox(
      height: 60, // Altura fixa para todos ficarem iguais
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white, size: 28), // Ícone Branco Grande
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white, // Texto Branco
            fontSize: 18,        // Tamanho legível
            fontWeight: FontWeight.bold, // Negrito para leitura rápida
            letterSpacing: 1.1,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 4, // Sombra para destacar
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Cantos arredondados modernos
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft, // Alinha ícone e texto à esquerda (opcional, ou center)
        ),
      ),
    );
  }
}
*/






























/*
import 'package:flutter/material.dart';
import 'pages/danger_page.dart';
import 'pages/calm_page.dart';
import 'pages/tips_page.dart';
import 'pages/contacts_page.dart'; 
import 'pages/map_page.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ark App'),
        actions: [ 
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configurações',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Como podemos te ajudar agora?',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.warning),
              label: const Text('Estou em perigo'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DangerPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.spa),
              label: const Text('Preciso me acalmar'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalmPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.info),
              label: const Text('Dicas de segurança'),
              onPressed: () {
                Navigator.push(
                  context,
                  //MaterialPageRoute(builder: (context) => const TipsPage()),
                  MaterialPageRoute(builder: (context) => const SafetyTipsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.contacts),
              label: const Text('Contatos de confiança'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('Ver mapa'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
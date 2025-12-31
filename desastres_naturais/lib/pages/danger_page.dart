import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DangerPage extends StatefulWidget {
  const DangerPage({super.key});

  @override
  State<DangerPage> createState() => _DangerPageState();
}

class _DangerPageState extends State<DangerPage> {
  bool _isSendingAlert = false; // Controla o loading do botão
  bool _alertActive = false;    // Controla se o estado de alerta está ligado
  bool _isLoadingState = true;  // NOVO: Para não mostrar o botão errado enquanto carrega

  @override
  void initState() {
    super.initState();
    // Assim que a tela nasce, verifica-se se o perigo já está ativo no banco
    _verificarSeJaEstouEmPerigo();
  }

  // RECUPERAR ESTADO 
  Future<void> _verificarSeJaEstouEmPerigo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        // Se no banco diz que está em perigo, atualizamos a tela local
        if (data != null && data['em_perigo'] == true) {
          setState(() {
            _alertActive = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao verificar estado inicial: $e");
    } finally {
      // Tira o loading inicial
      if (mounted) {
        setState(() {
          _isLoadingState = false;
        });
      }
    }
  }

  // Função para ATIVAR o perigo (Escreve no Firebase)
  Future<void> _ativarModoPerigo() async {
    setState(() => _isSendingAlert = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada pelo usuário.');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
         throw Exception('Permissão de localização negada permanentemente.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não autenticado.');

      await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
        'em_perigo': true,
        'inicio_perigo': FieldValue.serverTimestamp(),
        'latitude': position.latitude,
        'longitude': position.longitude,
      });

      setState(() {
        _alertActive = true;
        _isSendingAlert = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ALERTA ENVIADO! Seu pino VIOLETA está visível no mapa.'),
          backgroundColor: Colors.deepPurple,
          duration: Duration(seconds: 5),
        ),
      );

    } catch (e) {
      setState(() => _isSendingAlert = false);
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $errorMsg'), backgroundColor: Colors.red),
      );
    }
  }

  // Função para DESATIVAR (Estou salvo)
  Future<void> _desativarModoPerigo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
      'em_perigo': false,
    });

    setState(() => _alertActive = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alerta cancelado. Você está seguro.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    // Se estiver verificando o banco ainda, mostra um loading simples
    if (_isLoadingState) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _alertActive ? Colors.deepPurple[50] : Colors.white,
      appBar: AppBar(
        title: const Text('Emergência'),
        backgroundColor: _alertActive ? Colors.deepPurple[100] : Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- ESTADO 1: ALERTA LIGADO ---
              if (_alertActive) ...[
                const Icon(Icons.campaign_rounded, size: 120, color: Colors.deepPurple),
                const SizedBox(height: 30),
                const Text(
                  'PEDIDO DE SOCORRO ATIVO!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.deepPurple
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sua localização atual está sendo compartilhada com a comunidade no mapa.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 60),
                
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _desativarModoPerigo,
                    icon: const Icon(Icons.check_circle_outline, size: 28),
                    label: const Text('ESTOU SEGURO (DESLIGAR)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ] 
              
              // --- ESTADO 2: NORMAL (Botão de Pânico) ---
              else ...[
                const Icon(Icons.touch_app_outlined, size: 80, color: Colors.grey),
                const SizedBox(height: 20),
                const Text(
                  'Toque no botão abaixo apenas em caso de emergência real.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                 Text(
                  'Um pino VIOLETA aparecerá no mapa indicando sua posição para outros usuários.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 50),
                
                _isSendingAlert
                    ? const CircularProgressIndicator(color: Colors.red)
                    : GestureDetector(
                        onTapDown: (_) => setState(() {}),
                        onTapUp: (_) => setState(() {}),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              )
                            ],
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.redAccent, Colors.red],
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: _ativarModoPerigo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: const CircleBorder(),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sos_rounded, size: 70, color: Colors.white),
                                Text(
                                  'SOCORRO', 
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 22, 
                                    color: Colors.white,
                                    letterSpacing: 2.0
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}



















//tela funcionando!!!!!
/*
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DangerPage extends StatefulWidget {
  const DangerPage({super.key});

  @override
  State<DangerPage> createState() => _DangerPageState();
}

class _DangerPageState extends State<DangerPage> {
  bool _isSendingAlert = false; // Controla o loading do botão
  bool _alertActive = false;    // Controla se o estado de alerta está ligado

  // Função para ATIVAR o perigo (Escreve no Firebase)
  Future<void> _ativarModoPerigo() async {
    setState(() => _isSendingAlert = true);

    try {
      // 1. Checa e pede permissões de GPS
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada pelo usuário.');
        }
      }
      
      // Se negado para sempre, não tem o que fazer
      if (permission == LocationPermission.deniedForever) {
         throw Exception('Permissão de localização negada permanentemente. Habilite nas configurações.');
      }

      // 2. Pega a posição exata atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não autenticado.');

      // 3. Grava no Firebase: ESTOU EM PERIGO!
      // Esses campos SÃO EXATAMENTE os que a MapPage está esperando ler.
      await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
        'em_perigo': true,
        'inicio_perigo': FieldValue.serverTimestamp(), // Hora do servidor para sincronia
        'latitude': position.latitude,
        'longitude': position.longitude,
      });

      // Atualiza a UI
      setState(() {
        _alertActive = true;
        _isSendingAlert = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ALERTA ENVIADO! Seu pino VIOLETA está visível no mapa para todos.'),
          backgroundColor: Colors.deepPurple, // Combinando com a cor do pino
          duration: Duration(seconds: 5),
        ),
      );

    } catch (e) {
      setState(() => _isSendingAlert = false);
      // Mostra o erro de forma mais limpa
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $errorMsg'), backgroundColor: Colors.red),
      );
    }
  }

  // Função para DESATIVAR (Estou salvo)
  Future<void> _desativarModoPerigo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Desliga a flag no banco. A MapPage vai ler isso e remover o pino automaticamente.
    await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
      'em_perigo': false,
    });

    setState(() => _alertActive = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alerta cancelado. Você está seguro.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Muda a cor de fundo para roxo claro quando ativo, para dar feedback visual forte
    return Scaffold(
      backgroundColor: _alertActive ? Colors.deepPurple[50] : Colors.white,
      appBar: AppBar(
        title: const Text('Emergência'),
        backgroundColor: _alertActive ? Colors.deepPurple[100] : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- ESTADO 1: ALERTA LIGADO ---
              if (_alertActive) ...[
                const Icon(Icons.campaign_rounded, size: 120, color: Colors.deepPurple),
                const SizedBox(height: 30),
                const Text(
                  'PEDIDO DE SOCORRO ATIVO!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.deepPurple
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sua localização atual está sendo compartilhada com a comunidade no mapa.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 60),
                
                // Botão Gigante de "Estou Seguro"
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _desativarModoPerigo,
                    icon: const Icon(Icons.check_circle_outline, size: 28),
                    label: const Text('ESTOU SEGURO (DESLIGAR)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ] 
              
              // --- ESTADO 2: NORMAL (Botão de Pânico) ---
              else ...[
                const Icon(Icons.touch_app_outlined, size: 80, color: Colors.grey),
                const SizedBox(height: 20),
                const Text(
                  'Toque no botão abaixo apenas em caso de emergência real.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                 Text(
                  'Um pino VIOLETA aparecerá no mapa indicando sua posição para outros usuários.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 50),
                
                _isSendingAlert
                    ? const CircularProgressIndicator(color: Colors.red)
                    : GestureDetector(
                        // Efeito de "pressionar" no botão gigante
                        onTapDown: (_) => setState(() {}),
                        onTapUp: (_) => setState(() {}),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              )
                            ],
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.redAccent, Colors.red],
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: _ativarModoPerigo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: const CircleBorder(),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sos_rounded, size: 70, color: Colors.white),
                                Text(
                                  'SOCORRO', 
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 22, 
                                    color: Colors.white,
                                    letterSpacing: 2.0
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
*/








/*
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
*/

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
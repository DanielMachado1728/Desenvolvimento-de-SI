import 'package:flutter/material.dart';
import 'dart:math' as math;

class CalmPage extends StatefulWidget {
  const CalmPage({super.key});

  @override
  State<CalmPage> createState() => _CalmPageState();
}

class _CalmPageState extends State<CalmPage> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  Offset _pointerPosition = Offset.zero;
  bool _isTouching = false;

  @override
  void initState() {
    super.initState();
    
    // Configura o ritmo da respiração (4 segundos para inspirar/expirar)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 150.0, end: 220.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F), // Azul Marinho Profundo
      body: Stack(
        children: [
          // Botão Voltar
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.blueGrey, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Elementos Centrais
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Círculo de Respiração Pulsante
                AnimatedBuilder(
                  animation: _breathingAnimation,
                  builder: (context, child) {
                    return Container(
                      width: _breathingAnimation.value,
                      height: _breathingAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.withOpacity(0.2),
                            blurRadius: 40,
                            spreadRadius: 10,
                          )
                        ],
                        gradient: RadialGradient(
                          colors: [
                            Colors.cyan.withOpacity(0.4),
                            Colors.cyan.withOpacity(0.1),
                          ],
                        ),
                      ),
                      // --- AQUI ESTÁ O TEXTO ADICIONADO ---
                      child: Center(
                        child: Text(
                          // Verifica se está crescendo (forward) ou diminuindo (reverse)
                          _breathingController.status == AnimationStatus.forward
                              ? "Inspire"
                              : "Expire",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85), // Branco suave
                            fontSize: 22,
                            fontWeight: FontWeight.w300, // Fonte fina e elegante
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      // ------------------------------------
                    );
                  },
                ),
                
                const SizedBox(height: 80), // Espaçamento proporcional

                // 2. Tracejado da Calma (Infinito)
                SizedBox(
                  width: 300,
                  height: 150,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _pointerPosition = details.localPosition;
                        _isTouching = true;
                      });
                    },
                    onPanEnd: (_) => setState(() => _isTouching = false),
                    child: CustomPaint(
                      painter: InfinitePainter(_pointerPosition, _isTouching),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Pintor customizado para o caminho do Infinito
class InfinitePainter extends CustomPainter {
  final Offset pointer;
  final bool isTouching;
  InfinitePainter(this.pointer, this.isTouching);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final Path path = Path();
    
    double w = size.width;
    double h = size.height;
    
    // Desenha o símbolo do infinito
    for (double i = 0; i <= 1; i += 0.01) {
      double t = i * 2 * 3.14159;
      // Corrigi apenas o 'Math' para 'math' (minúsculo) para funcionar com o import
      double x = (w / 2.2) * ((1 * (w/w)) * ((1 * 1.4) * ((1 * (w/w)) * ((1 * 1.4) * 0.5 * ((1 * (w/w)) * ((1 * 1.4) * ((1 * (w/w)) * ((1 * 1.4) * 0.5 * ((1 * (w/w)) * ((1 * 1.4) * ((1 * (w/w)) * ((1 * 1.4) * 0.5 * ((1 * (w/w)) * ((1 * 1.4) * ((1 * (w/w)) * ((1 * 1.4) * (math.cos(t) / (1 + math.pow(math.sin(t), 2)))))))))))))))))));
      // A matemática original foi mantida conforme solicitado
    }

    // Curva simplificada para o desenho visual
    path.moveTo(w * 0.5, h * 0.5);
    path.cubicTo(w * 0.8, h * 0.1, w * 1.0, h * 0.9, w * 0.5, h * 0.5);
    path.cubicTo(w * 0.2, h * 0.1, w * 0.0, h * 0.9, w * 0.5, h * 0.5);

    canvas.drawPath(path, paint);

    // Se o usuário estiver tocando, desenha um "rastro" de luz
    if (isTouching) {
      final Paint pointerPaint = Paint()
        ..color = Colors.cyanAccent
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(pointer, 10, pointerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}





/*
import 'package:flutter/material.dart';
import 'dart:math' as math;

class CalmPage extends StatefulWidget {
  const CalmPage({super.key});

  @override
  State<CalmPage> createState() => _CalmPageState();
}

class _CalmPageState extends State<CalmPage> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  Offset _pointerPosition = Offset.zero;
  bool _isTouching = false;

  @override
  void initState() {
    super.initState();
    
    // Configura o ritmo da respiração (4 segundos para inspirar/expirar)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 150.0, end: 220.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F), // Azul Marinho Profundo
      body: Stack(
        children: [
          // Botão Voltar
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.blueGrey, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Elementos Centrais
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Círculo de Respiração Pulsante
                AnimatedBuilder(
                  animation: _breathingAnimation,
                  builder: (context, child) {
                    return Container(
                      width: _breathingAnimation.value,
                      height: _breathingAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.withOpacity(0.2),
                            blurRadius: 40,
                            spreadRadius: 10,
                          )
                        ],
                        gradient: RadialGradient(
                          colors: [
                            Colors.cyan.withOpacity(0.4),
                            Colors.cyan.withOpacity(0.1),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 80), // Espaçamento proporcional

                // 2. Tracejado da Calma (Infinito)
                SizedBox(
                  width: 300,
                  height: 150,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _pointerPosition = details.localPosition;
                        _isTouching = true;
                      });
                    },
                    onPanEnd: (_) => setState(() => _isTouching = false),
                    child: CustomPaint(
                      painter: InfinitePainter(_pointerPosition, _isTouching),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Pintor customizado para o caminho do Infinito
class InfinitePainter extends CustomPainter {
  final Offset pointer;
  final bool isTouching;
  InfinitePainter(this.pointer, this.isTouching);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final Path path = Path();
    
    // Desenha o símbolo do infinito matematicamente
    double w = size.width;
    double h = size.height;
    
    for (double i = 0; i <= 1; i += 0.01) {
      double t = i * 2 * 3.14159;
      double x = (w / 2.2) * ( (1 * (w/w)) * ( (1 * 1.4) * ( (1 * (w/w)) * ( (1 * 1.4) * 0.5 * ( (1 * (w/w)) * ( (1 * 1.4) * ( (1 * (w/w)) * ( (1 * 1.4) * 0.5 * ( (1 * (w/w)) * ( (1 * 1.4) * ( (1 * (w/w)) * ( (1 * 1.4) * 0.5 * ( (1 * (w/w)) * ( (1 * 1.4) * ( (1 * (w/w)) * ( (1 * 1.4) * (math.cos(t) / (1 + math.pow(math.sin(t), 2)))))))))))))))))));
      // Simplificando a curva de Lemniscata para o Flutter:
    }

    // Curva simplificada para o desenho
    path.moveTo(w * 0.5, h * 0.5);
    path.cubicTo(w * 0.8, h * 0.1, w * 1.0, h * 0.9, w * 0.5, h * 0.5);
    path.cubicTo(w * 0.2, h * 0.1, w * 0.0, h * 0.9, w * 0.5, h * 0.5);

    canvas.drawPath(path, paint);

    // Se o usuário estiver tocando, desenha um "rastro" de luz
    if (isTouching) {
      final Paint pointerPaint = Paint()
        ..color = Colors.cyanAccent
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(pointer, 10, pointerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
*/















/*
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
*/








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
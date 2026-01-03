import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true; 

  // Caminho da imagem
  final String _logoPath = 'assets/images/logo2.png'; 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Função ajustada para tela cheia
  void _mostrarLogoExpandida() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent, // Fundo transparente
        insetPadding: EdgeInsets.zero, // Remove margens
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: GestureDetector(
            onTap: () => Navigator.pop(context), // Fecha ao tocar
            child: InteractiveViewer(
              panEnabled: true, 
              minScale: 0.5,
              maxScale: 4.0,
              child: Hero(
                tag: 'logo_ark',
                child: Image.asset(
                  _logoPath, 
                  fit: BoxFit.contain, // Na tela cheia, mantém a proporção sem cortar
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    FocusScope.of(context).unfocus(); 
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha e-mail e senha'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
    } on FirebaseAuthException catch (e) {
      String msg = 'Erro ao fazer login.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        msg = 'E-mail ou senha incorretos.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToRegister() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              // ÁREA da logo com gestos
              Center(
                child: GestureDetector(
                  onTap: _mostrarLogoExpandida,
                  child: Hero(
                    tag: 'logo_ark',
                    child: Container(
                      // Antes 120 mas agora 160
                      height: 160, 
                      // Se quiser que seja um círculo perfeito, descomentar a linha abaixo e ajustar o width
                      // width: 160, 
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1), // Sombra um pouco mais forte
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          _logoPath,
                          // Usa 'cover' para preencher todo o quadrado/retângulo
                          // Se cortar partes importantes da logo, mude para 'BoxFit.fitHeight'
                          fit: BoxFit.cover, 
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.shield_moon, size: 100, color: Colors.blueAccent);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              
              const SizedBox(height: 30),
              const Text(
                'Faça login e entre na Arca',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'Acesse sua conta para continuar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              _buildTextField(controller: _emailController, label: 'E-mail', icon: Icons.email_outlined),
              _buildTextField(controller: _passwordController, label: 'Senha', icon: Icons.lock_outline, isPassword: true),

              const SizedBox(height: 20),

              SizedBox(
                height: 55,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('ENTRAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Não tem uma conta? ', style: TextStyle(color: Colors.grey[700])),
                  GestureDetector(
                    onTap: _goToRegister,
                    child: const Text('Cadastre-se', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          suffixIcon: isPassword ? IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ) : null,
        ),
      ),
    );
  }
}





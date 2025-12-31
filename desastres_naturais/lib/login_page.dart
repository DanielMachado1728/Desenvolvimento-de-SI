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
  
  // Variáveis de Estado
  bool _isLoading = false;
  bool _obscurePassword = true; // Controla se a senha está oculta

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    FocusScope.of(context).unfocus(); // Oculta o teclado

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha e-mail e senha'),
          backgroundColor: Colors.orangeAccent, // Aviso em laranja
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      // Se sucesso, vai para a HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Erro ao fazer login.';
      // Traduzindo mensagens comuns do Firebase
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        msg = 'E-mail ou senha incorretos.';
      } else if (e.code == 'invalid-email') {
        msg = 'Formato de e-mail inválido.';
      } else if (e.code == 'too-many-requests') {
        msg = 'Muitas tentativas. Tente novamente mais tarde.';
      }

      // Mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            msg,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent, // Fundo vermelho para erro
          behavior: SnackBarBehavior.floating, // Flutua sobre a tela
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  // Widget auxiliar para os campos de texto (reutilizável)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.grey[100], // Fundo cinza claro
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          // Botão de visibilidade da senha
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo Clean
      body: Center(
        child: SingleChildScrollView( // Evita overflow com teclado
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //  COLOCAR LOGO AQUI!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
              // Quando configurar os assets, descomentAR a linha abaixo:
              // Image.asset('assets/images/logo.jpg', height: 120),
              
              // ícone grande como placeholder
              const Icon(Icons.shield_moon, size: 80, color: Colors.blueAccent),
              
              const SizedBox(height: 20),
              const Text(
                'Faça login e entre na Arca',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Acesse sua conta para continuar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // Campos de Texto
              _buildTextField(
                controller: _emailController,
                label: 'E-mail',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                controller: _passwordController,
                label: 'Senha',
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              const SizedBox(height: 10),

              // Botão Esqueci Minha Senha (Opcional, mas útil)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Futura implementação de reset de senha
                  },
                  child: const Text(
                    'Esqueceu a senha?',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Botão de Login
              SizedBox(
                height: 55,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'ENTRAR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 24),

              // Link para Cadastro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Não tem uma conta? ',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  GestureDetector(
                    onTap: _goToRegister,
                    child: const Text(
                      'Cadastre-se',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
















/*
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

  void _login() async {
    FocusScope.of(context).unfocus(); // Oculta o teclado

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha e-mail e senha')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Se sucesso, vai para a HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Erro ao fazer login.';
      if (e.code == 'user-not-found') {
        msg = 'Usuário não encontrado.';
      } else if (e.code == 'wrong-password') {
        msg = 'Senha incorreta.';
      } else if (e.code == 'invalid-email') {
        msg = 'E-mail inválido.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Entrar'),
                  ),
            TextButton(
              onPressed: _goToRegister,
              child: const Text('Não tem conta? Cadastre-se'),
            )
          ],
        ),
      ),
    );
  }
}
*/

